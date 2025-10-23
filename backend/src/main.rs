use axum::Router;
use tower_http::cors::{Any, CorsLayer};
use tower_http::services::{ServeDir, ServeFile};
use tracing::info;
use std::sync::Arc;

mod error;
mod handlers;
mod models;
mod request;
mod routes;
mod services;

use services::traits::*;

#[derive(Clone)]
pub struct AppState {
    pub github_token: String,
    pub project_service: Arc<dyn ProjectService>,
    pub blog_service: Arc<dyn BlogService>,
    pub activity_service: Arc<dyn ActivityService>,
    pub commit_service: Arc<dyn CommitService>,
    pub stats_service: Arc<dyn StatsService>,
}

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    // 初始化日志
    tracing_subscriber::fmt::init();

    // 加载环境变量
    dotenvy::dotenv().ok();

    let github_token = std::env::var("GITHUB_TOKEN").unwrap_or_default();

    // 初始化 Service 实例
    let project_service: Arc<dyn ProjectService> = Arc::new(services::project_markdown::MarkdownProjectService::new());
    let blog_service: Arc<dyn BlogService> = Arc::new(services::blog_markdown::MarkdownBlogService::new());
    let activity_service: Arc<dyn ActivityService> = Arc::new(services::activity::ActivityService::new());
    let commit_service: Arc<dyn CommitService> = Arc::new(services::commit::CommitService::new());
    let stats_service: Arc<dyn StatsService> = Arc::new(services::stats::StatsService::new());

    let app_state = AppState {
        github_token,
        project_service,
        blog_service,
        activity_service,
        commit_service,
        stats_service,
    };

    // 构建 API 路由(使用独立的路由模块)
    let api_routes = routes::create_api_routes(app_state.clone());

    // 静态文件服务 - 为 SPA 应用提供 fallback
    let static_files_service =
        ServeDir::new("static").not_found_service(ServeFile::new("static/index.html"));

    // 构建完整应用路由
    let app = Router::new()
        // API 路由
        .nest("/api", api_routes)
        // 静态文件服务（处理所有非 API 路径）
        .fallback_service(static_files_service)
        .layer(
            CorsLayer::new()
                .allow_origin(Any)
                .allow_methods(Any)
                .allow_headers(Any),
        );

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8000").await?;
    info!("服务器启动在 http://0.0.0.0:8000");

    axum::serve(listener, app).await?;

    Ok(())
}
