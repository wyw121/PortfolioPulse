use reqwest::Client;
use anyhow::{Result, anyhow};

use crate::models::{GitHubRepo, GitHubCommit};

pub struct GitHubClient {
    client: Client,
    token: String,
}

impl GitHubClient {
    pub fn new(token: String) -> Self {
        Self {
            client: Client::new(),
            token,
        }
    }

    pub async fn get_user_repos(&self, username: &str) -> Result<Vec<GitHubRepo>> {
        let url = format!("https://api.github.com/users/{}/repos?per_page=100&sort=updated", username);

        let response = self
            .client
            .get(&url)
            .header("Authorization", format!("Bearer {}", self.token))
            .header("User-Agent", "PortfolioPulse/1.0")
            .send()
            .await?;

        if !response.status().is_success() {
            return Err(anyhow!("GitHub API 请求失败: {}", response.status()));
        }

        let repos: Vec<GitHubRepo> = response.json().await?;
        Ok(repos)
    }

    pub async fn get_repo_commits(&self, owner: &str, repo: &str, per_page: u32) -> Result<Vec<GitHubCommit>> {
        let url = format!(
            "https://api.github.com/repos/{}/{}/commits?per_page={}",
            owner, repo, per_page
        );

        let response = self
            .client
            .get(&url)
            .header("Authorization", format!("Bearer {}", self.token))
            .header("User-Agent", "PortfolioPulse/1.0")
            .send()
            .await?;

        if !response.status().is_success() {
            return Err(anyhow!("GitHub API 请求失败: {}", response.status()));
        }

        let commits: Vec<GitHubCommit> = response.json().await?;
        Ok(commits)
    }

    pub async fn get_commit_stats(&self, owner: &str, repo: &str, sha: &str) -> Result<GitHubCommit> {
        let url = format!("https://api.github.com/repos/{}/{}/commits/{}", owner, repo, sha);

        let response = self
            .client
            .get(&url)
            .header("Authorization", format!("Bearer {}", self.token))
            .header("User-Agent", "PortfolioPulse/1.0")
            .send()
            .await?;

        if !response.status().is_success() {
            return Err(anyhow!("GitHub API 请求失败: {}", response.status()));
        }

        let commit: GitHubCommit = response.json().await?;
        Ok(commit)
    }
}

// 同步 GitHub 数据到本地数据库
pub async fn sync_github_data(
    pool: &sqlx::MySqlPool,
    github_client: &GitHubClient,
    username: &str,
) -> Result<()> {
    let repos = github_client.get_user_repos(username).await?;
    let project_service = crate::services::project::ProjectService::new(pool.clone());
    let commit_service = crate::services::commit::CommitService::new(pool.clone());

    for repo in repos {
        if repo.full_name.starts_with(&format!("{}/", username)) {
            continue;
        }

        let _project = project_service.create_or_update(&repo).await?;

        let parts: Vec<&str> = repo.full_name.split('/').collect();
        if parts.len() == 2 {
            let owner = parts[0];
            let repo_name = parts[1];

            match github_client.get_repo_commits(owner, repo_name, 10).await {
                Ok(commits) => {
                    for commit in commits {
                        let _ = commit_service.save(_project.id, &commit).await;
                    }
                }
                Err(e) => {
                    tracing::warn!("获取 {} 仓库提交失败: {}", repo.full_name, e);
                }
            }
        }
    }

    Ok(())
}
