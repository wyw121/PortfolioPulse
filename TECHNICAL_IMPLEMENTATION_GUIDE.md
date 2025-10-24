# PortfolioPulse 技术实现指导文档

## 📋 概述

本文档基于对 sindresorhus.com 的深入分析，结合现代 Web 开发最佳实践，为 PortfolioPulse 项目提供详细的技术实现指导。

**设计参考**: [sindresorhus.com](https://sindresorhus.com) - 简洁现代的个人主页典范
**项目仓库**: [sindresorhus/sindresorhus.github.com](https://github.com/sindresorhus/sindresorhus.github.com)

## 🏗️ 前端技术实现

### 1. 项目架构 - 基于 Next.js 15 + sindresorhus.com 设计模式

#### 1.1 目录结构
```
frontend/
├── app/                    # Next.js 15 App Router
│   ├── (dashboard)/       # 仪表板路由组 (认证用户)
│   ├── (public)/          # 公共页面路由组 (访客)
│   ├── api/               # API 路由
│   │   ├── auth/          # 认证相关API
│   │   ├── github/        # GitHub数据获取
│   │   └── projects/      # 项目管理API
│   ├── globals.css        # 全局样式 (Tailwind基础)
│   ├── layout.tsx         # 根布局 (Meta标签+主题)
│   └── page.tsx           # 主页 (参考sindre的首页布局)
├── components/
│   ├── ui/                # shadcn/ui 基础组件
│   │   ├── button.tsx     # 按钮组件
│   │   ├── card.tsx       # 卡片组件 (项目展示核心)
│   │   ├── navigation-menu.tsx # 导航组件
│   │   └── heat-map.tsx   # GitHub贡献热力图
│   ├── layout/            # 布局组件
│   │   ├── header.tsx     # 顶部导航 (参考sindre的sticky设计)
│   │   ├── footer.tsx     # 页脚 (简洁社交链接)
│   │   └── mobile-nav.tsx # 移动端导航 (汉堡菜单)
│   ├── project/           # 项目相关组件
│   │   ├── project-card.tsx # 项目卡片
│   │   ├── project-grid.tsx # 响应式网格
│   │   └── project-filter.tsx # 项目筛选
│   └── github/            # GitHub相关组件
│       ├── contribution-graph.tsx # 贡献图表
│       ├── latest-commits.tsx     # 最新提交
│       └── repo-stats.tsx         # 仓库统计
├── lib/
│   ├── utils.ts           # 工具函数 (cn分类器等)
│   ├── github-api.ts      # GitHub API客户端
│   ├── auth.ts            # 认证逻辑
│   └── device-fingerprint.ts # 设备指纹生成
├── hooks/                 # 自定义 React Hooks
│   ├── use-github-data.ts # GitHub数据hooks
│   ├── use-visitor-auth.ts # 访客认证hooks
│   └── use-responsive.ts   # 响应式hooks
├── store/                 # Zustand 状态管理
│   ├── visitor-store.ts   # 访客状态
│   ├── projects-store.ts  # 项目数据
│   └── ui-store.ts        # UI状态 (主题、导航等)
├── types/                 # TypeScript 类型定义
│   ├── github.ts          # GitHub API类型
│   ├── visitor.ts         # 访客类型
│   └── project.ts         # 项目类型
└── constants/             # 常量定义
    ├── routes.ts          # 路由常量
    ├── github.ts          # GitHub配置
    └── ui.ts              # UI常量
```

#### 1.2 核心技术栈 - 经过验证的选择
- **框架**: Next.js 15 + React 18 + TypeScript
- **样式**: Tailwind CSS + shadcn/ui 组件库
- **状态管理**: Zustand (轻量级，类似 Sindre 的简洁哲学)
- **数据获取**: TanStack Query (强大的缓存和同步)
- **表单处理**: React Hook Form (性能优先)
- **动画**: CSS Transitions + Framer Motion (渐进增强)
- **图标**: Tabler Icons (与 sindre 保持一致)
- **GitHub贡献图**: @uiw/react-heat-map

### 2. 关键组件设计 - 参考 sindresorhus.com

#### 2.1 Header 组件 - 响应式导航

```typescript
// components/layout/header.tsx
'use client';

import { useState } from 'react';
import { Menu, X, Github, Mail, Rss } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useVisitorStore } from '@/store/visitor-store';

export function Header() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const { visitor, isAuthenticated } = useVisitorStore();

  return (
    <header className="sticky top-0 z-40 w-full bg-white/90 backdrop-blur-md border-b dark:bg-slate-950/90 dark:border-slate-800">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center py-4">
          {/* Logo */}
          <div className="flex items-center space-x-2">
            <span className="text-2xl font-bold">
              {/* 首页显示 🦄，其他页面显示名字 - 参考 Sindre */}
              PortfolioPulse
            </span>
          </div>

          {/* Desktop Navigation */}
          <nav className="hidden md:flex items-center space-x-8">
            <a href="/projects" className="text-gray-600 hover:text-gray-900 dark:text-gray-300">
              Projects
            </a>
            <a href="/learning" className="text-gray-600 hover:text-gray-900 dark:text-gray-300">
              Learning
            </a>
            <a href="/about" className="text-gray-600 hover:text-gray-900 dark:text-gray-300">
              About
            </a>

            {/* Social Icons */}
            <div className="flex items-center space-x-2">
              <Button variant="ghost" size="icon">
                <Github className="h-5 w-5" />
              </Button>
              <Button variant="ghost" size="icon">
                <Mail className="h-5 w-5" />
              </Button>
              <Button variant="ghost" size="icon">
                <Rss className="h-5 w-5" />
              </Button>
            </div>
          </nav>

          {/* Mobile Menu Button */}
          <Button
            variant="ghost"
            size="icon"
            className="md:hidden"
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          >
            {mobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
          </Button>
        </div>

        {/* Mobile Navigation */}
        {mobileMenuOpen && (
          <nav className="md:hidden py-4 border-t dark:border-slate-800">
            <div className="flex flex-col space-y-4">
              <a href="/projects" className="text-gray-600 hover:text-gray-900 dark:text-gray-300">
                Projects
              </a>
              <a href="/learning" className="text-gray-600 hover:text-gray-900 dark:text-gray-300">
                Learning
              </a>
              <a href="/about" className="text-gray-600 hover:text-gray-900 dark:text-gray-300">
                About
              </a>
            </div>
          </nav>
        )}
      </div>
    </header>
  );
}
```

#### 2.2 GitHub 贡献图组件

```typescript
// components/github/contribution-graph.tsx
'use client';

import { useQuery } from '@tanstack/react-query';
import HeatMap from '@uiw/react-heat-map';
import { getGitHubContributions } from '@/lib/github-api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';

interface ContributionGraphProps {
  username: string;
  className?: string;
}

export function ContributionGraph({ username, className }: ContributionGraphProps) {
  const { data: contributions, isLoading } = useQuery({
    queryKey: ['github-contributions', username],
    queryFn: () => getGitHubContributions(username),
    staleTime: 4 * 60 * 60 * 1000, // 4小时缓存
  });

  if (isLoading) {
    return (
      <Card className={className}>
        <CardHeader>
          <CardTitle>GitHub Activity</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="animate-pulse bg-gray-200 dark:bg-gray-700 h-32 rounded" />
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={className}>
      <CardHeader>
        <CardTitle>GitHub Activity</CardTitle>
      </CardHeader>
      <CardContent>
        <HeatMap
          value={contributions}
          width="100%"
          style={{ color: '#ad7242' }}
          startDate={new Date('2024/01/01')}
          panelColors={{
            0: '#ebedf0',
            2: '#c6e48b',
            4: '#7bc96f',
            10: '#239a3b',
            20: '#196127',
          }}
          rectProps={{
            rx: 2,
          }}
        />
        <p className="text-sm text-gray-500 mt-2">
          {contributions?.reduce((sum, day) => sum + day.count, 0) || 0} contributions in the last year
        </p>
      </CardContent>
    </Card>
  );
}
```

#### 2.3 项目卡片组件 - 响应式设计

```typescript
// components/project/project-card.tsx
'use client';

import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { ExternalLink, Github, Star } from 'lucide-react';
import { Project } from '@/types/project';

interface ProjectCardProps {
  project: Project;
  showFullContent: boolean; // 基于访客权限
}

export function ProjectCard({ project, showFullContent }: ProjectCardProps) {
  return (
    <Card className="group hover:shadow-xl transition-all duration-300 dark:hover:shadow-indigo-500/20">
      <CardContent className="p-6">
        <div className="flex items-start space-x-4">
          {/* 项目图标 */}
          <div className="flex-shrink-0">
            <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg flex items-center justify-center">
              <span className="text-2xl font-bold text-white">
                {project.name.charAt(0).toUpperCase()}
              </span>
            </div>
          </div>

          <div className="flex-1 min-w-0">
            <div className="flex items-center justify-between mb-2">
              <h3 className="text-xl font-bold text-gray-900 dark:text-white group-hover:text-blue-600 transition-colors">
                {project.name}
              </h3>
              <div className="flex items-center space-x-2">
                {project.stars && (
                  <div className="flex items-center text-yellow-500">
                    <Star className="w-4 h-4 mr-1" />
                    <span className="text-sm">{project.stars}</span>
                  </div>
                )}
              </div>
            </div>

            <p className="text-gray-600 dark:text-gray-300 mb-3 line-clamp-2">
              {showFullContent ? project.description : `${project.description.substring(0, 100)}...`}
            </p>

            {/* 技术标签 */}
            <div className="flex flex-wrap gap-2 mb-4">
              {project.technologies?.slice(0, showFullContent ? undefined : 3).map((tech) => (
                <Badge key={tech} variant="secondary" className="text-xs">
                  {tech}
                </Badge>
              ))}
              {!showFullContent && project.technologies?.length > 3 && (
                <Badge variant="outline" className="text-xs">
                  +{project.technologies.length - 3} more
                </Badge>
              )}
            </div>

            {/* 操作按钮 */}
            <div className="flex items-center justify-between">
              <div className="flex space-x-2">
                <Badge
                  variant={project.status === 'active' ? 'default' : 'secondary'}
                  className="text-xs"
                >
                  {project.status}
                </Badge>
                <Badge variant="outline" className="text-xs">
                  {project.isPrivate ? 'Private' : 'Public'}
                </Badge>
              </div>

              {showFullContent && (
                <div className="flex space-x-2">
                  {project.demoUrl && (
                    <a
                      href={project.demoUrl}
                      className="text-blue-600 hover:text-blue-800 dark:text-blue-400"
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      <ExternalLink className="w-4 h-4" />
                    </a>
                  )}
                  {project.githubUrl && (
                    <a
                      href={project.githubUrl}
                      className="text-gray-600 hover:text-gray-800 dark:text-gray-400"
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      <Github className="w-4 h-4" />
                    </a>
                  )}
                </div>
              )}
            </div>

            {!showFullContent && (
              <div className="mt-3 p-2 bg-blue-50 dark:bg-blue-900/20 rounded-lg text-center">
                <p className="text-sm text-blue-600 dark:text-blue-400">
                  Sign in to view full project details
                </p>
              </div>
            )}
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
```

```typescript
// store/visitor-store.ts
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface VisitorProfile {
  id: string;
  type: 'guest' | 'device_user' | 'named_friend';
  fingerprint?: string;
  friendCode?: string;
  trustScore: number;
  lastVisit: string;
  displayName: string;
  preferences: {
    theme: 'light' | 'dark' | 'system';
    language: 'en' | 'zh-CN';
  };
}

interface VisitorStore {
  visitor: VisitorProfile | null;
  isAuthenticated: boolean;
  accessLevel: 'guest' | 'authenticated';

  // Actions
  setVisitor: (visitor: VisitorProfile) => void;
  updateTrustScore: (score: number) => void;
  logout: () => void;

  // Content Access
  canViewFullContent: () => boolean;
  canInteract: () => boolean;
}

export const useVisitorStore = create<VisitorStore>()(
  devtools(
    persist(
      (set, get) => ({
        visitor: null,
        isAuthenticated: false,
        accessLevel: 'guest',

        setVisitor: (visitor) => set({
          visitor,
          isAuthenticated: visitor.type !== 'guest',
          accessLevel: visitor.type !== 'guest' ? 'authenticated' : 'guest'
        }),

        updateTrustScore: (score) => set((state) => ({
          visitor: state.visitor ? { ...state.visitor, trustScore: score } : null
        })),

        logout: () => set({
          visitor: null,
          isAuthenticated: false,
          accessLevel: 'guest'
        }),

        canViewFullContent: () => {
          const { visitor } = get();
          return visitor?.type === 'device_user' || visitor?.type === 'named_friend';
        },

        canInteract: () => {
          const { visitor } = get();
          return visitor?.trustScore >= 15 && get().canViewFullContent();
        }
      }),
      {
        name: 'visitor-storage',
        partialize: (state) => ({
          visitor: state.visitor,
          isAuthenticated: state.isAuthenticated,
          accessLevel: state.accessLevel
        })
      }
    )
  )
);
```

### 4. GitHub API 集成

```typescript
// lib/github-api.ts
import { Octokit } from '@octokit/rest';

const octokit = new Octokit({
  auth: process.env.GITHUB_TOKEN,
});

export interface GitHubContribution {
  date: string;
  count: number;
  level: 0 | 1 | 2 | 3 | 4;
}

export interface GitHubRepo {
  id: number;
  name: string;
  description: string | null;
  stargazers_count: number;
  forks_count: number;
  language: string | null;
  topics: string[];
  updated_at: string;
  html_url: string;
  private: boolean;
}

// 获取用户贡献数据
export async function getGitHubContributions(username: string): Promise<GitHubContribution[]> {
  try {
    // 使用 GitHub GraphQL API 获取贡献数据
    const query = `
      query($username: String!) {
        user(login: $username) {
          contributionsCollection {
            contributionCalendar {
              totalContributions
              weeks {
                contributionDays {
                  contributionCount
                  date
                }
              }
            }
          }
        }
      }
    `;

    const response = await fetch('https://api.github.com/graphql', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.GITHUB_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ query, variables: { username } }),
    });

    const data = await response.json();

    if (data.errors) {
      throw new Error('GitHub GraphQL API error');
    }

    const weeks = data.data.user.contributionsCollection.contributionCalendar.weeks;
    const contributions: GitHubContribution[] = [];

    weeks.forEach(week => {
      week.contributionDays.forEach(day => {
        contributions.push({
          date: day.date,
          count: day.contributionCount,
          level: Math.min(4, Math.floor(day.contributionCount / 3)) as 0 | 1 | 2 | 3 | 4
        });
      });
    });

    return contributions;
  } catch (error) {
    console.error('Failed to fetch GitHub contributions:', error);
    // 返回空数组或缓存数据
    return [];
  }
}

// 获取用户仓库列表
export async function getUserRepos(username: string): Promise<GitHubRepo[]> {
  try {
    const { data } = await octokit.repos.listForUser({
      username,
      sort: 'updated',
      per_page: 20,
    });

    return data.map(repo => ({
      id: repo.id,
      name: repo.name,
      description: repo.description,
      stargazers_count: repo.stargazers_count,
      forks_count: repo.forks_count,
      language: repo.language,
      topics: repo.topics || [],
      updated_at: repo.updated_at,
      html_url: repo.html_url,
      private: repo.private,
    }));
  } catch (error) {
    console.error('Failed to fetch GitHub repos:', error);
    return [];
  }
}

// 获取最新提交
export async function getLatestCommits(username: string, repo: string, count = 5) {
  try {
    const { data } = await octokit.repos.listCommits({
      owner: username,
      repo,
      per_page: count,
    });

    return data.map(commit => ({
      sha: commit.sha,
      message: commit.commit.message,
      author: commit.commit.author?.name || 'Unknown',
      date: commit.commit.author?.date || '',
      url: commit.html_url,
    }));
  } catch (error) {
    console.error('Failed to fetch commits:', error);
    return [];
  }
}
```

### 5. 设备指纹生成

```typescript
// lib/device-fingerprint.ts
interface DeviceInfo {
  userAgent: string;
  language: string;
  platform: string;
  screenResolution: string;
  timezone: string;
  touchSupport: boolean;
  canvasFingerprint: string;
}

export async function generateDeviceFingerprint(): Promise<string> {
  const deviceInfo: DeviceInfo = {
    userAgent: navigator.userAgent,
    language: navigator.language,
    platform: navigator.platform,
    screenResolution: `${screen.width}x${screen.height}`,
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
    touchSupport: 'ontouchstart' in window,
    canvasFingerprint: await generateCanvasFingerprint(),
  };

  // 使用简单的哈希算法生成指纹
  const fingerprint = await hashDeviceInfo(deviceInfo);

  return fingerprint;
}

async function generateCanvasFingerprint(): Promise<string> {
  const canvas = document.createElement('canvas');
  const ctx = canvas.getContext('2d');

  if (!ctx) return 'no-canvas';

  // 绘制一些图形来生成独特的画布指纹
  ctx.textBaseline = 'top';
  ctx.font = '14px Arial';
  ctx.fillText('PortfolioPulse fingerprint', 2, 2);
  ctx.fillStyle = 'rgba(102, 204, 0, 0.7)';
  ctx.fillRect(100, 5, 80, 20);

  return canvas.toDataURL();
}

async function hashDeviceInfo(deviceInfo: DeviceInfo): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(JSON.stringify(deviceInfo));
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

// 信任评分计算
export function calculateTrustScore(visitHistory: any[]): number {
  let score = 15; // 基础分数

  // 访问频率加分
  if (visitHistory.length > 10) score += 10;
  if (visitHistory.length > 50) score += 20;

  // 连续访问加分
  const recentVisits = visitHistory.filter(v =>
    new Date().getTime() - new Date(v.timestamp).getTime() < 7 * 24 * 60 * 60 * 1000
  );
  score += Math.min(30, recentVisits.length * 2);

  // 交互行为加分（浏览时长、点击等）
  const avgDuration = visitHistory.reduce((sum, v) => sum + (v.duration || 0), 0) / visitHistory.length;
  if (avgDuration > 30000) score += 15; // 30秒以上
  if (avgDuration > 120000) score += 25; // 2分钟以上

  return Math.min(100, Math.max(15, score));
}
```

## 🔧 后端技术实现

### 1. Rust 服务架构

#### 1.1 项目结构
```
backend/
├── src/
│   ├── main.rs           # 应用入口
│   ├── lib.rs            # 库根文件
│   ├── handlers/         # 请求处理器
│   ├── models/           # 数据模型
│   ├── services/         # 业务逻辑服务
│   ├── middleware/       # 中间件
│   ├── utils/            # 工具函数
│   └── config/           # 配置管理
├── migrations/           # 数据库迁移文件
├── tests/               # 测试文件
├── Cargo.toml           # Rust 项目配置
└── Dockerfile           # 容器配置
```

#### 1.2 核心依赖
```toml
[dependencies]
# Web 框架
axum = "0.7"
tokio = { version = "1", features = ["full"] }
tower = "0.4"

# 数据库
diesel = { version = "2.1", features = ["mysql", "chrono"] }
mysql = "24"

# 序列化
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"

# 认证和安全
jsonwebtoken = "8"
bcrypt = "0.14"

# 其他
chrono = { version = "0.4", features = ["serde"] }
uuid = { version = "1.0", features = ["v4", "serde"] }
```

### 2. API 设计规范

*（待实现时详细补充）*

### 3. 数据库架构

*（待实现时详细补充）*

## 🗄️ 数据库设计

### 1. 表结构设计

*（待实现时详细补充）*

### 2. 数据关系映射

*（待实现时详细补充）*

### 3. 索引优化策略

*（待实现时详细补充）*

## 🚀 部署与运维

### 1. 容器化配置

#### 1.1 Docker 配置
```dockerfile
# Dockerfile 示例框架
FROM node:18-alpine AS frontend-builder
# ... 前端构建步骤

FROM rust:1.75-slim AS backend-builder
# ... 后端构建步骤

FROM nginx:alpine AS production
# ... 生产环境配置
```

#### 1.2 Docker Compose 编排
```yaml
# docker-compose.yml 示例框架
version: '3.8'

services:
  frontend:
    build: ./frontend
    # ... 配置详情

  backend:
    build: ./backend
    # ... 配置详情

  database:
    image: mysql:8.0
    # ... 配置详情

  redis:
    image: redis:alpine
    # ... 配置详情
```

### 2. CI/CD 流程

*（待实现时详细补充）*

### 3. 监控与日志

*（待实现时详细补充）*

## 🔐 安全实现

### 1. 认证机制

*（待实现时详细补充）*

### 2. 权限控制

*（待实现时详细补充）*

### 3. 数据安全

*（待实现时详细补充）*

## ⚡ 性能优化

### 1. 前端性能

*（待实现时详细补充）*

### 2. 后端性能

*（待实现时详细补充）*

### 3. 数据库性能

*（待实现时详细补充）*

## 🧪 测试策略

### 1. 前端测试

*（待实现时详细补充）*

### 2. 后端测试

*（待实现时详细补充）*

### 3. 集成测试

*（待实现时详细补充）*

## 📝 开发规范

### 1. 代码规范

*（待实现时详细补充）*

### 2. Git 工作流

*（待实现时详细补充）*

### 3. 文档规范

*（待实现时详细补充）*

---

*本文档将在技术实现阶段根据实际开发进展逐步完善和补充具体的实现细节。*
