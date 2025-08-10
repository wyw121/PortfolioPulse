use sqlx::MySqlPool;
use anyhow::Result;
use chrono::{Utc, Duration};

use crate::models::ActivityResponse;

pub async fn get_recent_activity(pool: &MySqlPool, days: i32) -> Result<Vec<ActivityResponse>> {
    // 模拟数据，实际应从数据库查询
    let mock_activities = vec![
        ActivityResponse {
            date: "2024-01-15".to_string(),
            commits: 5,
            additions: 150,
            deletions: 32,
        },
        ActivityResponse {
            date: "2024-01-14".to_string(),
            commits: 3,
            additions: 89,
            deletions: 15,
        },
        ActivityResponse {
            date: "2024-01-13".to_string(),
            commits: 8,
            additions: 234,
            deletions: 67,
        },
        ActivityResponse {
            date: "2024-01-12".to_string(),
            commits: 2,
            additions: 45,
            deletions: 8,
        },
        ActivityResponse {
            date: "2024-01-11".to_string(),
            commits: 6,
            additions: 178,
            deletions: 43,
        },
        ActivityResponse {
            date: "2024-01-10".to_string(),
            commits: 4,
            additions: 112,
            deletions: 28,
        },
        ActivityResponse {
            date: "2024-01-09".to_string(),
            commits: 1,
            additions: 23,
            deletions: 5,
        },
    ];

    // 根据请求的天数筛选数据
    let limited_activities: Vec<ActivityResponse> = mock_activities
        .into_iter()
        .take(days as usize)
        .collect();

    Ok(limited_activities)
}

pub async fn record_daily_activity(
    pool: &MySqlPool,
    project_id: uuid::Uuid,
    date: chrono::DateTime<Utc>,
    commits: i32,
    additions: i32,
    deletions: i32,
) -> Result<()> {
    // 实际实现应该插入或更新数据库中的活动记录
    // 这里使用 INSERT ... ON DUPLICATE KEY UPDATE 或类似的 upsert 操作

    /*
    sqlx::query!(
        r#"
        INSERT INTO git_activities (id, project_id, date, commits, additions, deletions, created_at)
        VALUES (?, ?, DATE(?), ?, ?, ?, NOW())
        ON DUPLICATE KEY UPDATE
            commits = VALUES(commits),
            additions = VALUES(additions),
            deletions = VALUES(deletions)
        "#,
        uuid::Uuid::new_v4(),
        project_id,
        date,
        commits,
        additions,
        deletions
    )
    .execute(pool)
    .await?;
    */

    Ok(())
}
