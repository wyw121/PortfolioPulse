# PortfolioPulse - 个人项目集动态平台

<div align="center">

![PortfolioPulse Logo](./docs/assets/logo.png)

一个集成多个个人项目的动态展示平台，让访问者能够实时查看开发动态、学习进展和项目访问。

[![Build Status](https://github.com/wyw121/PortfolioPulse/workflows/CI/badge.svg)](https://github.com/wyw121/PortfolioPulse/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue)](https://www.typescriptlang.org/)
[![Next.js](https://img.shields.io/badge/Next.js-15-black)](https://nextjs.org/)
[![Rust](https://img.shields.io/badge/Rust-1.75-orange)](https://www.rust-lang.org/)

</div>

## ✨ 主要特性

- 🚀 **现代技术栈**: Next.js 15 + Tailwind CSS + shadcn/ui + Zustand + Rust + MySQL
- 📊 **实时动态追踪**: Git 提交历史、代码变更统计、活动时间线
- 📚 **学习记录管理**: 学习内容记录、进度追踪、知识标签系统
- 🎨 **项目展示**: 项目卡片展示、实时状态更新、跳转链接管理
- 📈 **数据可视化**: 提交活动图表、学习进度图表、统计面板
- 🌙 **主题切换**: 支持明暗主题无缝切换
- 📱 **响应式设计**: 完美适配桌面和移动设备

## 🛠️ 技术架构

### 前端技术栈
- **Next.js 15**: React 全栈框架，App Router
- **TypeScript**: 类型安全的 JavaScript
- **Tailwind CSS**: 实用优先的 CSS 框架
- **shadcn/ui**: 现代化组件库
- **Zustand**: 轻量级状态管理
- **Vercel**: 部署和托管平台

### 后端技术栈
- **Rust**: 高性能系统级编程语言
- **Tokio**: 异步运行时
- **Diesel**: ORM 数据库工具
- **MySQL**: 关系型数据库
- **JWT**: 身份认证

## 🚀 快速开始

### 环境要求

- Node.js >= 18.17.0
- Rust >= 1.75.0
- MySQL >= 8.0
- Git

### 安装和运行

1. **克隆仓库**
   ```bash
   git clone https://github.com/wyw121/PortfolioPulse.git
   cd PortfolioPulse
   ```

2. **设置环境变量**
   ```bash
   cp .env.example .env.local
   # 编辑 .env.local 配置必要的环境变量
   ```

3. **安装前端依赖**
   ```bash
   cd frontend
   npm install
   ```

4. **安装后端依赖**
   ```bash
   cd backend
   cargo build
   ```

5. **数据库初始化**
   ```bash
   # 安装 Diesel CLI
   cargo install diesel_cli --no-default-features --features mysql
   
   # 运行迁移
   cd backend
   diesel migration run
   ```

6. **启动开发服务器**
   ```bash
   # 启动后端服务 (端口 8000)
   cd backend && cargo run
   
   # 启动前端服务 (端口 3000)
   cd frontend && npm run dev
   ```

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
├── frontend/                   # Next.js 前端应用
│   ├── app/                   # App Router 页面
│   ├── components/            # React 组件
│   │   ├── ui/               # shadcn/ui 基础组件
│   │   └── custom/           # 自定义业务组件
│   ├── lib/                  # 工具库和配置
│   ├── hooks/                # 自定义 React Hooks
│   ├── store/                # Zustand 状态管理
│   └── types/                # TypeScript 类型定义
├── backend/                   # Rust 后端服务
│   ├── src/                  # Rust 源码
│   │   ├── models/           # 数据模型
│   │   ├── handlers/         # API 处理器
│   │   ├── repositories/     # 数据访问层
│   │   └── utils/           # 工具函数
│   ├── migrations/           # 数据库迁移
│   └── Cargo.toml           # Rust 项目配置
├── database/                  # 数据库相关
│   ├── schema/               # 数据库架构
│   └── seeds/                # 测试数据
├── docs/                     # 项目文档
│   ├── api/                  # API 文档
│   ├── deployment/           # 部署文档
│   └── development/          # 开发文档
└── scripts/                  # 构建和部署脚本
```

## 🔧 开发指南

### 代码规范

- **前端**: ESLint + Prettier，TypeScript 严格模式
- **后端**: rustfmt + clippy，Rust 官方编码规范
- **Git**: Conventional Commits 提交规范

### 测试策略

```bash
# 前端测试
cd frontend
npm run test        # 单元测试
npm run test:e2e    # 端到端测试

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
