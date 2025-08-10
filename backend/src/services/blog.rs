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
        
        let posts = sqlx::query_as!(
            BlogPost,
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

        Ok(posts)
    }

    // 根据slug获取博客文章
    pub async fn get_post_by_slug(&self, slug: &str) -> Result<Option<BlogPost>> {
        let post = sqlx::query_as!(
            BlogPost,
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

        // 增加浏览次数
        if post.is_some() {
            sqlx::query!(
                "UPDATE blog_posts SET view_count = view_count + 1 WHERE slug = ?",
                slug
            )
            .execute(&self.db)
            .await?;
        }

        Ok(post)
    }

    // 获取精选文章
    pub async fn get_featured_posts(&self, limit: u32) -> Result<Vec<BlogPost>> {
        let posts = sqlx::query_as!(
            BlogPost,
            r#"
            SELECT id, title, slug, content, excerpt, cover_image, category, tags, 
                   status, view_count, is_featured, created_at, updated_at, published_at
            FROM blog_posts 
            WHERE status = 'published' AND is_featured = true
            ORDER BY published_at DESC, created_at DESC
            LIMIT ?
            "#,
            limit
        )
        .fetch_all(&self.db)
        .await?;

        Ok(posts)
    }

    // 按分类获取文章
    pub async fn get_posts_by_category(&self, category: &str, page: u32, page_size: u32) -> Result<Vec<BlogPost>> {
        let offset = (page - 1) * page_size;
        
        let posts = sqlx::query_as!(
            BlogPost,
            r#"
            SELECT id, title, slug, content, excerpt, cover_image, category, tags, 
                   status, view_count, is_featured, created_at, updated_at, published_at
            FROM blog_posts 
            WHERE status = 'published' AND category = ?
            ORDER BY published_at DESC, created_at DESC
            LIMIT ? OFFSET ?
            "#,
            category,
            page_size,
            offset
        )
        .fetch_all(&self.db)
        .await?;

        Ok(posts)
    }

    // 获取所有分类
    pub async fn get_categories(&self) -> Result<Vec<BlogCategory>> {
        let categories = sqlx::query_as!(
            BlogCategory,
            r#"
            SELECT id, name, slug, description, color, post_count, created_at, updated_at
            FROM blog_categories 
            ORDER BY name
            "#
        )
        .fetch_all(&self.db)
        .await?;

        Ok(categories)
    }

    // 搜索文章
    pub async fn search_posts(&self, query: &str, page: u32, page_size: u32) -> Result<Vec<BlogPost>> {
        let offset = (page - 1) * page_size;
        let search_term = format!("%{}%", query);
        
        let posts = sqlx::query_as!(
            BlogPost,
            r#"
            SELECT id, title, slug, content, excerpt, cover_image, category, tags, 
                   status, view_count, is_featured, created_at, updated_at, published_at
            FROM blog_posts 
            WHERE status = 'published' 
            AND (title LIKE ? OR content LIKE ? OR excerpt LIKE ?)
            ORDER BY published_at DESC, created_at DESC
            LIMIT ? OFFSET ?
            "#,
            search_term,
            search_term,
            search_term,
            page_size,
            offset
        )
        .fetch_all(&self.db)
        .await?;

        Ok(posts)
    }

    // 管理员功能 - 创建文章
    pub async fn create_post(&self, req: CreateBlogPostRequest) -> Result<BlogPost> {
        let id = Uuid::new_v4();
        let slug = self.generate_slug(&req.title).await?;
        let tags_json = req.tags
            .as_ref()
            .map(|tags| serde_json::to_string(tags).unwrap_or_default());
        
        let now = Utc::now();
        let published_at = if req.status.as_deref() == Some("published") {
            Some(now)
        } else {
            None
        };

        sqlx::query!(
            r#"
            INSERT INTO blog_posts 
            (id, title, slug, content, excerpt, category, tags, status, is_featured, cover_image, published_at, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            "#,
            id,
            req.title,
            slug,
            req.content,
            req.excerpt,
            req.category,
            tags_json,
            req.status.as_deref().unwrap_or("draft"),
            req.is_featured.unwrap_or(false),
            req.cover_image,
            published_at,
            now,
            now
        )
        .execute(&self.db)
        .await?;

        // 更新分类文章计数
        if let Some(category) = &req.category {
            self.update_category_count(category).await?;
        }

        self.get_post_by_id(id).await?.ok_or_else(|| anyhow::anyhow!("Failed to create post"))
    }

    // 管理员功能 - 更新文章
    pub async fn update_post(&self, id: Uuid, req: UpdateBlogPostRequest) -> Result<BlogPost> {
        let mut query_parts = Vec::new();
        let mut params: Vec<Box<dyn sqlx::Encode<'_, sqlx::MySql> + Send>> = Vec::new();

        if let Some(title) = &req.title {
            query_parts.push("title = ?");
            params.push(Box::new(title.clone()));
        }

        if let Some(content) = &req.content {
            query_parts.push("content = ?");
            params.push(Box::new(content.clone()));
        }

        if let Some(excerpt) = &req.excerpt {
            query_parts.push("excerpt = ?");
            params.push(Box::new(excerpt.clone()));
        }

        if let Some(category) = &req.category {
            query_parts.push("category = ?");
            params.push(Box::new(category.clone()));
        }

        if let Some(tags) = &req.tags {
            let tags_json = serde_json::to_string(tags).unwrap_or_default();
            query_parts.push("tags = ?");
            params.push(Box::new(tags_json));
        }

        if let Some(status) = &req.status {
            query_parts.push("status = ?");
            params.push(Box::new(status.clone()));
            
            // 如果状态改为published，设置published_at
            if status == "published" {
                query_parts.push("published_at = ?");
                params.push(Box::new(Utc::now()));
            }
        }

        if let Some(is_featured) = req.is_featured {
            query_parts.push("is_featured = ?");
            params.push(Box::new(is_featured));
        }

        if let Some(cover_image) = &req.cover_image {
            query_parts.push("cover_image = ?");
            params.push(Box::new(cover_image.clone()));
        }

        if query_parts.is_empty() {
            return self.get_post_by_id(id).await?.ok_or_else(|| anyhow::anyhow!("Post not found"));
        }

        query_parts.push("updated_at = ?");
        params.push(Box::new(Utc::now()));

        // 这里需要手动构建查询，因为sqlx的动态查询比较复杂
        // 为简化起见，我们使用固定的更新逻辑
        
        let now = Utc::now();
        sqlx::query!(
            r#"UPDATE blog_posts SET 
               title = COALESCE(?, title),
               content = COALESCE(?, content),
               excerpt = COALESCE(?, excerpt),
               category = COALESCE(?, category),
               status = COALESCE(?, status),
               is_featured = COALESCE(?, is_featured),
               cover_image = COALESCE(?, cover_image),
               updated_at = ?
               WHERE id = ?"#,
            req.title,
            req.content,
            req.excerpt,
            req.category,
            req.status,
            req.is_featured,
            req.cover_image,
            now,
            id
        )
        .execute(&self.db)
        .await?;

        self.get_post_by_id(id).await?.ok_or_else(|| anyhow::anyhow!("Post not found"))
    }

    // 管理员功能 - 删除文章
    pub async fn delete_post(&self, id: Uuid) -> Result<()> {
        sqlx::query!("DELETE FROM blog_posts WHERE id = ?", id)
            .execute(&self.db)
            .await?;
        
        Ok(())
    }

    // 管理员功能 - 获取所有文章（包括草稿）
    pub async fn get_all_posts(&self, page: u32, page_size: u32) -> Result<Vec<BlogPost>> {
        let offset = (page - 1) * page_size;
        
        let posts = sqlx::query_as!(
            BlogPost,
            r#"
            SELECT id, title, slug, content, excerpt, cover_image, category, tags, 
                   status, view_count, is_featured, created_at, updated_at, published_at
            FROM blog_posts 
            ORDER BY updated_at DESC
            LIMIT ? OFFSET ?
            "#,
            page_size,
            offset
        )
        .fetch_all(&self.db)
        .await?;

        Ok(posts)
    }

    // 私有辅助方法
    async fn get_post_by_id(&self, id: Uuid) -> Result<Option<BlogPost>> {
        let post = sqlx::query_as!(
            BlogPost,
            r#"
            SELECT id, title, slug, content, excerpt, cover_image, category, tags, 
                   status, view_count, is_featured, created_at, updated_at, published_at
            FROM blog_posts 
            WHERE id = ?
            "#,
            id
        )
        .fetch_optional(&self.db)
        .await?;

        Ok(post)
    }

    async fn generate_slug(&self, title: &str) -> Result<String> {
        let base_slug = title
            .to_lowercase()
            .chars()
            .filter(|c| c.is_alphanumeric() || c.is_whitespace() || *c == '-')
            .collect::<String>()
            .split_whitespace()
            .collect::<Vec<_>>()
            .join("-");

        // 检查slug是否已存在
        let mut slug = base_slug.clone();
        let mut counter = 1;

        while self.slug_exists(&slug).await? {
            slug = format!("{}-{}", base_slug, counter);
            counter += 1;
        }

        Ok(slug)
    }

    async fn slug_exists(&self, slug: &str) -> Result<bool> {
        let count: (i64,) = sqlx::query_as(
            "SELECT COUNT(*) FROM blog_posts WHERE slug = ?"
        )
        .bind(slug)
        .fetch_one(&self.db)
        .await?;

        Ok(count.0 > 0)
    }

    async fn update_category_count(&self, category: &str) -> Result<()> {
        sqlx::query!(
            r#"UPDATE blog_categories 
               SET post_count = (
                   SELECT COUNT(*) FROM blog_posts 
                   WHERE category = ? AND status = 'published'
               )
               WHERE slug = ?"#,
            category,
            category
        )
        .execute(&self.db)
        .await?;

        Ok(())
    }
}
