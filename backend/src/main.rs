use axum::Router;
use tower_http::cors::{Any, CorsLayer};
use tower_http::services::{ServeDir, ServeFile};
use tracing::info;
use std::sync::Arc;

mod config;
mod error;
mod handlers;
mod models;
mod request;
mod routes;
mod services;

use services::traits::*;
use config::Config;

#[derive(Clone)]
pub struct AppState {
    pub config: Arc<Config>,
    pub project_service: Arc<dyn ProjectService>,
    pub blog_service: Arc<dyn BlogService>,
    pub activity_service: Arc<dyn ActivityService>,
    pub commit_service: Arc<dyn CommitService>,
    pub stats_service: Arc<dyn StatsService>,
}

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    // 加载环境变量
    dotenvy::dotenv().ok();

    // 加载应用配置
    let config = Arc::new(Config::from_env().map_err(|e| {
        eprintln!("配置加载失败: {}", e);
        std::process::exit(1);
    }).unwrap());

    // 初始化日志
    init_logging(&config.log)?;

    // 打印配置摘要
    config.print_summary();

    // 初始化 Service 实例
    let project_service: Arc<dyn ProjectService> = Arc::new(services::project_markdown::MarkdownProjectService::new());
    let blog_service: Arc<dyn BlogService> = Arc::new(services::blog_markdown::MarkdownBlogService::new());
    let activity_service: Arc<dyn ActivityService> = Arc::new(services::activity::ActivityService::new());
    let commit_service: Arc<dyn CommitService> = Arc::new(services::commit::CommitService::new());
    let stats_service: Arc<dyn StatsService> = Arc::new(services::stats::StatsService::new());

    let app_state = AppState {
        config: config.clone(),
        project_service,
        blog_service,
        activity_service,
        commit_service,
        stats_service,
    };

    // 构建 API 路由(使用独立的路由模块)
    let api_routes = routes::create_api_routes(app_state.clone());

    // 静态文件服务 - 为 SPA 应用提供 fallback
    let static_files_service = ServeDir::new(&config.server.static_dir)
        .not_found_service(ServeFile::new(format!("{}/index.html", config.server.static_dir)));

    // 构建 CORS 层
    let cors_layer = build_cors_layer(&config.security.cors_origins);

    // 构建完整应用路由
    let app = Router::new()
        // API 路由
        .nest("/api", api_routes)
        // 静态文件服务（处理所有非 API 路径）
        .fallback_service(static_files_service)
        .layer(cors_layer);

    // 启动服务器
    let server_address = config.server_address();
    let listener = tokio::net::TcpListener::bind(&server_address).await?;
    info!("服务器启动在 http://{}", server_address);

    axum::serve(listener, app).await?;

    Ok(())
}

/// 初始化日志系统
fn init_logging(log_config: &config::LogConfig) -> Result<(), anyhow::Error> {
    // 简化的日志初始化
    match log_config.format.as_str() {
        "json" => {
            // 对于 JSON 格式，使用基础初始化
            tracing_subscriber::fmt()
                .with_target(true)
                .init();
        }
        _ => {
            // 默认使用 pretty 格式
            tracing_subscriber::fmt()
                .with_target(true)
                .pretty()
                .init();
        }
    }

    info!("日志系统初始化完成，级别: {}", log_config.level);
    Ok(())
}

/// 构建 CORS 层
fn build_cors_layer(origins: &[String]) -> CorsLayer {
    let mut cors = CorsLayer::new()
        .allow_methods(Any)
        .allow_headers(Any);

    if origins.len() == 1 && origins[0] == "*" {
        cors = cors.allow_origin(Any);
    } else {
        for origin in origins {
            if let Ok(origin_header) = origin.parse::<axum::http::HeaderValue>() {
                cors = cors.allow_origin(origin_header);
            }
        }
    }

    cors
}
