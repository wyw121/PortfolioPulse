use anyhow::Result;
use sqlx::MySqlPool;

use crate::models::CommitResponse;

pub async fn get_recent_commits(_pool: &MySqlPool, _limit: i32) -> Result<Vec<CommitResponse>> {
    // 占位符实现：返回空列表，待实现
    Ok(vec![])
}

// 存储提交记录到数据库
pub async fn save_commit(
    _pool: &MySqlPool,
    _project_id: uuid::Uuid,
    _github_commit: &crate::models::GitHubCommit,
) -> Result<()> {
    // 占位符实现，待数据库表准备好后实现
    Ok(())
}
