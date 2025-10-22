//! GitHub 外部API模型
//! 
//! 用于与GitHub API交互的数据模型
//! 
//! 注意: 这些模型保留用于将来可能的GitHub同步功能

use serde::Deserialize;

/// GitHub仓库信息
#[allow(dead_code)]
#[derive(Debug, Deserialize)]
pub struct GitHubRepo {
    pub id: i64,
    pub name: String,
    pub full_name: String,
    pub description: Option<String>,
    pub html_url: String,
    pub homepage: Option<String>,
    pub language: Option<String>,
    pub stargazers_count: i32,
    pub forks_count: i32,
    pub topics: Vec<String>,
    pub updated_at: String,
}

/// GitHub提交信息
#[allow(dead_code)]
#[derive(Debug, Deserialize)]
pub struct GitHubCommit {
    pub sha: String,
    pub commit: GitHubCommitData,
    pub stats: Option<GitHubCommitStats>,
}

/// GitHub提交详细数据
#[allow(dead_code)]
#[derive(Debug, Deserialize)]
pub struct GitHubCommitData {
    pub message: String,
    pub author: GitHubCommitAuthor,
}

/// GitHub提交作者信息
#[allow(dead_code)]
#[derive(Debug, Deserialize)]
pub struct GitHubCommitAuthor {
    pub name: String,
    pub email: String,
    pub date: String,
}

/// GitHub提交统计信息
#[allow(dead_code)]
#[derive(Debug, Deserialize)]
pub struct GitHubCommitStats {
    pub additions: i32,
    pub deletions: i32,
    pub total: i32,
}
