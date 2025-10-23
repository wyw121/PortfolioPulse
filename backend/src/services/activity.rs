//! Activity 服务层
//! 
//! 采用结构体封装 + 依赖注入模式

use anyhow::Result;

use crate::models::ActivityResponse;

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
