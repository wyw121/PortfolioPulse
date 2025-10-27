# PortfolioPulse 项目学习指南

> **目标读者**: 有 Python 基础，但没有 Web 全栈项目经验的开发者
> **学习时间**: 2-3 小时快速入门，1-2 天深入掌握
> **学习方法**: 从请求流程出发，追踪代码执行路径

---

## 📋 目录

0. [【速成】Python → TypeScript/Rust 语法对照](#0-速成-python--typescriptrust-语法对照) ⭐
1. [项目全貌 - 10 分钟看懂整体架构](#1-项目全貌)
2. [关键路径 - 追踪一次完整的请求](#2-关键路径)
3. [文件导航 - 出问题去哪里改](#3-文件导航)
4. [实战演练 - 修改一个功能](#4-实战演练)
5. [常见问题定位](#5-常见问题定位)

---

## 0. 【速成】Python → TypeScript/Rust 语法对照

> **核心目标**: 用 10 分钟让你能看懂 80% 的项目代码，不纠结技术细节

### 0.1 回答你的问题

**Q: `.ts` 是 Java 开发的吗？**
A: 不是！`.ts` 是 **TypeScript**，它是 **JavaScript + 类型系统**。JavaScript 的语法和 Python 很像（都是脚本语言），TypeScript 只是加了类型检查。

**Q: `.rs` 是 Rust，和 Java 像吗？**
A: 对！`.rs` 是 **Rust**，它确实和 Java 有相似之处（都是编译型、强类型），但语法更接近 C++。不过你不需要深究，只要能看懂"这个函数干什么"就够了。

---

### 0.2 核心语法速查表

#### **变量定义**

| Python             | TypeScript                        | Rust                            |
| ------------------ | --------------------------------- | ------------------------------- |
| `name = "Alice"` | `const name = "Alice"`          | `let name = "Alice"`          |
| `age = 25`       | `const age: number = 25`        | `let age: i32 = 25`           |
| *(动态类型)*     | `const age = 25` *(自动推断)* | `let age = 25` *(自动推断)* |

**关键点**:

- TypeScript 用 `const`（不可变）或 `let`（可变）
- Rust 用 `let`（默认不可变）或 `let mut`（可变）
- **你只需记住**: 看到 `const`/`let` 就是在定义变量

---

#### **函数定义**

**Python:**

```python
def get_projects(user_id):
    return database.query("SELECT * FROM projects WHERE user_id = ?", user_id)
```

**TypeScript (.ts):**

```typescript
function getProjects(userId: number): Project[] {
    return database.query("SELECT * FROM projects WHERE user_id = ?", userId);
}
```

**Rust (.rs):**

```rust
fn get_projects(user_id: i32) -> Vec<Project> {
    database.query("SELECT * FROM projects WHERE user_id = ?", user_id)
}
```

**对应关系**:

| Python           | TypeScript         | Rust             | 含义                         |
| ---------------- | ------------------ | ---------------- | ---------------------------- |
| `def`          | `function`       | `fn`           | 定义函数                     |
| `user_id`      | `userId: number` | `user_id: i32` | 参数（带类型）               |
| `return [...]` | `return [...]`   | `[...]`        | 返回值（Rust 可省略 return） |

**你只需记住**: 看到 `function`/`fn` 就是函数，冒号后面是类型（可忽略）

---

#### **条件判断**

**Python:**

```python
if status == "active":
    print("Running")
else:
    print("Stopped")
```

**TypeScript:**

```typescript
if (status === "active") {
    console.log("Running");
} else {
    console.log("Stopped");
}
```

**Rust:**

```rust
if status == "active" {
    println!("Running");
} else {
    println!("Stopped");
}
```

**关键差异**:

- TypeScript 用 `===`（严格相等），Python 用 `==`
- 都用大括号 `{}`（Python 用缩进）
- Rust 的 `println!` 后面有感叹号（宏调用，忽略即可）

---

#### **数组/列表操作**

**Python:**

```python
projects = [p1, p2, p3]
for project in projects:
    print(project.name)
```

**TypeScript:**

```typescript
const projects = [p1, p2, p3];
projects.forEach(project => {
    console.log(project.name);
});
```

**Rust:**

```rust
let projects = vec![p1, p2, p3];
for project in projects.iter() {
    println!("{}", project.name);
}
```

**对应关系**:

| Python             | TypeScript                 | Rust                     | 含义     |
| ------------------ | -------------------------- | ------------------------ | -------- |
| `list = [...]`   | `const list = [...]`     | `let list = vec![...]` | 创建列表 |
| `for x in list:` | `list.forEach(x => ...)` | `for x in list.iter()` | 遍历     |

---

#### **异步操作（重要！）**

**Python (asyncio):**

```python
async def fetch_data():
    result = await database.query("SELECT * FROM users")
    return result
```

**TypeScript:**

```typescript
async function fetchData(): Promise<User[]> {
    const result = await database.query("SELECT * FROM users");
    return result;
}
```

**Rust:**

```rust
async fn fetch_data() -> Result<Vec<User>, Error> {
    let result = database.query("SELECT * FROM users").await?;
    Ok(result)
}
```

**关键点**:

- 三种语言都用 `async`/`await`（语法几乎一样！）
- **你只需记住**: 看到 `async` 就是异步函数，`await` 是等待结果

---

#### **错误处理**

**Python:**

```python
try:
    result = risky_operation()
except Exception as e:
    print(f"Error: {e}")
```

**TypeScript:**

```typescript
try {
    const result = riskyOperation();
} catch (e) {
    console.error(`Error: ${e}`);
}
```

**Rust (Result 类型):**

```rust
match risky_operation() {
    Ok(result) => println!("Success: {}", result),
    Err(e) => eprintln!("Error: {}", e),
}
```

**关键差异**:

- TypeScript 用 `try/catch`（和 Python 一样）
- Rust 用 `Result<T, E>` 类型（更安全，但你只需知道 `Ok` = 成功，`Err` = 失败）

---

### 0.3 看懂项目代码的关键

#### **前端 TypeScript 代码示例**

```typescript
// frontend-vite/src/lib/api.ts
export async function getProjects(): Promise<Project[]> {
    const response = await fetch(`${API_BASE_URL}/api/projects`);
    return response.json();
}
```

**用 Python 理解**:

```python
# 等价的 Python 代码
async def get_projects() -> List[Project]:
    response = await http_client.get(f"{API_BASE_URL}/api/projects")
    return response.json()
```

**你只需看懂**:

- `export` = 导出函数（类似 Python 模块）
- `async` = 异步函数
- `fetch()` = 发送 HTTP 请求（类似 Python 的 `requests.get()`）
- `Promise<Project[]>` = 返回 Project 列表（类型标注）

---

#### **后端 Rust 代码示例**

```rust
// backend/src/handlers.rs
pub async fn get_projects(
    State(state): State<AppState>,
) -> Result<Json<Vec<ProjectResponse>>, (StatusCode, Json<ErrorResponse>)> {
    match services::project::get_all_projects(&state.db).await {
        Ok(projects) => Ok(Json(projects)),
        Err(e) => Err((StatusCode::INTERNAL_SERVER_ERROR, Json(ErrorResponse { ... }))),
    }
}
```

**用 Python 理解**:

```python
# 等价的 Python 代码
async def get_projects(state: AppState) -> Union[List[Project], ErrorResponse]:
    try:
        projects = await services.project.get_all_projects(state.db)
        return projects
    except Exception as e:
        return ErrorResponse(status_code=500, error=str(e))
```

**你只需看懂**:

- `pub` = 公开函数（类似 Python 不加下划线的函数）
- `State(state)` = 依赖注入（从框架获取数据库连接）
- `Result<Ok, Err>` = 要么成功返回 Ok，要么失败返回 Err
- `match` = 类似 Python 的 `if/else`，处理成功/失败两种情况

---

### 0.4 快速阅读代码的技巧

1. **忽略类型标注**（冒号后面的内容）

   ```typescript
   userId: number  →  只看 userId
   -> Vec<Project>  →  只看"返回 Project 列表"
   ```
2. **关注函数名和调用链**

   ```
   getProjects() → fetch() → 返回 JSON
   get_projects() → get_all_projects() → 数据库查询
   ```
3. **看注释和变量名**（都是英文，很直观）

   ```typescript
   const projects = await getProjects();  // 获取项目列表
   ```
4. **用 Python 思维翻译**

   - `const` = 变量
   - `function`/`fn` = 函数
   - `async`/`await` = 异步
   - `if/else` = 条件
   - `for` = 循环

---

### 0.5 项目中最常见的代码模式

#### **模式 1: API 调用（前端）**

```typescript
// 总是这个结构
export async function someAPI(): Promise<SomeType> {
    const response = await fetch(url);
    return response.json();
}
```

**翻译**: 发送 HTTP 请求，返回 JSON 数据

---

#### **模式 2: 路由处理（后端）**

```rust
// 总是这个结构
pub async fn handler(State(state): State<AppState>) -> Result<Json<Data>, Error> {
    match service_call(&state.db).await {
        Ok(data) => Ok(Json(data)),
        Err(e) => Err(error_response(e)),
    }
}
```

**翻译**: 接收请求 → 调用业务逻辑 → 返回成功/失败

---

#### **模式 3: 数据库查询（后端）**

```rust
// 总是这个结构
let results = sqlx::query_as::<_, ModelType>(
    "SELECT * FROM table WHERE condition = ?"
)
.fetch_all(pool)
.await?;
```

**翻译**: 执行 SQL 查询，返回结果列表

---

### 0.6 现在试试看懂这段真实代码

**前端代码** (`frontend-vite/src/app/projects/page.tsx`):

```typescript
export default function ProjectsPage() {
    const [projects, setProjects] = useState([]);
  
    useEffect(() => {
        getProjects().then(setProjects);
    }, []);
  
    return (
        <div>{projects.map(p => <ProjectCard key={p.id} project={p} />)}</div>
    );
}
```

**用 Python 理解**:

```python
# 页面组件（类似 Flask 的路由函数）
def projects_page():
    projects = []  # 状态变量
  
    # 页面加载时执行
    def on_mount():
        projects = get_projects()  # 获取数据
  
    # 渲染页面
    html = "<div>"
    for p in projects:
        html += f"<ProjectCard id={p.id} project={p} />"
    html += "</div>"
    return html
```

**你看懂了什么？**


- `useState` = 定义状态变量（React 特性，存储数据）
- `useEffect` = 页面加载时执行（类似 `__init__`）
- `map` = 遍历列表（类似 Python 的 `for`）
- `<ProjectCard />` = 渲染组件（类似 HTML 模板）

---

---

## 1. 项目全貌 (10 分钟理解)

### 1.1 这个项目是干什么的？

**一句话**: 展示你的 GitHub 项目动态的个人主页

**核心功能**:

- ✅ 展示 3 个 GitHub 项目（hardcoded，不从 GitHub API 读取）
- ✅ 展示项目的 Git 提交历史
- ✅ 博客文章展示（纯展示，管理后台已删除）
- ✅ 个人简介页面

### 1.2 技术栈（用类比法理解）

```
前端 (frontend-vite/)        →  网站的"脸面"（用户看到的）
├── React 18                  →  类似 Python 的 Flask 模板，但更强大
├── TypeScript                →  Python + 类型检查
├── Vite                      →  超快的"打包工具"（把代码打包成浏览器能运行的）
└── Tailwind CSS              →  写样式像写 Python 装饰器一样简单

后端 (backend/)              →  网站的"大脑"（处理数据和逻辑）
├── Rust                      →  类似 C++，但更安全，超快
├── Axum 框架                 →  类似 Python 的 FastAPI
├── SQLx                      →  数据库操作库（类似 Python 的 SQLAlchemy）
└── MySQL                     →  数据存储

部署方式                      →  "一键启动"
└── 单个 Rust 二进制文件      →  包含前端静态文件 + 后端 API
```

### 1.3 项目结构速览

```
PortfolioPulse/
│
├── frontend-vite/           # 前端代码（用户看到的页面）
│   ├── src/
│   │   ├── app/            # 📍 页面入口（每个文件夹=一个页面）
│   │   │   ├── page.tsx            → 首页 (/)
│   │   │   ├── projects/page.tsx   → 项目页 (/projects)
│   │   │   ├── blog/page.tsx       → 博客页 (/blog)
│   │   │   └── about/page.tsx      → 关于页 (/about)
│   │   │
│   │   ├── components/     # 🧩 可复用组件（按钮、卡片等）
│   │   ├── lib/           # 🔧 工具函数
│   │   │   └── api.ts     # 📍 API 调用（与后端通信的桥梁）
│   │   └── types/         # 📘 TypeScript 类型定义
│   │
│   └── package.json        # 依赖列表（类似 Python 的 requirements.txt）
│
├── backend/                # 后端代码（处理数据和业务逻辑）
│   ├── src/
│   │   ├── main.rs        # 📍 程序入口（服务器启动点）
│   │   ├── handlers.rs    # 📍 请求处理器（类似 Flask 的路由函数）
│   │   ├── models.rs      # 📦 数据结构定义
│   │   └── services/      # 💼 业务逻辑层
│   │       ├── project.rs      → 项目相关逻辑
│   │       ├── blog.rs         → 博客相关逻辑
│   │       ├── activity.rs     → 活动记录逻辑
│   │       └── ...
│   │
│   ├── migrations/        # 🗄️ 数据库表结构定义（SQL 文件）
│   ├── static/           # 📦 前端构建产物（由 frontend-vite 生成）
│   └── Cargo.toml        # 依赖列表（类似 package.json）
│
└── docs/                 # 📚 项目文档
```

### 1.4 数据流向（最重要！）

```
用户浏览器
    ↓ (访问 http://localhost:8000)
Rust 静态文件服务
    ↓ (返回 index.html + JS)
React 前端加载
    ↓ (用户点击"项目"按钮)
前端发送 API 请求 (GET /api/projects)
    ↓
Rust Axum 路由匹配
    ↓
handlers.rs::get_projects()
    ↓
services/project.rs::get_all_projects()
    ↓ (查询数据库)
MySQL 数据库
    ↓ (返回数据)
JSON 响应
    ↓
前端接收并渲染
    ↓
用户看到项目列表
```

---

## 2. 关键路径 - 追踪一次完整请求

### 场景：用户访问项目列表页

让我们跟着代码走一遍完整流程 👣

#### Step 1: 用户点击导航栏的"Projects"

**文件**: `frontend-vite/src/app/layout.tsx`

```typescript
// 导航链接定义
<Link href="/projects">Projects</Link>
```

#### Step 2: React Router 路由到项目页面

**文件**: `frontend-vite/src/app/projects/page.tsx`

```typescript
'use client';
import { useState, useEffect } from 'react';
import { getProjects } from '@/lib/api';  // 📍 调用 API

export default function ProjectsPage() {
  const [projects, setProjects] = useState([]);
  
  useEffect(() => {
    // 📍 页面加载时获取项目数据
    getProjects().then(setProjects);
  }, []);
  
  return <div>展示项目列表...</div>
}
```

#### Step 3: 前端发送 HTTP 请求

**文件**: `frontend-vite/src/lib/api.ts`

```typescript
const API_BASE_URL = "http://localhost:8000";

export async function getProjects(): Promise<Project[]> {
  // 📍 发送 GET 请求到后端
  const response = await fetch(`${API_BASE_URL}/api/projects`);
  return response.json();
}
```

#### Step 4: 后端路由匹配

**文件**: `backend/src/main.rs`

```rust
// 📍 定义路由规则
let api_routes = Router::new()
    .route("/projects", get(get_projects))  // ← 匹配这条
    .route("/blog/posts", get(get_blog_posts))
    .with_state(app_state);

let app = Router::new()
    .nest("/api", api_routes)  // 所有 /api/* 请求
    // ...
```

#### Step 5: 调用请求处理器

**文件**: `backend/src/handlers.rs`

```rust
// 📍 处理 GET /api/projects 请求
pub async fn get_projects(
    State(state): State<AppState>,  // 获取数据库连接
) -> Result<Json<Vec<ProjectResponse>>, (StatusCode, Json<ErrorResponse>)> {
  
    // 📍 调用业务逻辑层
    match services::project::get_all_projects(&state.db).await {
        Ok(projects) => Ok(Json(projects)),
        Err(e) => {
            eprintln!("Error fetching projects: {}", e);
            Err((
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(ErrorResponse {
                    error: "Failed to fetch projects".to_string(),
                }),
            ))
        }
    }
}
```

#### Step 6: 执行业务逻辑

**文件**: `backend/src/services/project.rs`

```rust
// 📍 实际的数据库查询
pub async fn get_all_projects(
    pool: &MySqlPool
) -> Result<Vec<ProjectResponse>, sqlx::Error> {
  
    // 📍 SQL 查询（从数据库读取）
    let projects = sqlx::query_as::<_, Project>(
        "SELECT * FROM projects ORDER BY created_at DESC"
    )
    .fetch_all(pool)
    .await?;
  
    // 转换为 API 响应格式
    Ok(projects.into_iter().map(|p| ProjectResponse {
        id: p.id,
        name: p.name,
        description: p.description,
        // ...
    }).collect())
}
```

#### Step 7: 数据库返回结果

**表结构**: `backend/migrations/001_initial.sql`

```sql
CREATE TABLE projects (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    github_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Step 8: 前端渲染页面

**文件**: `frontend-vite/src/app/projects/page.tsx`

```typescript
return (
  <div>
    {projects.map(project => (
      <ProjectCard key={project.id} project={project} />
    ))}
  </div>
);
```

### 🎯 关键理解点

1. **前端只负责展示**，不直接操作数据库
2. **后端负责数据处理**，通过 API 提供数据
3. **handlers.rs 是"门面"**，实际逻辑在 services/ 目录
4. **数据库结构在 migrations/**，修改表结构要写 SQL

---

## 3. 文件导航 - 出问题去哪里改

下面是按常见问题/功能区域归类的文件导航，遇到问题时先去这些位置查看：

1) 前端页面显示问题（UI 不对、样式错位、组件异常）

   - 主要位置：`frontend-vite/src/app/`（页面入口）
   - 组件：`frontend-vite/src/components/`
   - 样式：`frontend-vite/src/styles/` 或 `tailwind.config.js`
   - 网络请求：`frontend-vite/src/lib/api.ts`（API 调用集中处）

   常见修复流程：

   - 用浏览器 DevTools 检查元素和网络请求（Network）
   - 如果接口返回错误，记录请求 URL 与响应（HTTP 状态码 + body）
   - 在 `lib/api.ts` 找到对应函数，确认 URL 是否与后端匹配
   - 如果前端渲染问题，检查组件 props、TypeScript 类型以及 CSS 类名
2) API 返回错误或 5xx（后端异常）

   - 主要位置：`backend/src/handlers.rs`（入口处理）
   - 业务逻辑：`backend/src/services/`（具体实现）
   - 数据模型：`backend/src/models.rs`
   - 数据库迁移：`backend/migrations/`（表结构和初始数据）

   常见修复流程：

   - 在后端运行 `cargo run`，观察终端日志与错误堆栈
   - 找到 `handlers.rs` 中对应路由的处理函数，增加日志打印查看流程
   - 向上追踪到 `services/*` 的实现，运行对应函数的最小测试（或调用）以重现错误
   - 检查 SQLx 查询与 migration 表结构是否匹配（字段名/类型/NULL 约束）
3) 数据库相关问题（连接失败、查询异常、迁移失败）

   - 配置：`backend/.env` 或 环境变量（检查启动脚本 `run.ps1` / `run.sh`）
   - 迁移脚本：`backend/migrations/*.sql`
   - 本地调试：使用 MySQL 客户端连接并执行迁移脚本

   常见修复流程：

   - 确保 `DATABASE_URL` 环境变量配置正确
   - 运行 `diesel migration run` 或手动使用 `mysql` 运行 SQL 文件
   - 如果使用 SQLx，运行 `cargo sqlx prepare`（如果配置了）以生成校验缓存
4) 构建/部署问题（静态文件未更新、端口冲突）

   - 前端构建：`frontend-vite/package.json`（`npm run build` 输出到 `../backend/static`）
   - 后端运行：`backend/Cargo.toml` + `cargo run`（会在 8000 端口启动）
   - 一键构建脚本：项目根的 `build.ps1` / `build.sh`

   常见修复流程：

   - 先单独构建前端：`cd frontend-vite && npm run build`，确认 `backend/static` 有最新文件
   - 再构建后端：`cd backend && cargo run`（或 `cargo build --release` 用于生产）
   - 检查端口冲突（Windows: 使用 `netstat -ano | Select-String 8000`）
5) TypeScript/前端类型错误

   - 位置：`frontend-vite/tsconfig.json`、`src/types/`、以及具体组件文件
   - 修复流程：运行 `npm run dev` 或 `npm run build`，观察 TypeScript 报错并修复类型声明
6) Rust 编译或类型错误

   - 位置：后端源码（`backend/src/**/*.rs`）
   - 修复流程：运行 `cargo build` 或 `cargo check`，按照编译器提示修改类型或生命周期问题

---

## 4. 实战演练 - 修改一个功能

接下来通过一个小示例，带你从业务需求到代码修改、测试与发布的完整流程。

示例任务：把项目列表页的 API 调用从后端 `GET /api/projects` 替换为读取本地 mock JSON（用于离线调试或后端暂不可用的场景）。

目标效果：在不改动后端的前提下，前端能显示本地 mock 的项目列表。此练习会帮你熟悉前端结构、API 调用位置与快速回归验证方法。

步骤分解：

1) 在前端创建 mock 数据

   - 新建文件：`frontend-vite/src/__mocks__/projects.json`
   - 内容示例：
     ```json
     [
         {"id":1,"name":"Project Alpha","description":"Demo project"},
         {"id":2,"name":"Project Beta","description":"Another demo"}
     ]
     ```
2) 修改 API 层，使其支持 mock 模式

   - 文件：`frontend-vite/src/lib/api.ts`
   - 建议改动（伪码）：
     ```typescript
     const USE_MOCK = import.meta.env.DEV && true; // 临时打开

     export async function getProjects(): Promise<Project[]> {
         if (USE_MOCK) {
             const res = await fetch('/src/__mocks__/projects.json');
             return res.json();
         }
         const response = await fetch(`${API_BASE_URL}/api/projects`);
         return response.json();
     }
     ```
3) 本地启动前端进行验证

   - 运行：
     ```powershell
     cd frontend-vite
     npm run dev
     ```
   - 打开浏览器访问 `http://localhost:3000/projects`，确认页面渲染 mock 数据
4) 回滚到真实 API（发布前）

   - 注释 `USE_MOCK` 或使用环境变量控制
   - 确保 `frontend-vite` 的构建不会包含本地 mock（通过 `.gitignore` 或构建脚本）
5) 如果希望把 mock 方案作为临时 feature 合入仓库，创建 Feature Branch：

   ```bash
   git checkout -b feat/mock-projects
   git add src/__mocks__/projects.json src/lib/api.ts
   git commit -m "feat: add mock projects for offline dev"
   git push origin feat/mock-projects
   ```

调试技巧：

- 使用浏览器 Network 面板查看是否从 `projects.json` 加载
- 控制台 `console.log`（临时）打印 `getProjects()` 返回值
- 如果 `fetch` 返回 404，确认 `vite` 的静态资源路径设置（可能需使用 `/src/__mocks__/projects.json` 或 `import projects from './__mocks__/projects.json'`）

此示例让你练习：

- 在前端快速定位 API 调用点
- 在不触动后端的情况下验证页面
- 使用分支保留临时改动以便代码审查

---

## 5. 常见问题定位

下面列出一些常见问题、快速诊断步骤和推荐修复点，便于你在遇到问题时快速定位并解决。

- 问题：页面不显示数据（空白或加载中无限循环）

  - 诊断：打开浏览器 DevTools → Network，检查 API 是否被请求，返回码是多少（200/404/500）
  - 去哪看： `frontend-vite/src/lib/api.ts` → `frontend-vite/src/app/projects/page.tsx`
  - 修复方向：如果返回 500，去后端 `handlers.rs` 查看日志；如果 404，检查前端请求的 URL 是否正确；如果没有请求，检查 useEffect 或路由是否生效。
- 问题：样式错位/样式没有生效

  - 诊断：检查 DevTools 中元素的 class，确认 Tailwind 是否在构建中被正确加载
  - 去哪看：`frontend-vite/src/styles/globals.css`、`tailwind.config.js`、`vite.config.ts`
  - 修复方向：重新构建前端 `npm run build`，或在 dev 模式下查看控制台是否有 Tailwind 的构建错误
- 问题：后端报 SQLx 类型错误或编译失败

  - 诊断：运行 `cargo build`，读取 Rust 编译器的错误提示（非常明确）
  - 去哪看：`backend/src/services/*.rs`、`backend/src/models.rs`、`backend/migrations/*.sql`
  - 修复方向：对照 migration 文件修正 SQL 查询字段名或模型结构，使用 `cargo sqlx prepare`（如启用）生成校验缓存
- 问题：静态文件未更新（生产环境）

  - 诊断：确认 `backend/static/` 中的文件是否为最新构建产物
  - 去哪看：`frontend-vite` 构建日志、`backend/static/` 目录、部署脚本（`build.ps1`）
  - 修复方向：按顺序运行前端构建再运行后端服务，或清理缓存后重新部署
- 问题：端口被占用或服务无法启动

  - 诊断：Windows 上使用 `netstat -ano | Select-String 8000` 查找占用 PID
  - 去哪看：查看正在运行的进程并结束或修改 `backend` 的监听端口
  - 修复方向：更换端口或停止占用进程

---

## 结语

按照上面的学习路线，你可以在 2-3 小时内掌握本项目的主要结构，1-2 天内能够独立做中等规模修改。

如果你愿意，我可以现在带你完成下面的任意一项（任选其一，马上开始执行）：

- A. 启动项目的本地开发环境（一步步运行前端/后端并确认页面可用）
- B. 跟你一起实现上面的 mock 示例，并提交一个 feature 分支
- C. 帮你写一份更简短的 "快速入门" README，放在项目根目录

请选择你想先做的，我会立刻开始并一步步带着你完成。

---

## 附录：3 天掌握项目时间表

### Day 1: 速成语法 + 项目结构 (2-3 小时)

**上午** (1 小时):

- ✅ 阅读第 0 章"语法速成"（重点看对照表）
- ✅ 用 Python 思维翻译前端/后端代码示例
- 🎯 目标：能看懂 60% 的代码含义

**下午** (1-2 小时):

- ✅ 阅读第 1 章"项目全貌"
- ✅ 运行本地开发环境（前端 + 后端）
- ✅ 在浏览器打开页面，对照代码看数据流向
- 🎯 目标：理解"用户点击按钮 → API 调用 → 数据库查询 → 页面渲染"完整流程

### Day 2: 深入关键路径 + 实战修改 (4-6 小时)

**上午** (2-3 小时):

- ✅ 阅读第 2 章"关键路径"（跟着代码追踪一次请求）
- ✅ 在代码中添加 `console.log`/`println!` 打印日志
- ✅ 修改一个字符串（如项目标题），观察页面变化
- 🎯 目标：能独立追踪一个功能的代码执行路径

**下午** (2-3 小时):

- ✅ 完成第 4 章"实战演练"（mock 数据示例）
- ✅ 提交一个 Git 分支
- 🎯 目标：能独立完成一个小功能的修改并提交代码

### Day 3: 独立调试 + 问题定位 (2-4 小时)

**上午** (1-2 小时):

- ✅ 阅读第 3 章"文件导航"和第 5 章"常见问题"
- ✅ 故意制造一个错误（如修改 API URL），练习定位和修复
- 🎯 目标：遇到问题能快速定位到对应文件

**下午** (1-2 小时):

- ✅ 选一个真实需求（如添加新字段、修改样式）
- ✅ 自己规划改动点 → 修改代码 → 测试 → 提交
- 🎯 目标：能独立完成中等规模的功能开发

---

## 快速参考卡片（打印或截图保存）

```
┌─────────────────────────────────────────────────┐
│  TypeScript/Rust 速查（给 Python 开发者）       │
├─────────────────────────────────────────────────┤
│  变量: const/let name = "value"                 │
│  函数: function/fn name() { ... }               │
│  异步: async/await（和 Python 一样）            │
│  列表: [...] 或 vec![...]                       │
│  遍历: forEach() 或 for x in list               │
│  条件: if (条件) { ... } else { ... }          │
│  错误: try/catch 或 Result<Ok, Err>             │
├─────────────────────────────────────────────────┤
│  忽略类型标注（: number, -> Vec<T>）            │
│  关注函数名和调用链                             │
│  用 Python 思维翻译代码逻辑                     │
└─────────────────────────────────────────────────┘
```

---

**最后的建议**: 不要试图一次学完所有技术细节，先用 80/20 原则掌握核心概念，在实践中逐步深入。遇到不懂的语法直接问我或查 MDN/Rust Book，但永远记住："看懂代码在做什么"比"完全理解语法"更重要。
