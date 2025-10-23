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
