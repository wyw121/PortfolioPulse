use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use serde::{Deserialize, Serialize};
use std::fmt;

/// 标准化错误响应结构
#[derive(Debug, Serialize, Deserialize)]
pub struct ErrorResponse {
    /// 错误码 - 用于程序判断错误类型
    pub code: String,
    /// 用户友好的错误消息
    pub message: String,
    /// 开发者详细信息（可选）
    #[serde(skip_serializing_if = "Option::is_none")]
    pub details: Option<String>,
    /// 请求ID，用于日志追踪
    #[serde(skip_serializing_if = "Option::is_none")]
    pub request_id: Option<String>,
}

/// 应用程序统一错误类型
#[derive(Debug)]
pub enum AppError {
    NotFound(String),
    BadRequest(String),
    InternalError(String),
    ValidationError(String),
    Unauthorized(String),
    Forbidden(String),
    Conflict(String),
    RateLimited(String),
}

impl fmt::Display for AppError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            AppError::NotFound(msg) => write!(f, "Not Found: {}", msg),
            AppError::BadRequest(msg) => write!(f, "Bad Request: {}", msg),
            AppError::InternalError(msg) => write!(f, "Internal Error: {}", msg),
            AppError::ValidationError(msg) => write!(f, "Validation Error: {}", msg),
            AppError::Unauthorized(msg) => write!(f, "Unauthorized: {}", msg),
            AppError::Forbidden(msg) => write!(f, "Forbidden: {}", msg),
            AppError::Conflict(msg) => write!(f, "Conflict: {}", msg),
            AppError::RateLimited(msg) => write!(f, "Rate Limited: {}", msg),
        }
    }
}

impl std::error::Error for AppError {}

/// 实现 IntoResponse，使 AppError 可以直接作为 Axum handler 的返回值
impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, code, message) = match &self {
            AppError::NotFound(msg) => (StatusCode::NOT_FOUND, "NOT_FOUND", msg),
            AppError::BadRequest(msg) => (StatusCode::BAD_REQUEST, "BAD_REQUEST", msg),
            AppError::InternalError(msg) => (StatusCode::INTERNAL_SERVER_ERROR, "INTERNAL_ERROR", msg),
            AppError::ValidationError(msg) => (StatusCode::BAD_REQUEST, "VALIDATION_ERROR", msg),
            AppError::Unauthorized(msg) => (StatusCode::UNAUTHORIZED, "UNAUTHORIZED", msg),
            AppError::Forbidden(msg) => (StatusCode::FORBIDDEN, "FORBIDDEN", msg),
            AppError::Conflict(msg) => (StatusCode::CONFLICT, "CONFLICT", msg),
            AppError::RateLimited(msg) => (StatusCode::TOO_MANY_REQUESTS, "RATE_LIMITED", msg),
        };

        let error_response = ErrorResponse {
            code: code.to_string(),
            message: message.clone(),
            details: None,
            request_id: None, // TODO: 后续可以从请求上下文中获取
        };

        let body = Json(error_response);
        (status, body).into_response()
    }
}

/// 从 anyhow::Error 转换为 AppError
impl From<anyhow::Error> for AppError {
    fn from(err: anyhow::Error) -> Self {
        tracing::error!("Internal error: {:?}", err);
        AppError::InternalError(err.to_string())
    }
}

/// 从 uuid::Error 转换为 AppError
impl From<uuid::Error> for AppError {
    fn from(_: uuid::Error) -> Self {
        AppError::BadRequest("无效的ID格式".to_string())
    }
}

/// 便利方法，用于快速创建各种错误
impl AppError {
    pub fn not_found(message: impl Into<String>) -> Self {
        AppError::NotFound(message.into())
    }

    pub fn bad_request(message: impl Into<String>) -> Self {
        AppError::BadRequest(message.into())
    }

    pub fn validation_error(message: impl Into<String>) -> Self {
        AppError::ValidationError(message.into())
    }

    pub fn unauthorized(message: impl Into<String>) -> Self {
        AppError::Unauthorized(message.into())
    }

    pub fn forbidden(message: impl Into<String>) -> Self {
        AppError::Forbidden(message.into())
    }

    pub fn conflict(message: impl Into<String>) -> Self {
        AppError::Conflict(message.into())
    }

    pub fn rate_limited(message: impl Into<String>) -> Self {
        AppError::RateLimited(message.into())
    }

    pub fn internal_error(message: impl Into<String>) -> Self {
        AppError::InternalError(message.into())
    }
}


