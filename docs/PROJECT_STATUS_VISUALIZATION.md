# 项目现状可视化图

```
═══════════════════════════════════════════════════════════════
                PortfolioPulse 项目现状 (2025-10-23)
═══════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────┐
│                    🎯 核心问题                               │
│                                                              │
│  你的项目处于 "过渡期" - 一半新一半旧                        │
│  • Blog ✅ 已完成 Markdown 方案 (向 Sindre 学习)            │
│  • Project ⚠️ 还在用 Mock 数据 (临时方案)                   │
└─────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────┐
│                📊 Blog模块 - ✅ 已完成                       │
└─────────────────────────────────────────────────────────────┘

  backend/
  ├── content/blog/              ✅ Markdown 文件存在
  │   ├── git-based-cms.md
  │   ├── portfoliopulse-launch.md
  │   └── why-rust-backend.md
  │
  ├── src/services/
  │   └── blog_markdown.rs       ✅ Markdown 解析服务
  │
  └── src/handlers.rs
      ├── get_blog_posts()       ✅ 从 Markdown 读取
      ├── get_blog_post()        ✅ 从 Markdown 读取
      └── get_featured_posts()   ✅ 从 Markdown 读取

  🎉 Blog API: http://localhost:8000/api/blog/posts
     完美运行，无需修改！


┌─────────────────────────────────────────────────────────────┐
│              ⚠️ Project模块 - 还在用Mock数据                 │
└─────────────────────────────────────────────────────────────┘

  backend/src/services/project.rs
  
  pub async fn get_all(&self) -> Result<Vec<ProjectResponse>> {
      // ❌ 硬编码 Mock 数据
      let projects = vec![
          Project {
              name: "AI Web Generator".to_string(),
              description: Some("...".to_string()),
              // ... 更多硬编码字段
          },
          Project { name: "QuantConsole".to_string(), ... },
          Project { name: "SmartCare Cloud".to_string(), ... },
      ];
      
      Ok(projects.into_iter().map(Into::into).collect())
  }

  ⚠️ 问题：
     • 数据写死在代码里
     • 每次更新项目要重新编译
     • 无法像Blog那样用Git管理内容


┌─────────────────────────────────────────────────────────────┐
│                🗑️ 僵尸代码 - 需要删除                        │
└─────────────────────────────────────────────────────────────┘

  1. backend/models/blog.rs              🗑️ 数据库模型,已不用
     ├── BlogPost (数据库实体)
     ├── BlogCategory (数据库实体)
     └── 被 models/mod.rs 导出但从未使用

  2. migrations/003_blog_tables.sql.disabled  🗑️ 已禁用的迁移
     ├── CREATE TABLE blog_posts
     ├── CREATE TABLE blog_categories
     └── CREATE TABLE admin_sessions

  ❌ 为什么存在？
     • Blog最初设计用数据库 + 管理后台
     • 后来改用 Markdown 方案
     • 旧代码未清理干净


┌─────────────────────────────────────────────────────────────┐
│              ✅ 正确的 Markdown 方案 (Sindre风格)            │
└─────────────────────────────────────────────────────────────┘

  Sindre Sorhus 的做法:
  
  sindresorhus.com/
  ├── source/content/
  │   ├── blog/*.md              ← Markdown 文件
  │   └── apps/*.md              ← 应用信息 Markdown
  │
  └── source/pages/
      └── blog/[slug].astro      ← 前端直接读取 Markdown

  
  你应该做的:
  
  PortfolioPulse/
  ├── backend/content/
  │   ├── blog/*.md              ✅ 已有！
  │   └── projects/*.md          ⚠️ 缺失！应该创建
  │
  └── backend/src/services/
      ├── blog_markdown.rs       ✅ 已有！
      └── project_markdown.rs    ⚠️ 缺失！应该创建


┌─────────────────────────────────────────────────────────────┐
│                  🎯 清理 + 迁移计划                          │
└─────────────────────────────────────────────────────────────┘

  第一步: 安全删除 (5分钟)
  ─────────────────────────────────────────────────
  rm backend/migrations/003_blog_tables.sql.disabled
  rm backend/src/models/blog.rs
  
  # 更新 models/mod.rs
  - mod blog;
  - pub use blog::*;


  第二步: Project迁移到Markdown (2小时)
  ─────────────────────────────────────────────────
  1. 创建 content/projects/ 目录
  2. 编写 3个项目的 Markdown 文件:
     • ai-web-generator.md
     • quantconsole.md
     • smartcare-cloud.md
  
  3. 复制 blog_markdown.rs → project_markdown.rs
  4. 修改适配项目字段
  5. 更新 handlers.rs 使用新服务


┌─────────────────────────────────────────────────────────────┐
│                    📝 Markdown 示例                          │
└─────────────────────────────────────────────────────────────┘

  content/projects/ai-web-generator.md
  ────────────────────────────────────────────
  ---
  name: "AI Web Generator"
  description: "基于DALL-E 3的智能网页图像生成器"
  url: "https://github.com/wyw121/ai_web_generator"
  language: "Rust"
  stars: 15
  topics: ["rust", "actix-web", "openai-api"]
  ---
  
  ## 项目介绍
  
  集成前端星空动画和后端Rust服务...


═══════════════════════════════════════════════════════════════
                        📊 总结
═══════════════════════════════════════════════════════════════

现状:
  ✅ Blog 已完成 Markdown 方案
  ⚠️  Project 还在用 Mock 数据
  🗑️  有僵尸代码未清理

下一步:
  1. 删除僵尸代码 (5分钟)
  2. Project迁移到Markdown (2小时)
  3. 统一架构风格 (完成过渡)

参考文档:
  • docs/BLOG_MANAGEMENT_RESEARCH.md
  • docs/CODE_CLEANUP_CHECKLIST.md
  • backend/src/services/blog_markdown.rs (实现示例)

═══════════════════════════════════════════════════════════════
```
