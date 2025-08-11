#!/usr/bin/env pwsh

# PortfolioPulse 简化版 Windows 交叉编译脚本
# 专门针对没有完整开发环境的系统

param(
    [switch]$UseDocker,
    [switch]$UseMusl,
    [switch]$Setup
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 PortfolioPulse 简化交叉编译方案" -ForegroundColor Cyan
Write-Host "🎯 目标: Ubuntu 22.04 LTS" -ForegroundColor Green
Write-Host ""

function Write-Step {
    param([string]$Message)
    Write-Host "🔹 $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)  
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Test-Command {
    param([string]$Command)
    try {
        $null = Get-Command $Command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# 方案1: Docker 编译
function Use-DockerCompile {
    Write-Step "使用 Docker 进行交叉编译"
    
    if (-not (Test-Command "docker")) {
        Write-Error "Docker 未安装"
        Write-Host "请安装 Docker Desktop: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
        return $false
    }
    
    Write-Host "🐳 使用 Docker 容器进行编译..." -ForegroundColor Blue
    
    # 创建 Dockerfile
    $dockerfile = @'
FROM ubuntu:22.04

# 安装构建依赖
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# 安装 Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# 安装 Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# 设置工作目录
WORKDIR /app

# 复制项目文件
COPY . .

# 构建后端
WORKDIR /app/backend
RUN cargo build --release

# 构建前端
WORKDIR /app/frontend
RUN npm ci && npm run build

# 创建部署目录
WORKDIR /app
RUN mkdir -p /output && \
    cp backend/target/release/portfolio* /output/ || \
    cp backend/target/release/main /output/portfolio_pulse_backend || \
    echo "Backend binary not found" && \
    cp -r frontend/.next/standalone/* /output/ && \
    cp -r frontend/.next/static /output/.next/ && \
    cp -r frontend/public /output/ 2>/dev/null || true

CMD ["ls", "-la", "/output"]
'@

    $dockerfile | Out-File -FilePath ".\Dockerfile.cross-compile" -Encoding utf8 -NoNewline
    
    try {
        # 构建 Docker 镜像
        Write-Host "🔨 构建 Docker 镜像..." -ForegroundColor Yellow
        docker build -f Dockerfile.cross-compile -t portfoliopulse-builder .
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Docker 镜像构建失败"
            return $false
        }
        
        # 创建容器并提取文件
        Write-Host "📦 提取编译产物..." -ForegroundColor Yellow
        $containerId = docker create portfoliopulse-builder
        
        # 创建输出目录
        New-Item -ItemType Directory -Path ".\build\docker-output" -Force | Out-Null
        
        # 复制文件
        docker cp "${containerId}:/output/." ".\build\docker-output\"
        docker rm $containerId
        
        Write-Success "Docker 编译完成"
        Write-Host "输出目录: .\build\docker-output" -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Error "Docker 编译失败: $($_.Exception.Message)"
        return $false
    }
}

# 方案2: Musl 静态编译
function Use-MuslCompile {
    Write-Step "使用 Musl 静态编译"
    
    if (-not (Test-Command "rustc")) {
        Write-Error "Rust 未安装，请先运行: .\install_dev_environment.ps1"
        return $false
    }
    
    # 确保目标已安装
    Write-Host "📦 确认编译目标..." -ForegroundColor Blue
    rustup target add x86_64-unknown-linux-musl
    rustup target add x86_64-unknown-linux-gnu
    
    # 创建构建目录
    New-Item -ItemType Directory -Path ".\build\musl-output" -Force | Out-Null
    
    # 编译后端
    Push-Location backend
    try {
        Write-Host "🦀 编译 Rust 后端..." -ForegroundColor Blue
        
        # 清理之前的构建
        cargo clean
        
        # 首先尝试 GNU 目标（更兼容）
        $targetTriple = "x86_64-unknown-linux-gnu"
        Write-Host "🎯 使用目标: $targetTriple" -ForegroundColor Yellow
        
        # 设置链接器环境变量
        $env:CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER = "x86_64-linux-gnu-gcc"
        
        # 如果没有交叉链接器，尝试其他方法
        if (-not (Test-Command "x86_64-linux-gnu-gcc")) {
            Write-Host "⚠️  未找到交叉链接器，尝试使用 Rust LLD..." -ForegroundColor Yellow
            $env:RUSTFLAGS = "-C linker=rust-lld -C target-cpu=generic"
        }
        
        cargo build --release --target $targetTriple
    
    # 创建构建目录
    New-Item -ItemType Directory -Path ".\build\musl-output" -Force | Out-Null
    
    # 编译后端
    Push-Location backend
    try {
        Write-Host "🦀 编译 Rust 后端 (GNU目标)..." -ForegroundColor Blue
        
        # 清理之前的构建
        cargo clean
        
        # 不设置 musl 特定的环境变量，使用默认设置
        cargo build --release --target $targetTriple
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "后端编译失败"
            return $false
        }
        
        # 查找并复制二进制文件
        $targetDir = "target\$targetTriple\release"
        $foundBinary = $null
        
        # 扩展可能的文件名搜索
        $possibleNames = @(
            "portfolio-pulse-backend", 
            "portfolio_pulse_backend", 
            "portfolio-pulse", 
            "portfolio_pulse",
            "backend", 
            "main"
        )
        
        foreach ($name in $possibleNames) {
            $binaryPath = "$targetDir\$name"
            if (Test-Path $binaryPath) {
                $foundBinary = $binaryPath
                Write-Host "找到二进制文件: $name" -ForegroundColor Green
                break
            }
            # 也尝试 .exe 扩展名（虽然在 Linux 目标中不太可能）
            $binaryPathExe = "$targetDir\$name.exe"
            if (Test-Path $binaryPathExe) {
                $foundBinary = $binaryPathExe
                Write-Host "找到二进制文件: $name.exe" -ForegroundColor Green
                break
            }
        }
        
        if ($foundBinary) {
            Copy-Item $foundBinary "..\build\musl-output\portfolio_pulse_backend" -Force
            Write-Success "后端编译成功 (GNU 目标)"
            
            # 显示文件信息
            $fileInfo = Get-Item "..\build\musl-output\portfolio_pulse_backend"
            Write-Host "  📊 文件大小: $([math]::Round($fileInfo.Length / 1MB, 2)) MB" -ForegroundColor Gray
        }
        else {
            # 列出所有可执行文件进行调试
            Write-Host "🔍 查找可执行文件..." -ForegroundColor Yellow
            if (Test-Path $targetDir) {
                Write-Host "目录内容 ($targetDir):" -ForegroundColor Yellow
                $allFiles = Get-ChildItem $targetDir -File
                $allFiles | ForEach-Object {
                    $isExecutable = ($_.Extension -eq "" -and $_.Length -gt 1000) -or ($_.Name -match "portfolio|backend|main")
                    $marker = if ($isExecutable) { "⭐" } else { "  " }
                    Write-Host "$marker $($_.Name) ($([math]::Round($_.Length / 1KB, 1)) KB)" -ForegroundColor Gray
                }
                
                # 尝试找到最大的可执行文件
                $largestExe = $allFiles | Where-Object { $_.Extension -eq "" -and $_.Length -gt 100000 } | Sort-Object Length -Descending | Select-Object -First 1
                if ($largestExe) {
                    Copy-Item $largestExe.FullName "..\build\musl-output\portfolio_pulse_backend" -Force
                    Write-Success "后端编译成功 (使用 $($largestExe.Name))"
                    Write-Host "  📊 文件大小: $([math]::Round($largestExe.Length / 1MB, 2)) MB" -ForegroundColor Gray
                }
                else {
                    Write-Error "未找到合适的可执行文件"
                    return $false
                }
            }
            else {
                Write-Error "编译输出目录不存在: $targetDir"
                return $false
            }
        }
    }
    finally {
        Pop-Location
    }
    
    # 编译前端
    if (-not (Test-Command "node")) {
        Write-Error "Node.js 未安装，请先运行: .\install_dev_environment.ps1"
        return $false
    }
    
    Push-Location frontend
    try {
        Write-Host "🟢 编译 Next.js 前端..." -ForegroundColor Blue
        
        npm ci
        if ($LASTEXITCODE -ne 0) {
            Write-Error "npm install 失败"
            return $false
        }
        
        npm run build
        if ($LASTEXITCODE -ne 0) {
            Write-Error "前端构建失败"
            return $false
        }
        
        # 复制前端文件
        if (Test-Path ".next\standalone") {
            Copy-Item -Path ".next\standalone\*" -Destination "..\build\musl-output\" -Recurse -Force
            
            if (Test-Path ".next\static") {
                New-Item -ItemType Directory -Path "..\build\musl-output\.next\static" -Force | Out-Null
                Copy-Item -Path ".next\static\*" -Destination "..\build\musl-output\.next\static\" -Recurse -Force
            }
            
            if (Test-Path "public") {
                Copy-Item -Path "public\*" -Destination "..\build\musl-output\public\" -Recurse -Force
            }
            
            Write-Success "前端编译成功"
        }
        else {
            Write-Error "未找到 Next.js standalone 输出"
            return $false
        }
    }
    finally {
        Pop-Location
    }
    
    Write-Success "Musl 静态编译完成"
    Write-Host "输出目录: .\build\musl-output" -ForegroundColor Gray
    return $true
}

# 方案3: 云编译服务
function Use-CloudCompile {
    Write-Step "使用云编译服务"
    
    Write-Host @"
🌐 推荐的云编译方案:

1. GitHub Actions (免费)
   - 创建 .github/workflows/build-linux.yml
   - 自动构建并生成 Linux 二进制文件
   
2. GitLab CI (免费)
   - 创建 .gitlab-ci.yml
   - 使用 Ubuntu 22.04 运行器
   
3. Azure DevOps (免费额度)
   - 使用 Ubuntu 代理池
   - 生成跨平台构建

4. CircleCI (免费额度)
   - 使用 Ubuntu 22.04 执行器

是否创建 GitHub Actions 工作流文件? (y/N): 
"@ -ForegroundColor Cyan
    
    $choice = Read-Host
    if ($choice -eq "y" -or $choice -eq "Y") {
        Create-GitHubWorkflow
    }
}

function Create-GitHubWorkflow {
    Write-Host "📝 创建 GitHub Actions 工作流..." -ForegroundColor Blue
    
    $workflowDir = ".github\workflows"
    New-Item -ItemType Directory -Path $workflowDir -Force | Out-Null
    
    $workflow = @'
name: Build for Ubuntu 22.04

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-22.04
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
        cache-dependency-path: frontend/package-lock.json
    
    - name: Setup Rust
      uses: actions-rs/toolchain@v1
      with:
        toolchain: stable
        override: true
    
    - name: Install system dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y build-essential pkg-config libssl-dev
    
    - name: Cache Rust dependencies
      uses: actions/cache@v3
      with:
        path: |
          ~/.cargo/registry
          ~/.cargo/git
          backend/target
        key: ${{ runner.os }}-cargo-${{ hashFiles('**/Cargo.lock') }}
    
    - name: Build backend
      run: |
        cd backend
        cargo build --release
    
    - name: Build frontend
      run: |
        cd frontend
        npm ci
        npm run build
    
    - name: Prepare deployment package
      run: |
        mkdir -p deploy
        
        # Copy backend binary
        cp backend/target/release/portfolio* deploy/ || \
        cp backend/target/release/main deploy/portfolio_pulse_backend
        
        # Copy frontend files
        cp -r frontend/.next/standalone/* deploy/
        [ -d frontend/.next/static ] && cp -r frontend/.next/static deploy/.next/
        [ -d frontend/public ] && cp -r frontend/public deploy/
        
        # Create startup script
        cat > deploy/start.sh << 'EOF'
        #!/bin/bash
        chmod +x portfolio_pulse_backend
        nohup ./portfolio_pulse_backend > backend.log 2>&1 &
        echo $! > backend.pid
        nohup node server.js > frontend.log 2>&1 &
        echo $! > frontend.pid
        echo "PortfolioPulse started successfully!"
        EOF
        
        chmod +x deploy/start.sh deploy/portfolio_pulse_backend
    
    - name: Upload deployment package
      uses: actions/upload-artifact@v4
      with:
        name: portfoliopulse-ubuntu-22.04
        path: deploy/
        retention-days: 30
    
    - name: Create release (if tagged)
      if: startsWith(github.ref, 'refs/tags/')
      uses: softprops/action-gh-release@v1
      with:
        files: |
          deploy/**
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
'@

    $workflow | Out-File -FilePath "$workflowDir\build-linux.yml" -Encoding utf8 -NoNewline
    
    Write-Success "GitHub Actions 工作流已创建"
    Write-Host "文件位置: $workflowDir\build-linux.yml" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📋 使用步骤:" -ForegroundColor Cyan
    Write-Host "1. 提交并推送到 GitHub" -ForegroundColor White
    Write-Host "2. 查看 Actions 标签页中的构建进度" -ForegroundColor White
    Write-Host "3. 下载生成的 Artifacts" -ForegroundColor White
    Write-Host "4. 上传到服务器并执行 start.sh" -ForegroundColor White
}

function Show-Options {
    Write-Host @"
🎯 选择编译方案:

1. Docker 编译 (推荐)
   - 不需要本地安装 Rust/Node.js
   - 完全隔离的编译环境
   - 生成 Ubuntu 22.04 兼容的二进制文件

2. Musl 静态编译
   - 需要本地 Rust 环境
   - 生成静态链接的可执行文件
   - 无依赖问题

3. 云编译服务 (GitHub Actions)
   - 完全免费
   - 自动化构建和发布
   - 支持多平台

选择方案 (1-3):
"@ -ForegroundColor Cyan
}

function Main {
    if ($Setup) {
        Write-Host "🔧 一键环境设置模式" -ForegroundColor Yellow
        Write-Host "建议执行: .\install_dev_environment.ps1 -AutoInstall" -ForegroundColor Green
        return
    }
    
    if ($UseDocker) {
        Use-DockerCompile
        return
    }
    
    if ($UseMusl) {
        Use-MuslCompile  
        return
    }
    
    # 交互式选择
    Show-Options
    $choice = Read-Host
    
    switch ($choice) {
        "1" { 
            Use-DockerCompile 
        }
        "2" { 
            Use-MuslCompile 
        }
        "3" { 
            Use-CloudCompile 
        }
        default {
            Write-Warning "无效选择，默认使用 Docker 编译"
            Use-DockerCompile
        }
    }
}

# 帮助信息
if ($args -contains "-h" -or $args -contains "--help") {
    Write-Host @"
🚀 PortfolioPulse 简化交叉编译脚本

用法:
  .\simple_cross_compile.ps1 [选项]

选项:
  -UseDocker       使用 Docker 进行编译
  -UseMusl         使用 Musl 静态编译
  -Setup           显示环境设置建议
  -h, --help       显示此帮助信息

示例:
  .\simple_cross_compile.ps1              # 交互式选择
  .\simple_cross_compile.ps1 -UseDocker   # 直接使用 Docker
  .\simple_cross_compile.ps1 -UseMusl     # 直接使用 Musl

前置要求:
  - Docker 方案: 需要安装 Docker Desktop
  - Musl 方案: 需要 Rust 和 Node.js 环境
  - 云编译方案: 需要 GitHub/GitLab 仓库
"@
    exit 0
}

# 执行主函数
Main
