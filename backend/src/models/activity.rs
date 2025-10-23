//! Activity 领域模型
//! 
//! 包含Git活动相关的API响应模型

use serde::{Deserialize, Serialize};

/// Git活动API响应模型
#[derive(Debug, Serialize, Deserialize)]
pub struct ActivityResponse {
    pub date: String,
    pub commits: i32,
    pub additions: i32,
    pub deletions: i32,
}
