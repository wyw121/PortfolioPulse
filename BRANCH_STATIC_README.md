# 静态化作品集分支 - 纯前端方案

## 🎯 分支目标

学习 Sindre Sorhus 的极简架构，打造纯静态的个人作品集网站。

## 📋 实现计划

### 阶段 1: 博客性能优化 ⭐ 优先
- [ ] 博客页面改为 Server Component (SSR)
- [ ] BlogGrid 组件改为接收 props
- [ ] 删除 /app/api/blog API 路由
- [ ] 性能提升: 150-450ms → 50-150ms

### 阶段 2: 项目数据优化
- [ ] 项目列表改为 GitHub API 客户端调用
- [ ] 或使用构建时静态生成 (SSG)
- [ ] 移除硬编码数据

### 阶段 3: 清理冗余代码
- [ ] 评估并删除 Rust 后端
- [ ] 删除未使用的 API 路由
- [ ] 简化部署配置

### 阶段 4: 静态化部署
- [ ] 配置 Next.js Static Export
- [ ] 设置 GitHub Actions 自动部署
- [ ] 部署到 Vercel/GitHub Pages

## 🏗️ 架构特点

- 前端: Next.js 15 (SSG/SSR)
- 后端: 无 (完全静态)
- 博客: Markdown 文件
- 数据: GitHub API (客户端/构建时)
- 部署: Vercel (免费)

## 🎓 设计哲学

遵循 Sindre Sorhus 的原则:
- ✅ 简单至上
- ✅ 静态优先
- ✅ Git 即 CMS
- ✅ 性能第一
- ✅ 专注内容

---

**当前状态**: 分支已创建，准备静态化重构
**创建时间**: 2025-10-24
**参考**: ARCHITECTURE_INVESTIGATION_REPORT.md
