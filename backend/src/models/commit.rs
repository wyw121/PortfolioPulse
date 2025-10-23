//! Commit 领域模型
//! 
//! 包含提交记录相关的API响应模型

use serde::{Deserialize, Serialize};

/// 提交记录API响应模型
#[derive(Debug, Serialize, Deserialize)]
pub struct CommitResponse {
    pub sha: String,
    pub message: String,
    pub author: String,
    pub date: String,
    pub repository: String,
}
