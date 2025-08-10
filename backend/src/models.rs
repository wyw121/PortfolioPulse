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

// 博客相关模型
#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct BlogPost {
    pub id: Uuid,
    pub title: String,
    pub slug: String,
    pub content: String,
    pub excerpt: Option<String>,
    pub cover_image: Option<String>,
    pub category: Option<String>,
    pub tags: Option<String>, // JSON字符串
    pub status: String,
    pub view_count: i32,
    pub is_featured: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub published_at: Option<DateTime<Utc>>,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct BlogCategory {
    pub id: Uuid,
    pub name: String,
    pub slug: String,
    pub description: Option<String>,
    pub color: String,
    pub post_count: i32,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct AdminSession {
    pub id: Uuid,
    pub session_token: String,
    pub user_id: String,
    pub user_name: String,
    pub expires_at: DateTime<Utc>,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct BlogUpload {
    pub id: Uuid,
    pub original_name: String,
    pub file_name: String,
    pub file_path: String,
    pub file_size: i64,
    pub mime_type: String,
    pub upload_type: String,
    pub post_id: Option<Uuid>,
    pub created_at: DateTime<Utc>,
}

// API请求模型
#[derive(Debug, Deserialize)]
pub struct CreateBlogPostRequest {
    pub title: String,
    pub content: String,
    pub excerpt: Option<String>,
    pub category: Option<String>,
    pub tags: Option<Vec<String>>,
    pub status: Option<String>,
    pub is_featured: Option<bool>,
    pub cover_image: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateBlogPostRequest {
    pub title: Option<String>,
    pub content: Option<String>,
    pub excerpt: Option<String>,
    pub category: Option<String>,
    pub tags: Option<Vec<String>>,
    pub status: Option<String>,
    pub is_featured: Option<bool>,
    pub cover_image: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct BlogPostResponse {
    pub id: String,
    pub title: String,
    pub slug: String,
    pub content: String,
    pub excerpt: Option<String>,
    pub cover_image: Option<String>,
    pub category: Option<String>,
    pub tags: Vec<String>,
    pub status: String,
    pub view_count: i32,
    pub is_featured: bool,
    pub created_at: String,
    pub updated_at: String,
    pub published_at: Option<String>,
}
