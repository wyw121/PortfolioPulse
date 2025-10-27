# PortfolioPulse 博客管理指南# PortfolioPulse 博客功能使用指南



> **新方案**: 采用 **Sindre Sorhus 模式** - Git 即 CMS，Markdown 即内容## 功能概述



## 🎯 核心理念PortfolioPulse 博客功能为您的个人项目网站添加了完整的博客系统，特别针对OneNote HTML文件上传进行了优化，方便您分享学习笔记和金融相关的内容。



告别数据库、告别后台管理系统,回归内容本质：## 核心特性



- ✅ **Git 即 CMS**: 版本控制天然支持### 🔹 访客功能

- ✅ **Markdown 编写**: 专注内容创作- **博客浏览**: 浏览所有已发布的博客文章

- ✅ **提交即发布**: 无需登录管理后台- **分类筛选**: 按照分类（金融学习、技术分享等）查看文章

- ✅ **完全静态化**: 性能极佳，CDN 友好- **标签搜索**: 通过标签快速找到相关内容

- **文章搜索**: 全文搜索功能

## 📁 目录结构- **精选文章**: 重点推荐的优质内容



```### 🔹 管理员功能（仅开发者）

frontend/- **文章管理**: 创建、编辑、删除博客文章

├── content/blog/              # 博客 Markdown 文件- **HTML上传**: 直接上传OneNote导出的HTML文件

│   ├── 2025-01-15-nextjs-15-features.md- **内容编辑**: 支持富文本编辑

│   ├── 2024-12-20-rust-async-guide.md- **状态管理**: 草稿、已发布、已归档状态

│   └── 2025-01-05-frontend-architecture.md- **分类管理**: 自定义文章分类

├── lib/blog-loader.ts         # Markdown 解析器- **标签管理**: 灵活的标签系统

└── app/blog/                  # 博客页面

    ├── page.tsx               # 列表页## 页面结构

    └── [slug]/page.tsx        # 详情页

```### 前端页面

```

## ✍️ 如何发布新文章/blog                  - 博客首页，显示文章列表和侧边栏

/blog/[slug]          - 文章详情页

### 1. 创建 Markdown 文件/admin/blog           - 博客管理后台（仅开发者）

/admin/blog/upload    - HTML文件上传页面（仅开发者）

```bash```

# 文件名: YYYY-MM-DD-slug.md

touch frontend/content/blog/2025-01-23-my-post.md### 后端API接口

``````

GET  /api/blog/posts              - 获取文章列表

### 2. 添加 FrontmatterGET  /api/blog/posts/:slug        - 获取单篇文章

GET  /api/blog/featured           - 获取精选文章

```markdownGET  /api/blog/categories         - 获取分类列表

---

title: 文章标题POST   /api/admin/blog/posts      - 创建文章（管理员）

description: 简短描述PUT    /api/admin/blog/posts/:id  - 更新文章（管理员）

date: 2025-01-23DELETE /api/admin/blog/posts/:id  - 删除文章（管理员）

category: 前端开发GET    /api/admin/blog/posts      - 获取所有文章（管理员）

tags:```

  - React

  - TypeScript## OneNote HTML 上传指南

featured: true

---### 步骤1：从OneNote导出HTML

1. 在OneNote中打开要分享的笔记页面

# 正文内容...2. 点击「文件」→「另存为」

```3. 选择「网页，已筛选 (*.html)」格式

4. 保存到本地

### 3. 提交发布

### 步骤2：上传到博客系统

```bash1. 访问 `/admin/blog/upload` 页面

git add frontend/content/blog/2025-01-23-my-post.md2. 选择导出的HTML文件

git commit -m "New blog: 文章标题"3. 填写文章标题（自动从文件名提取）

git push4. 选择合适的分类（如「金融学习」）

```5. 添加相关标签

6. 选择发布状态（草稿/立即发布）

## 📝 字段说明7. 点击上传按钮



| 字段 | 必填 | 说明 |### 步骤3：内容优化

|------|------|------|- 系统会自动解析HTML内容并保持原有格式

| `title` | ✅ | 文章标题 |- 表格、图片、列表等元素会被正确显示

| `description` | ✅ | 简短描述（SEO） |- 可以在上传后进行二次编辑优化

| `date` | ✅ | 发布日期 |

| `category` | ✅ | 分类 |## 认证和权限管理

| `tags` | ❌ | 标签数组 |

| `featured` | ❌ | 特色文章 |### 开发者认证方式

由于这是个人博客，只有开发者（您）有权限进行博客管理。系统设计了以下认证方案：

## 🚀 本地预览

#### 方案1：环境变量认证（推荐）

```bash```bash

cd frontend && npm run dev# 在环境变量中设置管理员信息

# 访问 http://localhost:3000/blogBLOG_ADMIN_USER=your-github-username

```BLOG_ADMIN_TOKEN=your-secure-token

```

## 🆚 对比旧方案

#### 方案2：GitHub OAuth（待实现）

| 特性 | 旧方案 | 新方案 |- 集成GitHub OAuth登录

|------|--------|--------|- 只允许特定GitHub用户（您的账号）访问管理功能

| 内容管理 | Web 后台 | Git |

| 存储 | MySQL | Markdown |#### 方案3：简单密码认证

| 版本控制 | ❌ | ✅ |- 设置管理员密码

| 性能 | 动态查询 | 静态生成 |- 通过简单的登录表单进行认证

| 维护成本 | 高 | 极低 |

### 当前状态

## 📚 参考目前系统的管理员功能暂时没有认证保护，建议：

1. 将管理页面部署在受保护的路径下

- [Sindre Sorhus](https://sindresorhus.com)2. 使用服务器级别的认证（如Basic Auth）

- [研究文档](./BLOG_MANAGEMENT_RESEARCH.md)3. 或者暂时通过服务器防火墙限制访问


## 数据库设计

### 主要数据表
- `blog_posts`: 博客文章主表
- `blog_categories`: 文章分类
- `admin_sessions`: 管理员会话（用于认证）
- `blog_uploads`: 上传文件记录

### 文章状态管理
- `draft`: 草稿状态，不对外显示
- `published`: 已发布，在博客首页显示
- `archived`: 已归档，不在首页显示但可以访问

## 部署说明

### 数据库迁移
```bash
# 运行新的数据库迁移
cd backend
cargo run  # 会自动运行迁移
```

### 前端构建
```bash
cd frontend
npm install  # 安装新的依赖
npm run build
```

### 环境变量配置
```bash
# .env 文件
DATABASE_URL=mysql://user:pass@localhost/portfolio_pulse
NEXT_PUBLIC_API_URL=http://localhost:8000
BLOG_ADMIN_USER=your-username
```

## 使用流程示例

### 发布金融学习笔记
1. 在OneNote中整理您的金融学习笔记
2. 使用「另存为HTML」导出
3. 访问 `/admin/blog/upload`
4. 上传HTML文件，选择「金融学习」分类
5. 添加标签如「投资」、「理财」、「股票分析」等
6. 选择「立即发布」
7. 文章会自动出现在博客首页

### 内容管理
1. 访问 `/admin/blog` 查看所有文章
2. 可以编辑文章标题、分类、标签
3. 可以将文章设为精选（在首页突出显示）
4. 可以查看文章浏览量等统计信息

## 样式和主题

### 文章显示优化
- 支持OneNote的表格、列表、图片
- 代码块语法高亮
- 响应式设计，移动端友好
- 支持暗色模式

### 自定义样式
文章内容会应用专门的CSS样式来处理：
- OneNote特有的格式
- 表格边框和间距
- 图片缩放和居中
- 代码块背景色

## 扩展功能规划

### 短期计划
- [ ] GitHub OAuth 集成
- [ ] 文章评论系统
- [ ] RSS订阅功能
- [ ] 文章浏览统计

### 长期计划
- [ ] 全文搜索优化
- [ ] 文章版本控制
- [ ] 批量导入工具
- [ ] SEO优化

## 故障排查

### 常见问题
1. **文件上传失败**
   - 检查文件大小是否超过限制
   - 确认文件格式为HTML
   - 查看服务器错误日志

2. **文章不显示**
   - 检查文章状态是否为「已发布」
   - 确认数据库连接正常
   - 查看浏览器控制台错误

3. **样式显示异常**
   - 清除浏览器缓存
   - 检查CSS文件是否正确加载
   - 确认响应式设计适配

### 技术支持
- 查看服务器日志：`tail -f /var/log/portfoliopulse/error.log`
- 数据库查询：使用MySQL客户端连接检查
- API测试：使用Postman或curl测试接口

## 安全注意事项

1. **HTML内容安全**
   - 上传的HTML会被直接渲染，注意XSS风险
   - 建议只上传可信的OneNote导出文件

2. **管理员权限**
   - 确保管理页面只有您能访问
   - 定期检查admin_sessions表

3. **数据备份**
   - 定期备份博客数据库
   - 保存HTML源文件作为备份

---

通过以上配置，您就可以轻松地将OneNote中的学习笔记转换为博客文章，与访客分享您的金融学习心得和技术见解！
