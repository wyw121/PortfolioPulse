//! DTO 转换层
//! 
//! 集中管理所有 Model → Response 的转换逻辑,避免在service层手动构造

use crate::models::{
    ActivityResponse, BlogPost, BlogPostResponse, Commit, CommitResponse, GitActivity, Project,
    ProjectResponse,
};

/// DTO 转换: Project -> ProjectResponse
impl From<Project> for ProjectResponse {
    fn from(project: Project) -> Self {
        ProjectResponse {
            id: project.id.to_string(),
            name: project.name,
            description: project.description.unwrap_or_default(),
            html_url: project.html_url,
            homepage: project.homepage,
            language: project.language.unwrap_or_else(|| "Unknown".to_string()),
            stargazers_count: project.stargazers_count,
            forks_count: project.forks_count,
            topics: project
                .topics
                .and_then(|t| serde_json::from_str(&t).ok())
                .unwrap_or_default(),
            updated_at: project.updated_at.to_rfc3339(),
        }
    }
}

/// DTO 转换: GitActivity -> ActivityResponse
impl From<GitActivity> for ActivityResponse {
    fn from(activity: GitActivity) -> Self {
        ActivityResponse {
            date: activity.date.format("%Y-%m-%d").to_string(),
            commits: activity.commits,
            additions: activity.additions,
            deletions: activity.deletions,
        }
    }
}

/// DTO 转换: Commit -> CommitResponse
/// 注意: repository字段需要额外提供,这里使用默认值
impl From<Commit> for CommitResponse {
    fn from(commit: Commit) -> Self {
        CommitResponse {
            sha: commit.sha,
            message: commit.message,
            author: commit.author,
            date: commit.date.to_rfc3339(),
            repository: String::new(), // 需要从project_id查询,暂时留空
        }
    }
}

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
