# PortfolioPulse - GitHub Copilot 项目指令中心

## 🎯 项目核心信息

**项目名称**: PortfolioPulse - 个人项目集动态平台  
**技术栈**: Vite + React 18 + TypeScript + Rust Axum + MySQL  
**部署模式**: 统一 Rust 二进制部署 (端口 8000)  
**设计风格**: 渐变科技风格，参考 sindresorhus.com

## 🏗️ 架构概览

```
项目架构 (重构后):
├── frontend-vite/     # Vite + React 18 前端应用
├── backend/           # Rust Axum 服务器 + 静态文件服务
├── database/          # MySQL 数据库配置
└── docs/             # 完整技术文档
```

## 📋 开发指令模块

这些指令文件为 GitHub Copilot 提供精确的项目上下文：

### 🎯 核心指令
- `instructions/project-overview.instructions.md` - 项目整体规范
- `instructions/frontend-development.instructions.md` - 前端开发规范
- `instructions/backend-development.instructions.md` - 后端开发规范
- `instructions/database-design.instructions.md` - 数据库设计规范
- `instructions/ui-style-system.instructions.md` - UI设计系统

### 🚀 快速命令

```bash
# 开发服务器
cd frontend-vite && npm run dev        # 前端开发 (端口 3000)
cd backend && cargo run                # 后端开发 (端口 8000)

# 生产构建
./build.ps1                           # 统一构建脚本
# 或
cd frontend-vite && npm run build && cd ../backend && cargo build --release

# 数据库
cd backend && diesel migration run     # 运行迁移
```

## 🔄 实时更新机制

1. **文档同步**: 代码变更时自动更新对应指令文件
2. **版本追踪**: 使用 Git hooks 确保文档与代码一致
3. **AI训练**: 定期优化指令提示词，提升 Copilot 理解度

## 📚 深度文档引用

详细文档位于 `docs/` 目录，包含：
- 系统架构分析
- 技术实现指南  
- 项目风格指南
- 前端重构报告
- 部署策略文档

## 🎨 设计系统要点

- **主题色**: 蓝紫粉渐变 (#3b82f6 → #8b5cf6 → #ec4899)
- **字体**: Inter (主字体) + JetBrains Mono (代码字体)
- **布局**: Vercel 风格，中心式布局，大量留白
- **交互**: 300ms 过渡，悬停提升效果

## 🔧 开发规范

- **TypeScript**: 严格模式，绝对路径导入
- **Rust**: rustfmt + clippy，Result<T, E> 错误处理
- **Git**: Conventional Commits 规范
- **测试**: 提交前运行完整测试套件

---

*本文件为 GitHub Copilot 优化，提供项目的核心上下文信息。*  
*详细文档请参考 `docs/DOCUMENTATION_INDEX.md`*
