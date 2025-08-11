use crate::models::*;
use anyhow::Result;
use chrono::Utc;
use sqlx::MySqlPool;
use uuid::Uuid;

pub struct BlogService {
    db: MySqlPool,
}

impl BlogService {
    pub fn new(db: MySqlPool) -> Self {
        Self { db }
    }

    // 获取所有已发布的博客文章（分页）
    pub async fn get_published_posts(&self, page: u32, page_size: u32) -> Result<Vec<BlogPost>> {
        let offset = (page - 1) * page_size;

        let rows = sqlx::query!(
            r#"
            SELECT id, title, slug, content, excerpt, cover_image, category, tags,
                   status, view_count, is_featured, created_at, updated_at, published_at
            FROM blog_posts
            WHERE status = 'published'
            ORDER BY published_at DESC, created_at DESC
            LIMIT ? OFFSET ?
            "#,
            page_size,
            offset
        )
        .fetch_all(&self.db)
        .await?;

        let posts = rows.into_iter().map(|row| BlogPost {
            id: row.id,
            title: row.title,
            slug: row.slug,
            content: row.content,
            excerpt: row.excerpt,
            cover_image: row.cover_image,
            category: row.category,
            tags: row.tags,
            status: row.status,
            view_count: row.view_count,
            is_featured: row.is_featured,
            created_at: row.created_at,
            updated_at: row.updated_at,
            published_at: row.published_at,
        }).collect();

        Ok(posts)
    }

    // 根据slug获取博客文章
    pub async fn get_post_by_slug(&self, slug: &str) -> Result<Option<BlogPost>> {
        let row = sqlx::query!(
            r#"
            SELECT id, title, slug, content, excerpt, cover_image, category, tags,
                   status, view_count, is_featured, created_at, updated_at, published_at
            FROM blog_posts
            WHERE slug = ? AND status = 'published'
            "#,
            slug
        )
        .fetch_optional(&self.db)
        .await?;

        let post = row.map(|row| BlogPost {
            id: row.id,
            title: row.title,
            slug: row.slug,
            content: row.content,
            excerpt: row.excerpt,
            cover_image: row.cover_image,
            category: row.category,
            tags: row.tags,
            status: row.status,
            view_count: row.view_count,
            is_featured: row.is_featured,
            created_at: row.created_at,
            updated_at: row.updated_at,
            published_at: row.published_at,
        });

        Ok(post)
    }

    // 获取特色文章
    pub async fn get_featured_posts(&self, limit: u32) -> Result<Vec<BlogPost>> {
        let rows = sqlx::query!(
            r#"
            SELECT id, title, slug, content, excerpt, cover_image, category, tags,
                   status, view_count, is_featured, created_at, updated_at, published_at
            FROM blog_posts
            WHERE status = 'published' AND is_featured = 1
            ORDER BY published_at DESC, created_at DESC
            LIMIT ?
            "#,
            limit
        )
        .fetch_all(&self.db)
        .await?;

        let posts = rows.into_iter().map(|row| BlogPost {
            id: row.id,
            title: row.title,
            slug: row.slug,
            content: row.content,
            excerpt: row.excerpt,
            cover_image: row.cover_image,
            category: row.category,
            tags: row.tags,
            status: row.status,
            view_count: row.view_count,
            is_featured: row.is_featured,
            created_at: row.created_at,
            updated_at: row.updated_at,
            published_at: row.published_at,
        }).collect();

        Ok(posts)
    }

    // 获取所有分类
    pub async fn get_all_categories(&self) -> Result<Vec<BlogCategory>> {
        // 返回空列表，先让编译通过
        Ok(vec![])
    }

    // 根据分类获取文章
    pub async fn get_posts_by_category(&self, category: &str, page: u32, page_size: u32) -> Result<Vec<BlogPost>> {
        // 返回空列表，先让编译通过
        Ok(vec![])
    }

    // 搜索文章
    pub async fn search_posts(&self, query: &str, page: u32, page_size: u32) -> Result<Vec<BlogPost>> {
        // 返回空列表，先让编译通过
        Ok(vec![])
    }

    // 创建文章 (管理员功能)
    pub async fn create_post(&self, req: CreateBlogPostRequest) -> Result<BlogPost> {
        // 返回错误，先让编译通过
        anyhow::bail!("功能暂未实现")
    }

    // 更新文章 (管理员功能)
    pub async fn update_post(&self, id: &str, req: UpdateBlogPostRequest) -> Result<BlogPost> {
        // 返回错误，先让编译通过
        anyhow::bail!("功能暂未实现")
    }

    // 删除文章 (管理员功能)
    pub async fn delete_post(&self, id: &str) -> Result<()> {
        // 返回错误，先让编译通过
        anyhow::bail!("功能暂未实现")
    }

    // 管理员获取所有文章
    pub async fn get_all_posts(&self, page: u32, page_size: u32) -> Result<Vec<BlogPost>> {
        // 返回空列表，先让编译通过
        Ok(vec![])
    }
}
