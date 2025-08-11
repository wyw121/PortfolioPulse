---
applyTo: "**"
---

# 项目整体指引 - PortfolioPulse 开发规范

## 项目定位

**项目名称**: PortfolioPulse - 个人项目集动态平台
**设计参考**: [sindresorhus.com](https://sindresorhus.com) - 简洁现代的个人主页典范
**核心理念**: 渐变科技风格，专业技术展示平台

## 技术栈要求

### 前端 (端口 3000)

- **Next.js 15**: App Router + TypeScript 严格模式
- **Tailwind CSS**: 原子化 CSS，配合自定义 CSS 变量
- **shadcn/ui**: 现代组件库，统一设计语言
- **Inter 字体**: 主字体，搭配 JetBrains Mono 代码字体

### 后端 (端口 8000)

- **Rust**: Axum 框架，异步编程模式
- **MySQL**: 数据库 (端口 3306)
- **Diesel ORM**: 数据库迁移和操作

## 部署策略（重要）

**部署模式**: 二进制部署（无 Docker）

- **前端**: Next.js Standalone 输出 + Node.js 运行时
- **后端**: Rust 编译的原生二进制文件
- **数据库**: 独立 MySQL 服务
- **代理**: Nginx 负责路由分发

## 开发规范

### 编码标准

- **TypeScript**: 严格模式，绝对路径导入 `@/components/ui/button`
- **Rust**: 使用 `rustfmt` + `clippy`，优先 `Result<T, E>` 错误处理
- **命名约定**:
  - 组件: PascalCase
  - 文件: kebab-case
  - 数据库: snake_case

### 构建命令

```bash
# 前端开发
cd frontend && npm run dev

# 后端开发
cd backend && cargo run --release

# 生产构建
cd backend && cargo build --release
cd frontend && npm run build
```

### 数据库操作

```bash
# 运行迁移
cd backend && diesel migration run

# 创建新迁移
diesel migration generate <name>
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

1. **项目展示**: 卡片式展示，实时状态更新
2. **动态追踪**: Git 提交历史，代码统计
3. **学习记录**: 进度追踪，知识标签
4. **用户认证**: GitHub OAuth 集成

### 导航结构

- 主导航: 首页 / 项目 / 博客 / 关于 / 联系
- 顶部居中对齐，透明背景

## 开发最佳实践

1. **始终测试**: 提交前运行完整测试套件
2. **代码审查**: 所有 PR 需要审查
3. **Git 规范**: 使用 Conventional Commits
4. **性能优先**:
   - Next.js 图片优化
   - 组件懒加载
   - 数据库查询优化

## 故障排查

### 常见问题

- **端口冲突**: 检查 3000、8000、3306 端口
- **依赖问题**: 清除缓存重装 (node_modules + Cargo)
- **构建失败**: 检查 TypeScript 类型错误和 Rust 编译

### 调试工具

- 前端: 浏览器开发者工具
- 后端: `cargo test` + `println!` 调试
- 部署: 查看构建日志

## 项目状态

- **开发阶段**: 活跃开发，架构可能变化
- **设计系统**: 已确定渐变科技风格
- **优先级**: 可维护性 > 过度优化

请在开发过程中严格遵循这些规范，确保项目的一致性和专业性。
