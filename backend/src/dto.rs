use crate::models::{BlogPost, BlogPostResponse};

/// DTO 转换: BlogPost -> BlogPostResponse
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
                .and_then(|t| {
                    // 如果 tags 是 JSON 格式字符串,尝试解析
                    if t.starts_with('[') {
                        serde_json::from_str(&t).ok()
                    } else {
                        // 否则按逗号分割
                        Some(
                            t.split(',')
                                .map(|s| s.trim().to_string())
                                .filter(|s| !s.is_empty())
                                .collect(),
                        )
                    }
                })
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
