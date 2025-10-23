//! Stats 服务层
//! 
//! 采用结构体封装 + 依赖注入模式

use anyhow::Result;

use crate::models::{StatsResponse, LanguageStat};

/// 统计数据服务
pub struct StatsService;

impl StatsService {
    /// 创建新的统计服务实例
    pub fn new() -> Self {
        Self
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


}
