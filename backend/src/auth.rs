use axum::{
    extract::{Request, State},
    http::{HeaderMap, StatusCode},
    middleware::Next,
    response::Response,
    Json,
};
use serde_json::json;

use crate::AppState;

// 简单的认证中间件
pub async fn admin_auth_middleware(
    State(_state): State<AppState>,
    headers: HeaderMap,
    request: Request,
    next: Next,
) -> Result<Response, (StatusCode, Json<serde_json::Value>)> {
    // 检查环境变量中配置的管理员认证
    let admin_user = std::env::var("BLOG_ADMIN_USER").unwrap_or_default();
    let admin_token = std::env::var("BLOG_ADMIN_TOKEN").unwrap_or_default();
    
    // 如果没有配置管理员认证，暂时允许所有请求（开发模式）
    if admin_user.is_empty() || admin_token.is_empty() {
        tracing::warn!("博客管理员认证未配置，允许所有请求");
        return Ok(next.run(request).await);
    }
    
    // 检查Authorization头
    if let Some(auth_header) = headers.get("authorization") {
        if let Ok(auth_str) = auth_header.to_str() {
            if auth_str.starts_with("Bearer ") {
                let token = &auth_str[7..];
                if token == admin_token {
                    // Token验证成功，继续处理请求
                    return Ok(next.run(request).await);
                }
            }
        }
    }
    
    // 检查简单的Basic Auth
    if let Some(auth_header) = headers.get("authorization") {
        if let Ok(auth_str) = auth_header.to_str() {
            if auth_str.starts_with("Basic ") {
                let credentials = &auth_str[6..];
                if let Ok(decoded) = base64::decode(credentials) {
                    if let Ok(decoded_str) = String::from_utf8(decoded) {
                        let parts: Vec<&str> = decoded_str.split(':').collect();
                        if parts.len() == 2 && parts[0] == admin_user && parts[1] == admin_token {
                            return Ok(next.run(request).await);
                        }
                    }
                }
            }
        }
    }
    
    // 认证失败
    Err((
        StatusCode::UNAUTHORIZED,
        Json(json!({
            "error": "需要管理员权限",
            "message": "请提供有效的认证凭据"
        })),
    ))
}

// 检查用户是否为管理员的辅助函数
pub fn is_admin_user(username: &str) -> bool {
    let admin_user = std::env::var("BLOG_ADMIN_USER").unwrap_or_default();
    !admin_user.is_empty() && username == admin_user
}

// GitHub OAuth 认证辅助（待实现）
pub async fn verify_github_token(token: &str) -> Result<String, anyhow::Error> {
    let client = reqwest::Client::new();
    let response = client
        .get("https://api.github.com/user")
        .header("Authorization", format!("Bearer {}", token))
        .header("User-Agent", "PortfolioPulse/1.0")
        .send()
        .await?;
    
    if response.status().is_success() {
        let user: serde_json::Value = response.json().await?;
        if let Some(username) = user["login"].as_str() {
            return Ok(username.to_string());
        }
    }
    
    Err(anyhow::anyhow!("无效的GitHub令牌"))
}
