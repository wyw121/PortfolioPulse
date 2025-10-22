//! Activity 服务层
//! 
//! 采用结构体封装 + 依赖注入模式

use anyhow::Result;
use chrono::Utc;
use sqlx::MySqlPool;
use uuid::Uuid;

use crate::models::ActivityResponse;

/// 活动数据服务
pub struct ActivityService {
    #[allow(dead_code)]
    pool: MySqlPool,
}

impl ActivityService {
    /// 创建新的活动服务实例
    pub fn new(pool: MySqlPool) -> Self {
        Self { pool }
    }

    /// 获取最近N天的活动数据
    pub async fn get_recent(&self, _days: i32) -> Result<Vec<ActivityResponse>> {
        Ok(vec![])
    }

    /// 同步项目活动数据(从GitHub API)
    #[allow(dead_code)]
    pub async fn sync_project_activity(
        &self,
        _project_id: Uuid,
        _date: chrono::DateTime<Utc>,
        _commits: i32,
        _additions: i32,
        _deletions: i32,
    ) -> Result<()> {
        Ok(())
    }
}
