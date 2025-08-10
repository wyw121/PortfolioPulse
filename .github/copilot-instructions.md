# PortfolioPulse - 个人项目集动态平台

## 项目概述

PortfolioPulse 是一个现代化的个人项目展示和动态追踪平台，专注于集成多个个人项目到统一的主页中，让访问者能够查看最新的开发动态、学习进展和项目跳转访问。该平台采用现代 Web 技术栈，提供实时的 Git 提交追踪、学习记录展示和项目集成管理功能。

**设计参考**: [sindresorhus.com](https://sindresorhus.com) - 简洁现代的个人主页典范

## 核心技术栈

### 前端技术栈

- **Next.js 15**: React 全栈框架，App Router，支持 SSR/SSG
- **TypeScript**: 类型安全，使用严格模式
- **Tailwind CSS**: 原子化 CSS 框架
- **shadcn/ui**: 基于 Radix UI 的现代组件库
- **Zustand**: 轻量级状态管理
- **React Hook Form**: 表单管理
- **Framer Motion**: 动画库

### 后端技术

- **Rust**: 系统级编程语言，用于 API 服务
- **MySQL**: 关系型数据库

### 部署平台

- **Vercel**: 前端部署和托管

## 项目结构

```
PortfolioPulse/
├── .github/                    # GitHub 配置和 Copilot 指令
├── src/
│   └── portfolio_pulse/        # 主要源码目录
├── frontend/                   # Next.js 前端应用
│   ├── app/                   # Next.js App Router
│   ├── components/            # React 组件
│   │   ├── ui/               # shadcn/ui 基础组件
│   │   └── custom/           # 自定义业务组件
│   ├── lib/                  # 工具库和配置
│   ├── hooks/                # 自定义 React Hooks
│   ├── store/                # Zustand 状态管理
│   └── types/                # TypeScript 类型定义
├── backend/                   # Rust 后端服务
│   ├── src/                  # Rust 源码
│   ├── migrations/           # 数据库迁移文件
│   └── Cargo.toml           # Rust 项目配置
├── database/                  # 数据库相关
│   ├── schema/               # 数据库架构
│   └── seeds/                # 测试数据
├── docs/                     # 项目文档
└── scripts/                  # 构建和部署脚本
```

## 开发环境要求

### 必需工具版本

- **Node.js**: >= 18.17.0 (推荐使用 LTS 版本)
- **npm**: >= 9.0.0 或 **pnpm**: >= 8.0.0
- **Rust**: >= 1.75.0
- **MySQL**: >= 8.0

### 环境变量

项目需要以下环境变量：

- `DATABASE_URL`: MySQL 数据库连接字符串
- `NEXTAUTH_SECRET`: NextAuth.js 密钥
- `GITHUB_TOKEN`: GitHub API 访问令牌
- `VERCEL_TOKEN`: Vercel 部署令牌

## 构建和开发指南

### 初始化项目

```bash
# 安装前端依赖
cd frontend && npm install

# 设置 Rust 工具链
rustup update stable

# 安装数据库工具
cargo install diesel_cli --no-default-features --features mysql
```

### 开发服务器

```bash
# 启动前端开发服务器 (端口 3000)
cd frontend && npm run dev

# 启动 Rust 后端服务器 (端口 8000)
cd backend && cargo run --release
```

### 构建和测试

```bash
# 前端构建和测试
cd frontend
npm run build      # 生产构建
npm run test       # 运行测试
npm run lint       # 代码检查

# 后端构建和测试
cd backend
cargo build --release    # 生产构建
cargo test               # 运行测试
cargo clippy             # 代码检查
```

### 数据库管理

```bash
# 运行数据库迁移
cd backend && diesel migration run

# 重置数据库
diesel database reset

# 创建新迁移
diesel migration generate <migration_name>
```

## 编码规范

### TypeScript/JavaScript 规范

- 使用 ESLint + Prettier 进行代码格式化
- 优先使用函数式组件和 React Hooks
- 使用 TypeScript 严格模式
- 组件名使用 PascalCase，文件名使用 kebab-case
- 使用绝对路径导入 (`@/components/ui/button`)

### Rust 编码规范

- 遵循 Rust 官方编码风格指南
- 使用 `rustfmt` 和 `clippy` 保证代码质量
- 优先使用 `Result<T, E>` 进行错误处理
- 使用 `tokio` 进行异步编程
- API 响应使用结构化的 JSON 格式

### 数据库设计原则

- 使用 snake_case 命名表和字段
- 所有表必须有主键和时间戳字段
- 外键关系明确定义
- 使用索引优化查询性能

## 核心功能模块

### 1. 用户认证与授权

- GitHub OAuth 集成
- JWT 令牌管理
- 用户权限控制

### 2. 项目动态追踪

- Git 提交历史抓取
- 代码变更统计
- 提交时间线展示

### 3. 学习记录管理

- 学习内容记录
- 进度追踪
- 知识标签系统

### 4. 项目展示模块

- 项目卡片展示
- 实时状态更新
- 跳转链接管理

### 5. 数据可视化

- 提交活动图表
- 学习进度图表
- 项目统计面板

## UI/UX 设计指导

### 设计原则

- 现代简洁的设计风格
- 支持明暗主题切换
- 响应式设计，移动端友好
- 无障碍访问支持

### 组件使用

- 优先使用 shadcn/ui 组件
- 保持设计系统一致性
- 遵循 Material Design 或类似设计语言
- 使用语义化的颜色变量

## 部署和运维

### Vercel 前端部署

- 自动化 CI/CD 集成
- 分支预览功能
- 环境变量管理

### 后端服务部署

- Docker 容器化部署
- 数据库迁移自动化
- 监控和日志记录

## 性能和安全

### 性能优化

- Next.js 图片优化
- 组件懒加载
- API 响应缓存
- 数据库查询优化

### 安全措施

- CORS 配置
- SQL 注入防护
- XSS 攻击防护
- 敏感数据加密

## 开发最佳实践

1. **始终运行测试**: 提交前确保所有测试通过
2. **遵循 Git 提交规范**: 使用 Conventional Commits
3. **代码审查**: 所有 PR 需要审查
4. **文档更新**: 功能变更时同步更新文档
5. **环境一致性**: 使用 Docker 保证开发环境一致

## 故障排查

### 常见问题

- **端口冲突**: 检查 3000 和 8000 端口是否被占用
- **数据库连接失败**: 验证环境变量和数据库服务状态
- **依赖安装失败**: 清除 node_modules 和 Cargo 缓存重新安装
- **构建失败**: 检查 TypeScript 类型错误和 Rust 编译错误

### 调试技巧

- 使用浏览器开发者工具调试前端
- 使用 `cargo test` 和 `println!` 调试 Rust 代码
- 查看 Vercel 部署日志排查部署问题

## 重要提醒

- 该项目处于活跃开发阶段，架构可能发生变化
- 提交代码前请运行完整的测试套件
- 遵循项目的 Git 分支策略
- 及时更新依赖包，关注安全更新
- 保持代码简洁可读，优先选择可维护性而非过度优化
