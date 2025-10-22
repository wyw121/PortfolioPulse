//! Commit 服务层
//! 
//! 采用结构体封装 + 依赖注入模式

use anyhow::Result;
use sqlx::MySqlPool;
use uuid::Uuid;

use crate::models::{CommitResponse, GitHubCommit};

/// 提交记录服务
pub struct CommitService {
    #[allow(dead_code)]
    pool: MySqlPool,
}

impl CommitService {
    /// 创建新的提交服务实例
    pub fn new(pool: MySqlPool) -> Self {
        Self { pool }
    }

    /// 获取最近的提交记录
    pub async fn get_recent(&self, _limit: i32) -> Result<Vec<CommitResponse>> {
        Ok(vec![])
    }

    /// 保存提交记录到数据库
    #[allow(dead_code)]
    pub async fn save(&self, _project_id: Uuid, _github_commit: &GitHubCommit) -> Result<()> {
        Ok(())
    }
}
