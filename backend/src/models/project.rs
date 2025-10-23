//! Project 领域模型
//! 
//! 包含项目相关的API响应模型

use serde::{Deserialize, Serialize};

/// 项目API响应模型
#[derive(Debug, Serialize, Deserialize)]
pub struct ProjectResponse {
    pub id: String,
    pub name: String,
    pub description: String,
    pub html_url: String,
    pub homepage: Option<String>,
    pub language: String,
    pub stargazers_count: i32,
    pub forks_count: i32,
    pub topics: Vec<String>,
    pub updated_at: String,
}
