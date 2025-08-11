use axum::{response::Json, routing::get, Router};
use tower_http::cors::{Any, CorsLayer};
use tracing::{info, instrument};

mod auth;
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
        .unwrap_or_else(|_| "mysql://root@localhost/portfolio_pulse".to_string());

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
        // 博客相关路由（公开访问）
        .route("/api/blog/posts", get(get_blog_posts))
        .route("/api/blog/posts/:slug", get(get_blog_post))
        .route("/api/blog/featured", get(get_featured_blog_posts))
        .route("/api/blog/categories", get(get_blog_categories))
        // 管理员路由（需要认证）
        .route("/api/admin/blog/posts",
            axum::routing::post(create_blog_post)
                .layer(axum::middleware::from_fn_with_state(app_state.clone(), auth::admin_auth_middleware))
        )
        .route("/api/admin/blog/posts",
            get(get_all_blog_posts_admin)
                .layer(axum::middleware::from_fn_with_state(app_state.clone(), auth::admin_auth_middleware))
        )
        .route("/api/admin/blog/posts/:id",
            axum::routing::put(update_blog_post)
                .layer(axum::middleware::from_fn_with_state(app_state.clone(), auth::admin_auth_middleware))
        )
        .route("/api/admin/blog/posts/:id",
            axum::routing::delete(delete_blog_post)
                .layer(axum::middleware::from_fn_with_state(app_state.clone(), auth::admin_auth_middleware))
        )
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
