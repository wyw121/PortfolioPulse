use axum::{response::Json, routing::get, Router};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use tower_http::cors::{Any, CorsLayer};
use tracing::{info, instrument};

mod handlers;
mod models;
mod services;

use handlers::*;

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
        .unwrap_or_else(|_| "mysql://root:password@localhost/portfolio_pulse".to_string());

    let pool = sqlx::MySqlPool::connect(&database_url).await?;

    // 运行数据库迁移
    sqlx::migrate!("./migrations").run(&pool).await?;

    let github_token = std::env::var("GITHUB_TOKEN").unwrap_or_default();

    let app_state = AppState {
        db: pool,
        github_token,
    };

    // 构建应用路由
    let app = Router::new()
        .route("/", get(health_check))
        .route("/api/health", get(health_check))
        .route("/api/projects", get(get_projects))
        .route("/api/projects/:id", get(get_project))
        .route("/api/activity", get(get_activity))
        .route("/api/commits", get(get_recent_commits))
        .route("/api/stats", get(get_stats))
        .layer(
            CorsLayer::new()
                .allow_origin(Any)
                .allow_methods(Any)
                .allow_headers(Any),
        )
        .with_state(app_state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8000").await?;
    info!("服务器启动在 http://0.0.0.0:8000");

    axum::serve(listener, app).await?;

    Ok(())
}

#[instrument]
async fn health_check() -> Json<serde_json::Value> {
    Json(serde_json::json!({
        "status": "healthy",
        "message": "PortfolioPulse Backend is running",
        "version": "0.1.0"
    }))
}
