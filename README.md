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

## 📚 文档导航

> 📋 **完整文档索引**: [docs/DOCUMENTATION_INDEX.md](docs/DOCUMENTATION_INDEX.md)

### 🔗 快速链接
- **🤖 AI开发指令**: [.github/copilot-instructions.md](.github/copilot-instructions.md) - GitHub Copilot 开发指南
- **🏗️ 系统架构**: [docs/SYSTEM_ARCHITECTURE_ANALYSIS.md](docs/SYSTEM_ARCHITECTURE_ANALYSIS.md) - 架构设计详解
- **🛠️ 技术实现**: [docs/TECHNICAL_IMPLEMENTATION_GUIDE.md](docs/TECHNICAL_IMPLEMENTATION_GUIDE.md) - 技术栈指南
- **🚀 部署指南**: [docs/BINARY_DEPLOYMENT_GUIDE.md](docs/BINARY_DEPLOYMENT_GUIDE.md) - 二进制部署方案
- **🎨 设计规范**: [docs/PROJECT_STYLE_GUIDE.md](docs/PROJECT_STYLE_GUIDE.md) - UI/UX设计系统

## ✨ 主要特性

- 🚀 **现代技术栈**: Next.js 15 + Tailwind CSS + shadcn/ui
- 📊 **静态数据展示**: 项目和活动统计
- 📝 **Markdown博客**: 使用 Git + Markdown 管理博客内容,无需数据库
- 🎨 **项目展示**: 项目卡片展示、实时状态更新
- 🌙 **主题切换**: 支持明暗主题无缝切换
- 📱 **响应式设计**: 完美适配桌面和移动设备

## 🛠️ 技术架构

### 前端技术栈
- **Next.js 15**: React 全栈框架，App Router，SSG/ISR
- **TypeScript**: 类型安全的 JavaScript
- **Tailwind CSS**: 实用优先的 CSS 框架
- **shadcn/ui**: 现代化组件库
- **gray-matter + remark**: Markdown 解析和渲染

## 🚀 快速开始

### 环境要求

- Node.js >= 18.17.0
- Git

### 安装和运行

1. **克隆仓库**
   ```bash
   git clone https://github.com/wyw121/PortfolioPulse.git
   cd PortfolioPulse
   ```

2. **安装依赖**
   ```bash
   cd frontend
   npm install
   ```

3. **启动开发服务器**
   ```bash
   npm run dev
   ```

4. **访问应用**

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
│   ├── content/              # Markdown 内容
│   │   └── blog/             # 博客文章 (.md 文件)
│   ├── lib/                  # 工具库和配置
│   ├── hooks/                # 自定义 React Hooks
│   └── types/                # TypeScript 类型定义
├── docs/                     # 项目文档
│   ├── api/                  # API 文档
│   ├── deployment/           # 部署文档
│   └── development/          # 开发文档
└── scripts/                  # 构建和部署脚本
```

## 🔧 开发指南

### 代码规范

- **前端**: ESLint + Prettier，TypeScript 严格模式
- **Git**: Conventional Commits 提交规范

### 测试策略

```bash
# 前端测试
cd frontend
npm run test        # 单元测试
npm run test:e2e    # 端到端测试
```

### 代码检查

```bash
# 前端代码检查
npm run lint
npm run type-check
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
npm run start
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
- [Vercel](https://vercel.com/) - 部署平台

---

<div align="center">

**⭐ 如果这个项目对你有帮助，请给个 Star！ ⭐**

[演示地址](https://portfolio-pulse.vercel.app) · [报告 Bug](https://github.com/wyw121/PortfolioPulse/issues) · [功能建议](https://github.com/wyw121/PortfolioPulse/issues)

</div>
