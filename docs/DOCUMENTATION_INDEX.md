# PortfolioPulse 文档架构 & 导航索引 (2025-08-23 更新)

## 📖 文档体系架构

PortfolioPulse 采用**三层文档架构**，实现AI指令与人类文档的完美联动：

### 🤖 AI开发指令层 (`.github/`)
专为 GitHub Copilot 和开发工具优化的精简指令
```
.github/
├── copilot-instructions.md        # 🎯 核心入口，项目概览
├── instructions/                   # 📁 模块化开发指令
│   ├── project-overview.instructions.md
│   ├── frontend-development.instructions.md    # ✅ 更新: Vite + React 18
│   ├── backend-development.instructions.md     # ✅ 更新: 静态文件服务
│   ├── ui-style-system.instructions.md
│   ├── database-design.instructions.md
│   └── binary-deployment.instructions.md       # 🆕 新增: 统一部署
└── prompts/                       # 📁 可复用提示模板
    ├── README.md                  # 模板库说明
    ├── react-component.md         # React 组件创建
    └── api-endpoint.md            # API 端点开发
```

### 📚 详细技术文档层 (`docs/`)
供开发者深度阅读的完整技术文档
```
docs/
├── 📋 DOCUMENTATION_INDEX.md      # 📌 当前文件，导航中心
├── 🏗️ SYSTEM_ARCHITECTURE_ANALYSIS.md
├── 🛠️ TECHNICAL_IMPLEMENTATION_GUIDE.md
├── 🎨 PROJECT_STYLE_GUIDE.md
├── 📈 BUSINESS_LOGIC_DESIGN.md
├── 🚀 BINARY_DEPLOYMENT_GUIDE.md
├── 📝 BLOG_USAGE_GUIDE.md
├── 🎯 PROJECT_REFINEMENT_GUIDE.md
├── 🔄 DESIGN_REFINEMENT_ROADMAP.md
└── 🌐 MULTI_PROJECT_DEPLOYMENT.md
```

### 🗂️ 根目录文档层 (项目根目录)
项目基础信息和快速开始文档
```
项目根目录/
├── README.md                      # 项目介绍 + 快速开始
├── FRONTEND_REFACTOR_REPORT.md    # 🔥 重构完成报告
├── DEPLOYMENT.md                  # 部署概览
├── DEPLOYMENT_GUIDE.md            # 详细部署指南
└── *.md                          # 其他基础文档
```

## 🔄 重大更新记录 (2025-08-23)

### ✅ 前端架构重构
- **技术栈变更**: Next.js 15 → Vite + React 18
- **路由系统**: App Router → React Router 6
- **构建输出**: Standalone → 静态文件 (backend/static/)
- **开发流程**: 双服务器 → 单一 Rust 服务器

### ✅ 后端能力增强
- **静态文件服务**: 新增 tower-http ServeDir 支持
- **SPA 路由**: 配置 fallback 到 index.html
- **API 前缀**: 统一使用 /api/* 避免路由冲突
- **统一端口**: 8000 端口同时服务 API 和前端

### ✅ 部署流程简化
- **构建脚本**: 新增 build.ps1 和 build.sh
- **VS Code 任务**: 更新所有开发任务配置
- **二进制部署**: 真正的单一二进制 + 静态文件部署

## 🔗 文档映射关系

### AI指令 ↔️ 技术文档 对应关系

| AI指令文件 | 对应技术文档 | 关系说明 |
|-----------|-------------|---------|
| **copilot-instructions.md** | 所有docs文档 | 核心入口，概览全项目 |
| **project-overview.instructions.md** | SYSTEM_ARCHITECTURE_ANALYSIS.md | 项目架构总览 |
| **frontend-development.instructions.md** | TECHNICAL_IMPLEMENTATION_GUIDE.md | 前端技术实现详情 |
| **backend-development.instructions.md** | TECHNICAL_IMPLEMENTATION_GUIDE.md | 后端技术实现详情 |
| **ui-style-system.instructions.md** | PROJECT_STYLE_GUIDE.md | UI/UX设计系统详解 |
| **database-design.instructions.md** | BUSINESS_LOGIC_DESIGN.md | 数据库设计规范 |
| **deployment-guide.instructions.md** | BINARY_DEPLOYMENT_GUIDE.md | 部署策略详解 |
| **binary-deployment.instructions.md** | MULTI_PROJECT_DEPLOYMENT.md | 多项目部署方案 |

## 🎯 使用指南

### 👨‍💻 开发者使用场景

1. **快速开始**: 阅读 `README.md` → `.github/copilot-instructions.md`
2. **日常开发**: 模块化指令会自动应用到对应文件类型
3. **深入学习**: 查阅 `docs/` 目录中的详细技术文档
4. **部署运维**: 参考 `DEPLOYMENT_GUIDE.md` 和相关部署文档

### 🤖 AI助手使用场景

1. **GitHub Copilot**: 自动读取 `.github/` 中的模块化指令
2. **VS Code**: 支持 `.instructions.md` 文件的 `applyTo` 前缀匹配
3. **Coding Agent**: 可访问完整的docs文档作为上下文参考

## 📋 文档维护原则

### ✅ 良好实践
- **保持同步**: AI指令变更时，同步更新对应的详细文档
- **模块化**: 按功能领域拆分，避免大而全的单一文档
- **引用链接**: 文档间相互引用，形成知识网络
- **版本控制**: 重要变更记录在Git提交中

### ❌ 避免问题
- **重复内容**: 相同信息不要在多个文档中重复
- **孤立文档**: 每个文档都应该有明确的导航路径
- **过时信息**: 定期检查和更新文档内容

## 🔄 实时联动机制

### 自动化联动 (规划中)
- **Git Hooks**: 检测指令文件变更，提醒更新对应文档
- **文档检查**: CI/CD中增加文档一致性检查
- **自动索引**: 自动更新本导航文件

### 手动联动 (当前)
- **开发规范**: 修改指令文件时，必须更新对应的详细文档
- **代码审查**: PR中包含文档一致性检查
- **定期维护**: 每月检查文档同步状态

---

## 🚀 快速导航

### 🔍 按需求类型导航

**🆕 新人入门**
1. [README.md](../README.md) - 项目介绍
2. [copilot-instructions.md](../.github/copilot-instructions.md) - AI助手指南
3. [TECHNICAL_IMPLEMENTATION_GUIDE.md](TECHNICAL_IMPLEMENTATION_GUIDE.md) - 技术实现

**💻 日常开发**
- [frontend-development.instructions.md](../.github/instructions/frontend-development.instructions.md) - 前端开发指令
- [backend-development.instructions.md](../.github/instructions/backend-development.instructions.md) - 后端开发指令
- [PROJECT_STYLE_GUIDE.md](PROJECT_STYLE_GUIDE.md) - UI样式指南

**🚀 部署运维**
- [BINARY_DEPLOYMENT_GUIDE.md](BINARY_DEPLOYMENT_GUIDE.md) - 二进制部署
- [DEPLOYMENT_GUIDE.md](../DEPLOYMENT_GUIDE.md) - 部署总指南
- [MULTI_PROJECT_DEPLOYMENT.md](MULTI_PROJECT_DEPLOYMENT.md) - 多项目方案

**📊 架构设计**
- [SYSTEM_ARCHITECTURE_ANALYSIS.md](SYSTEM_ARCHITECTURE_ANALYSIS.md) - 系统架构
- [BUSINESS_LOGIC_DESIGN.md](BUSINESS_LOGIC_DESIGN.md) - 业务逻辑
- [DESIGN_REFINEMENT_ROADMAP.md](DESIGN_REFINEMENT_ROADMAP.md) - 设计规划

---

*本文档最后更新: 2025-08-11*
*维护者: GitHub Copilot + PortfolioPulse Team*
