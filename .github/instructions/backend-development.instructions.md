------

applyTo: "backend/**/*,src/**/*.rs,Cargo.toml"applyTo: "backend/**/*,src/**/*.rs,Cargo.toml,diesel.toml,migrations/**/*"

------



# 后端开发指引 - Rust Axum 纯 API 服务# 后端开发指引 - Rust + MySQL + GitHub 集成



## 项目定位## Rust 开发规范



本项目后端是**无数据库的纯 API 服务**,主要功能:### 代码组织

- 提供静态 API 端点

- GitHub API 数据转发- 使用模块化结构组织代码

- 简单的数据聚合和格式化- API 路由按功能分组

- CORS 跨域支持- 数据模型定义在 `models/` 模块

- 数据库操作封装在 `repositories/` 模块

**不包含**:- 服务逻辑放在 `services/` 模块

- ❌ 数据库连接 (无 MySQL/PostgreSQL/SQLite)

- ❌ ORM (无 Diesel/SQLx)### 异步编程

- ❌ 数据持久化

- ❌ 用户认证系统- 使用 `tokio` 运行时进行异步编程

- API 处理函数使用 `async fn`

## Rust 开发规范- 数据库操作使用异步连接池

- 错误处理使用 `Result<T, E>` 类型

### 代码组织

### 错误处理

```

backend/src/```rust

├── main.rs          # 主入口,路由配置// 自定义错误类型

├── handlers.rs      # API 处理器函数use thiserror::Error;

└── models.rs        # 数据结构定义

```#[derive(Error, Debug)]

pub enum AppError {

**模块划分原则**:    #[error("Database error: {0}")]

- `main.rs`: 应用初始化、路由注册、服务器启动    Database(#[from] diesel::result::Error),

- `handlers.rs`: API 端点处理逻辑

- `models.rs`: 请求/响应数据结构    #[error("GitHub API error: {0}")]

    GitHubApi(String),

### 异步编程

    #[error("Authentication error: {0}")]

使用 Tokio 异步运行时:    Auth(String),



```rust    #[error("Validation error: {0}")]

#[tokio::main]    Validation(String),

async fn main() -> Result<(), anyhow::Error> {}

    // 初始化日志```

    tracing_subscriber::fmt::init();

## 数据库设计

    // 构建应用

    let app = Router::new()### MySQL 最佳实践

        .route("/api/health", get(health_check))

        .layer(CorsLayer::permissive());- 使用 Diesel ORM 进行数据库操作

- 所有表必须有 `created_at` 和 `updated_at` 字段

    // 启动服务器- 使用 UUID 作为主键

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8000").await?;- 外键关系明确定义

    axum::serve(listener, app).await?;- 建立适当索引优化查询

    Ok(())

}### 核心数据模型

```

#### 用户访问管理

### 错误处理

```rust

简单错误处理模式:#[derive(Queryable, Insertable, Serialize, Deserialize)]

#[diesel(table_name = friend_access)]

```rustpub struct FriendAccess {

use axum::{    pub id: Uuid,

    response::{IntoResponse, Response},    pub token: String,

    http::StatusCode,    pub nickname: String,

    Json,    pub permissions: Vec<String>, // JSON 存储

};    pub created_at: NaiveDateTime,

    pub last_access: Option<NaiveDateTime>,

#[derive(Debug)]    pub is_active: bool,

pub enum AppError {    pub trust_score: i32,

    InternalError(String),}

    NotFound(String),

    BadRequest(String),#[derive(Queryable, Insertable, Serialize, Deserialize)]

}#[diesel(table_name = device_fingerprints)]

pub struct DeviceFingerprint {

impl IntoResponse for AppError {    pub id: Uuid,

    fn into_response(self) -> Response {    pub fingerprint_hash: String,

        let (status, message) = match self {    pub user_agent: String,

            AppError::NotFound(msg) => (StatusCode::NOT_FOUND, msg),    pub screen_resolution: String,

            AppError::BadRequest(msg) => (StatusCode::BAD_REQUEST, msg),    pub timezone: String,

            AppError::InternalError(msg) => (StatusCode::INTERNAL_SERVER_ERROR, msg),    pub language: String,

        };    pub platform: String,

    pub created_at: NaiveDateTime,

        (status, Json(json!({ "error": message }))).into_response()    pub last_seen: NaiveDateTime,

    }    pub visit_count: i32,

}}

``````



## API 端点实现#### GitHub 数据模型



### 基础 API 模式```rust

#[derive(Queryable, Insertable, Serialize, Deserialize)]

```rust#[diesel(table_name = github_repos)]

use axum::{pub struct GitHubRepo {

    extract::{Path, State},    pub id: Uuid,

    Json,    pub github_id: i64,

};    pub name: String,

    pub description: Option<String>,

// 健康检查    pub html_url: String,

pub async fn health_check() -> Json<serde_json::Value> {    pub language: Option<String>,

    Json(json!({    pub stars_count: i32,

        "status": "ok",    pub forks_count: i32,

        "service": "PortfolioPulse Backend"    pub is_private: bool,

    }))    pub is_featured: bool,

}    pub last_sync: NaiveDateTime,

    pub created_at: NaiveDateTime,

// 获取项目列表    pub updated_at: NaiveDateTime,

pub async fn get_projects() -> Json<Vec<Project>> {}

    Json(get_mock_projects())

}#[derive(Queryable, Insertable, Serialize, Deserialize)]

```#[diesel(table_name = github_commits)]

pub struct GitHubCommit {

### GitHub API 代理    pub id: Uuid,

    pub repo_id: Uuid,

```rust    pub sha: String,

pub async fn get_recent_commits(    pub message: String,

    State(state): State<AppState>    pub author_name: String,

) -> Result<Json<Vec<GitHubCommit>>, AppError> {    pub author_email: String,

    let url = "https://api.github.com/repos/owner/repo/commits";    pub commit_date: NaiveDateTime,

    pub additions: i32,

    let response = state.http_client    pub deletions: i32,

        .get(url)    pub files_changed: i32,

        .header("User-Agent", "PortfolioPulse/1.0")    pub created_at: NaiveDateTime,

        .send()}

        .await?;```



    let commits = response.json().await?;#### 学习记录模型

    Ok(Json(commits))

}```rust

```#[derive(Queryable, Insertable, Serialize, Deserialize)]

#[diesel(table_name = learning_records)]

## 环境配置pub struct LearningRecord {

    pub id: Uuid,

```env    pub title: String,

# GitHub API Token (可选)    pub content: String, // Markdown 内容

GITHUB_TOKEN=    pub category: String,

    pub tags: Vec<String>, // JSON 存储

# 服务器配置    pub progress: i32, // 0-100

SERVER_HOST=0.0.0.0    pub is_completed: bool,

SERVER_PORT=8000    pub created_at: NaiveDateTime,

    pub updated_at: NaiveDateTime,

# 日志级别}

RUST_LOG=info```

```

## GitHub API 集成

## 开发工作流

### API 客户端实现

```bash

# 开发运行```rust

cargo runuse reqwest::Client;

use serde_json::Value;

# 代码检查

cargo clippypub struct GitHubClient {

    client: Client,

# 格式化    token: String,

cargo fmt    base_url: String,

}

# 测试

cargo testimpl GitHubClient {

    pub fn new(token: String) -> Self {

# 生产构建        Self {

cargo build --release            client: Client::new(),

```            token,

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
