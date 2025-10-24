# PortfolioPulse - GitHub Copilot 开发指令

## 项目架构 (Next.js 版本)

```
PortfolioPulse/
├── frontend/          # Next.js 15 + React 18 前端应用
│   ├── app/          # Next.js App Router
│   ├── components/   # React 组件
│   ├── content/      # Markdown 博客内容
│   │   └── blog/     # 博客文章 (.md 文件)
│   ├── lib/          # 工具函数
│   ├── styles/       # 样式文件
│   └── types/        # TypeScript 类型
└── backend/          # Rust Axum 后端 API 服务
    └── src/
        ├── main.rs   # 主入口（仅 API）
        ├── handlers.rs # API 处理器
        └── models.rs # 数据模型
```

## 技术栈

### 前端 (端口 3000)
- **Next.js 15**: React 全栈框架，App Router
- **React 18**: 现代 React 特性
- **TypeScript**: 严格类型检查
- **Tailwind CSS**: 原子化 CSS
- **shadcn/ui**: 现代组件库
- **gray-matter + remark**: Markdown 解析和渲染

### 后端 (端口 8000)
- **Rust**: 高性能语言
- **Axum**: Web 框架
- **Tokio**: 异步运行时

### 博客系统
- **Git + Markdown**: 无数据库设计
- **内容存储**: `frontend/content/blog/*.md`
- **元数据**: Front Matter (YAML)

## 开发命令

```bash
# 前端开发
cd frontend && npm run dev         # 开发服务器 (端口 3000)
cd frontend && npm run build       # 生产构建

# 后端开发
cd backend && cargo run            # API 服务器 (端口 8000)
cd backend && cargo build --release # 生产构建

# 博客管理
# 在 frontend/content/blog/ 目录下创建 .md 文件即可
# 文件名格式: YYYY-MM-DD-title.md
```

## 部署架构

**前后端分离部署**:
- 前端: Next.js 应用需要 Node.js 运行时
- 后端: Rust 二进制文件提供 API
- 博客: Markdown 文件通过前端静态读取
- 两个独立进程，通过 CORS 通信

## 开发规范

### Next.js
- 使用 App Router (`app/` 目录)
- Server Components 优先
- Client Components 标注 `'use client'`
- 动态路由: `[slug]/page.tsx`

### TypeScript
- 严格模式
- 接口命名: `IProjectCard`
- 类型文件: `types/*.ts`

### API 调用
- 后端 URL: `http://localhost:8000/api/*`
- 使用 `fetch` 或 `axios`
- 错误处理统一封装

## 状态管理

使用 Zustand:
```typescript
import { create } from 'zustand';

export const useProjectStore = create((set) => ({
  projects: [],
  setProjects: (projects) => set({ projects })
}));
```

## 样式系统

- **主题色**: 蓝紫粉渐变
- **暗色主题**: 默认
- **组件库**: shadcn/ui
- **动画**: Framer Motion

## 注意事项

1. **水合错误**: 避免客户端/服务端状态不一致
2. **环境变量**: 使用 `.env.local`
3. **博客文章**: 需要包含 Front Matter 元数据
4. **API 代理**: Next.js 可配置 rewrites
4. **构建输出**: `.next/` 目录不提交
