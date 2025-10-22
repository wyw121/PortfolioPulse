//! Blog 领域模型
//! 
//! 包含博客相关的数据库实体、API响应模型和请求模型

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;

/// 博客文章数据库实体
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct BlogPost {
    pub id: String,                          // CHAR(36) -> String
    pub title: String,                       // NOT NULL
    pub slug: String,                        // NOT NULL
    pub content: String,                     // NOT NULL
    pub excerpt: Option<String>,             // TEXT -> Option<String>
    pub cover_image: Option<String>,         // VARCHAR -> Option<String>
    pub category: Option<String>,            // VARCHAR -> Option<String>
    pub tags: Option<String>,                // JSON -> Option<String> (作为JSON字符串)
    pub status: String,                      // ENUM NOT NULL
    pub view_count: i32,                     // NOT NULL DEFAULT 0
    pub is_featured: i8,                     // BOOLEAN (MySQL TINYINT)
    pub created_at: DateTime<Utc>,           // NOT NULL
    pub updated_at: DateTime<Utc>,           // NOT NULL
    pub published_at: Option<DateTime<Utc>>, // TIMESTAMP NULL -> Option<DateTime<Utc>>
}

/// 博客分类数据库实体
#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct BlogCategory {
    pub id: String, // CHAR(36) -> String
    pub name: String,
    pub slug: String,
    pub description: Option<String>, // TEXT -> Option<String>
    pub color: String,
    pub post_count: i32,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
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
