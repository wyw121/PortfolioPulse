//! Blog 领域模型
//! 
//! 用于 Markdown 方案的博客数据结构

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

/// 博客文章模型 (Markdown 方案)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BlogPost {
    pub id: String,
    pub title: String,
    pub slug: String,
    pub content: String,
    pub excerpt: Option<String>,
    pub cover_image: Option<String>,
    pub category: Option<String>,
    pub tags: Option<String>, // CSV 格式字符串
    pub status: String,
    pub view_count: i32,
    pub is_featured: i8, // 0 or 1
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub published_at: Option<DateTime<Utc>>,
}

/// 博客文章API响应模型
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

/// 博客分类模型 (用于分类列表)
#[derive(Debug, Serialize, Deserialize)]
pub struct BlogCategory {
    pub name: String,
    pub slug: String,
    pub count: usize,
}

/// BlogPost → BlogPostResponse 转换
impl From<BlogPost> for BlogPostResponse {
    fn from(post: BlogPost) -> Self {
        BlogPostResponse {
            id: post.id,
            title: post.title,
            slug: post.slug,
            content: post.content,
            excerpt: post.excerpt,
            cover_image: post.cover_image,
            category: post.category,
            tags: post
                .tags
                .map(|t| t.split(',').map(|s| s.trim().to_string()).collect())
                .unwrap_or_default(),
            status: post.status,
            view_count: post.view_count,
            is_featured: post.is_featured != 0,
            created_at: post.created_at.to_rfc3339(),
            updated_at: post.updated_at.to_rfc3339(),
            published_at: post.published_at.map(|dt| dt.to_rfc3339()),
        }
    }
}
