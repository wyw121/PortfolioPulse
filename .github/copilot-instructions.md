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

### 部署策略

- **二进制部署**: 采用原生二进制文件部署，无 Docker 依赖
- **前端**: Next.js Standalone 输出 + Node.js 二进制运行 (端口 3000)
- **后端**: Rust 编译的原生二进制文件 (端口 8000)
- **反向代理**: Nginx 负责路由分发和静态文件服务
- **数据库**: 独立 MySQL 服务 (端口 3306)

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
# 前端依赖安装 (Windows PowerShell)
cd frontend
npm install

# Rust 工具链设置
rustup update stable
rustup target add x86_64-pc-windows-msvc

# 数据库工具安装
cargo install diesel_cli --no-default-features --features mysql
```

### 二进制构建流程

```bash
# 后端二进制构建 (生产版本)
cd backend
cargo build --release
# 输出: target/release/portfolio_pulse.exe (Windows)

# 前端 Standalone 构建
cd frontend
npm run build
# 输出: .next/standalone/ 目录 (可直接运行的 Node.js 应用)
```

### 开发服务器

```bash
# 前端开发服务器 (端口 3000)
cd frontend && npm run dev

# 后端开发服务器 (端口 8000)
cd backend && cargo run --release
```

### 生产部署流程

```bash
# 1. 构建二进制文件
cd backend && cargo build --release
cd frontend && npm run build

# 2. 服务器部署目录结构
/opt/portfoliopulse/
├── portfolio_pulse          # Rust 二进制文件
├── frontend/
│   ├── .next/standalone/    # Next.js 应用
│   └── .next/static/       # 静态资源
├── start.sh                # 启动脚本
└── .env                    # 环境变量

# 3. 启动服务 (Linux 服务器)
chmod +x start.sh
./start.sh
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

### 设计风格定位

- **选定风格**: 渐变科技风格（Gradient Tech）
- **参考标杆**: Vercel、Stripe
- **布局模式**: Vercel 风格 - 大屏中心式布局
- **核心理念**: 简洁现代、科技感强、专业展示

### 色彩系统

#### 品牌主色调

```css
/* 蓝紫粉渐变主题 */
--primary-gradient: linear-gradient(
  135deg,
  #3b82f6 0%,
  #8b5cf6 50%,
  #ec4899 100%
);
--primary-blue: #3b82f6; /* 主蓝色 */
--primary-purple: #8b5cf6; /* 主紫色 */
--primary-pink: #ec4899; /* 主粉色 */
```

#### 暗色模式配色（主要）

```css
:root[data-theme="dark"] {
  --bg-primary: #0f0f0f; /* 主背景 - 极深灰 */
  --bg-secondary: #1e1e1e; /* 卡片背景 - 深灰 */
  --bg-tertiary: #2a2a2a; /* 悬停背景 - 中灰 */
  --text-primary: #ffffff; /* 主文字 - 纯白 */
  --text-secondary: #a3a3a3; /* 辅助文字 - 中灰 */
  --text-muted: #6b7280; /* 弱化文字 - 浅灰 */
}
```

### 核心交互效果

#### 渐变边框效果（重要）

```css
.gradient-border:hover::before {
  content: "";
  position: absolute;
  inset: 0;
  padding: 1px;
  background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 50%, #ec4899 100%);
  border-radius: inherit;
  mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  mask-composite: xor;
}
```

#### 标准交互规范

- **悬停提升**: translateY(-4px) + 发光阴影
- **过渡动画**: 300ms cubic-bezier(0.4, 0, 0.2, 1)
- **发光效果**: 品牌色阴影 (rgba(59, 130, 246, 0.3))

### 布局特色

- **极简主义设计**: 大量留白空间，内容居中对齐
- **全屏 Hero Section**: 突出个人品牌和核心信息
- **卡片式展示**: 项目以 3 列网格形式展示
- **响应式设计**: 完美适配各种屏幕尺寸

### 组件使用原则

- 优先使用 shadcn/ui 组件，自定义渐变科技风格
- 统一使用 Inter 字体系统 + JetBrains Mono 代码字体
- 严格遵循色彩变量，避免硬编码颜色
- 确保色彩对比度符合 WCAG AA 标准

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
- **设计风格**: 已确定渐变科技风格（Gradient Tech），参考 Vercel 布局
- **核心交互**: 渐变边框悬停效果、300ms 过渡动画、translateY(-4px) 提升
- **色彩系统**: 蓝紫粉渐变主题，暗色模式为主，高对比度文字
- 提交代码前请运行完整的测试套件
- 遵循项目的 Git 分支策略
- 及时更新依赖包，关注安全更新
- 保持代码简洁可读，优先选择可维护性而非过度优化
- **UI 开发**: 严格遵循设计系统，使用 CSS 变量，确保响应式设计

## PowerShell 脚本禁用策略 (2025-08-11)

**问题**: PowerShell 终端频繁出现栈溢出崩溃 (退出码: -1073741571)，影响开发体验和 GitHub Copilot Agent 功能。

**根本原因**: VS Code Shell Integration 与某些 PowerShell 脚本产生递归调用冲突。

**解决方案**:

1. **禁用所有 PowerShell 脚本**: 项目中所有 `.ps1` 文件已被禁用，不再使用 PowerShell 脚本进行构建和部署
2. **VS Code 终端配置**: 已配置 "Safe PowerShell" 模式 (`-NoProfile -NoLogo`)
3. **Shell Integration**: 已禁用所有 VS Code 终端集成功能以避免冲突

**替代方案**:

- 使用 VS Code Tasks (tasks.json) 替代 PowerShell 脚本
- 使用 npm scripts (package.json) 进行前端操作
- 使用 cargo 命令进行后端操作
- 使用批处理 (.bat) 文件进行必要的系统操作

**禁用的脚本列表**:

- `init-database.ps1` - 数据库初始化
- `backend/run.ps1` - 后端启动脚本
- `backend/init-db.ps1` - 数据库初始化
- `scripts/*.ps1` - 所有构建、部署、修复脚本

**开发命令**:

```bash
# 前端开发
cd frontend && npm run dev

# 后端开发
cd backend && cargo run

# 构建
cd frontend && npm run build
cd backend && cargo build --release
```
