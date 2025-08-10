# GitHub Copilot 配置指南

## 📁 配置文件结构

根据 GitHub Copilot 官方最新建议，您的项目已配置以下结构：

```
.github/
├── copilot-instructions.md              # 🎯 主要的全局指令文件
├── instructions/                        # 📋 特定文件/目录的指令
│   ├── backend-development.instructions.md    # Rust + MySQL 后端开发
│   ├── frontend-development.instructions.md   # Next.js + sindresorhus 前端
│   ├── database-design.instructions.md        # 数据库设计规范
│   └── deployment-guide.instructions.md       # 部署和运维指南
└── prompts/                             # 🎨 可重用的提示模板
    ├── feature-development.prompt.md          # 新功能开发流程
    ├── code-refactoring.prompt.md             # 代码重构指导
    ├── deployment-devops.prompt.md            # 部署运维指导
    ├── security-review.prompt.md              # 安全审查清单
    └── learning-documentation.prompt.md      # 学习记录和文档

.vscode/
└── settings.json                        # VS Code 工作空间设置
```

## 🚀 使用方式

### 1. 自动应用的指令

以下指令会根据文件路径自动应用：

- **后端文件** (`backend/**/*`, `*.rs`): 自动应用 Rust + MySQL 开发规范
- **前端文件** (`frontend/**/*`, `app/**/*`): 自动应用 Next.js 15 + sindresorhus 设计规范
- **数据库文件** (`migrations/**/*`, `schema.sql`): 自动应用数据库设计规范
- **部署文件** (`**/deploy/**/*`, `Dockerfile`): 自动应用部署和运维指南

### 2. 可重用的提示模板

在 VS Code 中使用提示文件：

1. **附加提示文件**: 在聊天界面点击回形针图标 → Prompt → 选择相应提示
2. **直接调用**: 在聊天框输入 `/feature-development` 或 `/security-review`
3. **命令面板**: `Ctrl+Shift+P` → `Chat: Run Prompt` → 选择提示文件

### 3. 专门的指令应用

- **代码审查**: 自动应用后端/前端开发规范
- **提交信息**: 使用 Conventional Commits 格式，中文描述
- **PR 描述**: 包含功能概述、技术变更、测试说明

## 🎯 项目特定配置

### 核心业务逻辑
您的项目配置了以下关键特性：

1. **访问控制系统**
   - 专属访问链接认证 (朋友邀请制)
   - 设备指纹识别 (访客跟踪)
   - JWT 会话管理

2. **GitHub 数据集成**
   - 实时提交记录同步
   - 项目动态追踪
   - 代码统计分析

3. **学习记录管理**
   - Markdown 格式内容
   - 进度跟踪
   - 标签分类系统

4. **sindresorhus.com 设计风格**
   - 简洁现代的 UI 设计
   - 响应式布局
   - 明暗主题支持

### 技术栈配置
- **前端**: Next.js 15 + TypeScript + Tailwind CSS + shadcn/ui + Zustand
- **后端**: Rust + MySQL + Diesel ORM + Tokio
- **部署**: Vercel (前端) + Docker (后端)

## 📝 最佳实践

### 指令文件编写
- 使用自然语言描述规范
- 包含具体的代码示例
- 按功能模块组织内容
- 定期更新和维护

### 提示文件设计
- 专注于特定任务场景
- 提供清晰的步骤指导
- 包含质量检查清单
- 支持参数化输入

### 工作流程优化
- 充分利用自动应用的指令
- 合理组合多个提示文件
- 定期检查配置效果
- 根据使用反馈调整

## 🔧 高级配置

### 启用实验性功能
项目已在 `.vscode/settings.json` 中启用：
- Prompt Files 功能
- 自动指令文件检测
- 自定义指令位置配置

### 团队协作
- 所有配置文件已纳入版本控制
- 团队成员可共享相同的 Copilot 体验
- 支持个性化的用户级别配置

## 🎉 配置完成

您的 PortfolioPulse 项目现已完全优化 GitHub Copilot 配置！

🚀 **立即体验**: 打开任意源码文件，开始与 Copilot 对话，感受智能化的开发体验。
