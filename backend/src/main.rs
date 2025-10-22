use axum::Router;
use tower_http::cors::{Any, CorsLayer};
use tower_http::services::{ServeDir, ServeFile};
use tracing::info;

mod dto;
mod error;
mod handlers;
mod models;
mod routes;
mod services;

#[derive(Clone)]
pub struct AppState {
    pub db: sqlx::MySqlPool,
    pub github_token: String,
}

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    // 初始化日志
    tracing_subscriber::fmt::init();

    // 加载环境变量
    dotenvy::dotenv().ok();

    // 数据库连接
    let database_url = std::env::var("DATABASE_URL")
        .unwrap_or_else(|_| "mysql://root@localhost/portfolio_pulse".to_string());

    let pool = sqlx::MySqlPool::connect(&database_url).await?;

    // 运行数据库迁移
    sqlx::migrate!("./migrations").run(&pool).await?;

    let github_token = std::env::var("GITHUB_TOKEN").unwrap_or_default();

    let app_state = AppState {
        db: pool,
        github_token,
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
