//! Activity 服务层
//! 
//! 采用结构体封装 + 依赖注入模式

use anyhow::Result;
use async_trait::async_trait;
use crate::models::ActivityResponse;
use crate::services::traits::ActivityService as ActivityServiceTrait;

/// 活动数据服务
pub struct ActivityService;

impl ActivityService {
    /// 创建新的活动服务实例
    pub fn new() -> Self {
        Self
    }

    /// 获取最近N天的活动数据
    pub async fn get_recent(&self, _days: i32) -> Result<Vec<ActivityResponse>> {
        Ok(vec![])
    }
}

// ============= Trait 实现 =============

#[async_trait]
impl ActivityServiceTrait for ActivityService {
    async fn get_recent(&self, days: i32) -> Result<Vec<ActivityResponse>> {
        self.get_recent(days).await
    }
}
