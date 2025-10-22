use crate::models::*;
use anyhow::{Context, Result};
use chrono::{DateTime, Utc};
use pulldown_cmark::{html, Parser};
use std::fs;
use std::path::PathBuf;
use yaml_rust::YamlLoader;

pub struct MarkdownBlogService {
    content_dir: PathBuf,
}

impl MarkdownBlogService {
    pub fn new() -> Self {
        // 博客内容目录: backend/content/blog/
        let content_dir = PathBuf::from("content/blog");
        Self { content_dir }
    }

    /// 解析 Markdown 文件的 frontmatter 和正文
    fn parse_markdown(content: &str) -> Result<(BlogMetadata, String)> {
        // 规范化换行符为 \n (处理 Windows \r\n)
        let content = content.replace("\r\n", "\n");
        
        // 检查是否有 frontmatter (以 --- 开头和结尾)
        if !content.starts_with("---\n") {
            anyhow::bail!("Missing frontmatter");
        }

        // 提取 frontmatter
        let parts: Vec<&str> = content.splitn(3, "---\n").collect();
        if parts.len() < 3 {
            anyhow::bail!("Invalid frontmatter format");
        }

        let frontmatter = parts[1];
        let markdown_body = parts[2];

        // 解析 YAML frontmatter
        let yaml = YamlLoader::load_from_str(frontmatter)
            .context("Failed to parse YAML frontmatter")?;
        let doc = &yaml[0];

        // 提取字段
        let title = doc["title"]
            .as_str()
            .context("Missing title")?
            .to_string();
        let description = doc["description"].as_str().unwrap_or("").to_string();
        let pub_date_str = doc["pubDate"]
            .as_str()
            .context("Missing pubDate")?
            .to_string();

        // 解析日期
        let published_at = DateTime::parse_from_rfc3339(&format!("{}T00:00:00Z", pub_date_str))
            .context("Invalid date format")?
            .with_timezone(&Utc);

        // 提取标签
        let tags = if let Some(tags_yaml) = doc["tags"].as_vec() {
            tags_yaml
                .iter()
                .filter_map(|t| t.as_str().map(|s| s.to_string()))
                .collect::<Vec<_>>()
                .join(",")
        } else {
            String::new()
        };

        let metadata = BlogMetadata {
            title,
            description,
            published_at,
            tags,
        };

        // 将 Markdown 转换为 HTML
        let parser = Parser::new(markdown_body);
        let mut html_output = String::new();
        html::push_html(&mut html_output, parser);

        Ok((metadata, html_output))
    }

    /// 获取所有已发布的博客文章（分页）
    pub async fn get_published_posts(&self, page: u32, page_size: u32) -> Result<Vec<BlogPost>> {
        let mut posts = Vec::new();

        // 读取 content/blog/ 目录下的所有 .md 文件
        let entries = fs::read_dir(&self.content_dir)
            .context("Failed to read content directory")?;

        for entry in entries {
            let entry = entry?;
            let path = entry.path();

            // 只处理 .md 文件
            if path.extension().and_then(|s| s.to_str()) == Some("md") {
                let content = fs::read_to_string(&path)
                    .context(format!("Failed to read {:?}", path))?;

                match Self::parse_markdown(&content) {
                    Ok((metadata, html_content)) => {
                        // 从文件名提取 slug (去掉 .md 扩展名)
                        let slug = path
                            .file_stem()
                            .and_then(|s| s.to_str())
                            .unwrap_or("unknown")
                            .to_string();

                        posts.push(BlogPost {
                            id: slug.clone(), // 使用 slug 作为 ID
                            title: metadata.title,
                            slug,
                            content: html_content.clone(),
                            excerpt: Some(metadata.description.clone()),
                            cover_image: None,
                            category: None,
                            tags: Some(metadata.tags),
                            status: "published".to_string(),
                            view_count: 0,
                            is_featured: 0,
                            created_at: metadata.published_at,
                            updated_at: metadata.published_at,
                            published_at: Some(metadata.published_at),
                        });
                    }
                    Err(e) => {
                        eprintln!("Failed to parse {:?}: {}", path, e);
                        continue;
                    }
                }
            }
        }

        // 按发布日期降序排序
        posts.sort_by(|a, b| {
            b.published_at
                .unwrap_or_else(Utc::now)
                .cmp(&a.published_at.unwrap_or_else(Utc::now))
        });

        // 实现分页
        let start = ((page - 1) * page_size) as usize;
        let end = (start + page_size as usize).min(posts.len());

        Ok(posts[start..end].to_vec())
    }

    /// 根据 slug 获取博客文章
    pub async fn get_post_by_slug(&self, slug: &str) -> Result<Option<BlogPost>> {
        let file_path = self.content_dir.join(format!("{}.md", slug));

        if !file_path.exists() {
            return Ok(None);
        }

        let content = fs::read_to_string(&file_path)
            .context(format!("Failed to read {:?}", file_path))?;

        let (metadata, html_content) = Self::parse_markdown(&content)?;

        Ok(Some(BlogPost {
            id: slug.to_string(),
            title: metadata.title,
            slug: slug.to_string(),
            content: html_content,
            excerpt: Some(metadata.description),
            cover_image: None,
            category: None,
            tags: Some(metadata.tags),
            status: "published".to_string(),
            view_count: 0,
            is_featured: 0,
            created_at: metadata.published_at,
            updated_at: metadata.published_at,
            published_at: Some(metadata.published_at),
        }))
    }

    /// 获取特色文章（暂时返回最新的几篇）
    pub async fn get_featured_posts(&self, limit: u32) -> Result<Vec<BlogPost>> {
        self.get_published_posts(1, limit).await
    }
}

/// Frontmatter 元数据
struct BlogMetadata {
    title: String,
    description: String,
    published_at: DateTime<Utc>,
    tags: String,
}
