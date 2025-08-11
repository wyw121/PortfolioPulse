use axum::{
    extract::{Json as ExtractJson, Path, Query, State},
    http::StatusCode,
    response::Json,
};
use serde::Deserialize;
use tracing::{error, instrument};
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

// 博客相关API处理器
#[derive(Debug, Deserialize)]
pub struct BlogQuery {
    pub page: Option<u32>,
    pub page_size: Option<u32>,
    pub category: Option<String>,
    pub search: Option<String>,
}

// 获取博客文章列表
#[instrument(skip(state))]
pub async fn get_blog_posts(
    State(state): State<AppState>,
    Query(params): Query<BlogQuery>,
) -> Result<Json<Vec<BlogPostResponse>>, (StatusCode, Json<serde_json::Value>)> {
    let blog_service = services::blog::BlogService::new(state.db.clone());
    let page = params.page.unwrap_or(1);
    let page_size = params.page_size.unwrap_or(10);

    let posts = if let Some(search) = params.search {
        blog_service.search_posts(&search, page, page_size).await
    } else if let Some(category) = params.category {
        blog_service
            .get_posts_by_category(&category, page, page_size)
            .await
    } else {
        blog_service.get_published_posts(page, page_size).await
    };

    match posts {
        Ok(posts) => {
            let responses: Vec<BlogPostResponse> = posts
                .into_iter()
                .map(|post| BlogPostResponse {
                    id: post.id,
                    title: post.title,
                    slug: post.slug,
                    content: post.content,
                    excerpt: post.excerpt,
                    cover_image: post.cover_image,
                    category: post.category,
                    tags: post
                        .tags
                        .and_then(|t| serde_json::from_str(&t).ok())
                        .unwrap_or_default(),
                    status: post.status,
                    view_count: post.view_count,
                    is_featured: post.is_featured != 0,
                    created_at: post.created_at.to_rfc3339(),
                    updated_at: post.updated_at.to_rfc3339(),
                    published_at: post.published_at.map(|dt| dt.to_rfc3339()),
                })
                .collect();

            Ok(Json(responses))
        }
        Err(e) => {
            error!("获取博客文章失败: {}", e);
            Err((
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({ "error": "获取博客文章失败" })),
            ))
        }
    }
}

// 根据slug获取单篇博客文章
#[instrument(skip(state))]
pub async fn get_blog_post(
    State(state): State<AppState>,
    Path(slug): Path<String>,
) -> Result<Json<BlogPostResponse>, (StatusCode, Json<serde_json::Value>)> {
    let blog_service = services::blog::BlogService::new(state.db.clone());

    match blog_service.get_post_by_slug(&slug).await {
        Ok(Some(post)) => {
            let response = BlogPostResponse {
                id: post.id,
                title: post.title,
                slug: post.slug,
                content: post.content,
                excerpt: post.excerpt,
                cover_image: post.cover_image,
                category: post.category,
                tags: post
                    .tags
                    .and_then(|t| serde_json::from_str(&t).ok())
                    .unwrap_or_default(),
                status: post.status,
                view_count: post.view_count,
                is_featured: post.is_featured != 0,
                created_at: post.created_at.to_rfc3339(),
                updated_at: post.updated_at.to_rfc3339(),
                published_at: post.published_at.map(|dt| dt.to_rfc3339()),
            };
            Ok(Json(response))
        }
        Ok(None) => Err((
            StatusCode::NOT_FOUND,
            Json(serde_json::json!({ "error": "博客文章不存在" })),
        )),
        Err(e) => {
            error!("获取博客文章失败: {}", e);
            Err((
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({ "error": "获取博客文章失败" })),
            ))
        }
    }
}

// 获取精选博客文章
#[instrument(skip(state))]
pub async fn get_featured_blog_posts(
    State(state): State<AppState>,
) -> Result<Json<Vec<BlogPostResponse>>, (StatusCode, Json<serde_json::Value>)> {
    let blog_service = services::blog::BlogService::new(state.db.clone());

    match blog_service.get_featured_posts(5).await {
        Ok(posts) => {
            let responses: Vec<BlogPostResponse> = posts
                .into_iter()
                .map(|post| BlogPostResponse {
                    id: post.id,
                    title: post.title,
                    slug: post.slug,
                    content: post.content,
                    excerpt: post.excerpt,
                    cover_image: post.cover_image,
                    category: post.category,
                    tags: post
                        .tags
                        .and_then(|t| serde_json::from_str(&t).ok())
                        .unwrap_or_default(),
                    status: post.status,
                    view_count: post.view_count,
                    is_featured: post.is_featured != 0,
                    created_at: post.created_at.to_rfc3339(),
                    updated_at: post.updated_at.to_rfc3339(),
                    published_at: post.published_at.map(|dt| dt.to_rfc3339()),
                })
                .collect();

            Ok(Json(responses))
        }
        Err(e) => {
            error!("获取精选博客文章失败: {}", e);
            Err((
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({ "error": "获取精选博客文章失败" })),
            ))
        }
    }
}

// 获取博客分类
#[instrument(skip(state))]
pub async fn get_blog_categories(
    State(state): State<AppState>,
) -> Result<Json<Vec<BlogCategory>>, (StatusCode, Json<serde_json::Value>)> {
    let blog_service = services::blog::BlogService::new(state.db.clone());

    match blog_service.get_all_categories().await {
        Ok(categories) => Ok(Json(categories)),
        Err(e) => {
            error!("获取博客分类失败: {}", e);
            Err((
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({ "error": "获取博客分类失败" })),
            ))
        }
    }
}

// 管理员API - 创建博客文章
#[instrument(skip(state, req))]
pub async fn create_blog_post(
    State(state): State<AppState>,
    ExtractJson(req): ExtractJson<CreateBlogPostRequest>,
) -> Result<Json<BlogPostResponse>, (StatusCode, Json<serde_json::Value>)> {
    let blog_service = services::blog::BlogService::new(state.db.clone());

    match blog_service.create_post(req).await {
        Ok(post) => {
            let response = BlogPostResponse {
                id: post.id,
                title: post.title,
                slug: post.slug,
                content: post.content,
                excerpt: post.excerpt,
                cover_image: post.cover_image,
                category: post.category,
                tags: post
                    .tags
                    .and_then(|t| serde_json::from_str(&t).ok())
                    .unwrap_or_default(),
                status: post.status,
                view_count: post.view_count,
                is_featured: post.is_featured != 0,
                created_at: post.created_at.to_rfc3339(),
                updated_at: post.updated_at.to_rfc3339(),
                published_at: post.published_at.map(|dt| dt.to_rfc3339()),
            };
            Ok(Json(response))
        }
        Err(e) => {
            error!("创建博客文章失败: {}", e);
            Err((
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({ "error": "创建博客文章失败" })),
            ))
        }
    }
}

// 管理员API - 更新博客文章
#[instrument(skip(state, req))]
pub async fn update_blog_post(
    State(state): State<AppState>,
    Path(id): Path<String>,
    ExtractJson(req): ExtractJson<UpdateBlogPostRequest>,
) -> Result<Json<BlogPostResponse>, (StatusCode, Json<serde_json::Value>)> {
    let blog_service = services::blog::BlogService::new(state.db.clone());

    // 验证 ID 格式但直接使用字符串
    if Uuid::parse_str(&id).is_err() {
        return Err((
            StatusCode::BAD_REQUEST,
            Json(serde_json::json!({ "error": "无效的文章ID" })),
        ));
    }

    match blog_service.update_post(&id, req).await {
        // 直接使用 &id
        Ok(post) => {
            let response = BlogPostResponse {
                id: post.id,
                title: post.title,
                slug: post.slug,
                content: post.content,
                excerpt: post.excerpt,
                cover_image: post.cover_image,
                category: post.category,
                tags: post
                    .tags
                    .and_then(|t| serde_json::from_str(&t).ok())
                    .unwrap_or_default(),
                status: post.status,
                view_count: post.view_count,
                is_featured: post.is_featured != 0,
                created_at: post.created_at.to_rfc3339(),
                updated_at: post.updated_at.to_rfc3339(),
                published_at: post.published_at.map(|dt| dt.to_rfc3339()),
            };
            Ok(Json(response))
        }
        Err(e) => {
            error!("更新博客文章失败: {}", e);
            Err((
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({ "error": "更新博客文章失败" })),
            ))
        }
    }
}

// 管理员API - 删除博客文章
#[instrument(skip(state))]
pub async fn delete_blog_post(
    State(state): State<AppState>,
    Path(id): Path<String>,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    let blog_service = services::blog::BlogService::new(state.db.clone());

    // 验证 ID 格式但直接使用字符串
    if Uuid::parse_str(&id).is_err() {
        return Err((
            StatusCode::BAD_REQUEST,
            Json(serde_json::json!({ "error": "无效的文章ID" })),
        ));
    }

    match blog_service.delete_post(&id).await {
        // 直接使用 &id
        Ok(_) => Ok(Json(serde_json::json!({ "message": "文章删除成功" }))),
        Err(e) => {
            error!("删除博客文章失败: {}", e);
            Err((
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({ "error": "删除博客文章失败" })),
            ))
        }
    }
}

// 管理员API - 获取所有文章（包括草稿）
#[instrument(skip(state))]
pub async fn get_all_blog_posts_admin(
    State(state): State<AppState>,
    Query(params): Query<BlogQuery>,
) -> Result<Json<Vec<BlogPostResponse>>, (StatusCode, Json<serde_json::Value>)> {
    let blog_service = services::blog::BlogService::new(state.db.clone());
    let page = params.page.unwrap_or(1);
    let page_size = params.page_size.unwrap_or(20);

    match blog_service.get_all_posts(page, page_size).await {
        Ok(posts) => {
            let responses: Vec<BlogPostResponse> = posts
                .into_iter()
                .map(|post| BlogPostResponse {
                    id: post.id,
                    title: post.title,
                    slug: post.slug,
                    content: post.content,
                    excerpt: post.excerpt,
                    cover_image: post.cover_image,
                    category: post.category,
                    tags: post
                        .tags
                        .and_then(|t| serde_json::from_str(&t).ok())
                        .unwrap_or_default(),
                    status: post.status,
                    view_count: post.view_count,
                    is_featured: post.is_featured != 0,
                    created_at: post.created_at.to_rfc3339(),
                    updated_at: post.updated_at.to_rfc3339(),
                    published_at: post.published_at.map(|dt| dt.to_rfc3339()),
                })
                .collect();

            Ok(Json(responses))
        }
        Err(e) => {
            error!("获取所有博客文章失败: {}", e);
            Err((
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({ "error": "获取所有博客文章失败" })),
            ))
        }
    }
}
