//! Commit 领域模型
//! 
//! 包含提交记录相关的数据库实体和API响应模型

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;

/// 提交记录数据库实体
#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct Commit {
    pub id: Uuid,
    pub project_id: Uuid,
    pub sha: String,
    pub message: String,
    pub author: String,
    pub author_email: String,
    pub date: DateTime<Utc>,
    pub additions: i32,
    pub deletions: i32,
    pub created_at: DateTime<Utc>,
}

/// 提交记录API响应模型
#[derive(Debug, Serialize, Deserialize)]
pub struct CommitResponse {
    pub sha: String,
    pub message: String,
    pub author: String,
    pub date: String,
    pub repository: String,
}
