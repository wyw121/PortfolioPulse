# Docker 挂载卷编译 Rust 项目部署指南

## 概述

本指南介绍如何使用 Docker 挂载卷的方式编译 Rust 项目，避免将代码复制到容器内，实现更高效的开发和部署流程。

## 环境要求

- Windows 系统（您当前环境）
- Docker Desktop 已安装并运行
- 目标部署服务器：Ubuntu Server 22.04 LTS 64bit
- 项目结构：Rust 后端 + Next.js 前端

## 方案优势

✅ **无需复制代码**：直接挂载本地项目目录
✅ **快速编译**：利用本地文件系统性能
✅ **缓存友好**：编译缓存可以持久化
✅ **开发便利**：代码修改即时生效
✅ **跨平台兼容**：编译出 Linux 二进制文件

## 第一步：创建 Dockerfile

创建专门用于编译的 Dockerfile：

```dockerfile
# 编译阶段 - 使用 Ubuntu 22.04 基础镜像确保兼容性
FROM ubuntu:22.04 as builder

# 安装必要的系统依赖
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# 安装 Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# 设置工作目录
WORKDIR /workspace

# 设置 Rust 编译目标为 Linux
RUN rustup target add x86_64-unknown-linux-gnu

# 创建编译脚本
COPY <<EOF /usr/local/bin/build.sh
#!/bin/bash
set -e
echo "开始编译 Rust 项目..."
cd /workspace/backend
cargo build --release --target x86_64-unknown-linux-gnu
echo "编译完成！二进制文件位置："
ls -la target/x86_64-unknown-linux-gnu/release/
EOF

RUN chmod +x /usr/local/bin/build.sh

# 默认命令
CMD ["/usr/local/bin/build.sh"]
```

## 第二步：创建 Docker Compose 配置

创建 `docker-compose.build.yml` 文件：

```yaml
version: '3.8'

services:
  rust-builder:
    build:
      context: .
      dockerfile: Dockerfile.builder
    volumes:
      # 挂载项目根目录到容器的 /workspace
      - .:/workspace
      # 挂载 Cargo 缓存目录（可选，提高编译速度）
      - cargo-cache:/root/.cargo/registry
      - cargo-git-cache:/root/.cargo/git
    working_dir: /workspace
    environment:
      # 设置 Rust 编译环境变量
      - CARGO_TARGET_DIR=/workspace/backend/target
      - RUST_BACKTRACE=1
    command: /usr/local/bin/build.sh

volumes:
  cargo-cache:
  cargo-git-cache:
```

## 第三步：创建编译脚本

创建 PowerShell 编译脚本 `build-with-docker.ps1`：

```powershell
#!/usr/bin/env pwsh

# Docker 挂载编译脚本
param(
    [switch]$Clean,    # 是否清理之前的编译结果
    [switch]$Verbose   # 是否显示详细输出
)

Write-Host "🚀 开始使用 Docker 挂载方式编译 Rust 项目" -ForegroundColor Green

# 检查 Docker 是否运行
try {
    docker version | Out-Null
    Write-Host "✅ Docker 服务正常运行" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker 服务未运行，请启动 Docker Desktop" -ForegroundColor Red
    exit 1
}

# 进入项目根目录
Set-Location $PSScriptRoot

# 清理选项
if ($Clean) {
    Write-Host "🧹 清理之前的编译结果..." -ForegroundColor Yellow
    if (Test-Path "backend/target") {
        Remove-Item -Recurse -Force "backend/target"
    }
}

# 构建编译环境镜像
Write-Host "🔨 构建编译环境镜像..." -ForegroundColor Blue
docker build -t portfolio-pulse-builder -f Dockerfile.builder .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 镜像构建失败" -ForegroundColor Red
    exit 1
}

# 使用挂载方式编译
Write-Host "📦 开始编译项目..." -ForegroundColor Blue
$dockerArgs = @(
    "run"
    "--rm"
    "-v", "${PWD}:/workspace"
    "-v", "portfolio-pulse-cargo-cache:/root/.cargo/registry"
    "-v", "portfolio-pulse-cargo-git:/root/.cargo/git"
    "-w", "/workspace"
    "portfolio-pulse-builder"
)

if ($Verbose) {
    $dockerArgs += "--env", "RUST_LOG=debug"
}

& docker @dockerArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 编译成功！" -ForegroundColor Green
    Write-Host "📁 二进制文件位置: backend/target/x86_64-unknown-linux-gnu/release/" -ForegroundColor Green

    # 显示编译结果
    $binaryPath = "backend/target/x86_64-unknown-linux-gnu/release/portfolio-pulse-backend"
    if (Test-Path $binaryPath) {
        $fileInfo = Get-Item $binaryPath
        Write-Host "📋 文件信息:" -ForegroundColor Cyan
        Write-Host "   大小: $([math]::Round($fileInfo.Length / 1MB, 2)) MB" -ForegroundColor White
        Write-Host "   修改时间: $($fileInfo.LastWriteTime)" -ForegroundColor White

        # 验证是否为 Linux 二进制文件
        $fileOutput = & file $binaryPath 2>$null
        if ($fileOutput -match "Linux") {
            Write-Host "✅ 确认为 Linux 可执行文件" -ForegroundColor Green
        }
    }
} else {
    Write-Host "❌ 编译失败" -ForegroundColor Red
    exit 1
}

Write-Host "🎉 编译流程完成！" -ForegroundColor Green
```

## 第四步：创建部署脚本

创建部署脚本 `deploy-to-server.ps1`：

```powershell
#!/usr/bin/env pwsh

# 部署到 Ubuntu 服务器脚本
param(
    [Parameter(Mandatory=$true)]
    [string]$ServerIP,         # 服务器 IP 地址

    [Parameter(Mandatory=$true)]
    [string]$Username,         # SSH 用户名

    [string]$DeployPath = "/opt/portfolio-pulse",  # 部署路径
    [string]$ServiceName = "portfolio-pulse",      # 系统服务名
    [switch]$AutoRestart       # 是否自动重启服务
)

Write-Host "🚀 开始部署到 Ubuntu 服务器" -ForegroundColor Green

# 检查二进制文件是否存在
$binaryPath = "backend/target/x86_64-unknown-linux-gnu/release/portfolio-pulse-backend"
if (-not (Test-Path $binaryPath)) {
    Write-Host "❌ 未找到编译后的二进制文件，请先运行编译" -ForegroundColor Red
    Write-Host "   运行: .\build-with-docker.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "📁 找到二进制文件: $binaryPath" -ForegroundColor Green

# 使用 SCP 上传文件
Write-Host "📤 上传二进制文件到服务器..." -ForegroundColor Blue
$scpCommand = "scp `"$binaryPath`" ${Username}@${ServerIP}:${DeployPath}/portfolio-pulse-backend-new"
Write-Host "执行命令: $scpCommand" -ForegroundColor Gray

try {
    Invoke-Expression $scpCommand
    if ($LASTEXITCODE -ne 0) {
        throw "SCP 上传失败"
    }
    Write-Host "✅ 文件上传成功" -ForegroundColor Green
} catch {
    Write-Host "❌ 文件上传失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 在服务器上执行部署命令
Write-Host "🔄 在服务器上执行部署..." -ForegroundColor Blue
$deployCommands = @(
    "sudo chmod +x ${DeployPath}/portfolio-pulse-backend-new",
    "sudo mv ${DeployPath}/portfolio-pulse-backend ${DeployPath}/portfolio-pulse-backend-backup 2>/dev/null || true",
    "sudo mv ${DeployPath}/portfolio-pulse-backend-new ${DeployPath}/portfolio-pulse-backend"
)

if ($AutoRestart) {
    $deployCommands += "sudo systemctl restart $ServiceName"
    $deployCommands += "sudo systemctl status $ServiceName --no-pager"
}

$sshCommand = "ssh ${Username}@${ServerIP} `"$($deployCommands -join '; ')`""
Write-Host "执行命令: $sshCommand" -ForegroundColor Gray

try {
    Invoke-Expression $sshCommand
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 部署成功！" -ForegroundColor Green
        if ($AutoRestart) {
            Write-Host "🔄 服务已重启" -ForegroundColor Green
        }
    } else {
        throw "部署命令执行失败"
    }
} catch {
    Write-Host "❌ 部署失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "🎉 部署流程完成！" -ForegroundColor Green
```

## 第五步：使用方法

### 方式一：一键编译部署（推荐）

```powershell
# 仅编译（不部署）
.\one-click-deploy.ps1

# 编译并部署到服务器
.\one-click-deploy.ps1 -ServerIP "192.168.1.100" -Username "ubuntu"

# 编译并部署，自动重启服务
.\one-click-deploy.ps1 -ServerIP "192.168.1.100" -Username "ubuntu" -AutoRestart

# 清理编译并部署
.\one-click-deploy.ps1 -ServerIP "192.168.1.100" -Username "ubuntu" -Clean -Verbose
```

### 方式二：分步执行

#### 1. 编译项目

```powershell
# 基础编译
.\build-with-docker.ps1

# 清理后编译
.\build-with-docker.ps1 -Clean

# 详细输出编译
.\build-with-docker.ps1 -Verbose
```

#### 2. 部署到服务器

```powershell
# 部署到服务器
.\deploy-to-server.ps1 -ServerIP "192.168.1.100" -Username "ubuntu"

# 部署并自动重启服务
.\deploy-to-server.ps1 -ServerIP "192.168.1.100" -Username "ubuntu" -AutoRestart
```

### 方式三：使用 Docker Compose

```powershell
# 使用 Docker Compose 编译
docker-compose -f docker-compose.build.yml up --build

# 清理并重新编译
docker-compose -f docker-compose.build.yml down
docker-compose -f docker-compose.build.yml up --build --force-recreate
```

## 服务器初始化

在首次部署前，需要在您的 Ubuntu 服务器上运行设置脚本：

```bash
# 1. 将设置脚本上传到服务器
scp scripts/setup-ubuntu-server.sh username@your-server-ip:~/

# 2. 在服务器上运行设置脚本
ssh username@your-server-ip
chmod +x ~/setup-ubuntu-server.sh
./setup-ubuntu-server.sh
```

这将自动设置：
- ✅ 系统依赖包
- ✅ MySQL 数据库
- ✅ Nginx 反向代理
- ✅ Systemd 服务
- ✅ 防火墙配置
- ✅ 用户权限

## 目录结构

编译完成后，您的项目结构将如下：

```
📁 PortfolioPulse/
├── 🐳 Docker 配置
│   ├── Dockerfile.builder          # 编译环境 Dockerfile
│   └── docker-compose.build.yml    # Docker Compose 配置
├── 📜 部署脚本
│   ├── build-with-docker.ps1       # 编译脚本
│   ├── deploy-to-server.ps1        # 部署脚本
│   └── one-click-deploy.ps1        # 一键编译部署脚本
├── ⚙️ 配置文件
│   └── portfolio-pulse.service     # Systemd 服务配置
├── 📜 服务器脚本
│   └── scripts/
│       └── setup-ubuntu-server.sh  # 服务器初始化脚本
└── 🎯 编译输出
    └── backend/
        └── target/
            └── x86_64-unknown-linux-gnu/
                └── release/
                    └── portfolio_pulse_backend  # Linux 二进制文件
```

## 注意事项

### Windows 路径挂载
- 确保 Docker Desktop 中启用了文件共享
- 使用 PowerShell 时路径分隔符会自动处理

### 编译缓存
- Cargo 缓存会保存在 Docker 卷中，提高后续编译速度
- 如需清理缓存：`docker volume rm portfolio-pulse-cargo-cache portfolio-pulse-cargo-git`

### 权限问题
- 编译出的文件所有者可能是 root，这是正常现象
- 在服务器上部署时确保有适当的权限

### 性能优化
- 首次编译时间较长，后续编译会利用缓存
- 可以考虑使用 `cargo-chef` 进一步优化编译速度

## 故障排除

### 常见问题

1. **Docker 挂载失败**
   ```bash
   # 检查 Docker Desktop 文件共享设置
   # 确保项目目录在共享路径内
   ```

2. **编译失败**
   ```bash
   # 检查依赖是否安装完整
   docker run --rm -v ${PWD}:/workspace portfolio-pulse-builder bash -c "cd /workspace/backend && cargo check"
   ```

3. **二进制文件无法在 Ubuntu 上运行**
   ```bash
   # 检查文件格式
   file backend/target/x86_64-unknown-linux-gnu/release/portfolio-pulse-backend
   ```

### 调试命令

```powershell
# 进入编译容器调试
docker run --rm -it -v ${PWD}:/workspace portfolio-pulse-builder bash

# 查看编译日志
docker run --rm -v ${PWD}:/workspace portfolio-pulse-builder bash -c "cd /workspace/backend && cargo build --release --target x86_64-unknown-linux-gnu --verbose"
```

## 总结

使用 Docker 挂载方式编译 Rust 项目的优势：

- ✅ **高效开发**：无需代码复制，开发更流畅
- ✅ **跨平台兼容**：在 Windows 上编译 Linux 二进制
- ✅ **缓存优化**：编译缓存持久化，提高效率
- ✅ **环境一致**：确保编译环境与部署环境匹配
- ✅ **自动化部署**：一键编译部署，降低操作复杂度

这种方式特别适合需要在 Windows 开发环境中为 Linux 服务器编译 Rust 项目的场景。
