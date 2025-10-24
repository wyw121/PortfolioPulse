# 博客分类系统设计文档

## 设计理念

采用 **统一的英文 key + 前端多语言翻译** 的方案,而不是完全分离的双语系统。

## 为什么选择这个方案?

### ✅ 优势
1. **数据层统一**: 所有文章使用相同的分类 key,无论中英文
2. **维护简单**: 只需维护翻译映射表,不需要同步两套分类系统
3. **易于扩展**: 未来添加日语/韩语等语言,只需添加翻译即可
4. **避免不一致**: 不会出现中文分类和英文分类对不上的问题

### ❌ 备选方案的问题

**方案 A: 中英文使用不同的分类名**
```yaml
# 中文文章
category: 前端开发

# 英文文章  
category: Frontend Development
```
- ❌ 需要维护映射关系: "前端开发" ↔ "Frontend Development"
- ❌ 容易出错,翻译不一致时分类失效
- ❌ 扩展新语言时需要 N×N 映射

**方案 B: 完全独立的双语站点**
```
/blog?lang=zh  → 独立的中文文章
/blog?lang=en  → 独立的英文文章
```
- ❌ 维护成本翻倍(两套内容,两套系统)
- ❌ URL 需要区分语言
- ❌ 对技术博客来说过度工程化

## 实现方案

### 1. 文章 Frontmatter 使用统一的英文 key

```yaml
---
title: Rust 异步编程实战指南  # 可以用中文
category: backend              # 统一用英文 key
tags:
  - Rust
  - 异步编程
---
```

### 2. 前端维护分类翻译表

```typescript
// components/blog/blog-grid.tsx
const categoryNames: Record<string, Record<string, string>> = {
  all: { zh: "全部", en: "All" },
  frontend: { zh: "前端开发", en: "Frontend" },
  backend: { zh: "后端开发", en: "Backend" },
  architecture: { zh: "架构设计", en: "Architecture" },
  languages: { zh: "编程语言", en: "Languages" },
  performance: { zh: "性能优化", en: "Performance" },
  opensource: { zh: "开源文化", en: "Open Source" }
};
```

### 3. 渲染时根据当前语言显示

```tsx
{categoryKeys.map((key) => (
  <button onClick={() => setSelectedCategory(key)}>
    {categoryNames[key][locale]}  {/* 动态翻译 */}
  </button>
))}
```

## 支持的分类列表

| Key | 中文 | English |
|-----|------|---------|
| `all` | 全部 | All |
| `frontend` | 前端开发 | Frontend |
| `backend` | 后端开发 | Backend |
| `architecture` | 架构设计 | Architecture |
| `languages` | 编程语言 | Languages |
| `performance` | 性能优化 | Performance |
| `opensource` | 开源文化 | Open Source |

## 如何添加新分类

### 步骤 1: 更新 categoryKeys 数组
```typescript
const categoryKeys = [
  "all", "frontend", "backend", "architecture", 
  "languages", "performance", "opensource",
  "devops" // 新增
];
```

### 步骤 2: 添加翻译
```typescript
const categoryNames = {
  // ... 现有分类
  devops: { zh: "运维部署", en: "DevOps" }
};
```

### 步骤 3: 在文章中使用
```yaml
---
title: Kubernetes 实战指南
category: devops  # 使用新的 key
---
```

## 文件命名约定

- **中文版**: `YYYY-MM-DD-slug.md`
- **英文版**: `YYYY-MM-DD-slug.en.md`
- **其他语言**: `YYYY-MM-DD-slug.{locale}.md`

示例:
```
2024-12-20-rust-async-guide.md     # 中文
2024-12-20-rust-async-guide.en.md  # 英文
```

## 注意事项

1. **统一使用小写**: 所有 category key 都用小写
2. **避免特殊字符**: 只用字母和连字符
3. **保持简短**: key 尽量简洁(不超过 15 字符)
4. **语义清晰**: key 要能直观理解含义

## 迁移指南

如果你有旧文章使用了中文分类:

```bash
# 批量替换(示例)
sed -i 's/category: 前端开发/category: frontend/g' content/blog/*.md
sed -i 's/category: 后端开发/category: backend/g' content/blog/*.md
sed -i 's/category: 架构设计/category: architecture/g' content/blog/*.md
```

## 总结

这个设计平衡了:
- ✅ **简单性**: 一套数据,多语言展示
- ✅ **可维护性**: 翻译集中管理
- ✅ **可扩展性**: 轻松添加新语言
- ✅ **一致性**: 避免双语不匹配问题

适合中小型技术博客,既支持国际化,又不会过度复杂。
