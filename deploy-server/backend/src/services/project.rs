use sqlx::MySqlPool;
use uuid::Uuid;
use chrono::Utc;
use anyhow::Result;

use crate::models::*;

pub async fn get_all_projects(_pool: &MySqlPool) -> Result<Vec<ProjectResponse>> {
    // 模拟数据，实际应从数据库查询
    let mock_projects = vec![
        ProjectResponse {
            id: Uuid::new_v4().to_string(),
            name: "PortfolioPulse".to_string(),
            description: "现代化的个人项目展示和动态追踪平台".to_string(),
            html_url: "https://github.com/user/PortfolioPulse".to_string(),
            homepage: Some("https://portfoliopulse.dev".to_string()),
            language: "TypeScript".to_string(),
            stargazers_count: 42,
            forks_count: 8,
            topics: vec!["nextjs".to_string(), "react".to_string(), "typescript".to_string(), "portfolio".to_string()],
            updated_at: "2024-01-15T10:30:00Z".to_string(),
        },
        ProjectResponse {
            id: Uuid::new_v4().to_string(),
            name: "WebAPI-Framework".to_string(),
            description: "基于 Rust 的高性能 Web API 框架".to_string(),
            html_url: "https://github.com/user/webapi-framework".to_string(),
            homepage: None,
            language: "Rust".to_string(),
            stargazers_count: 128,
            forks_count: 23,
            topics: vec!["rust".to_string(), "webapi".to_string(), "performance".to_string(), "framework".to_string()],
            updated_at: "2024-01-10T14:20:00Z".to_string(),
        },
        ProjectResponse {
            id: Uuid::new_v4().to_string(),
            name: "DataViz-Tools".to_string(),
            description: "交互式数据可视化工具集".to_string(),
            html_url: "https://github.com/user/dataviz-tools".to_string(),
            homepage: Some("https://dataviz-tools.demo.com".to_string()),
            language: "Python".to_string(),
            stargazers_count: 67,
            forks_count: 15,
            topics: vec!["python".to_string(), "visualization".to_string(), "data-analysis".to_string(), "charts".to_string()],
            updated_at: "2024-01-08T09:15:00Z".to_string(),
        },
    ];

    Ok(mock_projects)
}

pub async fn get_project_by_id(_pool: &MySqlPool, id: Uuid) -> Result<Option<ProjectResponse>> {
    // 模拟数据查询
    let projects = get_all_projects(_pool).await?;
    Ok(projects.into_iter().find(|p| p.id == id.to_string()))
}

pub async fn create_or_update_project(
    _pool: &MySqlPool,
    github_repo: &GitHubRepo
) -> Result<Project> {
    let project_id = Uuid::new_v4();
    let now = Utc::now();

    // 实际实现应该检查项目是否已存在，然后决定创建或更新
    let project = Project {
        id: project_id,
        name: github_repo.name.clone(),
        description: github_repo.description.clone(),
        html_url: github_repo.html_url.clone(),
        homepage: github_repo.homepage.clone(),
        language: github_repo.language.clone(),
        stargazers_count: github_repo.stargazers_count,
        forks_count: github_repo.forks_count,
        topics: Some(serde_json::to_string(&github_repo.topics)?),
        is_active: true,
        created_at: now,
        updated_at: now,
    };

    // 这里应该执行实际的数据库插入/更新操作
    // sqlx::query!(...)

    Ok(project)
}
