# SQLx 编译时数据库验证问题修复

## 🚨 问题描述

```
error: error returned from database: 1146 (42S02): Table 'portfolio_pulse_test.blog_posts' doesn't exist
```

SQLx 在编译时会连接数据库验证查询语句，但 CI 环境中的测试数据库没有运行迁移，导致表不存在。

## 🔍 问题根因

1. **SQLx 编译时检查**: SQLx 的 `query!` 宏在编译时验证 SQL 查询
2. **缺少数据库表**: CI 环境的 MySQL 服务没有执行迁移脚本
3. **时序问题**: 数据库服务启动后没有初始化表结构

## ✅ 解决方案

### 1. 创建数据库初始化脚本

**文件**: `scripts/init-database.sh`
```bash
#!/bin/bash
# 统一的数据库初始化脚本
# 支持环境变量配置
# 自动等待服务就绪
# 按顺序执行迁移
```

### 2. 更新 GitHub Actions 工作流

#### 在 `deploy.yml` 中：
```yaml
- name: 🗄️ Setup Database
  run: |
    chmod +x scripts/init-database.sh
    scripts/init-database.sh
  env:
    DB_HOST: 127.0.0.1
    DB_USER: root
    DB_PASS: password
    DB_NAME: portfolio_pulse_test
```

#### 在 `ubuntu-cross-compile.yml` 中：
```yaml
services:
  mysql:
    image: mysql:8.0
    env:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: portfolio_pulse
    ports:
      - 3306:3306
    options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
```

### 3. 确保正确的执行顺序

1. 启动 MySQL 服务 (services)
2. 检出代码 (checkout)
3. 设置 Rust 环境
4. **设置数据库** (运行迁移) ← 关键步骤
5. 编译后端 (此时数据库表已存在)

## 🎯 修复效果

- ✅ SQLx 编译时能找到所有必需的表
- ✅ 消除 "Table doesn't exist" 错误  
- ✅ 支持多环境配置 (test/production)
- ✅ 统一的数据库初始化流程

## 📋 涉及文件

- `scripts/init-database.sh` - 新增数据库初始化脚本
- `.github/workflows/deploy.yml` - 更新测试工作流
- `.github/workflows/ubuntu-cross-compile.yml` - 更新交叉编译工作流

## 🔍 验证方法

### 本地验证:
```bash
# 启动本地 MySQL
# 运行初始化脚本
./scripts/init-database.sh

# 编译检查
cd backend && cargo check
```

### CI 验证:
推送代码后检查 GitHub Actions 构建日志，应看到：
- ✅ MySQL 服务启动
- ✅ 数据库初始化成功  
- ✅ 后端编译成功

## 📚 技术说明

**SQLx 编译时检查机制**:
- SQLx 在编译期连接数据库
- 验证查询语句和表结构
- 生成类型安全的代码
- 需要真实的数据库环境

**替代方案**:
- `SQLX_OFFLINE=true` + 预生成查询元数据
- 使用 `query_as!` 替代 `query!`
- 采用运行时查询验证

**选择当前方案的原因**:
- 保持类型安全
- 不需要维护额外的元数据文件
- CI 环境更接近生产环境
