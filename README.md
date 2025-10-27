# PortfolioPulse

<div align="center">

**现代化个人作品集 · 纯前端静态网站**

[![Next.js](https://img.shields.io/badge/Next.js-15.0-black?logo=next.js)](https://nextjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.2-blue?logo=typescript)](https://www.typescriptlang.org/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind-3.3-38bdf8?logo=tailwind-css)](https://tailwindcss.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

受 [sindresorhus.com](https://sindresorhus.com) 启发的极简个人主页

[在线演示](#) · [查看文档](docs/) · [报告问题](https://github.com/wyw121/PortfolioPulse/issues)

</div>

---

## ✨ 项目特色

### 🎯 核心理念

> **极简主义 · 内容优先 · 性能至上**

- **🚀 零服务器** - 纯静态网站，无需后端，部署到任意静态托管平台
- **� Git 即 CMS** - Markdown 文件管理内容，Git 作为版本控制系统
- **🎨 渐变科技风** - 蓝紫粉渐变主题，现代化设计语言
- **🌍 国际化就绪** - 完整中英双语支持，98% i18n 覆盖率
- **⚡ 极速加载** - SSG + ISR 策略，首屏秒开，SEO 友好

### 💡 技术亮点

```
纯前端架构 = Next.js 15 SSG + TypeScript + Tailwind CSS
无数据库 = Markdown 文件 + Git 版本控制
无状态管理库 = React Context + Custom Hooks
代码使用率 = 100% (零冗余)
```

---

## 🛠️ 技术栈

### 核心框架
- **[Next.js 15](https://nextjs.org/)** - App Router + React Server Components
- **[TypeScript 5.2](https://www.typescriptlang.org/)** - 严格模式，全链路类型安全
- **[Tailwind CSS 3.3](https://tailwindcss.com/)** - 原子化 CSS + 自定义设计系统

### UI 组件
- **[shadcn/ui](https://ui.shadcn.com/)** - 现代组件库（按需使用）
- **[Radix UI](https://www.radix-ui.com/)** - 无障碍组件基础
- **[Framer Motion](https://www.framer.com/motion/)** - 流畅动画效果
- **[Lucide Icons](https://lucide.dev/)** - 一致的图标系统

### 内容管理
- **[gray-matter](https://github.com/jonschlinkert/gray-matter)** - Markdown Front Matter 解析
- **[remark](https://remark.js.org/)** - Markdown 转 HTML
- **[remark-gfm](https://github.com/remarkjs/remark-gfm)** - GitHub 风格 Markdown

### 开发工具
- **[ESLint](https://eslint.org/)** - 代码质量检查
- **[next-themes](https://github.com/pacocoursey/next-themes)** - 主题切换系统


---

## 🚀 快速开始

### 前置要求

```bash
Node.js >= 18.17.0
npm >= 9.0.0
```

### 本地运行

```bash
# 1. 克隆仓库
git clone https://github.com/wyw121/PortfolioPulse.git
cd PortfolioPulse

# 2. 安装依赖
cd frontend
npm install

# 3. 启动开发服务器
npm run dev

# 4. 打开浏览器访问
# http://localhost:3000
```

### 生产构建

```bash
# 构建静态网站
npm run build

# 本地预览构建结果
npm run start
```

---

## 📁 项目结构

```
PortfolioPulse/
├── frontend/                   # Next.js 应用
│   ├── app/                   # App Router 页面
│   │   ├── page.tsx          # 首页
│   │   ├── about/            # 关于页面
│   │   ├── projects/         # 项目展示
│   │   └── blog/             # 博客（ISR）
│   ├── components/           # React 组件
│   │   ├── sections/         # 页面区块
│   │   ├── portfolio/        # 项目卡片
│   │   ├── blog/             # 博客组件
│   │   ├── about/            # 关于组件
│   │   ├── layout/           # 布局组件
│   │   └── ui/               # shadcn/ui 组件
│   ├── content/              # 内容管理
│   │   └── blog/            # Markdown 博客文章
│   ├── lib/                  # 工具库
│   │   ├── blog-loader.ts   # 博客加载器
│   │   ├── config.ts        # 站点配置
│   │   └── i18n.ts          # 国际化
│   ├── locales/              # 多语言字典
│   │   ├── zh.json          # 中文
│   │   └── en.json          # English
│   └── types/                # TypeScript 类型
├── docs/                      # 项目文档
└── .github/                   # GitHub 配置
    └── copilot-instructions.md  # AI 开发指令
```

---

## 📝 博客管理

### 创建新博客文章

在 `frontend/content/blog/` 目录下创建 Markdown 文件：

```markdown
---
title: "文章标题"
date: "2025-01-27"
excerpt: "文章摘要"
tags: ["Next.js", "TypeScript"]
category: "技术"
---

# 正文内容

这里是 Markdown 格式的文章内容...
```

### 博客特性

- ✅ **自动路由生成** - 文件名即 URL
- ✅ **ISR 增量更新** - 60秒自动重新验证
- ✅ **Front Matter** - 元数据管理
- ✅ **GFM 支持** - GitHub 风格 Markdown
- ✅ **双语支持** - `.md` (中文) + `.en.md` (英文)

---

## 🎨 设计系统

### 颜色方案

```css
/* 主题色 - 蓝紫粉渐变 */
--gradient-primary: linear-gradient(135deg, #3b82f6 → #8b5cf6 → #ec4899);

/* 暗色主题 */
--bg-primary: #0f0f0f;
--bg-secondary: #1e1e1e;
--text-primary: #ffffff;
--text-secondary: #a3a3a3;
```

### 组件风格

- **悬停效果**: `translateY(-4px)` + 发光阴影
- **动画时长**: 300ms cubic-bezier(0.4, 0, 0.2, 1)
- **边框渐变**: 鼠标悬停显示渐变边框
- **布局原则**: 大屏中心式，大量留白（Vercel 风格）

---

## 🌍 国际化

### 切换语言

项目支持中英双语：

```typescript
// 使用 useTranslation Hook
const { dict, lang, setLang } = useTranslation();

// 在组件中使用翻译
<h1>{dict.home.welcome}</h1>
```

### 添加新语言

1. 在 `frontend/locales/` 创建新语言文件（如 `ja.json`）
2. 在 `lib/i18n.ts` 添加语言配置
3. 更新语言切换器组件

---

## 📊 页面列表

| 路由 | 页面 | 渲染方式 | 说明 |
|------|------|---------|------|
| `/` | 首页 | SSG | 静态生成，包含 Hero + 项目网格 |
| `/about` | 关于 | SSG | 个人简介、技能、经验 |
| `/projects` | 项目 | SSG | 项目展示卡片网格 |
| `/blog` | 博客列表 | ISR | 60s 重新验证 |
| `/blog/[slug]` | 博客详情 | ISR | 动态路由，60s 重新验证 |


---

## 🚢 部署

### Vercel 一键部署（推荐）

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/wyw121/PortfolioPulse)

### 其他静态托管平台

项目支持部署到任意支持 Next.js 的平台：

- **Netlify**: 自动识别 Next.js 项目
- **GitHub Pages**: 需要配置 `output: 'export'`
- **Cloudflare Pages**: 原生 Next.js 支持

### 构建输出

```bash
npm run build
# 生成 .next/ 目录（Standalone 模式）
# 或 out/ 目录（Static Export 模式）
```

---

## 📖 核心文档

| 文档 | 说明 |
|------|------|
| [开发指令](.github/copilot-instructions.md) | GitHub Copilot AI 开发规范 |
| [前端架构](docs/FRONTEND_ARCHITECTURE_ANALYSIS.md) | 前端架构深度分析 |
| [系统分析](docs/FINAL_SYSTEM_ANALYSIS_REPORT.md) | 完整系统状态报告 |
| [项目风格](docs/PROJECT_STYLE_GUIDE.md) | UI/UX 设计系统 |
| [主题实现](docs/THEME_AND_LANGUAGE_IMPLEMENTATION_GUIDE.md) | 主题和国际化指南 |
| [博客使用](docs/BLOG_USAGE_GUIDE.md) | 博客系统使用说明 |

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 贡献流程

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/amazing-feature`
3. 提交更改：`git commit -m 'feat: add amazing feature'`
4. 推送分支：`git push origin feature/amazing-feature`
5. 提交 Pull Request

### 提交规范

使用 [Conventional Commits](https://www.conventionalcommits.org/)：

```
feat: 新功能
fix: 修复 Bug
docs: 文档更新
style: 代码格式
refactor: 重构
perf: 性能优化
test: 测试
chore: 构建/工具
```

---

## 📄 许可证

本项目采用 [MIT](LICENSE) 许可证。

---

## 🙏 致谢

### 设计灵感

- [sindresorhus.com](https://sindresorhus.com) - 极简主义的完美典范
- [Vercel](https://vercel.com) - 现代化的布局和交互

### 技术栈

感谢以下优秀的开源项目：

- [Next.js](https://nextjs.org/) - The React Framework
- [Tailwind CSS](https://tailwindcss.com/) - Utility-first CSS
- [shadcn/ui](https://ui.shadcn.com/) - Re-usable components
- [TypeScript](https://www.typescriptlang.org/) - JavaScript with syntax for types
- [Framer Motion](https://www.framer.com/motion/) - Production-ready motion library

---

<div align="center">

**Made with ❤️ by [wyw121](https://github.com/wyw121)**

⭐ **如果这个项目对你有帮助，请给个 Star！** ⭐

[GitHub](https://github.com/wyw121/PortfolioPulse) · [文档](docs/) · [问题反馈](https://github.com/wyw121/PortfolioPulse/issues)

</div>
