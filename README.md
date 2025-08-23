# PortfolioPulse - 个人项目集动态平台

<div align="center">

![PortfolioPulse Logo](./docs/assets/logo.png)

一个集成多个个人项目的动态展示平台，使用**统一 Rust 架构**提供高性能的全栈解决方案。

[![Build Status](https://github.com/wyw121/PortfolioPulse/workflows/CI/badge.svg)](https://github.com/wyw121/PortfolioPulse/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.2-blue)](https://www.typescriptlang.org/)
[![Vite](https://img.shields.io/badge/Vite-5.4-purple)](https://vitejs.dev/)
[![Rust](https://img.shields.io/badge/Rust-1.75-orange)](https://www.rust-lang.org/)
[![React](https://img.shields.io/badge/React-18-cyan)](https://reactjs.org/)

</div>

## 🎉 重大架构重构 (2025-08-23)

**从 Next.js + Rust 双服务器 → 统一 Rust 单体应用**

- ✅ **前端技术栈**: Next.js 15 → Vite + React 18
- ✅ **路由系统**: App Router → React Router 6  
- ✅ **部署模式**: 双端口 → 单端口 8000
- ✅ **服务架构**: 双进程 → 单一 Rust 二进制
- ✅ **内存占用**: 大幅降低，启动更快

[查看完整重构报告 →](FRONTEND_REFACTOR_REPORT.md)

## 📚 文档导航

### 🎯 AI开发指令 (GitHub Copilot)
- **🤖 核心指令**: [.github/copilot-instructions.md](.github/copilot-instructions.md) - GitHub Copilot 项目指令中心
- **📁 模块化指令**: [.github/instructions/](.github/instructions/) - 分模块开发规范
- **📝 提示模板**: [.github/prompts/](.github/prompts/) - 可复用的 Copilot 提示模板

### 📋 重构文档
- **🎉 重构报告**: [FRONTEND_REFACTOR_REPORT.md](FRONTEND_REFACTOR_REPORT.md) - 前端重构完成报告  
- **� 二进制部署**: [.github/instructions/binary-deployment.instructions.md](.github/instructions/binary-deployment.instructions.md) - 统一部署指南
- **�️ 文档索引**: [docs/DOCUMENTATION_INDEX.md](docs/DOCUMENTATION_INDEX.md) - 完整文档导航

### 🛠️ 技术文档
- **🏗️ 系统架构**: [docs/SYSTEM_ARCHITECTURE_ANALYSIS.md](docs/SYSTEM_ARCHITECTURE_ANALYSIS.md) - 架构设计详解
- **🛠️ 技术实现**: [docs/TECHNICAL_IMPLEMENTATION_GUIDE.md](docs/TECHNICAL_IMPLEMENTATION_GUIDE.md) - 技术栈指南
- **🎨 设计规范**: [docs/PROJECT_STYLE_GUIDE.md](docs/PROJECT_STYLE_GUIDE.md) - UI/UX设计系统

## ✨ 主要特性

- 🚀 **现代技术栈**: Vite + React 18 + Tailwind CSS + shadcn/ui + Zustand + Rust + MySQL
- 📊 **实时动态追踪**: Git 提交历史、代码变更统计、活动时间线
- 📚 **学习记录管理**: 学习内容记录、进度追踪、知识标签系统
- 🎨 **项目展示**: 项目卡片展示、实时状态更新、跳转链接管理
- 📈 **数据可视化**: 提交活动图表、学习进度图表、统计面板
- 🌙 **主题切换**: 支持明暗主题无缝切换
- 📱 **响应式设计**: 完美适配桌面和移动设备
- 🦀 **统一部署**: 单个 Rust 二进制文件，简化部署流程

## 🛠️ 技术架构

### 前端技术栈
- **Vite**: 快速的前端构建工具
- **React 18**: 现代化 React 框架
- **TypeScript**: 类型安全的 JavaScript
- **React Router**: 客户端路由管理
- **Tailwind CSS**: 实用优先的 CSS 框架
- **shadcn/ui**: 现代化组件库
- **Zustand**: 轻量级状态管理

### 后端技术栈
- **Rust**: 高性能系统级编程语言
- **Tokio**: 异步运行时
- **Diesel**: ORM 数据库工具
- **MySQL**: 关系型数据库
- **JWT**: 身份认证

## 🚀 快速开始

### 开发环境要求

- Node.js >= 18.17.0
- Rust >= 1.75.0
- MySQL >= 8.0
- Git

### 本地开发

1. **克隆仓库**
   ```bash
   git clone https://github.com/wyw121/PortfolioPulse.git
   cd PortfolioPulse
   ```

2. **一键构建（推荐）**
   ```bash
   # Windows
   ./build.ps1

   # Linux/macOS
   ./build.sh
   ```

3. **启动应用**
   ```bash
   cd backend
   cargo run --release
   # 应用运行在 http://localhost:8000
   # 前端和 API 都通过同一端口访问
   ```

### 开发模式（前后端分离）

如果你需要前后端分离开发：

1. **启动后端服务**
   ```bash
   cd backend
   cargo run
   # 后端 API 运行在 http://localhost:8000
   ```

2. **启动前端开发服务器**
   ```bash
   cd frontend-vite
   npm install
   npm run dev
   # 前端开发服务器运行在 http://localhost:3000
   # 自动代理 API 请求到后端
   ```

### 生产部署

**推荐的统一部署方式**：

1. **构建应用**
   ```bash
   ./build.ps1  # 或 ./build.sh
   ```

2. **部署到服务器**
   ```bash
   # 复制构建产物到服务器
   scp -r backend/target/release/portfolio-pulse-backend user@server:/opt/portfoliopulse/
   scp -r backend/static user@server:/opt/portfoliopulse/

   # 在服务器上启动
   cd /opt/portfoliopulse
   ./portfolio-pulse-backend
   ```

3. **访问应用**
   - 完整应用：http://your-server-ip:8000
   - API 端点：http://your-server-ip:8000/api/*

📋 详细部署指南请参考：[BINARY_DEPLOYMENT_GUIDE.md](BINARY_DEPLOYMENT_GUIDE.md)

7. **访问应用**

   打开浏览器访问 `http://localhost:3000`

## 📁 项目结构

```
PortfolioPulse/
├── .github/                    # GitHub 配置和 Copilot 指令
│   ├── workflows/             # CI/CD 工作流
│   ├── instructions/          # 模块化开发指令
│   ├── prompts/              # 项目提示模板
│   └── copilot-instructions.md
├── frontend-vite/             # Vite + React 前端应用 (新)
│   ├── src/                  # 源代码
│   │   ├── components/       # React 组件
│   │   ├── pages/           # 页面组件
│   │   ├── styles/          # 样式文件
│   │   ├── lib/             # 工具库
│   │   ├── hooks/           # 自定义 Hooks
│   │   └── types/           # TypeScript 类型
│   ├── vite.config.ts       # Vite 配置
│   └── package.json         # 依赖管理
├── frontend/                  # Next.js 应用 (备份保留)
├── backend/                   # Rust 后端服务
│   ├── static/               # 前端构建输出 (新)
│   ├── src/                  # Rust 源码
│   │   ├── models/           # 数据模型
│   │   ├── handlers/         # API 处理器
│   │   ├── services/         # 业务逻辑层
│   │   └── main.rs          # 入口文件 (含静态文件服务)
│   ├── migrations/           # 数据库迁移
│   └── Cargo.toml           # Rust 项目配置
├── database/                  # 数据库相关
├── docs/                     # 项目文档
├── scripts/                  # 构建和部署脚本
├── build.ps1                 # Windows 构建脚本 (新)
├── build.sh                  # Linux/macOS 构建脚本 (新)
├── .vscode/tasks.json        # VS Code 任务配置 (更新)
└── FRONTEND_REFACTOR_REPORT.md  # 重构报告 (新)
```

## 🔧 开发指南

### 代码规范

- **前端**: ESLint + Prettier，TypeScript 严格模式
- **后端**: rustfmt + clippy，Rust 官方编码规范
- **Git**: Conventional Commits 提交规范

### VS Code 开发任务

使用 `Ctrl/Cmd + Shift + P` 打开命令面板，搜索 "Tasks: Run Task"：

- **🏗️ 构建完整应用** - 构建前端和后端 (默认)
- **🚀 启动完整应用 (生产)** - 构建并启动生产版本
- **🎨 构建前端** - 仅构建前端
- **🦀 构建后端** - 仅构建后端
- **🚀 启动前端开发** - 前端开发服务器
- **🚀 启动后端服务** - 后端开发服务器

### 测试策略

```bash
# 前端测试
cd frontend-vite
npm run test        # 单元测试 (配置中)
npm run lint        # 代码检查

# 后端测试
cd backend
cargo test          # Rust 单元测试
cargo test --integration  # 集成测试
```

### 代码检查

```bash
# 前端代码检查
npm run lint
npm run type-check

# 后端代码检查
cargo clippy
cargo fmt --check
```

## 📊 核心功能

### 1. 项目动态追踪
- Git 提交历史自动抓取
- 代码变更统计和可视化
- 开发活跃度分析

### 2. 学习记录系统
- 学习内容分类管理
- 进度追踪和统计
- 知识点标签化

### 3. 项目集成展示
- 项目卡片动态展示
- 实时状态更新
- 一键跳转访问

### 4. 数据可视化面板
- GitHub 风格的提交热力图
- 学习进度图表
- 项目统计仪表板

## 🚀 部署

### Vercel 部署 (推荐)

1. 连接 GitHub 仓库到 Vercel
2. 配置环境变量
3. 自动部署

### 手动部署

```bash
# 构建前端
cd frontend
npm run build

# 构建后端
cd backend
cargo build --release

# 运行生产服务
./target/release/portfolio-pulse-backend
```

## 🤝 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

### 贡献规范
- 遵循现有代码风格
- 添加适当的测试用例
- 更新相关文档
- 确保 CI/CD 检查通过

## 📝 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 💬 联系方式

- **作者**: wyw121
- **GitHub**: [@wyw121](https://github.com/wyw121)
- **项目链接**: [PortfolioPulse](https://github.com/wyw121/PortfolioPulse)

## 🙏 致谢

感谢以下优秀的开源项目：

- [Next.js](https://nextjs.org/) - React 全栈框架
- [Tailwind CSS](https://tailwindcss.com/) - CSS 框架
- [shadcn/ui](https://ui.shadcn.com/) - 组件库
- [Rust](https://www.rust-lang.org/) - 系统编程语言
- [Vercel](https://vercel.com/) - 部署平台

---

<div align="center">

**⭐ 如果这个项目对你有帮助，请给个 Star！ ⭐**

[演示地址](https://portfolio-pulse.vercel.app) · [报告 Bug](https://github.com/wyw121/PortfolioPulse/issues) · [功能建议](https://github.com/wyw121/PortfolioPulse/issues)

</div>
