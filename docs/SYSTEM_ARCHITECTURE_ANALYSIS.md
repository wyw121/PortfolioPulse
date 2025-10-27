# PortfolioPulse 系统架构与数据同步分析文档

## 📋 项目概述

PortfolioPulse 作为个人项目集动态和学习记录平台，需要综合考虑数据同步、权限管理、系统架构隔离等多个方面。本文档详细分析了系统的各个层面，为项目的完善提供指导。

## 🔄 数据同步策略

### 1. 数据源分类

#### 1.1 自动同步数据

- **GitHub 仓库数据**

  - 提交记录（commits）
  - 分支状态（branches）
  - 问题追踪（issues）
  - 拉取请求（pull requests）
  - 代码统计（code statistics）
- **项目运行状态**

  - 服务健康检查
  - 部署状态
  - 访问统计

#### 1.2 手动录入数据

- **学习记录**

  - 学习内容
  - 进度更新
  - 知识总结
  - 标签分类
- **项目描述**

  - 项目介绍
  - 技术栈说明
  - 演示链接

### 2. 同步机制设计

#### 2.1 实时同步（Real-time Sync）

```mermaid
graph LR
    A[GitHub Webhooks] --> B[后端API]
    B --> C[数据库更新]
    C --> D[WebSocket推送]
    D --> E[前端实时更新]
```

**实现方式：**

- GitHub Webhooks 触发
- Server-Sent Events (SSE) 或 WebSocket
- 数据增量更新

#### 2.2 定时同步（Scheduled Sync）

```mermaid
graph TB
    A[Cron Job调度器] --> B[GitHub API轮询]
    B --> C[数据对比]
    C --> D{是否有变更}
    D -->|是| E[更新数据库]
    D -->|否| F[等待下次调度]
    E --> G[推送通知]
```

**同步频率建议：**

- 提交数据：每30分钟
- 项目状态：每小时
- 统计数据：每日
- 备份数据：每周

#### 2.3 手动触发同步

- 管理员界面手动刷新按钮
- API接口触发同步
- 紧急数据恢复机制

## 🔐 权限管理与访问控制

### 1. 用户角色设计

#### 1.1 角色层级

```
Owner (你)
├── 完全控制权限
├── 数据管理权限
├── 系统配置权限
└── 内容发布权限

Friend (朋友们)
├── 查看公开项目
├── 查看学习记录
├── 留言评论（可选）
└── 无管理权限

Visitor (访客)
├── 查看基础信息
├── 查看公开项目列表
└── 只读权限
```

#### 1.2 认证策略

- **无需登录访问**：基础项目展示、公开学习记录
- **朋友邀请码**：通过邀请码注册，查看更多详细内容
- **管理员隐藏入口**：URL路径 + 特殊参数 + JWT认证

### 2. 内容发布机制

#### 2.1 隐藏式管理入口

```typescript
// 示例：隐藏管理入口
// 访问 https://yoursite.com/projects?admin=true&token=SECRET_TOKEN
// 或者 https://yoursite.com/secret-admin-panel

const AdminPanel = () => {
  const [isAuthorized, setIsAuthorized] = useState(false);

  useEffect(() => {
    const checkAuth = async () => {
      const urlParams = new URLSearchParams(window.location.search);
      const adminFlag = urlParams.get('admin');
      const token = urlParams.get('token') || localStorage.getItem('adminToken');

      if (adminFlag === 'true' && token === process.env.NEXT_PUBLIC_ADMIN_SECRET) {
        setIsAuthorized(true);
      }
    };

    checkAuth();
  }, []);

  // 管理界面组件
};
```

#### 2.2 内容管理功能

- **项目管理**

  - 添加/编辑/删除项目
  - 设置项目可见性
  - 配置项目链接
- **学习记录管理**

  - 快速添加学习条目
  - 批量导入/导出
  - 标签管理
- **动态发布**

  - Markdown编辑器
  - 图片上传
  - 发布时间控制

## 🏗️ 系统架构与隔离策略

### 1. 服务隔离方案

#### 1.1 容器化部署

```yaml
# docker-compose.yml 示例
version: '3.8'

services:
  portfoliopulse-frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    networks:
      - portfolio-network

  portfoliopulse-backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - JWT_SECRET=${JWT_SECRET}
    networks:
      - portfolio-network

  # 其他项目服务
  project-a:
    build: ./projects/project-a
    ports:
      - "3001:3000"
    networks:
      - project-a-network

  project-b:
    build: ./projects/project-b
    ports:
      - "3002:3000"
    networks:
      - project-b-network

networks:
  portfolio-network:
    driver: bridge
  project-a-network:
    driver: bridge
  project-b-network:
    driver: bridge
```

#### 1.2 反向代理配置

```nginx
# nginx.conf
server {
    listen 80;
    server_name yourdomain.com;

    # PortfolioPulse 主站
    location / {
        proxy_pass http://portfoliopulse-frontend:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # API 路由
    location /api/ {
        proxy_pass http://portfoliopulse-backend:8000/;
    }

    # 子项目A
    location /projects/project-a/ {
        proxy_pass http://project-a:3000/;
        proxy_set_header Host $host;
    }

    # 子项目B
    location /projects/project-b/ {
        proxy_pass http://project-b:3000/;
    }
}
```

### 2. 数据库隔离策略

#### 2.1 数据库分离方案

```sql
-- 数据库规划
CREATE DATABASE portfolio_pulse;  -- 主应用数据库
CREATE DATABASE project_a_db;     -- 项目A数据库
CREATE DATABASE project_b_db;     -- 项目B数据库
CREATE DATABASE shared_resources; -- 共享资源数据库

-- 用户权限隔离
CREATE USER 'portfolio_user'@'%' IDENTIFIED BY 'secure_password';
CREATE USER 'project_a_user'@'%' IDENTIFIED BY 'project_a_password';
CREATE USER 'project_b_user'@'%' IDENTIFIED BY 'project_b_password';

GRANT ALL PRIVILEGES ON portfolio_pulse.* TO 'portfolio_user'@'%';
GRANT ALL PRIVILEGES ON project_a_db.* TO 'project_a_user'@'%';
GRANT ALL PRIVILEGES ON project_b_db.* TO 'project_b_user'@'%';
```

#### 2.2 会话与Cookie隔离

```javascript
// 不同项目使用不同的会话存储键
const sessionConfig = {
  portfolioPulse: {
    name: 'portfolio_session',
    domain: '.yourdomain.com',
    path: '/'
  },
  projectA: {
    name: 'project_a_session',
    domain: '.yourdomain.com',
    path: '/projects/project-a'
  },
  projectB: {
    name: 'project_b_session',
    domain: '.yourdomain.com',
    path: '/projects/project-b'
  }
};
```

## ⚡ 性能优化策略

### 1. 缓存策略

```typescript
// Redis 缓存配置
const cacheConfig = {
  github_data: { ttl: 1800 }, // 30分钟
  project_stats: { ttl: 3600 }, // 1小时
  user_sessions: { ttl: 86400 }, // 24小时
  static_content: { ttl: 604800 } // 7天
};
```

### 2. CDN 与静态资源

- 图片、样式文件使用CDN加速
- 静态资源版本控制
- 压缩与优化

## 🛡️ 安全考虑

### 1. API 安全

```typescript
// API 限流中间件
const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分钟
  max: 100, // 最多100个请求
  message: 'Too many requests from this IP'
});

// JWT 验证中间件
const verifyToken = (req: Request, res: Response, next: NextFunction) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({ error: 'Access denied' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(400).json({ error: 'Invalid token' });
  }
};
```

### 2. 数据安全

- 敏感信息加密存储
- SQL注入防护
- XSS攻击防护
- CSRF令牌验证

## 📊 监控与运维

### 1. 健康检查

```typescript
// 健康检查端点
app.get('/health', async (req, res) => {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis(),
    github_api: await checkGitHubAPI(),
    disk_space: await checkDiskSpace()
  };

  const isHealthy = Object.values(checks).every(check => check.status === 'ok');

  res.status(isHealthy ? 200 : 503).json(checks);
});
```

### 2. 日志管理

- 结构化日志记录
- 错误日志告警
- 访问日志分析
- 性能指标收集

## 🔧 部署配置

### 1. 环境变量管理

```bash
# 生产环境配置
NODE_ENV=production
DATABASE_URL=mysql://user:pass@localhost:3306/portfolio_pulse
REDIS_URL=redis://localhost:6379
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
JWT_SECRET=your-super-secure-jwt-secret
ADMIN_SECRET_TOKEN=your-admin-access-token
NEXTAUTH_SECRET=your-nextauth-secret
NEXTAUTH_URL=https://yourdomain.com

# 子项目隔离配置
PROJECT_A_DB_URL=mysql://user:pass@localhost:3306/project_a_db
PROJECT_B_DB_URL=mysql://user:pass@localhost:3306/project_b_db
```

### 2. CI/CD 流水线

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Setup Rust
        uses: actions-rs/toolchain@v1
        with:
          toolchain: stable

      - name: Build and Deploy
        run: |
          npm install
          npm run build
          cargo build --release

          # 部署到服务器
          rsync -avz ./dist/ user@server:/var/www/portfolio/
```

## 💡 未来扩展建议

### 1. 功能扩展

- 访客评论系统
- RSS订阅功能
- 邮件通知系统
- 移动端PWA支持
- 数据可视化dashboard
- AI助手集成

### 2. 技术升级

- 微服务架构迁移
- GraphQL API
- 服务网格(Service Mesh)
- 容器编排(Kubernetes)

*本文档将根据讨论结果持续更新和完善。*
