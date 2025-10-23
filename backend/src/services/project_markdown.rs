use crate::models::*;
use crate::services::traits::ProjectService;
use anyhow::{Context, Result};
use async_trait::async_trait;
use chrono::{DateTime, NaiveDate, Utc};
use pulldown_cmark::{html, Parser};
use std::fs;
use std::path::PathBuf;
use yaml_rust::YamlLoader;

pub struct MarkdownProjectService {
    content_dir: PathBuf,
}

impl MarkdownProjectService {
    pub fn new() -> Self {
        // 项目内容目录: backend/content/projects/
        let content_dir = PathBuf::from("content/projects");
        Self { content_dir }
    }

    /// 解析 Markdown 文件的 frontmatter 和正文
    fn parse_markdown(content: &str) -> Result<(ProjectMetadata, String)> {
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

        // 提取必填字段
        let name = doc["name"]
            .as_str()
            .context("Missing name")?
            .to_string();
        
        let description = doc["description"]
            .as_str()
            .unwrap_or("")
            .to_string();
        
        let url = doc["url"]
            .as_str()
            .context("Missing url")?
            .to_string();
        
        let language = doc["language"]
            .as_str()
            .unwrap_or("Unknown")
            .to_string();

        // 提取可选字段
        let homepage = doc["homepage"].as_str().map(|s| s.to_string());
        let stars = doc["stars"].as_i64().unwrap_or(0) as i32;
        let forks = doc["forks"].as_i64().unwrap_or(0) as i32;
        let featured = doc["featured"].as_bool().unwrap_or(false);
        let status = doc["status"].as_str().unwrap_or("active").to_string();

        // 提取 topics 数组
        let topics = if let Some(topics_yaml) = doc["topics"].as_vec() {
            topics_yaml
                .iter()
                .filter_map(|t| t.as_str().map(|s| s.to_string()))
                .collect::<Vec<_>>()
        } else {
            Vec::new()
        };

        // 解析日期 (YYYY-MM-DD 格式)
        let created_at_str = doc["createdAt"]
            .as_str()
            .context("Missing createdAt")?;
        let updated_at_str = doc["updatedAt"]
            .as_str()
            .context("Missing updatedAt")?;

        let created_at = NaiveDate::parse_from_str(created_at_str, "%Y-%m-%d")
            .context("Invalid createdAt format")?
            .and_hms_opt(0, 0, 0)
            .unwrap()
            .and_utc();

        let updated_at = NaiveDate::parse_from_str(updated_at_str, "%Y-%m-%d")
            .context("Invalid updatedAt format")?
            .and_hms_opt(0, 0, 0)
            .unwrap()
            .and_utc();

        let metadata = ProjectMetadata {
            name,
            description,
            url,
            homepage,
            language,
            stars,
            forks,
            topics,
            status,
            featured,
            created_at,
            updated_at,
        };

        // 将 Markdown 转换为 HTML
        let parser = Parser::new(markdown_body);
        let mut html_output = String::new();
        html::push_html(&mut html_output, parser);

        Ok((metadata, html_output))
    }

    /// 获取所有项目列表
    pub async fn get_all_projects(&self) -> Result<Vec<ProjectResponse>> {
        let mut projects = Vec::new();

        // 读取 content/projects/ 目录下的所有 .md 文件
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
                        // 从文件名提取 slug
                        let slug = path
                            .file_stem()
                            .and_then(|s| s.to_str())
                            .unwrap_or("unknown")
                            .to_string();

                        projects.push(ProjectResponse {
                            id: slug.clone(),
                            name: metadata.name,
                            description: if metadata.description.is_empty() {
                                html_content.chars().take(200).collect()
                            } else {
                                metadata.description
                            },
                            html_url: metadata.url,
                            homepage: metadata.homepage,
                            language: metadata.language,
                            stargazers_count: metadata.stars,
                            forks_count: metadata.forks,
                            topics: metadata.topics,
                            updated_at: metadata.updated_at.to_rfc3339(),
                        });
                    }
                    Err(e) => {
                        eprintln!("Failed to parse {:?}: {}", path, e);
                        continue;
                    }
                }
            }
        }

        // 按更新日期降序排序
        projects.sort_by(|a, b| b.updated_at.cmp(&a.updated_at));

        Ok(projects)
    }

    /// 根据 slug 获取项目详情
    pub async fn get_project_by_slug(&self, slug: &str) -> Result<Option<ProjectResponse>> {
        let file_path = self.content_dir.join(format!("{}.md", slug));

        if !file_path.exists() {
            return Ok(None);
        }

        let content = fs::read_to_string(&file_path)
            .context(format!("Failed to read {:?}", file_path))?;

        let (metadata, html_content) = Self::parse_markdown(&content)?;

        Ok(Some(ProjectResponse {
            id: slug.to_string(),
            name: metadata.name,
            description: if metadata.description.is_empty() {
                html_content.chars().take(200).collect()
            } else {
                metadata.description
            },
            html_url: metadata.url,
            homepage: metadata.homepage,
            language: metadata.language,
            stargazers_count: metadata.stars,
            forks_count: metadata.forks,
            topics: metadata.topics,
            updated_at: metadata.updated_at.to_rfc3339(),
        }))
    }

    /// 获取特色项目
    pub async fn get_featured_projects(&self) -> Result<Vec<ProjectResponse>> {
        let all_projects = self.get_all_projects().await?;
        
        // 这里可以基于 frontmatter 中的 featured 字段过滤
        // 暂时返回前3个
        Ok(all_projects.into_iter().take(3).collect())
    }
}

/// Frontmatter 元数据
struct ProjectMetadata {
    name: String,
    description: String,
    url: String,
    homepage: Option<String>,
    language: String,
    stars: i32,
    forks: i32,
    topics: Vec<String>,
    status: String,
    featured: bool,
    created_at: DateTime<Utc>,
    updated_at: DateTime<Utc>,
}

// ============= Trait 实现 =============

#[async_trait]
impl ProjectService for MarkdownProjectService {
    async fn get_all_projects(&self) -> Result<Vec<ProjectResponse>> {
        self.get_all_projects().await
    }
    
    async fn get_project_by_slug(&self, slug: &str) -> Result<Option<ProjectResponse>> {
        self.get_project_by_slug(slug).await
    }
    
    async fn get_featured_projects(&self) -> Result<Vec<ProjectResponse>> {
        self.get_featured_projects().await
    }
}
