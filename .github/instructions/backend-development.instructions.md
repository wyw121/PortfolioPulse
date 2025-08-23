---
applyTo: "backend/**/*,src/**/*.rs,Cargo.toml,diesel.toml,migrations/**/*"
---

# 后端开发指引 - Rust Axum 全栈服务器

## 🎯 重构后架构 (2025-08-23)

**当前状态**: 统一 Rust 部署，整合静态文件服务 ✅  
**端口**: 8000 (同时服务 API 和前端静态文件)  
**框架**: Axum + tower-http + diesel + MySQL

### 📁 目录结构

```
backend/
├── src/
│   ├── main.rs           # 主服务器，含静态文件服务
│   ├── handlers.rs       # API 路由处理器
│   ├── models.rs         # 数据模型
│   ├── auth.rs          # 认证中间件
│   └── services/        # 业务逻辑服务
├── static/              # 前端构建输出目录 (新增)
│   ├── index.html       # SPA 入口文件
│   └── assets/          # JS/CSS/图片资源
├── migrations/          # 数据库迁移文件
├── Cargo.toml          # Rust 依赖配置
└── diesel.toml         # Diesel ORM 配置
```

### 🚀 静态文件服务 (新增核心功能)

```rust
use tower_http::services::{ServeDir, ServeFile};

// 主要路由配置
let app = Router::new()
    .nest("/api", api_routes())
    .nest_service("/", 
        ServeDir::new("static")
            .not_found_service(ServeFile::new("static/index.html"))
    );
```

**重要**: 所有 API 端点必须使用 `/api/` 前缀！

## Rust 开发规范

### 代码组织

- 使用模块化结构组织代码
- API 路由按功能分组，使用 `/api/` 前缀
- 数据模型定义在 `models/` 模块
- 数据库操作封装在 `repositories/` 模块
- 服务逻辑放在 `services/` 模块

### 异步编程

- 使用 `tokio` 运行时进行异步编程
- API 处理函数使用 `async fn`
- 数据库操作使用异步连接池
- 错误处理使用 `Result<T, E>` 类型

### 错误处理

```rust
// 自定义错误类型
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("Database error: {0}")]
    Database(#[from] diesel::result::Error),

    #[error("GitHub API error: {0}")]
    GitHubApi(String),

    #[error("Authentication error: {0}")]
    Auth(String),

    #[error("Validation error: {0}")]
    Validation(String),
}
```

## 数据库设计

### MySQL 最佳实践

- 使用 Diesel ORM 进行数据库操作
- 所有表必须有 `created_at` 和 `updated_at` 字段
- 使用 UUID 作为主键
- 外键关系明确定义
- 建立适当索引优化查询

### 核心数据模型

#### 用户访问管理

```rust
#[derive(Queryable, Insertable, Serialize, Deserialize)]
#[diesel(table_name = friend_access)]
pub struct FriendAccess {
    pub id: Uuid,
    pub token: String,
    pub nickname: String,
    pub permissions: Vec<String>, // JSON 存储
    pub created_at: NaiveDateTime,
    pub last_access: Option<NaiveDateTime>,
    pub is_active: bool,
    pub trust_score: i32,
}

#[derive(Queryable, Insertable, Serialize, Deserialize)]
#[diesel(table_name = device_fingerprints)]
pub struct DeviceFingerprint {
    pub id: Uuid,
    pub fingerprint_hash: String,
    pub user_agent: String,
    pub screen_resolution: String,
    pub timezone: String,
    pub language: String,
    pub platform: String,
    pub created_at: NaiveDateTime,
    pub last_seen: NaiveDateTime,
    pub visit_count: i32,
}
```

#### GitHub 数据模型

```rust
#[derive(Queryable, Insertable, Serialize, Deserialize)]
#[diesel(table_name = github_repos)]
pub struct GitHubRepo {
    pub id: Uuid,
    pub github_id: i64,
    pub name: String,
    pub description: Option<String>,
    pub html_url: String,
    pub language: Option<String>,
    pub stars_count: i32,
    pub forks_count: i32,
    pub is_private: bool,
    pub is_featured: bool,
    pub last_sync: NaiveDateTime,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

#[derive(Queryable, Insertable, Serialize, Deserialize)]
#[diesel(table_name = github_commits)]
pub struct GitHubCommit {
    pub id: Uuid,
    pub repo_id: Uuid,
    pub sha: String,
    pub message: String,
    pub author_name: String,
    pub author_email: String,
    pub commit_date: NaiveDateTime,
    pub additions: i32,
    pub deletions: i32,
    pub files_changed: i32,
    pub created_at: NaiveDateTime,
}
```

#### 学习记录模型

```rust
#[derive(Queryable, Insertable, Serialize, Deserialize)]
#[diesel(table_name = learning_records)]
pub struct LearningRecord {
    pub id: Uuid,
    pub title: String,
    pub content: String, // Markdown 内容
    pub category: String,
    pub tags: Vec<String>, // JSON 存储
    pub progress: i32, // 0-100
    pub is_completed: bool,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}
```

## GitHub API 集成

### API 客户端实现

```rust
use reqwest::Client;
use serde_json::Value;

pub struct GitHubClient {
    client: Client,
    token: String,
    base_url: String,
}

impl GitHubClient {
    pub fn new(token: String) -> Self {
        Self {
            client: Client::new(),
            token,
            base_url: "https://api.github.com".to_string(),
        }
    }

    pub async fn get_user_repos(&self, username: &str) -> Result<Vec<Value>, AppError> {
        let url = format!("{}/users/{}/repos", self.base_url, username);
        let response = self.client
            .get(&url)
            .header("Authorization", format!("token {}", self.token))
            .header("User-Agent", "PortfolioPulse/1.0")
            .send()
            .await?;

        let repos: Vec<Value> = response.json().await?;
        Ok(repos)
    }

    pub async fn get_repo_commits(&self, owner: &str, repo: &str) -> Result<Vec<Value>, AppError> {
        let url = format!("{}/repos/{}/{}/commits", self.base_url, owner, repo);
        let response = self.client
            .get(&url)
            .header("Authorization", format!("token {}", self.token))
            .header("User-Agent", "PortfolioPulse/1.0")
            .send()
            .await?;

        let commits: Vec<Value> = response.json().await?;
        Ok(commits)
    }
}
```

### 数据同步服务

```rust
pub struct GitHubSyncService {
    github_client: GitHubClient,
    db_pool: DbPool,
}

impl GitHubSyncService {
    pub async fn sync_all_data(&self) -> Result<(), AppError> {
        // 1. 同步仓库信息
        self.sync_repositories().await?;

        // 2. 同步提交记录
        self.sync_commits().await?;

        // 3. 更新统计数据
        self.update_statistics().await?;

        Ok(())
    }

    pub async fn sync_repositories(&self) -> Result<(), AppError> {
        let repos = self.github_client.get_user_repos("username").await?;

        for repo_data in repos {
            let repo = GitHubRepo {
                // 解析 GitHub API 数据到本地模型
            };

            // 插入或更新数据库
            self.upsert_repository(repo).await?;
        }

        Ok(())
    }
}
```

## API 设计

### REST API 结构

```rust
use actix_web::{web, HttpResponse, Result};

// API 响应统一格式
#[derive(Serialize)]
pub struct ApiResponse<T> {
    pub success: bool,
    pub data: Option<T>,
    pub message: Option<String>,
    pub error: Option<String>,
}

// 项目数据 API
pub async fn get_projects(
    _req: HttpRequest,
    db_pool: web::Data<DbPool>,
) -> Result<HttpResponse> {
    let conn = db_pool.get().map_err(|_| AppError::Database)?;

    let projects = projects::table
        .filter(projects::is_active.eq(true))
        .order(projects::created_at.desc())
        .load::<Project>(&conn)
        .map_err(AppError::Database)?;

    Ok(HttpResponse::Ok().json(ApiResponse {
        success: true,
        data: Some(projects),
        message: None,
        error: None,
    }))
}

// GitHub 数据 API
pub async fn get_github_activity(
    _req: HttpRequest,
    db_pool: web::Data<DbPool>,
) -> Result<HttpResponse> {
    let conn = db_pool.get().map_err(|_| AppError::Database)?;

    let recent_commits = github_commits::table
        .order(github_commits::commit_date.desc())
        .limit(20)
        .load::<GitHubCommit>(&conn)
        .map_err(AppError::Database)?;

    Ok(HttpResponse::Ok().json(ApiResponse {
        success: true,
        data: Some(recent_commits),
        message: None,
        error: None,
    }))
}
```

### 认证中间件

```rust
use actix_web::{dev::ServiceRequest, Error, HttpMessage};
use actix_web_httpauth::extractors::bearer::BearerAuth;

pub async fn jwt_validator(
    req: ServiceRequest,
    credentials: BearerAuth,
) -> Result<ServiceRequest, Error> {
    let token = credentials.token();

    // 验证 JWT 令牌
    match validate_jwt_token(token) {
        Ok(claims) => {
            req.extensions_mut().insert(claims);
            Ok(req)
        }
        Err(_) => Err(AuthError::InvalidToken.into()),
    }
}
```

## 性能和安全

### 数据库优化

- 使用连接池管理数据库连接
- 实施查询缓存策略
- 定期分析和优化慢查询
- 使用事务确保数据一致性

### 安全措施

- API 端点实施 Rate Limiting
- 输入验证和清理
- SQL 注入防护（Diesel ORM 提供）
- CORS 配置
- 敏感数据加密存储

### 监控和日志

```rust
use tracing::{info, error, instrument};

#[instrument]
pub async fn handle_request(&self, req: Request) -> Result<Response, AppError> {
    info!("Processing request: {:?}", req);

    match self.process_request(req).await {
        Ok(response) => {
            info!("Request processed successfully");
            Ok(response)
        }
        Err(err) => {
            error!("Request processing failed: {:?}", err);
            Err(err)
        }
    }
}
```

- 表名和字段使用 snake_case 命名
- 所有表包含 `id`, `created_at`, `updated_at` 字段
- 使用索引优化查询性能

### 迁移管理

- 使用 `diesel migration` 管理数据库变更
- 迁移文件包含 up 和 down 脚本
- 数据结构变更需要向后兼容

## API 设计

### RESTful API 规范

- 使用标准 HTTP 状态码
- API 响应使用 JSON 格式
- 支持分页和过滤参数
- 实现适当的 CORS 配置

### 安全措施

- 输入参数验证和清理
- SQL 注入防护
- JWT 令牌认证
- 敏感数据加密存储
