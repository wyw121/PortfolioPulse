use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct ProjectResponse {
    pub id: String,
    pub name: String,
    pub description: Option<String>,
    pub html_url: String,
    pub homepage: Option<String>,
    pub language: Option<String>,
    pub stargazers_count: i32,
    pub forks_count: i32,
    pub topics: Vec<String>,
    pub is_active: bool,
    pub created_at: String,
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
    pub author_email: String,
    pub date: String,
    pub additions: i32,
    pub deletions: i32,
    pub project_name: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct StatsResponse {
    pub total_projects: i32,
    pub active_projects: i32,
    pub total_commits: i32,
    pub total_additions: i32,
    pub total_deletions: i32,
    pub languages: Vec<(String, i32)>,
}
