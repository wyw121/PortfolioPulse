use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct Project {
    pub id: Uuid,
    pub name: String,
    pub description: Option<String>,
    pub html_url: String,
    pub homepage: Option<String>,
    pub language: Option<String>,
    pub stargazers_count: i32,
    pub forks_count: i32,
    pub topics: Option<String>, // JSON字符串
    pub is_active: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct GitActivity {
    pub id: Uuid,
    pub project_id: Uuid,
    pub date: DateTime<Utc>,
    pub commits: i32,
    pub additions: i32,
    pub deletions: i32,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct Commit {
    pub id: Uuid,
    pub project_id: Uuid,
    pub sha: String,
    pub message: String,
    pub author: String,
    pub author_email: String,
    pub date: DateTime<Utc>,
    pub additions: i32,
    pub deletions: i32,
    pub created_at: DateTime<Utc>,
}

// API响应模型
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

#[derive(Debug, Serialize, Deserialize)]
pub struct ActivityResponse {
    pub date: String,
    pub commits: i32,
    pub additions: i32,
    pub deletions: i32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CommitResponse {
    pub sha: String,
    pub message: String,
    pub author: String,
    pub date: String,
    pub repository: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct StatsResponse {
    pub total_projects: i32,
    pub total_commits: i32,
    pub total_additions: i32,
    pub total_deletions: i32,
    pub languages: Vec<LanguageStat>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct LanguageStat {
    pub name: String,
    pub count: i32,
    pub percentage: f32,
}

// GitHub API 模型
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

#[derive(Debug, Deserialize)]
pub struct GitHubCommit {
    pub sha: String,
    pub commit: GitHubCommitData,
    pub stats: Option<GitHubCommitStats>,
}

#[derive(Debug, Deserialize)]
pub struct GitHubCommitData {
    pub message: String,
    pub author: GitHubCommitAuthor,
}

#[derive(Debug, Deserialize)]
pub struct GitHubCommitAuthor {
    pub name: String,
    pub email: String,
    pub date: String,
}

#[derive(Debug, Deserialize)]
pub struct GitHubCommitStats {
    pub additions: i32,
    pub deletions: i32,
    pub total: i32,
}
