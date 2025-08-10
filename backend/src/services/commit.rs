use sqlx::MySqlPool;
use anyhow::Result;

use crate::models::CommitResponse;

pub async fn get_recent_commits(pool: &MySqlPool, limit: i32) -> Result<Vec<CommitResponse>> {
    // 模拟数据，实际应从数据库查询
    let mock_commits = vec![
        CommitResponse {
            sha: "a1b2c3d".to_string(),
            message: "添加项目动态展示功能".to_string(),
            author: "Developer".to_string(),
            date: "2024-01-15T10:30:00Z".to_string(),
            repository: "PortfolioPulse".to_string(),
        },
        CommitResponse {
            sha: "e4f5g6h".to_string(),
            message: "优化数据库查询性能".to_string(),
            author: "Developer".to_string(),
            date: "2024-01-15T09:15:00Z".to_string(),
            repository: "WebAPI-Framework".to_string(),
        },
        CommitResponse {
            sha: "i7j8k9l".to_string(),
            message: "修复响应式布局问题".to_string(),
            author: "Developer".to_string(),
            date: "2024-01-14T16:45:00Z".to_string(),
            repository: "PortfolioPulse".to_string(),
        },
        CommitResponse {
            sha: "m0n1o2p".to_string(),
            message: "添加新的图表类型支持".to_string(),
            author: "Developer".to_string(),
            date: "2024-01-14T14:20:00Z".to_string(),
            repository: "DataViz-Tools".to_string(),
        },
        CommitResponse {
            sha: "q3r4s5t".to_string(),
            message: "更新API文档".to_string(),
            author: "Developer".to_string(),
            date: "2024-01-13T11:30:00Z".to_string(),
            repository: "WebAPI-Framework".to_string(),
        },
    ];

    // 根据limit参数限制返回数量
    let limited_commits: Vec<CommitResponse> = mock_commits
        .into_iter()
        .take(limit as usize)
        .collect();

    Ok(limited_commits)
}

pub async fn save_commit(
    pool: &MySqlPool,
    project_id: uuid::Uuid,
    github_commit: &crate::models::GitHubCommit,
) -> Result<()> {
    // 实际实现应该将提交数据保存到数据库
    /*
    let commit_id = uuid::Uuid::new_v4();
    let commit_date = chrono::DateTime::parse_from_rfc3339(&github_commit.commit.author.date)?;

    sqlx::query!(
        r#"
        INSERT INTO commits (id, project_id, sha, message, author, author_email, date, additions, deletions, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
        ON DUPLICATE KEY UPDATE
            message = VALUES(message),
            author = VALUES(author),
            author_email = VALUES(author_email),
            additions = VALUES(additions),
            deletions = VALUES(deletions)
        "#,
        commit_id,
        project_id,
        github_commit.sha,
        github_commit.commit.message,
        github_commit.commit.author.name,
        github_commit.commit.author.email,
        commit_date.naive_utc(),
        github_commit.stats.as_ref().map(|s| s.additions).unwrap_or(0),
        github_commit.stats.as_ref().map(|s| s.deletions).unwrap_or(0)
    )
    .execute(pool)
    .await?;
    */

    Ok(())
}
