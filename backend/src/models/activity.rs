//! Activity 领域模型
//! 
//! 包含Git活动相关的数据库实体和API响应模型

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;

/// Git活动数据库实体
#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct GitActivity {
    pub id: Uuid,
    pub project_id: Uuid,
    pub date: DateTime<Utc>,
    pub commits: i32,
    pub additions: i32,
    pub deletions: i32,
    pub created_at: DateTime<Utc>,
}

/// Git活动API响应模型
#[derive(Debug, Serialize, Deserialize)]
pub struct ActivityResponse {
    pub date: String,
    pub commits: i32,
    pub additions: i32,
    pub deletions: i32,
}
