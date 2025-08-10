# 二进制部署 vs Docker 部署对比

## 方案一：纯二进制部署（你提到的方案）

### Windows 交叉编译到 Linux
```bash
# 在 Windows 上为 Linux 编译 Rust
rustup target add x86_64-unknown-linux-gnu
cargo build --target x86_64-unknown-linux-gnu --release
```

### 优点：
- ✅ 文件小（只有二进制文件）
- ✅ 启动快
- ✅ 资源占用少
- ✅ 不需要 Docker 环境

### 缺点：
- ❌ 跨平台编译复杂（Windows → Linux）
- ❌ 需要手动安装系统依赖
- ❌ 不同 Linux 发行版兼容性问题
- ❌ 环境配置繁琐
- ❌ 版本管理困难

### 实际部署步骤：
```bash
# 1. 在服务器安装依赖
sudo apt-get update
sudo apt-get install -y libssl-dev pkg-config ca-certificates

# 2. 上传二进制文件
scp ./target/x86_64-unknown-linux-gnu/release/portfolio-pulse-backend user@server:/opt/app/

# 3. 设置权限和服务
chmod +x /opt/app/portfolio-pulse-backend
sudo systemctl create service...

# 4. 配置数据库连接
export DATABASE_URL=...

# 5. 运行迁移
./portfolio-pulse-backend migrate

# 6. 启动服务
./portfolio-pulse-backend
```

## 方案二：Docker 部署

### 优点：
- ✅ 环境一致性（开发、测试、生产）
- ✅ 依赖管理简单
- ✅ 跨平台无差异
- ✅ 版本控制完整
- ✅ 回滚方便
- ✅ 扩展容易

### 缺点：
- ❌ 镜像大（包含完整环境）
- ❌ 需要 Docker 环境
- ❌ 轻微的性能开销

### 部署步骤：
```bash
# 1. 构建镜像（在任何有 Docker 的地方）
docker build -f Dockerfile.backend -t portfolio-pulse-backend .

# 2. 运行（所有依赖都在镜像里）
docker run -d portfolio-pulse-backend
```

## 推荐方案

### 对于你的项目，我建议：

**生产环境：使用 Docker**
- 你的项目是全栈应用（前端 + 后端 + 数据库）
- Docker Compose 可以一键启动整个服务栈
- 环境一致性对 Web 应用很重要

**学习目的：两种都试试**
- 先用二进制部署理解底层原理
- 再用 Docker 体验现代部署方式

## 混合方案

可以结合两种方式：
```dockerfile
# 多阶段构建：编译阶段 + 运行阶段
FROM rust:1.75 AS builder
# ... 编译生成二进制文件

FROM debian:bookworm-slim AS runtime
# 只复制二进制文件和必要的系统库
COPY --from=builder /app/target/release/portfolio-pulse-backend ./
```

这样既有 Docker 的环境一致性，又有二进制文件的轻量特性。
