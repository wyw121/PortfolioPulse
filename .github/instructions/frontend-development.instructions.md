---
applyTo: "frontend/**/*,app/**/*,components/**/*,lib/**/*,hooks/**/*,store/**/*,types/**/*"
---

# 前端开发指引 - Next.js 15 + sindresorhus.com 设计理念

## 项目架构参考

### 设计灵感

- **参考站点**: [sindresorhus.com](https://sindresorhus.com)
- **设计理念**: 简洁、现代、专业
- **核心特点**: 极简主义、内容为王、优秀用户体验

## Next.js 15 开发规范

### 目录结构 (App Router)

```
frontend/
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
├── store/                 # Zustand 状态管理
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

## 状态管理 - Zustand

### Store 结构

```typescript
interface AppStore {
  // 用户状态
  user: User | null;
  setUser: (user: User | null) => void;

  // 项目数据
  projects: Project[];
  setProjects: (projects: Project[]) => void;

  // GitHub 数据
  githubData: GitHubData | null;
  setGitHubData: (data: GitHubData) => void;

  // UI 状态
  theme: "light" | "dark";
  toggleTheme: () => void;

  // 访问控制
  accessToken: string | null;
  userType: "owner" | "friend" | "visitor";
  setAccessToken: (token: string | null) => void;
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
