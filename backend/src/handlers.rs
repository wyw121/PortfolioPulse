use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    response::Json,
};
use serde::Deserialize;
use tracing::instrument;

use crate::{models::*, AppState};

fn get_mock_projects() -> Vec<ProjectResponse> {
    vec![
        ProjectResponse {
            id: "1".to_string(),
            name: "PortfolioPulse".to_string(),
            description: Some("现代化的个人项目展示和动态追踪平台".to_string()),
            html_url: "https://github.com/username/portfoliopulse".to_string(),
            homepage: Some("https://portfoliopulse.dev".to_string()),
            language: Some("Rust".to_string()),
            stargazers_count: 42,
            forks_count: 8,
            topics: vec!["nextjs".to_string(), "rust".to_string()],
            is_active: true,
            created_at: "2024-01-01T00:00:00Z".to_string(),
            updated_at: "2024-01-15T10:30:00Z".to_string(),
        },
    ]
}

fn get_mock_activities() -> Vec<ActivityResponse> {
    vec![
        ActivityResponse {
            date: "2024-01-15".to_string(),
            commits: 5,
            additions: 150,
            deletions: 32,
        },
        ActivityResponse {
            date: "2024-01-14".to_string(),
            commits: 3,
            additions: 89,
            deletions: 15,
        },
    ]
}

fn get_mock_commits() -> Vec<CommitResponse> {
    vec![
        CommitResponse {
            sha: "a1b2c3d".to_string(),
            message: "添加项目动态展示功能".to_string(),
            author: "Developer".to_string(),
            author_email: "dev@example.com".to_string(),
            date: "2024-01-15T10:30:00Z".to_string(),
            additions: 45,
            deletions: 12,
            project_name: "PortfolioPulse".to_string(),
        },
    ]
}

#[instrument(skip(_state))]
pub async fn get_projects(
    State(_state): State<AppState>,
) -> Result<Json<Vec<ProjectResponse>>, (StatusCode, Json<serde_json::Value>)> {
    Ok(Json(get_mock_projects()))
}

#[instrument(skip(_state))]
pub async fn get_project(
    State(_state): State<AppState>,
    Path(id): Path<String>,
) -> Result<Json<ProjectResponse>, (StatusCode, Json<serde_json::Value>)> {
    let projects = get_mock_projects();
    if let Some(project) = projects.into_iter().find(|p| p.id == id) {
        Ok(Json(project))
    } else {
        Err((StatusCode::NOT_FOUND, Json(serde_json::json!({ "error": "项目不存在" }))))
    }
}

#[derive(Debug, Deserialize)]
pub struct ActivityQuery {
    days: Option<i32>,
}

#[instrument(skip(_state))]
pub async fn get_activity(
    State(_state): State<AppState>,
    Query(params): Query<ActivityQuery>,
) -> Result<Json<Vec<ActivityResponse>>, (StatusCode, Json<serde_json::Value>)> {
    let days = params.days.unwrap_or(7);
    let activities = get_mock_activities();
    let result = activities.into_iter().take(days as usize).collect();
    Ok(Json(result))
}

#[derive(Debug, Deserialize)]
pub struct CommitQuery {
    limit: Option<i32>,
}

#[instrument(skip(_state))]
pub async fn get_recent_commits(
    State(_state): State<AppState>,
    Query(params): Query<CommitQuery>,
) -> Result<Json<Vec<CommitResponse>>, (StatusCode, Json<serde_json::Value>)> {
    let limit = params.limit.unwrap_or(10);
    let commits = get_mock_commits();
    let result = commits.into_iter().take(limit as usize).collect();
    Ok(Json(result))
}

#[instrument(skip(_state))]
pub async fn get_stats(
    State(_state): State<AppState>,
) -> Result<Json<StatsResponse>, (StatusCode, Json<serde_json::Value>)> {
    Ok(Json(StatsResponse {
        total_projects: 2,
        active_projects: 2,
        total_commits: 18,
        total_additions: 914,
        total_deletions: 205,
        languages: vec![
            ("Rust".to_string(), 45),
            ("TypeScript".to_string(), 35),
        ],
    }))
}
