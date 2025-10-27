# PortfolioPulse - GitHub Copilot 开发指令

## 项目架构（纯前端静态网站）

```
PortfolioPulse/
├── frontend/              # Next.js 15 + React 18 应用
│   ├── app/              # Next.js App Router
│   │   ├── page.tsx      # 首页（SSG）
│   │   ├── about/        # 关于页面（SSG）
│   │   ├── projects/     # 项目展示（SSG）
│   │   └── blog/         # 博客（ISR）
│   ├── components/       # React 组件
│   │   ├── sections/     # 页面区块
│   │   ├── portfolio/    # 项目卡片
│   │   ├── blog/         # 博客组件
│   │   ├── about/        # 关于组件
│   │   ├── layout/       # 布局组件
│   │   └── ui/           # shadcn/ui 组件
│   ├── content/          # Markdown 内容管理
│   │   └── blog/         # 博客文章（.md 文件）
│   ├── lib/              # 工具函数
│   │   ├── blog-loader.ts  # Markdown 解析
│   │   ├── config.ts       # 站点配置
│   │   └── i18n.ts         # 国际化
│   ├── locales/          # 多语言字典
│   │   ├── zh.json       # 中文
│   │   └── en.json       # English
│   ├── contexts/         # React Context
│   ├── hooks/            # 自定义 Hooks
│   ├── styles/           # 样式文件
│   └── types/            # TypeScript 类型
├── docs/                 # 项目文档
└── .github/              # GitHub 配置
    └── instructions/     # 模块化开发指令
```

## 技术栈

### 核心框架
- **Next.js 15**: React 全栈框架，App Router，SSG/ISR
- **React 18**: Server Components，Suspense
- **TypeScript 5.2**: 严格模式，全链路类型安全
- **Tailwind CSS 3.3**: 原子化 CSS + 自定义设计系统

### UI 组件
- **shadcn/ui**: 现代组件库（按需使用）
- **Radix UI**: 无障碍组件基础
- **Framer Motion 10.16**: GPU 加速动画
- **Lucide Icons**: 图标系统

### 内容管理
- **Git + Markdown**: 无数据库，版本控制即 CMS
- **gray-matter**: Front Matter 元数据解析
- **remark**: Markdown → HTML 转换
- **remark-gfm**: GitHub 风格 Markdown 支持

### 状态管理
- **React Context**: 全局配置（SiteConfigContext）
- **Custom Hooks**: useTranslation（i18n）
- **next-themes**: 主题切换系统
- **无状态管理库**: 不使用 Zustand/Redux

### 部署
- **Vercel**: 推荐部署平台（零配置）
- **Netlify/Cloudflare Pages**: 替代方案
- **Static Export**: 可导出为纯静态 HTML

## 开发命令

```bash
# 启动开发服务器
cd frontend && npm run dev        # http://localhost:3000

# 生产构建
npm run build                     # 构建静态网站
npm run start                     # 预览构建结果

# 代码检查
npm run lint                      # ESLint 检查
npm run type-check                # TypeScript 类型检查

# 博客管理
# 在 frontend/content/blog/ 目录创建 .md 文件
# 文件名格式: YYYY-MM-DD-title.md
# 双语支持: title.md (中文) + title.en.md (英文)
```

## 部署架构

**纯前端静态部署**:
- **渲染策略**: SSG（静态生成） + ISR（增量静态再生）
- **博客更新**: ISR 60秒自动重新验证
- **无服务器**: 无需后端，无需数据库
- **内容管理**: Git 作为 CMS，Markdown 文件存储
- **托管方式**: 任意静态托管平台（Vercel/Netlify/GitHub Pages）

## 开发规范

### Next.js App Router
- 使用 App Router (`app/` 目录)
- **Server Components 优先**: 默认服务端组件
- **Client Components**: 必须显式标注 `'use client'`
- 动态路由: `[slug]/page.tsx`
- 布局: `layout.tsx` 嵌套布局
- 加载状态: `loading.tsx`
- 错误处理: `error.tsx`

### TypeScript 规范
- 严格模式: `strict: true`
- 类型定义: `types/*.ts`
- 避免 `any`，使用 `unknown` 或具体类型
- Props 接口命名: 无需 `I` 前缀（如 `ProjectCardProps`）

### React 组件规范
- 函数组件优先
- 使用 TypeScript 定义 Props
- 组件文件名: kebab-case（`project-card.tsx`）
- 组件导出: 命名导出优先

### 样式规范
- **Tailwind CSS 优先**: 使用原子类
- **CSS 变量**: 定义在 `globals.css`
- **主题色**: 蓝紫粉渐变（`#3b82f6` → `#8b5cf6` → `#ec4899`）
- **暗色主题**: 默认主题
- **组件库**: shadcn/ui 按需使用

### 文件组织
- **Barrel Exports**: 使用 `index.ts` 统一导出
- **绝对路径导入**: `@/components/ui/button`
- **模块化**: 按功能分组（sections/、portfolio/、blog/）

## 状态管理策略

### Context API
```typescript
// contexts/site-config-context.tsx
import { createContext, useContext } from 'react';

const SiteConfigContext = createContext(null);

export function useSiteConfig() {
  return useContext(SiteConfigContext);
}
```

### Custom Hooks
```typescript
// hooks/use-translation.ts
export function useTranslation() {
  const [lang, setLang] = useState('zh');
  const dict = getDictionary(lang);
  return { dict, lang, setLang };
}
```

### 主题切换
```typescript
// 使用 next-themes
import { useTheme } from 'next-themes';

const { theme, setTheme } = useTheme();
```

## 样式系统

### 颜色方案
```css
/* 主题色 - 蓝紫粉渐变 */
--gradient-primary: linear-gradient(135deg, #3b82f6, #8b5cf6, #ec4899);

/* 暗色主题（默认） */
--bg-primary: #0f0f0f;
--bg-secondary: #1e1e1e;
--text-primary: #ffffff;
--text-secondary: #a3a3a3;

/* 亮色主题 */
--bg-light: #ffffff;
--text-dark: #1a1a1a;
```

### 组件风格
- **悬停效果**: `translateY(-4px)` + 发光阴影
- **动画时长**: 300ms cubic-bezier(0.4, 0, 0.2, 1)
- **边框渐变**: 鼠标悬停显示
- **布局**: Vercel 风格（大屏中心，大量留白）

### 响应式断点
```css
sm: 640px   /* 移动端 */
md: 768px   /* 平板 */
lg: 1024px  /* 桌面 */
xl: 1280px  /* 大屏 */
```

## 国际化（i18n）

### 语言文件结构
```
locales/
├── zh.json    # 中文
└── en.json    # English
```

### 使用方式
```typescript
const { dict, lang, setLang } = useTranslation();

// 在组件中
<h1>{dict.home.welcome}</h1>
```

### 博客双语
- 中文文章: `2025-01-27-title.md`
- 英文文章: `2025-01-27-title.en.md`

## 性能优化

### Next.js 优化
- **SSG**: 静态页面预生成
- **ISR**: 博客 60秒重新验证
- **Image Optimization**: 使用 `next/image`
- **Code Splitting**: 自动代码分割
- **Dynamic Import**: 组件懒加载

### 构建优化
- **Tree Shaking**: 移除未使用代码
- **Minification**: 代码压缩
- **Compression**: Gzip/Brotli 压缩
- **Cache Headers**: 静态资源缓存

## 注意事项

1. ⚠️ **水合错误**: 避免客户端/服务端状态不一致
2. ⚠️ **环境变量**: 使用 `.env.local`（不提交）
3. ⚠️ **博客元数据**: 必须包含完整 Front Matter
4. ⚠️ **构建输出**: `.next/` 目录不提交到 Git
5. ⚠️ **类型安全**: 所有组件必须定义 TypeScript 类型
- **动画**: Framer Motion

## 注意事项

1. **水合错误**: 避免客户端/服务端状态不一致
2. **环境变量**: 使用 `.env.local`
3. **博客文章**: 需要包含 Front Matter 元数据
4. **API 代理**: Next.js 可配置 rewrites
4. **构建输出**: `.next/` 目录不提交
