# PortfolioPulse 软件体系架构深度剖析

> **文档版本**: v1.0  
> **创建日期**: 2025-10-21  
> **作者**: GitHub Copilot AI Assistant  
> **适用读者**: 项目开发者、架构师、技术学习者

---

## 📋 目录

1. [架构概览](#架构概览)
2. [核心架构模式](#核心架构模式)
3. [详细分层结构](#详细分层结构)
4. [数据流分析](#数据流分析)
5. [横切关注点](#横切关注点)
6. [架构模式总结](#架构模式总结)
7. [实战案例](#实战案例)
8. [架构评估](#架构评估)
9. [改进建议](#改进建议)

---

## 🎯 架构概览

### 核心定位

PortfolioPulse 采用 **分层架构（Layered Architecture）** 作为主架构模式，结合了 **领域驱动设计（DDD）** 的元素，实现了一个现代化的全栈 Web 应用。

### 技术栈

| 层级 | 技术选型 | 版本 |
|------|---------|------|
| **前端框架** | React | 18.2 |
| **构建工具** | Vite | 5.4 |
| **路由** | React Router | 6.20 |
| **UI 库** | shadcn/ui + Radix UI | 最新 |
| **状态管理** | Zustand | 4.4 |
| **样式** | Tailwind CSS | 3.x |
| **后端框架** | Axum (Rust) | 0.7 |
| **数据库 ORM** | SQLx | 0.7 |
| **数据库** | MySQL | 8.0+ |
| **HTTP 客户端** | Axios (前端) / Reqwest (后端) | 最新 |

### 部署模式

```
统一 Rust 单体部署模式:
- 前端: Vite 构建 → backend/static/
- 后端: Rust 编译 → 单一二进制文件
- 端口: 8000 (API + 静态文件服务)
- 进程: 单一进程，低内存占用
```

---

## 🏛️ 核心架构模式

### 整体架构图

```
┌─────────────────────────────────────────────────────────────┐
│                    展示层 (Presentation)                      │
│              React Components + React Router                 │
│  HomePage.tsx, ProjectsPage.tsx, Layout.tsx, api.ts         │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTP/JSON
                       ↓
┌─────────────────────────────────────────────────────────────┐
│                    应用层 (Application)                       │
│                   Axum Handlers + Middleware                 │
│         handlers.rs, auth.rs (跨层关注点)                    │
└──────────────────────┬──────────────────────────────────────┘
                       │ Function Calls
                       ↓
┌─────────────────────────────────────────────────────────────┐
│                  业务逻辑层 (Business Logic)                  │
│                      Services Module                         │
│  project.rs, blog.rs, activity.rs, github.rs, stats.rs      │
└──────────────────────┬──────────────────────────────────────┘
                       │ Data Access
                       ↓
┌─────────────────────────────────────────────────────────────┐
│                  数据访问层 (Data Access)                     │
│                    SQLx + Models.rs                          │
│      Project, GitActivity, Commit (Domain Models)            │
└──────────────────────┬──────────────────────────────────────┘
                       │ SQL Queries
                       ↓
┌─────────────────────────────────────────────────────────────┐
│                    数据持久层 (Persistence)                   │
│                        MySQL Database                        │
└─────────────────────────────────────────────────────────────┘
```

### 架构特点

#### ✅ 优势

1. **清晰的职责分离**: 每层专注于特定功能
2. **技术栈独立**: 前后端完全解耦
3. **易于测试**: 各层可独立进行单元测试
4. **可扩展性**: 易于添加新功能模块
5. **类型安全**: TypeScript + Rust 全链路类型检查

#### ⚠️ 权衡

1. **性能开销**: 层级间调用有轻微开销
2. **学习曲线**: 需要理解多层结构
3. **代码量**: 相比单层应用代码量更大

---

## 📐 详细分层结构

### 第一层：展示层（Presentation Layer）

**位置**: `frontend-vite/src/`

#### 目录结构

```
frontend-vite/src/
├── main.tsx              # Vite 入口文件，React 应用启动点
├── App.tsx               # React Router 配置中心
├── components/           # 可复用 UI 组件
│   ├── Layout.tsx        # 全局布局容器
│   ├── Navigation.tsx    # 顶部导航栏
│   └── ProjectGrid.tsx   # 项目网格展示
├── pages/                # 页面级组件（路由端点）
│   ├── HomePage.tsx      # 首页 "/"
│   ├── ProjectsPage.tsx  # 项目列表 "/projects"
│   ├── BlogPage.tsx      # 博客 "/blog"
│   ├── AboutPage.tsx     # 关于页面 "/about"
│   └── ContactPage.tsx   # 联系页面 "/contact"
├── lib/
│   └── api.ts            # API 客户端（后端通信唯一入口）
├── hooks/                # 自定义 React Hooks
├── types/                # TypeScript 类型定义
└── styles/
    └── globals.css       # 全局样式 + Tailwind 配置
```

#### 核心职责

| 职责 | 描述 | 实现方式 |
|------|------|---------|
| **UI 渲染** | 将数据转换为用户界面 | React 函数组件 + JSX |
| **用户交互** | 处理点击、输入等事件 | 事件处理器 (onClick, onChange) |
| **客户端路由** | SPA 页面切换 | React Router 6 |
| **状态管理** | 组件间数据共享 | Zustand (轻量级状态库) |
| **API 调用** | 获取后端数据 | api.ts 封装的 fetch 请求 |
| **样式渲染** | 视觉呈现 | Tailwind CSS + shadcn/ui |

#### 关键代码示例

**App.tsx - 路由配置**
```typescript
import { Route, Routes } from "react-router-dom";
import Layout from "./components/Layout";

function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/projects" element={<ProjectsPage />} />
        <Route path="/blog" element={<BlogPage />} />
        {/* 其他路由... */}
      </Routes>
    </Layout>
  );
}
```

**api.ts - API 客户端抽象**
```typescript
const API_BASE_URL = import.meta.env.VITE_API_URL || "";

export async function getProjects(): Promise<Project[]> {
  const response = await fetch(`${API_BASE_URL}/api/projects`);
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  return response.json();
}
```

#### 设计模式

- **Facade 模式**: `api.ts` 作为后端 API 的统一入口
- **Container/Presenter**: `Layout.tsx` 容器组件包裹展示组件
- **Hooks 模式**: 自定义 Hooks 封装逻辑复用

---

### 第二层：应用层（Application Layer）

**位置**: `backend/src/handlers.rs`, `backend/src/auth.rs`, `backend/src/main.rs`

#### 核心职责

| 职责 | 描述 | 文件 |
|------|------|------|
| **路由映射** | URL → Handler 函数 | main.rs |
| **请求处理** | 解析 HTTP 请求，调用业务逻辑 | handlers.rs |
| **响应构建** | 业务结果 → JSON 响应 | handlers.rs |
| **错误转换** | 业务错误 → HTTP 状态码 | handlers.rs |
| **认证授权** | Token 验证，权限检查 | auth.rs |
| **中间件** | 日志、CORS、认证等横切关注点 | main.rs |

#### 关键代码示例

**handlers.rs - 请求处理器**
```rust
#[instrument(skip(state))]  // 自动日志追踪
pub async fn get_projects(
    State(state): State<AppState>,  // 依赖注入
) -> Result<Json<Vec<ProjectResponse>>, (StatusCode, Json<...>)> {
    // 1. 调用业务逻辑层
    match services::project::get_all_projects(&state.db).await {
        Ok(projects) => Ok(Json(projects)),  // 2. 成功响应
        Err(e) => {
            error!("获取项目列表失败: {}", e);
            Err((  // 3. 错误转换
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(json!({ "error": "获取项目列表失败" }))
            ))
        }
    }
}
```

**main.rs - 路由配置**
```rust
let api_routes = Router::new()
    // 公开 API
    .route("/health", get(health_check))
    .route("/projects", get(get_projects))
    .route("/projects/:id", get(get_project))
    
    // 管理员 API（需认证）
    .route("/admin/blog/posts", post(create_blog_post)
        .layer(middleware::from_fn_with_state(
            app_state.clone(),
            auth::admin_auth_middleware  // 认证中间件
        )))
    .with_state(app_state);
```

**auth.rs - 认证中间件**
```rust
pub async fn admin_auth_middleware(
    State(_state): State<AppState>,
    headers: HeaderMap,
    request: Request,
    next: Next,
) -> Result<Response, (StatusCode, Json<...>)> {
    // 1. 提取 Authorization 头
    if let Some(auth_header) = headers.get("authorization") {
        // 2. 验证 Bearer Token
        if auth_str.starts_with("Bearer ") {
            let token = &auth_str[7..];
            if token == admin_token {
                return Ok(next.run(request).await);  // 3. 通过验证
            }
        }
    }
    // 4. 验证失败
    Err((StatusCode::UNAUTHORIZED, Json(json!({"error": "未授权"}))))
}
```

#### 设计特点

1. **薄应用层**: 不包含业务逻辑，只做协调和转换
2. **依赖注入**: `State(state)` 注入共享资源（数据库连接池）
3. **错误链**: `anyhow::Error` → `(StatusCode, Json)`
4. **中间件栈**: 请求 → CORS → Auth → Handler → 响应

---

### 第三层：业务逻辑层（Business Logic Layer）

**位置**: `backend/src/services/`

#### 模块组织（垂直切片）

```
services/
├── mod.rs              # 模块导出
├── project.rs          # 项目管理业务逻辑
├── blog.rs             # 博客文章 CRUD
├── activity.rs         # 活动追踪统计
├── github.rs           # GitHub API 集成
├── commit.rs           # Git 提交记录处理
└── stats.rs            # 统计数据计算
```

#### 核心职责

| 职责 | 描述 | 示例 |
|------|------|------|
| **业务规则** | 核心业务逻辑实现 | 项目创建/更新规则 |
| **数据转换** | 外部模型 → 领域模型 | GitHubRepo → Project |
| **流程编排** | 协调多个操作 | 创建或更新项目 |
| **外部集成** | 第三方 API 调用 | GitHub API |
| **数据聚合** | 组合多个数据源 | 统计数据计算 |

#### 关键代码示例

**project.rs - 项目业务逻辑**
```rust
pub async fn get_all_projects(_pool: &MySqlPool) -> Result<Vec<ProjectResponse>> {
    // 业务逻辑：构建项目列表
    let projects = vec![
        ProjectResponse {
            id: Uuid::new_v4().to_string(),
            name: "AI Web Generator".to_string(),
            description: "基于DALL-E 3的智能网页图像生成器...".to_string(),
            // ... 其他字段
        },
        // 更多项目...
    ];
    Ok(projects)
}

pub async fn create_or_update_project(
    _pool: &MySqlPool,
    github_repo: &GitHubRepo,
) -> Result<Project> {
    // 业务逻辑：创建或更新判断
    // 1. 检查项目是否存在
    // 2. 存在则更新，不存在则创建
    // 3. 转换数据模型
    let project = Project {
        id: Uuid::new_v4(),
        name: github_repo.name.clone(),
        description: github_repo.description.clone(),
        // ... 数据转换
    };
    Ok(project)
}
```

**github.rs - 外部 API 集成**
```rust
pub async fn fetch_repositories(
    github_token: &str,
) -> Result<Vec<GitHubRepo>> {
    let client = reqwest::Client::new();
    let response = client
        .get("https://api.github.com/user/repos")
        .header("Authorization", format!("token {}", github_token))
        .send()
        .await?;
    
    let repos: Vec<GitHubRepo> = response.json().await?;
    Ok(repos)
}
```

#### 设计模式

- **Service 模式**: 每个模块封装一组相关业务功能
- **Facade 模式**: 对外提供简化的业务接口
- **Strategy 模式**: 不同的数据处理策略（如 GitHub 数据获取）

---

### 第四层：数据访问层（Data Access Layer）

**位置**: `backend/src/models.rs` + SQLx 查询

#### 核心职责

| 职责 | 描述 | 实现 |
|------|------|------|
| **领域建模** | 定义核心业务实体 | struct 定义 |
| **ORM 映射** | 数据库字段 ↔ Rust 结构体 | `#[derive(FromRow)]` |
| **DTO 定义** | API 响应数据结构 | Response structs |
| **查询执行** | SQL 查询封装 | SQLx macros |
| **类型转换** | 数据库类型 ↔ Rust 类型 | 自动转换 |

#### 关键代码示例

**models.rs - 领域模型**
```rust
// 领域模型（数据库映射）
#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct Project {
    pub id: Uuid,
    pub name: String,
    pub description: Option<String>,
    pub html_url: String,
    pub language: Option<String>,
    pub stargazers_count: i32,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

// DTO（API 响应）
#[derive(Debug, Serialize, Deserialize)]
pub struct ProjectResponse {
    pub id: String,
    pub name: String,
    pub description: String,
    pub topics: Vec<String>,  // 简化的数据结构
    pub updated_at: String,   // 格式化的日期
}

// 外部 API 模型
#[derive(Debug, Deserialize)]
pub struct GitHubRepo {
    pub name: String,
    pub description: Option<String>,
    pub html_url: String,
    pub stargazers_count: i32,
    // ... GitHub API 字段
}
```

#### 模型分类

```
models.rs
├── 领域模型 (Domain Models)
│   ├── Project           # 项目实体
│   ├── GitActivity       # 活动记录
│   ├── Commit            # 提交记录
│   └── BlogPost          # 博客文章
│
├── 响应 DTO (Response DTOs)
│   ├── ProjectResponse
│   ├── ActivityResponse
│   └── CommitResponse
│
└── 外部模型 (External Models)
    ├── GitHubRepo
    └── GitHubCommit
```

#### SQLx 查询示例

```rust
// 编译时验证的 SQL 查询
let projects = sqlx::query_as!(
    Project,
    r#"
    SELECT id, name, description, html_url, language,
           stargazers_count, created_at, updated_at
    FROM projects
    WHERE is_active = true
    ORDER BY updated_at DESC
    "#
)
.fetch_all(pool)
.await?;
```

---

### 第五层：数据持久层（Persistence Layer）

**位置**: MySQL 数据库 + `backend/migrations/`

#### 数据库迁移

```
migrations/
├── 001_initial.sql       # 初始表结构
├── 002_seed_data.sql     # 测试数据
└── 003_blog_tables.sql   # 博客表
```

#### 核心表结构

**projects 表**
```sql
CREATE TABLE projects (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    html_url VARCHAR(512) NOT NULL,
    homepage VARCHAR(512),
    language VARCHAR(100),
    stargazers_count INT DEFAULT 0,
    forks_count INT DEFAULT 0,
    topics TEXT,  -- JSON 字符串
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
               ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_updated_at (updated_at),
    INDEX idx_is_active (is_active)
);
```

**activity_logs 表**
```sql
CREATE TABLE activity_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    project_id VARCHAR(36),
    activity_type VARCHAR(50) NOT NULL,
    description TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id)
        ON DELETE CASCADE,
    INDEX idx_project_timestamp (project_id, timestamp)
);
```

**blog_posts 表**
```sql
CREATE TABLE blog_posts (
    id VARCHAR(36) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    excerpt TEXT,
    content LONGTEXT NOT NULL,
    published BOOLEAN DEFAULT FALSE,
    featured BOOLEAN DEFAULT FALSE,
    view_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
               ON UPDATE CURRENT_TIMESTAMP,
    published_at TIMESTAMP NULL,
    INDEX idx_published (published, published_at),
    INDEX idx_slug (slug)
);
```

#### 数据库设计原则

1. **主键**: 使用 UUID 确保分布式唯一性
2. **时间戳**: 自动维护创建和更新时间
3. **索引**: 为查询字段添加索引优化性能
4. **外键**: 维护引用完整性
5. **软删除**: `is_active` 字段实现软删除

---

## 🔄 数据流分析

### 完整请求流程：用户查看项目列表

让我们跟踪一个完整的 HTTP 请求从浏览器到数据库再返回的全过程：

```
步骤 1: 用户操作
┌─────────────────┐
│   用户浏览器     │
│  点击"项目"菜单  │
└────────┬────────┘
         │
步骤 2: 前端路由
         ↓
┌─────────────────────────┐
│   React Router          │
│  /projects → 渲染        │
│  <ProjectsPage />       │
└────────┬────────────────┘
         │
步骤 3: 组件渲染
         ↓
┌─────────────────────────────┐
│   ProjectsPage.tsx          │
│  useEffect(() => {          │
│    api.getProjects()        │
│  })                         │
└────────┬────────────────────┘
         │
步骤 4: API 调用
         ↓
┌──────────────────────────────┐
│   api.ts                     │
│  fetch("/api/projects")      │
│  → HTTP GET 请求             │
└────────┬─────────────────────┘
         │ HTTP/JSON
         │
步骤 5: 后端路由匹配
         ↓
┌──────────────────────────────┐
│   Axum Router (main.rs)      │
│  .route("/projects",         │
│         get(get_projects))   │
└────────┬─────────────────────┘
         │
步骤 6: 应用层处理
         ↓
┌────────────────────────────────────┐
│   handlers::get_projects()         │
│  1. 提取 State(state)              │
│  2. 调用业务层                     │
│  services::project::                │
│    get_all_projects(&state.db)     │
└────────┬───────────────────────────┘
         │
步骤 7: 业务逻辑层
         ↓
┌────────────────────────────────┐
│   services/project.rs          │
│  1. 执行业务逻辑               │
│  2. 可能查询数据库             │
│  sqlx::query_as!(...)          │
│    .fetch_all(pool)            │
└────────┬───────────────────────┘
         │ SQL
         │
步骤 8: 数据库查询
         ↓
┌──────────────────────────────┐
│   MySQL                      │
│  SELECT * FROM projects      │
│  WHERE is_active = true      │
│  → 返回行数据                │
└────────┬─────────────────────┘
         │
步骤 9: 数据映射
         ↓
┌──────────────────────────────┐
│   models::Project            │
│  FromRow trait 自动映射      │
│  数据库行 → Rust 结构体      │
└────────┬─────────────────────┘
         │
步骤 10: 业务层返回
         ↓
┌──────────────────────────────┐
│   services/project.rs        │
│  Project → ProjectResponse   │
│  (数据转换)                  │
│  Ok(Vec<ProjectResponse>)    │
└────────┬─────────────────────┘
         │
步骤 11: 应用层响应
         ↓
┌──────────────────────────────┐
│   handlers.rs                │
│  Ok(Json(projects))          │
│  → HTTP 200 + JSON body      │
└────────┬─────────────────────┘
         │ HTTP Response
         │
步骤 12: 前端接收
         ↓
┌──────────────────────────────┐
│   api.ts                     │
│  response.json()             │
│  → 解析 JSON                 │
└────────┬─────────────────────┘
         │
步骤 13: 状态更新
         ↓
┌──────────────────────────────┐
│   ProjectsPage.tsx           │
│  setProjects(data)           │
│  → 触发重新渲染              │
└────────┬─────────────────────┘
         │
步骤 14: UI 更新
         ↓
┌──────────────────────────────┐
│   用户浏览器                 │
│  显示项目列表                │
└──────────────────────────────┘
```

### 关键数据转换点

```
1. 数据库行 → Rust 结构体
   MySQL Row → models::Project (FromRow trait)

2. 领域模型 → DTO
   models::Project → models::ProjectResponse (业务层)

3. Rust 结构体 → JSON
   ProjectResponse → JSON (Axum 自动序列化)

4. JSON → TypeScript 对象
   JSON → api.Project (fetch 自动解析)

5. TypeScript 对象 → React 组件
   Project[] → JSX (React 渲染)
```

### 错误传播链

```
数据库错误 (SQLx)
    ↓
业务层错误 (anyhow::Error)
    ↓
应用层错误 ((StatusCode, Json))
    ↓
HTTP 响应 (4xx/5xx)
    ↓
前端错误处理 (try-catch)
    ↓
用户提示 (Toast/Alert)
```

---

## 🔀 横切关注点（Cross-Cutting Concerns）

### 1. 认证授权

**位置**: `backend/src/auth.rs`

```rust
// 管理员认证中间件
pub async fn admin_auth_middleware(
    State(_state): State<AppState>,
    headers: HeaderMap,
    request: Request,
    next: Next,
) -> Result<Response, (StatusCode, Json<...>)> {
    // 1. 读取环境变量配置
    let admin_token = std::env::var("BLOG_ADMIN_TOKEN")
        .unwrap_or_default();
    
    // 2. 检查 Authorization 头
    if let Some(auth_header) = headers.get("authorization") {
        if let Ok(auth_str) = auth_header.to_str() {
            // 3. Bearer Token 验证
            if auth_str.starts_with("Bearer ") {
                let token = &auth_str[7..];
                if token == admin_token {
                    return Ok(next.run(request).await);
                }
            }
            // 4. Basic Auth 验证
            if auth_str.starts_with("Basic ") {
                let decoded = base64::decode(&auth_str[6..])?;
                // 验证用户名密码...
            }
        }
    }
    
    // 5. 验证失败
    Err((
        StatusCode::UNAUTHORIZED,
        Json(json!({"error": "未授权访问"}))
    ))
}
```

**应用方式**：
```rust
// 在路由上应用中间件
.route("/admin/blog/posts", 
    post(create_blog_post)
        .layer(middleware::from_fn_with_state(
            app_state.clone(),
            auth::admin_auth_middleware
        ))
)
```

---

### 2. 日志追踪

**位置**: 全局（使用 `tracing` crate）

```rust
// main.rs - 初始化日志
tracing_subscriber::fmt::init();

// handlers.rs - 函数级追踪
#[instrument(skip(state))]  // 自动记录函数调用
pub async fn get_projects(
    State(state): State<AppState>,
) -> Result<...> {
    // 日志会自动记录：
    // - 函数名
    // - 参数（除了 skip 的）
    // - 执行时间
    // - 返回值/错误
}

// 手动日志
error!("获取项目列表失败: {}", e);
info!("服务器启动在 http://0.0.0.0:8000");
```

**日志级别**（通过环境变量控制）：
```bash
RUST_LOG=debug    # 详细日志
RUST_LOG=info     # 生产日志
RUST_LOG=error    # 仅错误
```

---

### 3. CORS 配置

**位置**: `backend/src/main.rs`

```rust
use tower_http::cors::{Any, CorsLayer};

let app = Router::new()
    // ... 路由配置
    .layer(
        CorsLayer::new()
            .allow_origin(Any)           // 允许所有来源
            .allow_methods(Any)          // 允许所有 HTTP 方法
            .allow_headers(Any)          // 允许所有请求头
    );
```

**生产环境配置建议**：
```rust
.layer(
    CorsLayer::new()
        .allow_origin("https://yourdomain.com".parse::<HeaderValue>()?)
        .allow_methods([Method::GET, Method::POST])
        .allow_headers([header::AUTHORIZATION, header::CONTENT_TYPE])
)
```

---

### 4. 错误处理

#### 后端错误处理策略

```rust
// 1. 使用 anyhow::Error 统一错误类型
use anyhow::{Context, Result};

pub async fn get_project(id: Uuid) -> Result<Project> {
    sqlx::query_as!(...)
        .fetch_one(pool)
        .await
        .context("查询项目失败")?  // 添加上下文信息
}

// 2. 在 handlers 中转换为 HTTP 错误
match services::project::get_project(id).await {
    Ok(project) => Ok(Json(project)),
    Err(e) => {
        error!("错误: {:#}", e);  // 打印完整错误链
        Err((
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(json!({"error": "服务器错误"}))
        ))
    }
}
```

#### 前端错误处理

```typescript
// api.ts
export async function getProjects(): Promise<Project[]> {
  try {
    const response = await fetch(`${API_BASE_URL}/api/projects`);
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error("获取项目列表失败:", error);
    
    // 返回降级数据或重新抛出
    return getFallbackProjects();
  }
}
```

---

### 5. 环境配置管理

**位置**: `.env` 文件 + `dotenvy` crate

```bash
# .env
DATABASE_URL=mysql://user:pass@localhost:3306/portfolio_pulse
GITHUB_TOKEN=ghp_xxx
BLOG_ADMIN_USER=admin
BLOG_ADMIN_TOKEN=secret_token_here
RUST_LOG=info
```

**代码读取**：
```rust
// main.rs
dotenvy::dotenv().ok();  // 加载 .env 文件

let database_url = std::env::var("DATABASE_URL")
    .unwrap_or_else(|_| "mysql://root@localhost/portfolio_pulse".to_string());

let github_token = std::env::var("GITHUB_TOKEN")
    .unwrap_or_default();
```

---

### 6. 静态文件服务

**位置**: `backend/src/main.rs`

```rust
use tower_http::services::{ServeDir, ServeFile};

// 静态文件服务 + SPA Fallback
let static_files_service = ServeDir::new("static")
    .not_found_service(ServeFile::new("static/index.html"));

let app = Router::new()
    .nest("/api", api_routes)           // API 路由优先
    .fallback_service(static_files_service);  // 其他路径返回前端
```

**工作原理**：
1. `/api/*` → Rust Handler
2. `/assets/*` → `static/assets/` (静态资源)
3. `/`, `/projects`, `/blog` 等 → `static/index.html` (React Router 接管)

---

## 🎯 架构模式总结

### 主架构模式：分层架构（Layered Architecture）

```
特点：
✅ 每层只依赖下层，不依赖上层
✅ 层与层之间通过接口通信
✅ 每层可独立测试和替换

体现：
展示层 → 应用层 → 业务层 → 数据层 → 持久层
```

---

### 辅助模式 1：领域驱动设计（DDD）元素

```
体现：
1. 领域模型: Project, GitActivity, Commit (models.rs)
2. 服务层: ProjectService, BlogService (services/)
3. 仓储模式: SQLx 作为数据仓储抽象
4. 值对象: ProjectResponse (不可变的传输对象)
5. 领域事件: 可扩展（当前未实现）
```

**DDD 分层对应**：
```
DDD 层级              本项目对应
─────────────────────────────────────
应用层 (Application)  → handlers.rs
领域层 (Domain)       → services/ + models.rs
基础设施层 (Infra)    → SQLx + MySQL
接口层 (Interface)    → React 前端
```

---

### 辅助模式 2：依赖注入（Dependency Injection）

```rust
// AppState 作为依赖容器
#[derive(Clone)]
pub struct AppState {
    pub db: sqlx::MySqlPool,      // 数据库连接池
    pub github_token: String,     // GitHub Token
}

// Axum State 机制注入依赖
pub async fn get_projects(
    State(state): State<AppState>,  // ← 注入点
) -> Result<...> {
    // 使用 state.db 访问数据库
    services::project::get_all_projects(&state.db).await
}
```

**优势**：
- 测试友好（可注入 Mock 数据库）
- 解耦组件间依赖
- 集中管理共享资源

---

### 辅助模式 3：客户端-服务器架构（Client-Server）

```
客户端 (Client):
- React SPA (纯前端应用)
- 运行在用户浏览器
- 无状态（状态存储在内存/LocalStorage）

服务器 (Server):
- Rust Axum 后端
- 提供 RESTful API
- 管理数据库连接和业务逻辑

通信协议:
- HTTP/HTTPS
- JSON 数据格式
- RESTful 风格 API
```

---

### 辅助模式 4：微内核架构（Microkernel）的影子

```
核心 (Core):
- Axum 路由系统
- 基础 HTTP 服务器

插件 (Plugins):
- tower-http: 静态文件服务
- CorsLayer: CORS 中间件
- auth middleware: 认证插件
- tracing: 日志追踪插件
```

**可扩展性**：
```rust
// 添加新中间件就像插入插件
.layer(RateLimitLayer::new(...))      // 限流
.layer(CompressionLayer::new())       // 压缩
.layer(TimeoutLayer::new(...))        // 超时
```

---

### 辅助模式 5：Facade 模式

**前端 API 抽象**：
```typescript
// api.ts 作为 Facade
export async function getProjects(): Promise<Project[]> {
  // 隐藏复杂的 fetch 调用细节
  const response = await fetch(`${API_BASE_URL}/api/projects`);
  return response.json();
}

// 组件只需简单调用
const projects = await api.getProjects();
```

---

### 辅助模式 6：Repository 模式（部分实现）

```rust
// SQLx 提供基础仓储功能
pub async fn get_all_projects(pool: &MySqlPool) -> Result<Vec<Project>> {
    sqlx::query_as!(Project, "SELECT * FROM projects")
        .fetch_all(pool)
        .await
}

// 理想的完整仓储模式应该是：
trait ProjectRepository {
    async fn find_all(&self) -> Result<Vec<Project>>;
    async fn find_by_id(&self, id: Uuid) -> Result<Option<Project>>;
    async fn save(&self, project: &Project) -> Result<()>;
    async fn delete(&self, id: Uuid) -> Result<()>;
}
```

---

## 💼 实战案例

### 案例 1: 添加新功能 - 项目点赞功能 ⚠️ 未来计划

> **注意**: 此功能当前未实现，仅作为架构示例。实际项目采用 YAGNI 原则，仅实现有明确需求的功能。

让我们看看如何在现有架构中添加新功能：

#### 步骤 1: 数据库迁移（持久层）

```sql
-- migrations/004_project_likes.sql （未实现）
ALTER TABLE projects ADD COLUMN likes_count INT DEFAULT 0;

CREATE TABLE project_likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    project_id VARCHAR(36) NOT NULL,
    user_ip VARCHAR(45) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_like (project_id, user_ip),
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);
```

#### 步骤 2: 更新数据模型（数据访问层）

```rust
// models.rs
#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct Project {
    // ... 现有字段
    pub likes_count: i32,  // ← 新增字段
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ProjectResponse {
    // ... 现有字段
    pub likes_count: i32,  // ← 新增字段
}
```

#### 步骤 3: 实现业务逻辑（业务层）

```rust
// services/project.rs
pub async fn like_project(
    pool: &MySqlPool,
    project_id: Uuid,
    user_ip: &str,
) -> Result<()> {
    // 业务规则：同一IP只能点赞一次
    sqlx::query!(
        "INSERT IGNORE INTO project_likes (project_id, user_ip) VALUES (?, ?)",
        project_id.to_string(),
        user_ip
    )
    .execute(pool)
    .await?;
    
    // 更新点赞计数
    sqlx::query!(
        "UPDATE projects SET likes_count = likes_count + 1 WHERE id = ?",
        project_id.to_string()
    )
    .execute(pool)
    .await?;
    
    Ok(())
}
```

#### 步骤 4: 添加 HTTP 处理器（应用层）

```rust
// handlers.rs
#[derive(Deserialize)]
pub struct LikeRequest {
    project_id: String,
}

pub async fn like_project(
    State(state): State<AppState>,
    ConnectInfo(addr): ConnectInfo<SocketAddr>,  // 获取客户端IP
    Json(payload): Json<LikeRequest>,
) -> Result<StatusCode, (StatusCode, Json<...>)> {
    let project_id = Uuid::parse_str(&payload.project_id)
        .map_err(|_| (StatusCode::BAD_REQUEST, Json(json!({"error": "无效ID"}))))?;
    
    match services::project::like_project(&state.db, project_id, &addr.ip().to_string()).await {
        Ok(_) => Ok(StatusCode::OK),
        Err(e) => {
            error!("点赞失败: {}", e);
            Err((StatusCode::INTERNAL_SERVER_ERROR, Json(json!({"error": "点赞失败"}))))
        }
    }
}
```

#### 步骤 5: 注册路由（应用层）

```rust
// main.rs
let api_routes = Router::new()
    // ... 现有路由
    .route("/projects/:id/like", post(like_project))  // ← 新增路由
    .with_state(app_state);
```

#### 步骤 6: 前端 API 调用（展示层）

```typescript
// lib/api.ts
export async function likeProject(projectId: string): Promise<void> {
  const response = await fetch(`${API_BASE_URL}/api/projects/${projectId}/like`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ project_id: projectId }),
  });
  
  if (!response.ok) {
    throw new Error('点赞失败');
  }
}
```

#### 步骤 7: UI 组件更新（展示层）

```tsx
// components/ProjectCard.tsx
function ProjectCard({ project }: { project: Project }) {
  const [likes, setLikes] = useState(project.likes_count);
  
  const handleLike = async () => {
    try {
      await api.likeProject(project.id);
      setLikes(likes + 1);
    } catch (error) {
      alert('点赞失败');
    }
  };
  
  return (
    <div className="project-card">
      {/* ... 项目信息 */}
      <button onClick={handleLike}>
        ❤️ {likes}
      </button>
    </div>
  );
}
```

**总结**：
- ✅ 从数据库到 UI 的完整功能添加
- ✅ 每层职责清晰，互不干扰
- ✅ 遵循现有架构模式
- ✅ 易于测试和维护

---

### 案例 2: 性能优化 - 添加 Redis 缓存

假设我们要为项目列表添加缓存：

#### 步骤 1: 添加 Redis 依赖

```toml
# Cargo.toml
[dependencies]
redis = { version = "0.23", features = ["tokio-comp", "connection-manager"] }
```

#### 步骤 2: 扩展 AppState（依赖注入）

```rust
// main.rs
#[derive(Clone)]
pub struct AppState {
    pub db: sqlx::MySqlPool,
    pub github_token: String,
    pub redis: redis::aio::ConnectionManager,  // ← 新增
}

// 初始化 Redis
let redis_client = redis::Client::open("redis://localhost:6379")?;
let redis = redis::aio::ConnectionManager::new(redis_client).await?;

let app_state = AppState {
    db: pool,
    github_token,
    redis,  // ← 注入
};
```

#### 步骤 3: 更新业务逻辑（业务层）

```rust
// services/project.rs
use redis::AsyncCommands;

pub async fn get_all_projects_cached(
    pool: &MySqlPool,
    redis: &mut redis::aio::ConnectionManager,
) -> Result<Vec<ProjectResponse>> {
    // 1. 尝试从 Redis 获取
    let cache_key = "projects:all";
    if let Ok(cached) = redis.get::<_, String>(cache_key).await {
        if let Ok(projects) = serde_json::from_str(&cached) {
            return Ok(projects);
        }
    }
    
    // 2. 缓存未命中，查询数据库
    let projects = get_all_projects(pool).await?;
    
    // 3. 写入缓存（5分钟过期）
    let json = serde_json::to_string(&projects)?;
    redis.set_ex(cache_key, json, 300).await?;
    
    Ok(projects)
}
```

**架构优势体现**：
- ✅ 不影响其他层级代码
- ✅ 通过依赖注入添加新依赖
- ✅ 业务逻辑封装在服务层

---

## 📊 架构评估

### 架构模式匹配度评分

| 架构模式 | 匹配度 | 评分 | 说明 |
|---------|--------|------|------|
| **分层架构** | ⭐⭐⭐⭐⭐ | 10/10 | 清晰的五层分离，职责明确 |
| **MVC/MVT** | ⭐⭐⭐⭐ | 8/10 | React (View) + Handlers (Controller) + Services (Model) |
| **仓储模式** | ⭐⭐⭐ | 6/10 | SQLx 提供基础抽象，但缺少完整的 Repository trait |
| **服务层模式** | ⭐⭐⭐⭐⭐ | 10/10 | 业务逻辑完全封装在 services 层 |
| **依赖注入** | ⭐⭐⭐⭐⭐ | 10/10 | Axum State 完美实现 DI |
| **中间件模式** | ⭐⭐⭐⭐ | 8/10 | 认证、CORS、日志都通过中间件实现 |
| **DDD** | ⭐⭐⭐ | 6/10 | 有领域模型和服务层，缺少聚合根、值对象等高级概念 |
| **RESTful API** | ⭐⭐⭐⭐⭐ | 10/10 | 标准的 RESTful 设计 |

### 架构质量属性

#### 1. 可维护性 ⭐⭐⭐⭐⭐

**优势**：
- ✅ 代码分层清晰，易于定位问题
- ✅ 每层职责单一，修改影响范围小
- ✅ TypeScript + Rust 类型安全，重构更放心

**示例**：修改数据库字段只需改 3 个地方
1. 数据库迁移 SQL
2. `models.rs` 结构体定义
3. 业务层数据转换逻辑

---

#### 2. 可扩展性 ⭐⭐⭐⭐

**优势**：
- ✅ 新功能可通过添加新的 service 模块实现
- ✅ 中间件系统易于扩展（限流、压缩等）
- ✅ 前后端完全解耦，可独立扩展

**改进空间**：
- 🔧 添加插件系统支持第三方扩展
- 🔧 实现事件驱动架构支持异步任务

---

#### 3. 性能 ⭐⭐⭐⭐

**优势**：
- ✅ Rust 原生性能，低内存占用
- ✅ 异步 I/O（Tokio）支持高并发
- ✅ 数据库连接池复用

**改进空间**：
- 🔧 添加 Redis 缓存层
- 🔧 实现 GraphQL 减少 API 调用次数
- 🔧 前端代码分割和懒加载

---

#### 4. 可测试性 ⭐⭐⭐⭐⭐

**优势**：
- ✅ 每层可独立单元测试
- ✅ 依赖注入便于 Mock
- ✅ 业务逻辑纯函数居多

**测试策略**：
```rust
// 单元测试（业务层）
#[cfg(test)]
mod tests {
    use super::*;
    
    #[tokio::test]
    async fn test_create_project() {
        let pool = create_test_pool().await;
        let project = create_test_project(&pool).await.unwrap();
        assert_eq!(project.name, "Test Project");
    }
}

// 集成测试（应用层）
#[tokio::test]
async fn test_get_projects_api() {
    let app = create_test_app().await;
    let response = app
        .oneshot(Request::builder().uri("/api/projects").body(Body::empty()).unwrap())
        .await
        .unwrap();
    assert_eq!(response.status(), StatusCode::OK);
}
```

---

#### 5. 安全性 ⭐⭐⭐⭐

**优势**：
- ✅ JWT/Basic Auth 认证
- ✅ CORS 配置保护
- ✅ SQL 注入防护（SQLx 参数化查询）
- ✅ 类型安全防止数据错误

**改进空间**：
- 🔧 添加 HTTPS/TLS 支持
- 🔧 实现 Rate Limiting 防 DDoS
- 🔧 添加 CSRF Token 保护
- 🔧 实现角色权限系统（RBAC）

---

#### 6. 部署便利性 ⭐⭐⭐⭐⭐

**优势**：
- ✅ 单一二进制文件，无运行时依赖
- ✅ Docker 容器化部署
- ✅ 统一端口，无需反向代理配置
- ✅ 快速启动（<1秒）

---

## 🔧 改进建议

### 短期改进（1-2周）

#### 1. 完善 Repository 模式

**当前问题**：SQL 查询分散在 services 层

**改进方案**：
```rust
// 创建 repositories/ 目录
repositories/
├── mod.rs
├── project_repository.rs
├── blog_repository.rs
└── activity_repository.rs

// 定义 Repository trait
#[async_trait]
pub trait ProjectRepository {
    async fn find_all(&self) -> Result<Vec<Project>>;
    async fn find_by_id(&self, id: Uuid) -> Result<Option<Project>>;
    async fn save(&self, project: &Project) -> Result<()>;
    async fn delete(&self, id: Uuid) -> Result<()>;
}

// 实现
pub struct MySqlProjectRepository {
    pool: MySqlPool,
}

#[async_trait]
impl ProjectRepository for MySqlProjectRepository {
    async fn find_all(&self) -> Result<Vec<Project>> {
        sqlx::query_as!(Project, "SELECT * FROM projects")
            .fetch_all(&self.pool)
            .await
            .map_err(Into::into)
    }
}
```

**好处**：
- ✅ 数据访问逻辑集中管理
- ✅ 易于切换数据库实现
- ✅ 测试时可 Mock Repository

---

#### 2. 添加 DTO 转换层

**当前问题**：Model → Response 转换逻辑分散

**改进方案**：
```rust
// 创建 dto/ 目录
dto/
├── mod.rs
├── project_dto.rs
└── converters.rs

// 统一转换逻辑
impl From<Project> for ProjectResponse {
    fn from(project: Project) -> Self {
        ProjectResponse {
            id: project.id.to_string(),
            name: project.name,
            topics: serde_json::from_str(&project.topics.unwrap_or_default())
                .unwrap_or_default(),
            // ... 其他字段转换
        }
    }
}

// 使用
let response: ProjectResponse = project.into();
```

---

#### 3. 统一错误处理

**当前问题**：错误处理不一致

**改进方案**：
```rust
// 创建自定义错误类型
#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error("数据库错误: {0}")]
    Database(#[from] sqlx::Error),
    
    #[error("未找到资源: {0}")]
    NotFound(String),
    
    #[error("验证失败: {0}")]
    Validation(String),
    
    #[error("未授权")]
    Unauthorized,
}

// 实现到 HTTP 响应的转换
impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, message) = match self {
            AppError::NotFound(msg) => (StatusCode::NOT_FOUND, msg),
            AppError::Unauthorized => (StatusCode::UNAUTHORIZED, "未授权".to_string()),
            _ => (StatusCode::INTERNAL_SERVER_ERROR, "服务器错误".to_string()),
        };
        
        (status, Json(json!({"error": message}))).into_response()
    }
}
```

---

### 中期改进（1-2月）

#### 4. 添加缓存层

**方案**：引入 Redis 作为缓存

```rust
// 缓存策略
pub struct CachedProjectService {
    repository: Arc<dyn ProjectRepository>,
    cache: redis::aio::ConnectionManager,
}

impl CachedProjectService {
    pub async fn get_all_projects(&self) -> Result<Vec<ProjectResponse>> {
        // 1. 尝试缓存
        let cache_key = "projects:all";
        if let Ok(cached) = self.cache.get(cache_key).await {
            return Ok(cached);
        }
        
        // 2. 查询数据库
        let projects = self.repository.find_all().await?;
        
        // 3. 写入缓存
        self.cache.set_ex(cache_key, &projects, 300).await?;
        
        Ok(projects)
    }
}
```

---

#### 5. 实现事件驱动架构

**方案**：使用事件总线解耦业务逻辑

```rust
// 定义事件
pub enum DomainEvent {
    ProjectCreated(ProjectCreatedEvent),
    ProjectUpdated(ProjectUpdatedEvent),
    BlogPostPublished(BlogPostPublishedEvent),
}

// 事件处理器
#[async_trait]
pub trait EventHandler: Send + Sync {
    async fn handle(&self, event: &DomainEvent) -> Result<()>;
}

// 示例：项目创建后发送通知
pub struct NotificationHandler;

#[async_trait]
impl EventHandler for NotificationHandler {
    async fn handle(&self, event: &DomainEvent) -> Result<()> {
        match event {
            DomainEvent::ProjectCreated(e) => {
                // 发送邮件/Webhook通知
                send_notification(&e.project_name).await?;
            }
            _ => {}
        }
        Ok(())
    }
}
```

---

#### 6. 前端状态管理优化

**当前问题**：状态管理较简单

**改进方案**：使用 Zustand 完善状态管理

```typescript
// store/projectStore.ts
import create from 'zustand';

interface ProjectStore {
  projects: Project[];
  loading: boolean;
  error: string | null;
  
  fetchProjects: () => Promise<void>;
  likeProject: (id: string) => Promise<void>;
  clearError: () => void;
}

export const useProjectStore = create<ProjectStore>((set, get) => ({
  projects: [],
  loading: false,
  error: null,
  
  fetchProjects: async () => {
    set({ loading: true, error: null });
    try {
      const projects = await api.getProjects();
      set({ projects, loading: false });
    } catch (error) {
      set({ error: error.message, loading: false });
    }
  },
  
  likeProject: async (id) => {
    await api.likeProject(id);
    set(state => ({
      projects: state.projects.map(p =>
        p.id === id ? { ...p, likes_count: p.likes_count + 1 } : p
      )
    }));
  },
  
  clearError: () => set({ error: null }),
}));
```

---

### 长期改进（3-6月）

#### 7. 微服务拆分（如果规模增长）

**拆分方案**：
```
当前单体应用 → 按业务域拆分

services/
├── project-service/     # 项目管理服务
├── blog-service/        # 博客服务
├── activity-service/    # 活动追踪服务
└── gateway/            # API 网关
```

---

#### 8. GraphQL API

**优势**：减少 API 调用次数，前端按需查询

```rust
// 使用 async-graphql
#[Object]
impl Query {
    async fn project(&self, id: ID) -> Result<Project> {
        // 返回项目
    }
    
    async fn projects(
        &self,
        limit: Option<i32>,
        offset: Option<i32>,
    ) -> Result<Vec<Project>> {
        // 返回项目列表
    }
}
```

---

#### 9. 实现 CQRS 模式

**适用场景**：读写分离，优化查询性能

```rust
// 命令（写操作）
pub struct CreateProjectCommand {
    pub name: String,
    pub description: String,
}

pub struct ProjectCommandHandler {
    repository: Arc<dyn ProjectRepository>,
    event_bus: Arc<EventBus>,
}

impl ProjectCommandHandler {
    pub async fn handle(&self, cmd: CreateProjectCommand) -> Result<Project> {
        let project = Project::new(cmd.name, cmd.description);
        self.repository.save(&project).await?;
        self.event_bus.publish(DomainEvent::ProjectCreated(project.clone())).await?;
        Ok(project)
    }
}

// 查询（读操作）
pub struct ProjectQueryService {
    read_model: Arc<dyn ProjectReadModel>,
}

impl ProjectQueryService {
    pub async fn get_all(&self) -> Result<Vec<ProjectResponse>> {
        // 从优化的读模型查询
        self.read_model.find_all().await
    }
}
```

---

## 🎓 总结

### 架构核心特点

PortfolioPulse 采用 **分层架构** 作为主架构模式，是一个教科书级别的现代全栈应用实现：

1. **前端**：展示层完全独立，React + Vite + Router
2. **后端**：经典三层架构（应用层 → 业务层 → 数据层）
3. **通信**：RESTful API（HTTP/JSON）
4. **横切关注点**：中间件处理认证、日志、CORS
5. **设计模式**：Service 模式 + 依赖注入 + Facade 模式

### 架构优势

| 优势 | 说明 |
|------|------|
| 🎯 **职责清晰** | 每层专注特定功能，易于理解 |
| 🔧 **易于维护** | 修改影响范围小，代码可读性高 |
| 🚀 **高性能** | Rust 原生性能 + 异步 I/O |
| 🔒 **类型安全** | TypeScript + Rust 全链路类型检查 |
| 🧪 **易于测试** | 各层可独立单元测试 |
| 📦 **简化部署** | 单一二进制文件，低内存占用 |

### 适用场景

✅ **适合**：
- 中小型 Web 应用
- 需要清晰架构的项目
- 团队协作开发
- 需要长期维护的系统

⚠️ **不适合**：
- 极简单的静态网站（过度设计）
- 超大规模系统（考虑微服务）
- 实时性要求极高的应用（考虑 WebSocket/gRPC）

### 学习路径建议

1. **基础阶段**：理解分层架构概念
2. **实践阶段**：按照案例添加新功能
3. **优化阶段**：实施短期改进建议
4. **进阶阶段**：探索 DDD、CQRS 等高级模式

---

## 📚 附录

### A. 关键文件索引

| 文件路径 | 作用 | 层级 |
|---------|------|------|
| `frontend-vite/src/App.tsx` | React 路由配置 | 展示层 |
| `frontend-vite/src/lib/api.ts` | API 客户端 | 展示层 |
| `backend/src/main.rs` | Axum 服务器入口 | 应用层 |
| `backend/src/handlers.rs` | HTTP 请求处理器 | 应用层 |
| `backend/src/auth.rs` | 认证中间件 | 横切关注点 |
| `backend/src/services/` | 业务逻辑模块 | 业务层 |
| `backend/src/models.rs` | 数据模型定义 | 数据访问层 |
| `backend/migrations/` | 数据库迁移 | 持久层 |

---

### B. 常用命令速查

```bash
# 开发环境启动
cd frontend-vite && npm run dev       # 前端开发服务器（端口 3000）
cd backend && cargo run               # 后端开发服务器（端口 8000）

# 生产构建
./build.ps1                           # Windows 统一构建
./build.sh                            # Linux/Mac 统一构建

# 数据库操作
cd backend && diesel migration run    # 运行迁移
diesel migration generate <name>      # 创建新迁移

# 代码质量
cd frontend-vite && npm run lint      # 前端 Lint
cd backend && cargo fmt               # Rust 格式化
cargo clippy                          # Rust Lint

# 测试
cd frontend-vite && npm test          # 前端测试
cd backend && cargo test              # 后端测试
```

---

### C. 环境变量配置

```bash
# .env 文件配置项
DATABASE_URL=mysql://user:pass@localhost:3306/portfolio_pulse
GITHUB_TOKEN=ghp_your_token_here
BLOG_ADMIN_USER=admin
BLOG_ADMIN_TOKEN=your_secret_token
RUST_LOG=info
```

---

### D. 相关文档链接

- [项目总览](../README.md)
- [前端重构报告](../FRONTEND_REFACTOR_REPORT.md)
- [部署指南](../.github/instructions/binary-deployment.instructions.md)
- [项目规范](../.github/instructions/project-overview.instructions.md)
- [前端开发规范](../.github/instructions/frontend-development.instructions.md)
- [后端开发规范](../.github/instructions/backend-development.instructions.md)
- [数据库设计规范](../.github/instructions/database-design.instructions.md)

---

### E. 技术栈版本记录

| 技术 | 版本 | 更新日期 |
|------|------|---------|
| React | 18.2.0 | 2024-08-23 |
| Vite | 5.4.0 | 2024-08-23 |
| Rust | 1.75+ | 2024-08-23 |
| Axum | 0.7.0 | 2024-08-23 |
| SQLx | 0.7.0 | 2024-08-23 |
| MySQL | 8.0+ | 2024-08-23 |
| TypeScript | 5.2.0 | 2024-08-23 |
| Tailwind CSS | 3.x | 2024-08-23 |

---

### F. 贡献指南

如果要为项目贡献代码，请遵循以下步骤：

1. **理解架构**：仔细阅读本文档
2. **遵循规范**：参考 `.github/instructions/` 目录下的开发规范
3. **添加测试**：为新功能编写单元测试
4. **更新文档**：修改代码后同步更新相关文档
5. **提交 PR**：使用 Conventional Commits 规范

---

### G. 常见问题 FAQ

#### Q1: 为什么选择 Rust 而不是 Node.js？

**A**: 
- 性能：Rust 原生性能，内存占用低
- 安全：编译时类型检查，避免运行时错误
- 部署：单一二进制文件，无需 Node.js 运行时
- 学习：技术栈多样化，提升技能

#### Q2: 前端为什么从 Next.js 迁移到 Vite？

**A**:
- 简化部署：Vite 构建为纯静态文件
- 统一架构：前端由 Rust 服务器托管
- 降低成本：单一进程，减少内存占用
- 更快构建：Vite 构建速度优于 Next.js

#### Q3: 如何添加新的 API 端点？

**A**: 遵循分层架构：
1. 数据库迁移（如需新表）
2. 更新 `models.rs`（数据模型）
3. 实现 `services/` 业务逻辑
4. 添加 `handlers.rs` 处理器
5. 注册路由（`main.rs`）
6. 前端 `api.ts` 添加调用方法

#### Q4: 如何切换数据库（如 PostgreSQL）？

**A**:
1. 修改 `Cargo.toml` 依赖：`sqlx = { features = ["postgres"] }`
2. 更新 `DATABASE_URL` 环境变量
3. 调整 SQL 语法（PostgreSQL 与 MySQL 略有差异）
4. 重新运行迁移

#### Q5: 生产环境如何优化性能？

**A**:
- 启用 Rust release 模式：`cargo build --release`
- 前端生产构建：`npm run build`
- 添加 Redis 缓存层
- 配置 CDN 托管静态资源
- 数据库索引优化
- 启用 gzip 压缩

---

## 📖 结语

PortfolioPulse 的架构设计体现了现代软件工程的最佳实践，它不是简单的分层架构，而是融合了多种模式的**混合架构**：

- **传统优势**：分层架构的清晰性
- **现代实践**：DDD、依赖注入、RESTful API
- **技术创新**：Rust 性能 + React 生态
- **部署简化**：单一二进制文件

这是一个**可学习、可扩展、可维护**的优秀架构范例，适合作为全栈项目的参考模板。

---

**文档维护者**: GitHub Copilot AI  
**最后更新**: 2025-10-21  
**版本**: v1.0  
**许可证**: MIT License

---

🎉 **祝你在 PortfolioPulse 项目中学习愉快！**

