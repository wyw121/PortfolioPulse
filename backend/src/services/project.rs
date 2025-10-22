//! Project 服务层
//! 
//! 采用结构体封装 + 依赖注入模式,支持测试mock

use anyhow::Result;
use chrono::Utc;
use sqlx::MySqlPool;
use uuid::Uuid;

use crate::models::{GitHubRepo, Project, ProjectResponse};

/// 项目服务 - 统一的Service结构体模式
pub struct ProjectService {
    #[allow(dead_code)]
    pool: MySqlPool,
}

impl ProjectService {
    /// 创建新的项目服务实例
    pub fn new(pool: MySqlPool) -> Self {
        Self { pool }
    }

    /// 获取所有项目列表
    pub async fn get_all(&self) -> Result<Vec<ProjectResponse>> {
        let now = Utc::now();
        
        // 模拟数据 - 创建Project实体,然后通过DTO转换为Response
        let projects: Vec<Project> = vec![
            Project {
                id: Uuid::new_v4(),
                name: "AI Web Generator".to_string(),
                description: Some("基于DALL-E 3的智能网页图像生成器，集成前端星空动画和后端Rust服务，支持实时文生图功能。采用Actix-Web框架和OpenAI API，提供流畅的用户交互体验。".to_string()),
                html_url: "https://github.com/wyw121/ai_web_generator".to_string(),
                homepage: Some("https://demo.ai-generator.com".to_string()),
                language: Some("Rust".to_string()),
                stargazers_count: 15,
                forks_count: 3,
                topics: Some(serde_json::to_string(&vec!["rust", "actix-web", "openai-api", "dall-e", "javascript", "html5-canvas"])?),
                is_active: true,
                created_at: now,
                updated_at: now,
            },
            Project {
                id: Uuid::new_v4(),
                name: "QuantConsole".to_string(),
                description: Some("专业级加密货币短线交易控制台，支持多交易所实时数据、价格监控预警、技术指标分析。集成Binance和OKX API，提供永续合约交易、用户认证和风险管理功能。".to_string()),
                html_url: "https://github.com/wyw121/QuantConsole".to_string(),
                homepage: Some("https://demo.quantconsole.com".to_string()),
                language: Some("TypeScript".to_string()),
                stargazers_count: 45,
                forks_count: 12,
                topics: Some(serde_json::to_string(&vec!["react", "typescript", "rust", "cryptocurrency", "trading", "binance-api", "mysql", "redis"])?),
                is_active: true,
                created_at: now,
                updated_at: now,
            },
            Project {
                id: Uuid::new_v4(),
                name: "SmartCare Cloud".to_string(),
                description: Some("智慧医养大数据公共服务平台，实现医养结合的数字化服务。包含老人档案管理、健康监测预警、医疗设备管理和大数据分析，支持多角色权限控制。".to_string()),
                html_url: "https://github.com/wyw121/SmartCare_Cloud".to_string(),
                homepage: Some("https://demo.smartcare-cloud.com".to_string()),
                language: Some("Java".to_string()),
                stargazers_count: 32,
                forks_count: 8,
                topics: Some(serde_json::to_string(&vec!["vue", "element-plus", "spring-boot", "mybatis-plus", "mysql", "healthcare", "big-data"])?),
                is_active: true,
                created_at: now,
                updated_at: now,
            },
        ];

        // 使用DTO转换: Project -> ProjectResponse
        Ok(projects.into_iter().map(Into::into).collect())
    }

    /// 根据ID获取单个项目
    pub async fn get_by_id(&self, id: Uuid) -> Result<Option<ProjectResponse>> {
        let projects = self.get_all().await?;
        Ok(projects.into_iter().find(|p| p.id == id.to_string()))
    }

    /// 创建或更新项目(从GitHub同步)
    #[allow(dead_code)]
    pub async fn create_or_update(&self, github_repo: &GitHubRepo) -> Result<Project> {
        let project_id = Uuid::new_v4();
        let now = Utc::now();

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

        Ok(project)
    }
}
