---
applyTo: "frontend/**/*,app/**/*,components/**/*,lib/**/*,hooks/**/*,store/**/*,types/**/*"
---

# 前端开发指引 - Next.js 15 现代化开发

## 🎯 设计理念 (参考 sindresorhus.com)

### 核心原则
- **极简主义**: 内容为王，去除多余装饰
- **现代科技**: 渐变效果 + 发光阴影
- **响应式**: 移动端优先设计
- **性能优先**: 代码分割 + 图片优化

## ⚡ 开发命令

### 日常开发
```bash
cd frontend
npm run dev         # 开发服务器 (端口 3000)
npm run build       # 生产构建 (Standalone输出)
npm run test        # 运行测试
npm run lint        # 代码检查
```

## 📁 目录结构 (App Router)
├── app/                    # Next.js 15 App Router
│   ├── (dashboard)/       # 仪表板路由组 (认证用户)
│   ├── (public)/          # 公共页面路由组 (访客)
│   ├── api/               # API 路由
│   ├── globals.css        # 全局样式
│   ├── layout.tsx         # 根布局
│   └── page.tsx           # 主页
├── components/
│   ├── ui/                # shadcn/ui 基础组件
│   ├── layout/            # 布局组件
│   ├── project/           # 项目相关组件
│   └── github/            # GitHub 相关组件
├── lib/                   # 工具库和配置
├── hooks/                 # 自定义 React Hooks
├── contexts/              # React Context 状态管理
└── types/                 # TypeScript 类型定义
```

### 组件设计原则

- 优先使用函数式组件
- 遵循单一职责原则
- 使用 TypeScript 严格模式
- 组件名使用 PascalCase
- 文件名使用 kebab-case

### 访问控制系统

#### 专属访问链接认证

```typescript
interface FriendAccess {
  token: string; // 唯一标识符
  nickname: string; // 友好显示名称
  permissions: string[]; // 访问权限
  createdAt: Date; // 创建时间
  lastAccess?: Date; // 最后访问时间
  isActive: boolean; // 是否激活
  trustScore: number; // 信任分数
}

const generateFriendLink = (nickname: string) => {
  const token = `friend-${nickname}-${Date.now()}`;
  return {
    url: `${SITE_URL}/welcome/${token}`,
    sessionToken: jwtToken,
  };
};
```

#### 设备指纹识别

```typescript
interface DeviceFingerprint {
  id: string;
  userAgent: string;
  screenResolution: string;
  timezone: string;
  language: string;
  platform: string;
  cookiesEnabled: boolean;
  localStorageEnabled: boolean;
  sessionStorageEnabled: boolean;
  indexedDBEnabled: boolean;
  addedPlugins: string[];
  canvas?: string;
  webgl?: string;
  createdAt: Date;
  lastSeen: Date;
  visitCount: number;
}
```

## shadcn/ui 集成

### 组件使用规范

- 优先使用 shadcn/ui 提供的基础组件
- 自定义组件放置在 `components/custom/` 目录
- 遵循 shadcn/ui 的变体系统进行扩展
- 使用 `cn()` 工具函数合并样式类

### 项目展示组件

```typescript
// 项目卡片组件 - 参考 sindresorhus.com 设计
interface ProjectCardProps {
  project: {
    id: string;
    name: string;
    description: string;
    techStack: string[];
    githubUrl?: string;
    liveUrl?: string;
    status: "active" | "completed" | "paused";
    lastUpdate: Date;
  };
  variant?: "default" | "compact" | "featured";
}
```

## 样式和主题

### 设计系统

- 使用 Tailwind CSS 进行样式开发
- 支持明暗主题切换 (`dark:` 前缀)
- 使用 CSS 变量定义主题色彩
- 响应式设计优先 (`sm:`, `md:`, `lg:`, `xl:`)

### sindresorhus.com 风格实现

```css
/* 全局样式变量 - 参考 sindresorhus 配色 */
:root {
  --color-primary: #007acc;
  --color-secondary: #6c757d;
  --color-success: #28a745;
  --color-warning: #ffc107;
  --color-danger: #dc3545;
  --color-background: #ffffff;
  --color-surface: #f8f9fa;
  --color-text: #212529;
  --color-text-secondary: #6c757d;
}

[data-theme="dark"] {
  --color-background: #1a1a1a;
  --color-surface: #2d2d2d;
  --color-text: #ffffff;
  --color-text-secondary: #a0a0a0;
}
```

## 状态管理 - React Context

### Context 结构

```typescript
// contexts/site-config-context.tsx
interface SiteConfig {
  // 站点配置
  title: string;
  description: string;
  url: string;
  
  // 用户状态
  user: User | null;
  
  // 项目数据
  projects: Project[];
  
  // GitHub 数据
  githubData: GitHubData | null;
  
  // UI 状态
  theme: "light" | "dark";
  locale: "zh" | "en";
}

const SiteConfigContext = createContext<SiteConfig | null>(null);

export function useSiteConfig() {
  const context = useContext(SiteConfigContext);
  if (!context) {
    throw new Error('useSiteConfig must be used within SiteConfigProvider');
  }
  return context;
}
```

### Custom Hooks

```typescript
// hooks/use-translation.ts
export function useTranslation() {
  const [lang, setLang] = useState<'zh' | 'en'>('zh');
  const dict = getDictionary(lang);
  return { dict, lang, setLang };
}

// hooks/use-theme.ts
import { useTheme } from 'next-themes';

export function useAppTheme() {
  const { theme, setTheme } = useTheme();
  return { theme, setTheme };
}
```

## 性能优化

### Next.js 15 特性

- 使用 App Router 进行路由管理
- 优先使用 Server Components
- Client Components 需明确 `'use client'` 声明
- 利用内置图片优化和字体优化

### 加载优化

- 实现组件懒加载
- 使用 React.memo 优化重渲染
- 图片使用 Next.js Image 组件
- 实施代码分割策略

## 代码质量

### TypeScript 规范

- 使用 ESLint 和 Prettier 保持代码风格一致
- 组件 Props 使用 TypeScript 接口定义
- 使用绝对路径导入 (`@/` 前缀)
- 遵循 React Hook 使用规则

### 测试策略

- 单元测试使用 Jest + Testing Library
- 组件测试覆盖关键交互
- E2E 测试使用 Playwright
- 视觉回归测试集成
