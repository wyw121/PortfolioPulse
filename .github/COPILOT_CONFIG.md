# GitHub Copilot 配置说明

## 📁 配置文件结构

根据 GitHub Copilot 官方建议，PortfolioPulse 项目的 `.github` 目录已按以下结构配置：

```
.github/
├── copilot-instructions.md              # 🎯 主要全局指令文件
├── instructions/                        # 📂 针对性指令文件夹
│   ├── project-overview.instructions.md       # 🌟 新增：项目整体指引
│   ├── ui-style-system.instructions.md        # 🌟 新增：UI风格系统
│   ├── frontend-development.instructions.md   # ✅ 前端开发指引
│   ├── backend-development.instructions.md    # ✅ 后端开发指引
│   ├── database-design.instructions.md        # ✅ 数据库设计指引
│   ├── deployment-guide.instructions.md       # ✅ 部署指引
│   └── binary-deployment.instructions.md      # ✅ 二进制部署指引
├── prompts/                             # 📂 VS Code 提示文件夹
│   ├── gradient-tech-design.prompt.md         # 🌟 新增：渐变科技设计
│   ├── vercel-style-layout.prompt.md          # 🌟 新增：Vercel风格布局
│   ├── binary-build.prompt.md                 # ✅ 二进制构建
│   ├── code-refactoring.prompt.md             # ✅ 代码重构
│   ├── deployment-devops.prompt.md            # ✅ 部署运维
│   ├── feature-development.prompt.md          # ✅ 功能开发
│   ├── learning-documentation.prompt.md       # ✅ 学习文档
│   └── security-review.prompt.md              # ✅ 安全审查
├── workflows/                           # 📂 GitHub Actions
└── copilot-workspace.code-workspace    # 🌟 新增：工作区配置
```

## 🎨 风格系统集成

### 新增的设计系统指引

1. **ui-style-system.instructions.md** - 综合风格系统
   - 渐变科技风格定位
   - 蓝紫粉渐变主题色彩
   - 暗色模式为主
   - 渐变边框交互效果
   - Inter + JetBrains Mono 字体系统

2. **project-overview.instructions.md** - 项目整体指引
   - 技术栈要求
   - 二进制部署策略
   - 开发和构建规范
   - Vercel 风格布局原则

### 新增的提示文件

1. **gradient-tech-design.prompt.md** - 渐变科技设计
   - 具体的色彩代码和实现
   - 交互效果规范
   - 组件设计准则

2. **vercel-style-layout.prompt.md** - Vercel 风格布局
   - 大屏中心式布局指南
   - 响应式断点规范
   - Hero Section 设计

## ⚙️ 工作区配置

### 启用功能
- ✅ 提示文件支持 (`"chat.promptFiles": true`)
- ✅ GitHub Copilot 代码补全
- ✅ Copilot Chat 集成
- ✅ 推荐扩展自动安装

### 推荐扩展
- GitHub.copilot
- GitHub.copilot-chat
- ms-vscode.vscode-typescript-next
- bradlc.vscode-tailwindcss
- rust-lang.rust-analyzer

## 🚀 使用方法

### 1. 自动应用指令
- **全局指令**: `copilot-instructions.md` 自动应用于所有 Copilot 请求
- **针对性指令**: `instructions/*.instructions.md` 根据文件模式自动应用

### 2. 手动使用提示
在 VS Code 中：
1. 打开 Copilot Chat
2. 点击回形针图标 (📎)
3. 选择 "Prompt..."
4. 选择相应的 `.prompt.md` 文件

### 3. 验证配置
- Copilot Chat 响应中会显示使用的指令文件
- 查看 References 列表确认指令是否正确加载

## 📋 关键特性

### applyTo 模式匹配
```yaml
# UI风格系统指令应用于：
applyTo: "frontend/**/*,components/**/*,app/**/*,styles/**/*"

# 项目整体指引应用于：
applyTo: "**"  # 所有文件
```

### 设计风格强化
- 🎯 明确的渐变科技风格定位
- 🎨 具体的色彩代码和变量
- ⚡ 标准化的交互效果
- 📐 Vercel 风格布局规范

## 🔧 配置更新记录

**2025年8月11日** - 风格系统集成：
- ✅ 整合项目风格建议文档
- ✅ 新增 UI 风格系统指令
- ✅ 添加渐变科技设计提示
- ✅ 配置 Vercel 风格布局指南
- ✅ 启用 VS Code 提示文件功能
- ✅ 更新主指令文件风格指导

这个配置确保了 GitHub Copilot 能够深度理解项目的设计理念和技术要求，提供更加精准和一致的代码建议。
