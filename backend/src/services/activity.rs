use anyhow::Result;
use chrono::Utc;
use sqlx::MySqlPool;

use crate::models::ActivityResponse;

pub async fn get_recent_activity(_pool: &MySqlPool, _days: i32) -> Result<Vec<ActivityResponse>> {
    // 占位符实现：返回空列表，待实现
    Ok(vec![])
}

// 同步项目活动数据 (从 GitHub API)
pub async fn sync_project_activity(
    _pool: &MySqlPool,
    _project_id: uuid::Uuid,
    _date: chrono::DateTime<Utc>,
    _commits: i32,
    _additions: i32,
    _deletions: i32,
) -> Result<()> {
    // 占位符实现，待数据库表准备好后实现
    Ok(())
}
