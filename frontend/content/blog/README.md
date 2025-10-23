# 博客内容目录

## 说明

此目录存储所有博客文章的 Markdown 源文件。采用 **Sindre Sorhus 模式**：

- ✅ **Git 即 CMS**: 无需数据库，版本控制原生支持
- ✅ **Markdown 编写**: 专注内容，提交即发布
- ✅ **Frontmatter 元数据**: YAML 格式描述文章信息

## 文件命名规范

格式: `YYYY-MM-DD-slug.md`

示例:
- `2025-01-15-nextjs-15-features.md`
- `2024-12-20-rust-async-guide.md`

## Frontmatter 字段

```yaml
---
title: 文章标题
description: 简短描述（用于 SEO）
date: 2025-01-15
category: 前端开发
tags:
  - Next.js
  - React
  - TypeScript
featured: true
readTime: 8 分钟
---
```

### 必填字段

- `title`: 文章标题
- `description`: 简短描述
- `date`: 发布日期（YYYY-MM-DD）
- `category`: 分类

### 可选字段

- `tags`: 标签数组
- `featured`: 是否为特色文章（默认 false）
- `readTime`: 阅读时长（默认自动计算）
- `cover`: 封面图片路径

## 发布流程

1. 在本目录创建 Markdown 文件
2. 编写内容并添加 Frontmatter
3. 提交到 Git: `git add . && git commit -m "New blog: 标题"`
4. 推送到远程: `git push`
5. 自动构建并发布

## 示例文章

参考目录下的示例文章：
- `2025-01-15-nextjs-15-features.md`
- `2024-12-20-rust-async-guide.md`
