---
title: Git-based 内容管理:向 Sindre Sorhus 学习
description: 为什么放弃传统 CMS,采用基于 Git 的内容管理方式
pubDate: 2024-10-21
tags:
  - git
  - content-management
  - best-practices
---

## 传统 CMS 的困境

在最初的设计中,PortfolioPulse 实现了一个完整的博客管理后台:

- ❌ 用户认证系统
- ❌ 富文本编辑器
- ❌ 图片上传功能
- ❌ 复杂的 CRUD API

**结果**: 花了大量时间开发系统,却一篇文章都没写! 🤦

## Sindre Sorhus 的方案

在研究了 Sindre Sorhus 的 [个人网站](https://sindresorhus.com) 后,我发现他使用了一个极简的方案:

### 核心理念: Git as CMS

```bash
# 1. 写 Markdown
vim content/blog/my-post.md

# 2. 提交到 Git
git add content/blog/my-post.md
git commit -m "Add blog: My Post"
git push

# 3. 自动构建部署
# GitHub Actions 会自动触发构建
```

### Frontmatter 规范

```markdown
---
title: 文章标题
description: 简短描述
pubDate: 2024-10-21
tags:
  - tag1
  - tag2
---

文章正文...
```

## 优势分析

### 1. 极简架构

- ✅ 无需数据库存储博客内容
- ✅ 无需认证系统
- ✅ 无需管理后台

### 2. 版本控制

Git 提供了天然的版本管理:

```bash
# 查看修改历史
git log -- content/blog/my-post.md

# 回退到之前版本
git checkout HEAD~1 content/blog/my-post.md
```

### 3. 开发者友好

作为开发者,我们每天都在使用:

- VS Code / Vim 等编辑器
- Git 版本控制
- Markdown 语法

为什么不用这些熟悉的工具来写博客呢?

### 4. 性能优秀

- 静态文件,零数据库查询
- 可以轻松部署到 CDN
- 构建时生成 HTML,运行时零开销

## 实施步骤

### 1. 后端读取 Markdown

```rust
use pulldown_cmark::{html, Parser};
use std::fs;

fn load_blog_post(slug: &str) -> Result<BlogPost> {
    let path = format!("content/blog/{}.md", slug);
    let content = fs::read_to_string(path)?;
    
    // 解析 frontmatter 和正文
    let (metadata, markdown_body) = parse_frontmatter(&content)?;
    
    // Markdown 转 HTML
    let parser = Parser::new(markdown_body);
    let mut html = String::new();
    html::push_html(&mut html, parser);
    
    Ok(BlogPost {
        title: metadata.title,
        content: html,
        // ...
    })
}
```

### 2. API 保持不变

前端无需修改,继续使用:

```typescript
// 前端代码完全不变
const response = await fetch('/api/blog/posts/my-post');
const post = await response.json();
```

### 3. 删除数据库表

```sql
-- 注释掉博客相关的数据库迁移
-- migrations/003_blog_tables.sql.disabled
```

## 最佳实践

### 文件命名

使用 slug 作为文件名:

```
content/blog/
├── portfoliopulse-launch.md
├── why-rust-backend.md
└── git-based-cms.md
```

### Frontmatter 模板

```yaml
---
title: 必填标题
description: 必填描述 (用于 SEO)
pubDate: YYYY-MM-DD (必填)
tags: [可选标签列表]
---
```

### Git Workflow

```bash
# 写作流程
git checkout -b blog/new-post
vim content/blog/new-post.md
git add content/blog/new-post.md
git commit -m "Add blog: New Post"
git push origin blog/new-post

# 通过 PR 发布
# 合并到 main 分支后自动部署
```

## 总结

> "最好的内容管理系统,就是不需要管理系统。" —— 某位智者

通过采用 Git-based 的内容管理方式:

- ✅ 删除了 90% 的博客管理代码
- ✅ 专注于内容创作而非系统维护
- ✅ 获得了完整的版本控制能力
- ✅ 享受熟悉的开发工具

这就是 **YAGNI 原则** (You Aren't Gonna Need It) 的最佳实践! 🎯
