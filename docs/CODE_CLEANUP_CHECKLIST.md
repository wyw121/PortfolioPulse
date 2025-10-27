# PortfolioPulse 代码清理清单

**生成日期**: 2025-10-23  
**目标**: 删除僵尸代码，统一使用Markdown方案

---

## 🗑️ 需要删除的文件

### 1. Blog相关僵尸代码

#### 数据库迁移（已禁用但未删除）
- [ ] `backend/migrations/003_blog_tables.sql.disabled`
  - **状态**: 已禁用 `.disabled` 后缀
  - **操作**: 直接删除
  - **原因**: 不再使用数据库存储博客

#### 数据库模型（无用）
- [ ] `backend/src/models/blog.rs`
  - **状态**: 代码还在，定义了 `BlogPost`/`BlogCategory` 数据库实体
  - **操作**: 删除整个文件
  - **原因**: 已改用Markdown，不需要数据库模型

**检查依赖**：
```bash
# 检查是否有其他地方引用
grep -r "models::blog" backend/src/
grep -r "use.*blog" backend/src/models/mod.rs
```

---

## ✅ 保留的文件（Markdown方案）

### Blog模块 - 已完成 ✅
- ✅ `backend/content/blog/*.md` - Markdown文件
- ✅ `backend/src/services/blog_markdown.rs` - Markdown解析服务
- ✅ `backend/src/handlers.rs` 中的 blog API

**状态**: 完美运行，无需修改

---

## 🔄 需要迁移到Markdown的模块

### Project模块 - 当前Mock数据

#### 当前状态
```rust
// backend/src/services/project.rs
let projects = vec![
    Project { name: "AI Web Generator", ... }, // ❌ 硬编码
];
```

#### 目标状态（参考blog_markdown.rs）
```
backend/content/projects/
├── ai-web-generator.md
├── quantconsole.md
└── smartcare-cloud.md
```

#### 迁移步骤
1. [ ] 创建 `backend/content/projects/` 目录
2. [ ] 创建 `backend/src/services/project_markdown.rs` (复制blog_markdown.rs)
3. [ ] 编写3个项目的Markdown文件
4. [ ] 修改 `handlers.rs` 使用新服务
5. [ ] 删除旧的Mock数据

---

## 📊 清理前后对比

### 清理前（当前）
```
backend/
├── migrations/003_blog_tables.sql.disabled  ← 僵尸文件
├── src/
│   ├── models/blog.rs                       ← 无用模型
│   └── services/
│       ├── project.rs                       ← Mock数据
│       └── blog_markdown.rs                 ← ✅ 好的
└── content/
    └── blog/*.md                            ← ✅ 好的
```

### 清理后（目标）
```
backend/
├── src/
│   └── services/
│       ├── project_markdown.rs              ← 🆕 新增
│       └── blog_markdown.rs                 ← ✅ 保留
└── content/
    ├── projects/*.md                        ← 🆕 新增
    └── blog/*.md                            ← ✅ 保留
```

---

## 🎯 执行顺序

### 第一步: 安全删除（5分钟）
```bash
# 1. 删除禁用的数据库迁移
rm backend/migrations/003_blog_tables.sql.disabled

# 2. 检查blog.rs是否被引用
grep -r "models::blog" backend/src/
grep -r "use.*blog" backend/src/models/mod.rs

# 3. 如果没有引用，删除
rm backend/src/models/blog.rs

# 4. 更新 models/mod.rs，删除 blog 引用
```

### 第二步: Project迁移到Markdown（2小时）
```bash
# 1. 创建目录
mkdir -p backend/content/projects

# 2. 创建Markdown文件
touch backend/content/projects/ai-web-generator.md
touch backend/content/projects/quantconsole.md
touch backend/content/projects/smartcare-cloud.md

# 3. 复制服务文件
cp backend/src/services/blog_markdown.rs \
   backend/src/services/project_markdown.rs

# 4. 修改 project_markdown.rs 适配项目字段
# 5. 更新 handlers.rs
```

---

## ⚠️ 风险提示

### 低风险
- ✅ 删除 `003_blog_tables.sql.disabled` - 已禁用，安全
- ✅ 删除 `models/blog.rs` - 检查后无引用即可删除

### 中风险
- ⚠️ Project迁移 - 需要测试前端API调用

---

## 🧪 验证清单

### 清理后验证
- [ ] 后端编译通过: `cd backend && cargo check`
- [ ] 前端编译通过: `cd frontend-vite && npm run build`
- [ ] Blog API正常: `curl http://localhost:8000/api/blog/posts`
- [ ] Project API正常: `curl http://localhost:8000/api/projects`

---

## 📚 参考文档

- **Markdown方案**: `docs/BLOG_MANAGEMENT_RESEARCH.md`
- **已实现示例**: `backend/src/services/blog_markdown.rs`
- **Sindre Sorhus**: https://github.com/sindresorhus/sindresorhus.github.com

---

**创建人**: GitHub Copilot  
**下次检查**: 清理完成后
