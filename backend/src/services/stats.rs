use sqlx::MySqlPool;
use anyhow::Result;

use crate::models::{StatsResponse, LanguageStat};

pub async fn get_overall_stats(_pool: &MySqlPool) -> Result<StatsResponse> {
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

pub async fn get_project_stats(_pool: &MySqlPool, _project_id: uuid::Uuid) -> Result<StatsResponse> {
    // 实际实现应该查询特定项目的统计信息
    /*
    let project_stats = sqlx::query_as!(
        ProjectStats,
        r#"
        SELECT
            COUNT(*) as total_commits,
            SUM(additions) as total_additions,
            SUM(deletions) as total_deletions
        FROM commits
        WHERE project_id = ?
        "#,
        project_id
    )
    .fetch_one(pool)
    .await?;
    */

    // 模拟返回单个项目的统计数据
    let stats = StatsResponse {
        total_projects: 1,
        total_commits: 25,
        total_additions: 1200,
        total_deletions: 300,
        languages: vec![
            LanguageStat {
                name: "TypeScript".to_string(),
                count: 1,
                percentage: 100.0,
            }
        ],
    };

    Ok(stats)
}

#[allow(dead_code)]
struct ProjectStats {
    pub total_commits: Option<i64>,
    pub total_additions: Option<i64>,
    pub total_deletions: Option<i64>,
}
