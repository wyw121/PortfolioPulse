# SQLx 编译时数据库验证问题修复

## 🚨 问题描述

```
error: set `DATABASE_URL` to use query macros online, or run `cargo sqlx prepare` to update the query cache
```

SQLx 的 `query!` 宏在编译时需要：
1. 设置 `DATABASE_URL` 环境变量，或
2. 运行 `cargo sqlx prepare` 生成查询缓存

## 🔍 问题根因

1. **SQLx 编译时检查**: SQLx 的 `query!` 宏在编译时验证 SQL 查询
2. **缺少环境变量**: CI 环境中 `DATABASE_URL` 未正确设置
3. **缺少查询缓存**: 没有预生成的 SQLx 查询元数据文件

## ✅ 解决方案

### 1. 在 CI 中设置完整的数据库环境

#### A. 添加 MySQL 服务
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

#### B. 数据库初始化
```yaml
- name: 🗄️ 设置数据库
  run: |
    chmod +x scripts/init-database.sh
    scripts/init-database.sh
  env:
    DB_HOST: 127.0.0.1
    DB_USER: root
    DB_PASS: password
    DB_NAME: portfolio_pulse
```

#### C. 编译时设置环境变量
```yaml
- name: 🦀 编译后端
  env:
    DATABASE_URL: mysql://root:password@127.0.0.1:3306/portfolio_pulse
  run: |
    # 安装 SQLx CLI
    cargo install sqlx-cli --no-default-features --features native-tls,mysql
    
    # 生成查询缓存 (如果需要)
    cargo sqlx prepare --check || cargo sqlx prepare
    
    # 编译
    cargo build --release --target x86_64-unknown-linux-gnu
```

### 2. 统一的数据库初始化脚本

**文件**: `scripts/init-database.sh`
- 支持环境变量配置
- 自动等待 MySQL 服务就绪
- 按顺序执行迁移脚本
- 兼容测试和生产环境

### 3. 完整的执行时序

```
MySQL 服务启动 → 代码检出 → Rust 环境 → 数据库初始化 → SQLx 准备 → 后端编译
```

## 🎯 修复效果

- ✅ SQLx 编译时验证通过
- ✅ 消除 "set DATABASE_URL" 错误  
- ✅ 生成查询缓存 (离线模式兼容)
- ✅ GitHub Actions 构建成功
- ✅ 交叉编译到 Ubuntu 22.04 成功

## 📋 涉及文件

- `scripts/init-database.sh` - 统一数据库初始化脚本
- `.github/workflows/deploy.yml` - 测试工作流
- `.github/workflows/ubuntu-cross-compile.yml` - 交叉编译工作流
- `SQLX_DATABASE_FIX.md` - 修复记录文档

## 🔍 验证方法

### 本地验证:
```bash
# 设置数据库
./scripts/init-database.sh

# 设置环境变量
export DATABASE_URL="mysql://root:password@localhost:3306/portfolio_pulse"

# 编译检查
cd backend
cargo sqlx prepare --check
cargo build
```

### CI 验证:
推送代码后检查 GitHub Actions 构建日志：
- ✅ MySQL 服务健康检查通过
- ✅ 数据库初始化成功
- ✅ SQLx 查询缓存生成/验证成功
- ✅ 后端编译成功

## 📚 技术细节

**SQLx 工作模式**:
1. **在线模式**: 编译时连接数据库验证查询
2. **离线模式**: 使用预生成的查询元数据 (`.sqlx/` 目录)

**选择在线模式的原因**:
- 🔒 更强的类型安全
- 🗄️ 确保查询与实际表结构匹配  
- 🚀 CI 环境更接近生产环境
- 🔄 自动检测数据库结构变化

**环境变量优先级**:
1. `DATABASE_URL` 环境变量
2. `.env` 文件
3. `sqlx-data.json` 查询缓存
4. 编译失败
