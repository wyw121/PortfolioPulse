---
applyTo: "frontend-vite/**/*,app/**/*,components/**/*,lib/**/*,hooks/**/*,store/**/*,types/**/*"
---

# 前端开发指引 - Vite + React 18 (重构后)

## 🎯 重构后技术栈 (2025-08-23)

**技术栈**: Vite + React 18 + TypeScript + React Router  
**构建工具**: Vite 5.4.19 (替代 Next.js)  
**部署方式**: 静态文件，由 Rust 后端服务  
**开发端口**: 3000 (开发) / 8000 (生产)

### 📁 新目录结构

```
frontend-vite/
├── src/
│   ├── main.tsx              # 应用入口
│   ├── App.tsx               # 主应用组件 + 路由
│   ├── components/           # 可复用组件
│   │   ├── Layout.tsx        # 布局组件
│   │   └── Navigation.tsx    # 导航组件
│   ├── pages/               # 页面组件
│   │   ├── HomePage.tsx
│   │   ├── ProjectsPage.tsx
│   │   ├── AboutPage.tsx
│   │   ├── BlogPage.tsx
│   │   └── ContactPage.tsx
│   ├── lib/                 # 工具函数
│   └── styles/              # 样式文件
├── public/                  # 静态资源
├── package.json
├── vite.config.ts           # Vite 配置
├── tailwind.config.js       # Tailwind 配置
└── tsconfig.json           # TypeScript 配置
```

### 🔄 路由系统 (React Router)

```tsx
// App.tsx
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/projects" element={<ProjectsPage />} />
        <Route path="/about" element={<AboutPage />} />
        <Route path="/blog" element={<BlogPage />} />
        <Route path="/contact" element={<ContactPage />} />
      </Routes>
    </Router>
  );
}
```

### 🛠️ 构建配置

```typescript
// vite.config.ts
export default defineConfig({
  build: {
    outDir: '../backend/static',  // 输出到后端静态目录
  },
  server: {
    port: 3000,
    proxy: {
      '/api': 'http://localhost:8000'  // API 代理到后端
    }
  }
});
```

## 🎨 设计理念 (参考 sindresorhus.com)

### 核心原则
- **极简主义**: 内容为王，去除多余装饰
- **现代科技**: 渐变效果 + 发光阴影
- **响应式**: 移动端优先设计
- **性能优先**: Vite HMR + 懒加载

## ⚡ 开发命令

### 日常开发
```bash
cd frontend-vite
npm run dev         # 开发服务器 (端口 3000)
npm run build       # 生产构建 (输出到 ../backend/static/)
npm run preview     # 预览生产构建
npm run lint        # 代码检查
```

## React 18 开发规范

### 组件开发

- 使用函数组件 + Hooks
- TypeScript 严格模式，类型安全第一
- 组件命名使用 PascalCase
- 文件命名使用 kebab-case

### Hooks 使用

```tsx
// 状态管理
const [state, setState] = useState<Type>(initialValue);

// 副作用
useEffect(() => {
  // 异步操作
}, [dependencies]);

// API 调用
const { data, loading, error } = useQuery('/api/projects');
```
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
