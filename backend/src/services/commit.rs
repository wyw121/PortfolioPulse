//! Commit 服务层
//! 
//! 采用结构体封装 + 依赖注入模式

use anyhow::Result;

use crate::models::CommitResponse;

/// 提交记录服务
pub struct CommitService;

impl CommitService {
    /// 创建新的提交服务实例
    pub fn new() -> Self {
        Self
    }

    /// 获取最近的提交记录
    pub async fn get_recent(&self, _limit: i32) -> Result<Vec<CommitResponse>> {
        Ok(vec![])
    }
}
