---
applyTo: "**/deploy/**/*,**/scripts/**/*,Dockerfile,docker-compose.yml,.github/workflows/**/*"
---

# 部署和 DevOps 指引

## 部署架构

### 前端部署 - Vercel

- 自动 CI/CD 集成
- 分支预览功能
- 环境变量管理
- 域名配置和 SSL

### 后端部署

- Docker 容器化部署
- 数据库迁移自动化
- 负载均衡配置
- 监控和日志记录

## 环境变量管理

### 必需环境变量

```bash
# 数据库配置
DATABASE_URL=mysql://user:password@host:port/database

# GitHub 集成
GITHUB_TOKEN=ghp_xxxxxxxxxxxx
GITHUB_USERNAME=your-username

# 认证配置
NEXTAUTH_SECRET=your-secret-key
NEXTAUTH_URL=https://your-domain.com

# Vercel 配置
VERCEL_TOKEN=your-vercel-token
```

### 开发环境设置

```bash
# 复制环境变量模板
cp .env.example .env.local

# 数据库初始化
cd backend && diesel migration run

# 启动开发服务器
npm run dev          # 前端 (端口 3000)
cargo run --release  # 后端 (端口 8000)
```

## 部署流程

### 前端部署流程

1. 推送到 main 分支触发自动部署
2. Vercel 构建和部署
3. 自动运行测试和类型检查
4. 部署到生产环境

### 后端部署流程

1. Docker 镜像构建
2. 数据库迁移
3. 服务健康检查
4. 滚动更新部署

## 监控和维护

### 性能监控

- 应用性能指标追踪
- 错误日志聚合
- 用户行为分析
- 系统资源监控

### 备份策略

- 数据库定期备份
- 代码版本管理
- 配置文件备份
- 恢复流程验证

## Docker 配置

### Dockerfile 最佳实践

```dockerfile
# 多阶段构建
FROM rust:1.75 as builder
FROM node:18-alpine as frontend

# 优化镜像大小
# 使用 Alpine Linux
# 清理构建缓存
```

### docker-compose 服务编排

```yaml
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=mysql://root:password@db:3306/portfolio
    depends_on:
      - db

  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: portfolio
    volumes:
      - db_data:/var/lib/mysql
```

## 安全配置

### HTTPS 和证书

- 使用 Let's Encrypt 或 Cloudflare
- 强制 HTTPS 重定向
- HSTS 头部设置
- CSP 策略配置

### 访问控制

- IP 白名单
- Rate Limiting
- CORS 配置
- 安全头部设置
