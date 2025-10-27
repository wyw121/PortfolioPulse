---
applyTo: "**"
---

# 项目整体指引 - PortfolioPulse 开发规范

## 项目定位

**项目名称**: PortfolioPulse - 个人项目集动态平台
**设计参考**: [sindresorhus.com](https://sindresorhus.com) - 简洁现代的个人主页典范
**核心理念**: 渐变科技风格，专业技术展示平台

## 技术栈要求

### 前端技术栈

- **Next.js 15**: App Router + TypeScript 严格模式 + SSG/ISR
- **Tailwind CSS**: 原子化 CSS，配合自定义 CSS 变量
- **shadcn/ui**: 现代组件库，统一设计语言
- **Inter 字体**: 主字体，搭配 JetBrains Mono 代码字体
- **React Context**: 轻量级状态管理
- **Markdown**: Git 作为 CMS，内容版本控制

## 部署策略（重要）

**部署模式**: 纯前端静态部署

- **渲染策略**: SSG (静态生成) + ISR (增量静态再生)
- **内容管理**: Git + Markdown 文件（无数据库）
- **托管平台**: Vercel / Netlify / Cloudflare Pages
- **博客更新**: ISR 60秒自动重新验证
- **无服务器**: 零后端依赖，纯静态网站

## 开发规范

### 编码标准

- **TypeScript**: 严格模式，绝对路径导入 `@/components/ui/button`
- **命名约定**:
  - 组件: PascalCase
  - 文件: kebab-case
  - Markdown: YYYY-MM-DD-title.md

### 构建命令

```bash
# 前端开发
cd frontend && npm run dev        # 开发服务器 (端口 3000)

# 生产构建
cd frontend && npm run build      # 静态网站构建
cd frontend && npm run start      # 预览构建结果

# 代码检查
npm run lint                      # ESLint 检查
npm run type-check                # TypeScript 类型检查
```

### 内容管理

```bash
# 博客管理
# 在 frontend/content/blog/ 目录创建 .md 文件
# 文件名格式: YYYY-MM-DD-title.md
# 双语支持: title.md (中文) + title.en.md (英文)
```

## 设计系统集成

### 颜色系统

- **主题色**: 蓝紫粉渐变 (#3b82f6 → #8b5cf6 → #ec4899)
- **背景色**: 暗色主题为主 (#0f0f0f, #1e1e1e, #2a2a2a)
- **文字色**: 高对比度白色系 (#ffffff, #a3a3a3, #6b7280)

### 交互规范

- **悬停提升**: `translateY(-4px)` + 发光阴影
- **过渡动画**: 300ms cubic-bezier(0.4, 0, 0.2, 1)
- **边框效果**: 渐变边框悬停效果

### 布局原则

- **Vercel 风格**: 大屏中心式布局，大量留白
- **内容层级**: Hero Section + 3 列项目网格
- **响应式**: 移动端优先设计

## 功能模块

### 核心功能

1. **项目展示**: 卡片式展示，Markdown 内容管理
2. **博客系统**: Markdown 文件 + ISR，双语支持
3. **学习记录**: 进度追踪，知识标签
4. **国际化**: 中英文切换 (i18n)

### 导航结构

- 主导航: 首页 / 项目 / 博客 / 关于 / 联系
- 顶部居中对齐，透明背景

## 开发最佳实践

1. **始终测试**: 提交前运行完整测试套件
2. **代码审查**: 所有 PR 需要审查
3. **Git 规范**: 使用 Conventional Commits
4. **性能优先**:
   - Next.js 图片优化 (next/image)
   - 组件懒加载 (Dynamic Import)
   - 静态生成 (SSG)
   - 增量静态再生 (ISR)

## 故障排查

### 常见问题

- **端口冲突**: 检查 3000 端口 (仅前端开发服务器)
- **依赖问题**: 清除缓存重装 (`rm -rf node_modules && npm install`)
- **构建失败**: 检查 TypeScript 类型错误 (`npm run type-check`)

### 调试工具

- 前端: 浏览器开发者工具
- 构建: Next.js 构建日志分析
- 部署: 查看 Vercel/Netlify 部署日志

## 项目状态

- **开发阶段**: 活跃开发，架构可能变化
- **设计系统**: 已确定渐变科技风格
- **优先级**: 可维护性 > 过度优化

请在开发过程中严格遵循这些规范，确保项目的一致性和专业性。
