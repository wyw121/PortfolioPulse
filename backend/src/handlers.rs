use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    response::Json,
};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use tracing::{error, info, instrument};
use uuid::Uuid;

use crate::{models::*, services, AppState};

#[instrument(skip(state))]
pub async fn get_projects(
    State(state): State<AppState>,
) -> Result<Json<Vec<ProjectResponse>>, (StatusCode, Json<serde_json::Value>)> {
    match services::project::get_all_projects(&state.db).await {
        Ok(projects) => Ok(Json(projects)),
        Err(e) => {
            error!("获取项目列表失败: {}", e);
            Err((
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({ "error": "获取项目列表失败" })),
            ))
        }
    }
}

#[instrument(skip(state))]
pub async fn get_project(
    State(state): State<AppState>,
    Path(id): Path<String>,
) -> Result<Json<ProjectResponse>, (StatusCode, Json<serde_json::Value>)> {
    let project_id = match Uuid::parse_str(&id) {
        Ok(id) => id,
        Err(_) => {
            return Err((
                StatusCode::BAD_REQUEST,
                Json(serde_json::json!({ "error": "无效的项目ID" })),
            ));
        }
    };

    match services::project::get_project_by_id(&state.db, project_id).await {
        Ok(Some(project)) => Ok(Json(project)),
        Ok(None) => Err((
            StatusCode::NOT_FOUND,
            Json(serde_json::json!({ "error": "项目不存在" })),
        )),
        Err(e) => {
            error!("获取项目详情失败: {}", e);
            Err((
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({ "error": "获取项目详情失败" })),
            ))
        }
    }
}

#[derive(Debug, Deserialize)]
pub struct ActivityQuery {
    days: Option<i32>,
}

#[instrument(skip(state))]
pub async fn get_activity(
    State(state): State<AppState>,
    Query(params): Query<ActivityQuery>,
) -> Result<Json<Vec<ActivityResponse>>, (StatusCode, Json<serde_json::Value>)> {
    let days = params.days.unwrap_or(7);

    match services::activity::get_recent_activity(&state.db, days).await {
        Ok(activities) => Ok(Json(activities)),
        Err(e) => {
            error!("获取活动数据失败: {}", e);
            Err((
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({ "error": "获取活动数据失败" })),
            ))
        }
    }
}

#[derive(Debug, Deserialize)]
pub struct CommitQuery {
    limit: Option<i32>,
}

#[instrument(skip(state))]
pub async fn get_recent_commits(
    State(state): State<AppState>,
    Query(params): Query<CommitQuery>,
) -> Result<Json<Vec<CommitResponse>>, (StatusCode, Json<serde_json::Value>)> {
    let limit = params.limit.unwrap_or(10);

    match services::commit::get_recent_commits(&state.db, limit).await {
        Ok(commits) => Ok(Json(commits)),
        Err(e) => {
            error!("获取最近提交失败: {}", e);
            Err((
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({ "error": "获取最近提交失败" })),
            ))
        }
    }
}

#[instrument(skip(state))]
pub async fn get_stats(
    State(state): State<AppState>,
) -> Result<Json<StatsResponse>, (StatusCode, Json<serde_json::Value>)> {
    match services::stats::get_overall_stats(&state.db).await {
        Ok(stats) => Ok(Json(stats)),
        Err(e) => {
            error!("获取统计数据失败: {}", e);
            Err((
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({ "error": "获取统计数据失败" })),
            ))
        }
    }
}
