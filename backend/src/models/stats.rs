//! Stats 统计模型
//! 
//! 包含统计数据相关的API响应模型

use serde::{Deserialize, Serialize};

/// 统计数据API响应模型
#[derive(Debug, Serialize, Deserialize)]
pub struct StatsResponse {
    pub total_projects: i32,
    pub total_commits: i32,
    pub total_additions: i32,
    pub total_deletions: i32,
    pub languages: Vec<LanguageStat>,
}

/// 编程语言统计
#[derive(Debug, Serialize, Deserialize)]
pub struct LanguageStat {
    pub name: String,
    pub count: i32,
    pub percentage: f32,
}
