use axum::{extract::{Path, Query, State}, response::Json};
use serde::Deserialize;
use tracing::instrument;
use uuid::Uuid;

use crate::{error::AppError, models::*, services, AppState};

/// 健康检查端点
/// 
/// 返回服务器健康状态和版本信息
#[instrument]
pub async fn health_check() -> Json<serde_json::Value> {
    Json(serde_json::json!({
        "status": "healthy",
        "message": "PortfolioPulse Backend is running",
        "version": "0.1.0"
    }))
}

#[instrument(skip(state))]
pub async fn get_projects(State(state): State<AppState>) -> Result<Json<Vec<ProjectResponse>>, AppError> {
    let service = services::project::ProjectService::new(state.db.clone());
    let projects = service.get_all().await.map_err(|_| AppError::internal("获取项目列表失败"))?;
    Ok(Json(projects))
}

#[instrument(skip(state))]
pub async fn get_project(State(state): State<AppState>, Path(id): Path<String>) -> Result<Json<ProjectResponse>, AppError> {
    let project_id = Uuid::parse_str(&id)?;
    let service = services::project::ProjectService::new(state.db.clone());
    let project = service.get_by_id(project_id).await.map_err(|_| AppError::internal("获取项目详情失败"))?.ok_or_else(|| AppError::not_found("项目不存在"))?;
    Ok(Json(project))
}

#[derive(Debug, Deserialize)]
pub struct ActivityQuery { days: Option<i32> }

#[instrument(skip(state))]
pub async fn get_activity(State(state): State<AppState>, Query(params): Query<ActivityQuery>) -> Result<Json<Vec<ActivityResponse>>, AppError> {
    let days = params.days.unwrap_or(7);
    let service = services::activity::ActivityService::new(state.db.clone());
    let activities = service.get_recent(days).await.map_err(|_| AppError::internal("获取活动数据失败"))?;
    Ok(Json(activities))
}

#[derive(Debug, Deserialize)]
pub struct CommitQuery { limit: Option<u32> }

#[instrument(skip(state))]
pub async fn get_recent_commits(State(state): State<AppState>, Query(params): Query<CommitQuery>) -> Result<Json<Vec<CommitResponse>>, AppError> {
    let limit = params.limit.unwrap_or(10) as i32;
    let service = services::commit::CommitService::new(state.db.clone());
    let commits = service.get_recent(limit).await.map_err(|_| AppError::internal("获取最近提交失败"))?;
    Ok(Json(commits))
}

#[instrument(skip(state))]
pub async fn get_stats(State(state): State<AppState>) -> Result<Json<StatsResponse>, AppError> {
    let service = services::stats::StatsService::new(state.db.clone());
    let stats = service.get_overall().await.map_err(|_| AppError::internal("获取统计数据失败"))?;
    Ok(Json(stats))
}

#[derive(Debug, Deserialize)]
pub struct BlogQuery { pub page: Option<u32>, pub page_size: Option<u32>, pub category: Option<String>, pub search: Option<String> }

#[instrument(skip(_state))]
pub async fn get_blog_posts(State(_state): State<AppState>, Query(params): Query<BlogQuery>) -> Result<Json<Vec<BlogPostResponse>>, AppError> {
    let blog_service = services::blog_markdown::MarkdownBlogService::new();
    let page = params.page.unwrap_or(1);
    let page_size = params.page_size.unwrap_or(10);
    let posts = blog_service.get_published_posts(page, page_size).await.map_err(|_| AppError::internal("获取博客文章失败"))?;
    let responses: Vec<BlogPostResponse> = posts.into_iter().map(Into::into).collect();
    Ok(Json(responses))
}

#[instrument(skip(_state))]
pub async fn get_blog_post(State(_state): State<AppState>, Path(slug): Path<String>) -> Result<Json<BlogPostResponse>, AppError> {
    let blog_service = services::blog_markdown::MarkdownBlogService::new();
    let post = blog_service.get_post_by_slug(&slug).await.map_err(|_| AppError::internal("获取博客文章失败"))?.ok_or_else(|| AppError::not_found("博客文章不存在"))?;
    Ok(Json(post.into()))
}

#[instrument(skip(_state))]
pub async fn get_featured_blog_posts(State(_state): State<AppState>) -> Result<Json<Vec<BlogPostResponse>>, AppError> {
    let blog_service = services::blog_markdown::MarkdownBlogService::new();
    let posts = blog_service.get_featured_posts(5).await.map_err(|_| AppError::internal("获取精选博客文章失败"))?;
    let responses: Vec<BlogPostResponse> = posts.into_iter().map(Into::into).collect();
    Ok(Json(responses))
}

#[instrument(skip(_state))]
pub async fn get_blog_categories(State(_state): State<AppState>) -> Result<Json<Vec<BlogCategory>>, AppError> {
    Ok(Json(vec![]))
}
