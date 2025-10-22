//! Stats 服务层
//! 
//! 采用结构体封装 + 依赖注入模式

use sqlx::MySqlPool;
use anyhow::Result;
use uuid::Uuid;

use crate::models::{StatsResponse, LanguageStat};

/// 统计数据服务
pub struct StatsService {
    #[allow(dead_code)]
    pool: MySqlPool,
}

impl StatsService {
    /// 创建新的统计服务实例
    pub fn new(pool: MySqlPool) -> Self {
        Self { pool }
    }

    /// 获取整体统计数据
    pub async fn get_overall(&self) -> Result<StatsResponse> {
        // 模拟数据，实际应从数据库聚合查询
        let language_stats = vec![
            LanguageStat {
                name: "TypeScript".to_string(),
                count: 5,
                percentage: 35.7,
            },
            LanguageStat {
                name: "Rust".to_string(),
                count: 3,
                percentage: 21.4,
            },
            LanguageStat {
                name: "Python".to_string(),
                count: 3,
                percentage: 21.4,
            },
            LanguageStat {
                name: "JavaScript".to_string(),
                count: 2,
                percentage: 14.3,
            },
            LanguageStat {
                name: "Go".to_string(),
                count: 1,
                percentage: 7.1,
            },
        ];

        let stats = StatsResponse {
            total_projects: 14,
            total_commits: 342,
            total_additions: 15420,
            total_deletions: 3240,
            languages: language_stats,
        };

        Ok(stats)
    }

    /// 获取特定项目的统计数据
    #[allow(dead_code)]
    pub async fn get_project_stats(&self, _project_id: Uuid) -> Result<StatsResponse> {
        // 占位符实现
        self.get_overall().await
    }
}
