#!/usr/bin/env pwsh

# PortfolioPulse Windows to Linux 交叉编译脚本
# 专门用于在 Windows 上生成 Ubuntu 22.04 LTS 兼容的二进制文件

param(
    [switch]$InstallTools,
    [switch]$CheckOnly,
    [switch]$Verbose
)

# 设置严格模式
$ErrorActionPreference = "Stop"

Write-Host "🐧 PortfolioPulse Linux 交叉编译脚本" -ForegroundColor Cyan
Write-Host "🎯 目标系统: Ubuntu 22.04 LTS (x86_64)" -ForegroundColor Green
Write-Host "📅 编译时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# 全局变量
$LinuxTarget = "x86_64-unknown-linux-gnu"
$BuildDir = ".\build"
$DeployDir = "$BuildDir\linux-deploy"
$BinariesDir = "$BuildDir\binaries"

# 实用函数
function Write-Step {
    param([string]$Message)
    Write-Host "`n🔹 $Message" -ForegroundColor Blue
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

# 检查 Rust 环境
function Test-RustEnvironment {
    Write-Step "检查 Rust 开发环境"
    
    if (-not (Test-Command "rustc")) {
        Write-Error "Rust 未安装"
        Write-Host "请访问 https://rustup.rs/ 安装 Rust" -ForegroundColor Yellow
        return $false
    }
    
    $rustVersion = rustc --version
    Write-Success "Rust 已安装: $rustVersion"
    
    if (-not (Test-Command "cargo")) {
        Write-Error "Cargo 未找到"
        return $false
    }
    
    $cargoVersion = cargo --version
    Write-Success "Cargo 已安装: $cargoVersion"
    
    return $true
}

# 安装 Linux 交叉编译目标
function Install-LinuxTarget {
    Write-Step "安装 Linux 交叉编译目标"
    
    $installedTargets = rustup target list --installed
    
    if ($installedTargets -match $LinuxTarget) {
        Write-Success "Linux 目标已安装: $LinuxTarget"
        return $true
    }
    
    Write-Host "📥 正在安装 $LinuxTarget..." -ForegroundColor Yellow
    rustup target add $LinuxTarget
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "成功安装 $LinuxTarget"
        return $true
    }
    else {
        Write-Error "安装 $LinuxTarget 失败"
        return $false
    }
}

# 安装交叉编译工具链
function Install-CrossCompileTools {
    Write-Step "配置 Windows 交叉编译环境"
    
    # 方案1: 检查是否已有 Rust LLD（内置链接器）
    Write-Host "🔧 检查 Rust 内置工具..." -ForegroundColor Blue
    $rustcSysroot = rustc --print sysroot
    $lldPath = Join-Path $rustcSysroot "bin\rust-lld.exe"
    
    if (Test-Path $lldPath) {
        Write-Success "找到 Rust LLD 链接器: $lldPath"
        $script:UseRustLLD = $true
        return $true
    }
    
    # 方案2: 检查 MSYS2/MinGW
    $msys2Path = "C:\msys64\usr\bin"
    if (Test-Path $msys2Path) {
        Write-Success "找到 MSYS2 环境"
        $env:PATH = "$msys2Path;$env:PATH"
        
        $crossGcc = "$msys2Path\x86_64-linux-gnu-gcc.exe"
        if (Test-Path $crossGcc) {
            Write-Success "找到 Linux 交叉编译器"
            $script:UseRustLLD = $false
            return $true
        }
    }
    
    # 方案3: 使用 musl 目标进行静态链接
    Write-Host "🔄 配置静态链接编译..." -ForegroundColor Yellow
    
    $muslTarget = "x86_64-unknown-linux-musl"
    $installedTargets = rustup target list --installed
    
    if (-not ($installedTargets -match $muslTarget)) {
        Write-Host "📥 安装 musl 目标..." -ForegroundColor Yellow
        rustup target add $muslTarget
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "成功安装 $muslTarget"
            $script:LinuxTarget = $muslTarget
            $script:UseRustLLD = $true
            return $true
        }
    }
    else {
        Write-Success "$muslTarget 已安装"
        $script:LinuxTarget = $muslTarget
        $script:UseRustLLD = $true
        return $true
    }
    
    Write-Warning "无完整交叉编译工具链，将使用 Rust 内置链接器"
    $script:UseRustLLD = $true
    return $true
}

# 检查 Node.js 环境
function Test-NodeEnvironment {
    Write-Step "检查 Node.js 开发环境"
    
    if (-not (Test-Command "node")) {
        Write-Error "Node.js 未安装"
        Write-Host "请访问 https://nodejs.org/ 安装 Node.js LTS 版本" -ForegroundColor Yellow
        return $false
    }
    
    $nodeVersion = node --version
    Write-Success "Node.js 已安装: $nodeVersion"
    
    if (-not (Test-Command "npm")) {
        Write-Error "npm 未找到"
        return $false
    }
    
    $npmVersion = npm --version
    Write-Success "npm 已安装: $npmVersion"
    
    return $true
}

# 准备构建目录
function Initialize-BuildDirectories {
    Write-Step "准备构建目录"
    
    # 清理旧的构建目录
    if (Test-Path $BuildDir) {
        Remove-Item -Recurse -Force $BuildDir
        Write-Host "🧹 已清理旧的构建目录" -ForegroundColor Gray
    }
    
    # 创建新的构建目录
    New-Item -ItemType Directory -Path $DeployDir -Force | Out-Null
    New-Item -ItemType Directory -Path $BinariesDir -Force | Out-Null
    
    Write-Success "构建目录已创建"
    Write-Host "  📁 构建目录: $BuildDir" -ForegroundColor Gray
    Write-Host "  📁 部署目录: $DeployDir" -ForegroundColor Gray
    Write-Host "  📁 二进制目录: $BinariesDir" -ForegroundColor Gray
}

# 编译后端 Rust 应用
function Build-RustBackend {
    Write-Step "编译 Rust 后端 (目标: $LinuxTarget)"
    
    if (-not (Test-Path "backend\Cargo.toml")) {
        Write-Error "未找到 backend/Cargo.toml"
        return $false
    }
    
    Push-Location backend
    
    try {
        # 清理之前的构建
        Write-Host "🧹 清理之前的构建..." -ForegroundColor Gray
        cargo clean
        
        # 配置编译环境
        Write-Host "🔧 配置编译环境..." -ForegroundColor Yellow
        
        if ($script:UseRustLLD -eq $true) {
            Write-Host "使用 Rust 内置链接器 (LLD)" -ForegroundColor Blue
            
            if ($LinuxTarget -eq "x86_64-unknown-linux-musl") {
                # Musl 静态链接配置
                $env:RUSTFLAGS = "-C target-feature=+crt-static -C link-self-contained=yes -C linker=rust-lld"
                $env:CC_x86_64_unknown_linux_musl = "clang"
                $env:AR_x86_64_unknown_linux_musl = "llvm-ar"
            }
            else {
                # GNU 目标使用 LLD
                $env:RUSTFLAGS = "-C linker=rust-lld -C target-cpu=generic"
                $env:CC_x86_64_unknown_linux_gnu = "clang"
            }
        }
        else {
            Write-Host "使用系统交叉编译器" -ForegroundColor Blue
            if ($LinuxTarget -eq "x86_64-unknown-linux-gnu") {
                $env:CC_x86_64_unknown_linux_gnu = "x86_64-linux-gnu-gcc"
                $env:CXX_x86_64_unknown_linux_gnu = "x86_64-linux-gnu-g++"
            }
        }
        
        # 开始编译
        Write-Host "🦀 开始交叉编译..." -ForegroundColor Blue
        Write-Host "目标架构: $LinuxTarget" -ForegroundColor Gray
        
        if ($Verbose) {
            cargo build --release --target $LinuxTarget --verbose
        }
        else {
            cargo build --release --target $LinuxTarget
        }
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "后端编译失败"
            return $false
        }
        
        # 查找编译产物
        $targetDir = "target\$LinuxTarget\release"
        if (-not (Test-Path $targetDir)) {
            Write-Error "编译产物目录不存在: $targetDir"
            return $false
        }
        
        # 查找可执行文件
        $possibleNames = @(
            "portfolio-pulse-backend",
            "portfolio_pulse_backend", 
            "portfolio_pulse",
            "backend",
            "main"
        )
        
        $foundBinary = $null
        foreach ($name in $possibleNames) {
            $binaryPath = "$targetDir\$name"
            if (Test-Path $binaryPath) {
                $foundBinary = $binaryPath
                break
            }
        }
        
        if (-not $foundBinary) {
            Write-Error "未找到编译后的二进制文件"
            Write-Host "target 目录内容:" -ForegroundColor Yellow
            Get-ChildItem $targetDir | Format-Table Name, Length, LastWriteTime
            return $false
        }
        
        # 复制二进制文件
        $outputBinary = "..\$BinariesDir\portfolio_pulse_backend"
        Copy-Item $foundBinary $outputBinary -Force
        
        Write-Success "后端编译成功"
        Write-Host "  📦 源文件: $foundBinary" -ForegroundColor Gray
        Write-Host "  📦 输出: $outputBinary" -ForegroundColor Gray
        
        # 显示文件信息
        $fileInfo = Get-Item $outputBinary
        Write-Host "  📊 文件大小: $([math]::Round($fileInfo.Length / 1MB, 2)) MB" -ForegroundColor Gray
        
        return $true
    }
    catch {
        Write-Error "编译过程中发生异常: $($_.Exception.Message)"
        return $false
    }
    finally {
        Pop-Location
    }
}

# 编译前端 Next.js 应用
function Build-NextjsFrontend {
    Write-Step "编译 Next.js 前端应用"
    
    if (-not (Test-Path "frontend\package.json")) {
        Write-Error "未找到 frontend/package.json"
        return $false
    }
    
    Push-Location frontend
    
    try {
        # 安装依赖
        Write-Host "📦 安装前端依赖..." -ForegroundColor Blue
        npm ci
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "依赖安装失败"
            return $false
        }
        
        # 构建应用
        Write-Host "🏗️  构建前端应用..." -ForegroundColor Blue
        npm run build
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "前端构建失败"
            return $false
        }
        
        # 检查 standalone 输出
        if (-not (Test-Path ".next\standalone")) {
            Write-Error "未找到 standalone 构建输出"
            Write-Host "请检查 next.config.js 是否配置了 output: 'standalone'" -ForegroundColor Yellow
            return $false
        }
        
        # 复制文件到构建目录
        Write-Host "📁 复制前端文件..." -ForegroundColor Blue
        
        # 复制 standalone 应用
        Copy-Item -Path ".next\standalone\*" -Destination "..\$BinariesDir\" -Recurse -Force
        
        # 复制静态资源
        if (Test-Path ".next\static") {
            $staticDir = "..\$BinariesDir\.next\static"
            New-Item -ItemType Directory -Path $staticDir -Force | Out-Null
            Copy-Item -Path ".next\static\*" -Destination $staticDir -Recurse -Force
        }
        
        # 复制 public 文件
        if (Test-Path "public") {
            Copy-Item -Path "public\*" -Destination "..\$BinariesDir\public\" -Recurse -Force
        }
        
        Write-Success "前端编译成功"
        return $true
    }
    catch {
        Write-Error "前端编译过程中发生异常: $($_.Exception.Message)"
        return $false
    }
    finally {
        Pop-Location
    }
}

# 创建 Linux 部署脚本
function Create-LinuxDeploymentScripts {
    Write-Step "创建 Linux 部署脚本"
    
    # 创建启动脚本
    $startScript = @'
#!/bin/bash
# PortfolioPulse 启动脚本 - Ubuntu 22.04 LTS

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🚀 PortfolioPulse 启动脚本${NC}"
echo -e "${CYAN}🐧 目标系统: Ubuntu 22.04 LTS${NC}"
echo "📅 启动时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 系统信息检查
echo -e "${BLUE}📋 系统信息${NC}"
echo "操作系统: $(lsb_release -d | cut -f2)"
echo "内核版本: $(uname -r)"
echo "架构: $(uname -m)"
echo "当前用户: $(whoami)"
echo "当前目录: $(pwd)"
echo ""

# 依赖检查
echo -e "${BLUE}🔧 依赖检查${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js 未安装${NC}"
    echo "安装 Node.js: curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs"
    exit 1
fi

echo -e "${GREEN}✅ Node.js $(node --version)${NC}"
echo -e "${GREEN}✅ npm $(npm --version)${NC}"

# 环境变量配置
export NODE_ENV=production
export PORT=3000

if [ -f ".env" ]; then
    source .env
    echo -e "${GREEN}✅ 已加载 .env 文件${NC}"
else
    echo -e "${YELLOW}⚠️  .env 文件不存在${NC}"
fi

# 文件权限检查
echo -e "${BLUE}📁 文件权限检查${NC}"
if [ ! -f "portfolio_pulse_backend" ]; then
    echo -e "${RED}❌ 后端二进制文件不存在${NC}"
    exit 1
fi

# 添加执行权限
chmod +x portfolio_pulse_backend
echo -e "${GREEN}✅ 后端文件权限已设置${NC}"

if [ ! -f "server.js" ]; then
    echo -e "${RED}❌ 前端 server.js 文件不存在${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 前端文件检查通过${NC}"

# 清理旧进程
echo -e "${BLUE}🧹 清理旧进程${NC}"
for pid_file in backend.pid frontend.pid; do
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo "停止旧进程: $pid"
            kill "$pid" || true
            sleep 2
        fi
        rm -f "$pid_file"
    fi
done

# 启动后端服务
echo -e "${BLUE}🦀 启动后端服务 (端口 8000)${NC}"
nohup ./portfolio_pulse_backend > backend.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > backend.pid
echo -e "${GREEN}✅ 后端已启动 (PID: $BACKEND_PID)${NC}"

# 等待后端启动
echo -n "⏳ 等待后端服务启动"
for i in {1..30}; do
    if curl -s -f "http://localhost:8000" >/dev/null 2>&1; then
        echo ""
        echo -e "${GREEN}✅ 后端服务就绪${NC}"
        break
    fi
    
    if ! kill -0 "$BACKEND_PID" 2>/dev/null; then
        echo ""
        echo -e "${RED}❌ 后端进程异常退出${NC}"
        echo "📋 后端日志:"
        tail -20 backend.log
        exit 1
    fi
    
    echo -n "."
    sleep 1
    
    if [ $i -eq 30 ]; then
        echo ""
        echo -e "${RED}❌ 后端启动超时${NC}"
        kill "$BACKEND_PID" || true
        exit 1
    fi
done

# 启动前端服务
echo -e "${BLUE}🟢 启动前端服务 (端口 3000)${NC}"
nohup node server.js > frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > frontend.pid
echo -e "${GREEN}✅ 前端已启动 (PID: $FRONTEND_PID)${NC}"

# 等待前端启动
echo -n "⏳ 等待前端服务启动"
for i in {1..20}; do
    if curl -s -f "http://localhost:3000" >/dev/null 2>&1; then
        echo ""
        echo -e "${GREEN}✅ 前端服务就绪${NC}"
        break
    fi
    
    if ! kill -0 "$FRONTEND_PID" 2>/dev/null; then
        echo ""
        echo -e "${RED}❌ 前端进程异常退出${NC}"
        echo "📋 前端日志:"
        tail -20 frontend.log
        kill "$BACKEND_PID" || true
        exit 1
    fi
    
    echo -n "."
    sleep 1
    
    if [ $i -eq 20 ]; then
        echo ""
        echo -e "${RED}❌ 前端启动超时${NC}"
        kill "$BACKEND_PID" "$FRONTEND_PID" || true
        exit 1
    fi
done

# 启动完成
echo ""
echo -e "${GREEN}🎉 PortfolioPulse 启动成功!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 服务状态:"
echo "  🦀 后端: PID $BACKEND_PID - http://localhost:8000"
echo "  🟢 前端: PID $FRONTEND_PID - http://localhost:3000"
echo ""
echo "🌐 访问地址: http://localhost:3000"
echo "📋 管理命令:"
echo "  查看状态: ./status.sh"
echo "  停止服务: ./stop.sh"
echo "  查看日志: tail -f backend.log frontend.log"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
'@

    # 停止脚本
    $stopScript = @'
#!/bin/bash
# PortfolioPulse 停止脚本

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🛑 停止 PortfolioPulse...${NC}"

for service in frontend backend; do
    pid_file="${service}.pid"
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo "停止 $service (PID: $pid)"
            kill "$pid" || true
            sleep 2
            
            # 强制停止
            if kill -0 "$pid" 2>/dev/null; then
                kill -9 "$pid" || true
            fi
        fi
        rm -f "$pid_file"
    fi
done

echo -e "${GREEN}✅ 所有服务已停止${NC}"
'@

    # 状态检查脚本
    $statusScript = @'
#!/bin/bash
# PortfolioPulse 状态检查脚本

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📊 PortfolioPulse 状态检查${NC}"
echo "📅 检查时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "🖥️  系统: $(lsb_release -d | cut -f2) ($(uname -m))"
echo ""

# 系统资源
echo -e "${BLUE}🖥️  系统资源${NC}"
echo "负载: $(uptime | awk -F'load average:' '{print $2}')"
free -h | head -2
echo "磁盘: $(df -h . | tail -1 | awk '{print $4 " 可用"}')"
echo ""

# 服务状态
for service in backend frontend; do
    echo -e "${BLUE}🔍 $service 服务${NC}"
    
    pid_file="${service}.pid"
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "  ${GREEN}✅ 运行中 (PID: $pid)${NC}"
            
            # 资源使用情况
            cpu_mem=$(ps -p "$pid" -o %cpu,%mem --no-headers 2>/dev/null)
            if [ -n "$cpu_mem" ]; then
                echo "  📊 资源: CPU ${cpu_mem%% *}%, 内存 ${cpu_mem##* }%"
            fi
            
            # HTTP 健康检查
            port=""
            case $service in
                backend) port=8000;;
                frontend) port=3000;;
            esac
            
            if [ -n "$port" ]; then
                if curl -s -f "http://localhost:$port" >/dev/null 2>&1; then
                    response_time=$(curl -o /dev/null -s -w "%{time_total}" "http://localhost:$port")
                    echo -e "  ${GREEN}🌐 HTTP 正常 (${response_time}s)${NC}"
                else
                    echo -e "  ${YELLOW}⚠️  HTTP 无响应${NC}"
                fi
            fi
        else
            echo -e "  ${RED}❌ 进程不存在 (PID: $pid)${NC}"
        fi
    else
        echo -e "  ${RED}❌ 未运行${NC}"
    fi
    echo ""
done

# 日志文件状态
echo -e "${BLUE}📄 日志文件${NC}"
for log in backend.log frontend.log; do
    if [ -f "$log" ]; then
        size=$(du -h "$log" | cut -f1)
        lines=$(wc -l < "$log")
        errors=$(grep -ic "error\|fail" "$log" 2>/dev/null || echo "0")
        echo "  $log: $size ($lines 行, $errors 错误)"
    fi
done
'@

    # 保存脚本到部署目录
    $startScript | Out-File -FilePath "$DeployDir\start.sh" -Encoding utf8 -NoNewline
    $stopScript | Out-File -FilePath "$DeployDir\stop.sh" -Encoding utf8 -NoNewline  
    $statusScript | Out-File -FilePath "$DeployDir\status.sh" -Encoding utf8 -NoNewline
    
    Write-Success "Linux 部署脚本已创建"
}

# 创建部署包
function Create-DeploymentPackage {
    Write-Step "创建部署包"
    
    # 复制二进制文件到部署目录
    Copy-Item -Path "$BinariesDir\*" -Destination $DeployDir -Recurse -Force
    
    # 创建环境变量模板
    $envTemplate = @'
# PortfolioPulse 环境变量配置
# 请根据实际情况修改以下配置

# 数据库配置
DATABASE_URL=mysql://username:password@localhost:3306/portfolio_pulse

# GitHub 集成
GITHUB_TOKEN=your_github_token_here
GITHUB_USERNAME=your_github_username

# 应用配置
NODE_ENV=production
PORT=3000

# 认证配置 (可选)
NEXTAUTH_SECRET=your_secret_key_here
NEXTAUTH_URL=http://your-domain.com

# 日志级别
RUST_LOG=info
'@

    $envTemplate | Out-File -FilePath "$DeployDir\.env.example" -Encoding utf8 -NoNewline
    
    # 创建部署说明
    $deployGuide = @'
# PortfolioPulse Linux 部署指南

## 🎯 系统要求

- Ubuntu 22.04 LTS (x86_64)
- Node.js 18+ 
- MySQL 8.0+
- 2GB+ RAM
- 5GB+ 磁盘空间

## 🚀 快速部署

### 1. 上传文件到服务器

```bash
# 使用 scp 上传部署包
scp -r linux-deploy/ user@server:/opt/portfoliopulse/

# 或使用 rsync (推荐)
rsync -avz --progress linux-deploy/ user@server:/opt/portfoliopulse/
```

### 2. 设置权限

```bash
cd /opt/portfoliopulse
chmod +x portfolio_pulse_backend start.sh stop.sh status.sh
```

### 3. 配置环境变量

```bash
cp .env.example .env
nano .env  # 编辑配置文件
```

### 4. 启动服务

```bash
./start.sh
```

### 5. 检查状态

```bash
./status.sh
```

## 🛠️ 管理命令

- `./start.sh` - 启动所有服务
- `./stop.sh` - 停止所有服务  
- `./status.sh` - 检查服务状态
- `tail -f *.log` - 查看实时日志

## 🔧 故障排查

### 后端无法启动

1. 检查文件权限: `ls -la portfolio_pulse_backend`
2. 检查系统兼容性: `ldd portfolio_pulse_backend`
3. 查看错误日志: `cat backend.log`

### 前端无法启动

1. 检查 Node.js 版本: `node --version`
2. 检查依赖: `ls -la node_modules/`
3. 查看错误日志: `cat frontend.log`

### 端口冲突

1. 检查端口占用: `netstat -tlnp | grep -E ':3000|:8000'`
2. 停止冲突进程: `sudo fuser -k 8000/tcp`

## 📊 系统监控

推荐使用 systemd 管理服务:

```bash
# 创建系统服务
sudo nano /etc/systemd/system/portfoliopulse.service
```

```ini
[Unit]
Description=PortfolioPulse Service
After=network.target

[Service]
Type=forking
User=your-user
WorkingDirectory=/opt/portfoliopulse
ExecStart=/opt/portfoliopulse/start.sh
ExecStop=/opt/portfoliopulse/stop.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

启用自动启动:
```bash
sudo systemctl enable portfoliopulse
sudo systemctl start portfoliopulse
```

## 🔄 更新部署

1. 停止服务: `./stop.sh`
2. 备份数据: `cp -r . ../backup-$(date +%Y%m%d)`
3. 上传新版本文件
4. 启动服务: `./start.sh`

## 📞 技术支持

如遇问题，请检查:
1. 系统日志: `journalctl -u portfoliopulse`
2. 应用日志: `tail -f backend.log frontend.log`
3. 系统资源: `htop` 或 `free -h`
'@

    $deployGuide | Out-File -FilePath "$DeployDir\README.md" -Encoding utf8 -NoNewline
    
    Write-Success "部署包已创建"
}

# 显示构建摘要
function Show-BuildSummary {
    Write-Host "`n" -NoNewline
    Write-Host "🎉 构建完成!" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    
    Write-Host "📁 部署包位置: " -NoNewline -ForegroundColor Yellow
    Write-Host (Resolve-Path $DeployDir) -ForegroundColor White
    
    Write-Host "`n📦 包含文件:" -ForegroundColor Yellow
    Get-ChildItem $DeployDir | ForEach-Object {
        if ($_.PSIsContainer) {
            Write-Host "  📁 $($_.Name)/" -ForegroundColor Blue
        }
        else {
            $size = if ($_.Length -gt 1MB) { "{0:N1} MB" -f ($_.Length / 1MB) } else { "{0:N0} KB" -f ($_.Length / 1KB) }
            Write-Host "  📄 $($_.Name) ($size)" -ForegroundColor White
        }
    }
    
    Write-Host "`n🚀 部署步骤:" -ForegroundColor Cyan
    Write-Host "1. 上传部署包到服务器:" -ForegroundColor White
    Write-Host "   scp -r $DeployDir user@server:/opt/portfoliopulse/" -ForegroundColor Gray
    Write-Host "2. 设置权限:" -ForegroundColor White  
    Write-Host "   chmod +x /opt/portfoliopulse/*.sh /opt/portfoliopulse/portfolio_pulse_backend" -ForegroundColor Gray
    Write-Host "3. 配置环境变量:" -ForegroundColor White
    Write-Host "   cp .env.example .env && nano .env" -ForegroundColor Gray
    Write-Host "4. 启动服务:" -ForegroundColor White
    Write-Host "   ./start.sh" -ForegroundColor Gray
    
    Write-Host "`n📋 文件检查:" -ForegroundColor Blue
    
    $backendBinary = "$DeployDir\portfolio_pulse_backend"
    if (Test-Path $backendBinary) {
        $fileInfo = Get-Item $backendBinary
        Write-Host "  🦀 后端二进制: $([math]::Round($fileInfo.Length / 1MB, 2)) MB" -ForegroundColor Green
    }
    
    if (Test-Path "$DeployDir\server.js") {
        Write-Host "  🟢 前端服务器: ✅" -ForegroundColor Green
    }
    
    if (Test-Path "$DeployDir\.next") {
        $nextDir = Get-ChildItem "$DeployDir\.next" -Recurse | Measure-Object -Property Length -Sum
        $nextSize = [math]::Round($nextDir.Sum / 1MB, 2)
        Write-Host "  📦 Next.js 资源: $nextSize MB" -ForegroundColor Green
    }
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
}

# 主函数
function Main {
    try {
        # 参数处理
        if ($CheckOnly) {
            Write-Host "🔍 仅检查环境，不进行构建" -ForegroundColor Yellow
        }
        
        # 环境检查
        if (-not (Test-RustEnvironment)) {
            Write-Error "Rust 环境检查失败"
            exit 1
        }
        
        if (-not (Test-NodeEnvironment)) {
            Write-Error "Node.js 环境检查失败"  
            exit 1
        }
        
        if (-not (Install-LinuxTarget)) {
            Write-Error "Linux 交叉编译目标安装失败"
            exit 1
        }
        
        if ($InstallTools) {
            if (-not (Install-CrossCompileTools)) {
                Write-Warning "交叉编译工具链安装不完整，将使用 musl 静态编译"
            }
        }
        else {
            Install-CrossCompileTools | Out-Null
        }
        
        if ($CheckOnly) {
            Write-Success "环境检查完成，可以进行交叉编译"
            return
        }
        
        # 检查项目结构
        if (-not (Test-Path "backend\Cargo.toml") -or -not (Test-Path "frontend\package.json")) {
            Write-Error "请在 PortfolioPulse 项目根目录运行此脚本"
            Write-Host "当前目录: $(Get-Location)" -ForegroundColor Yellow
            Write-Host "需要存在: backend/Cargo.toml 和 frontend/package.json" -ForegroundColor Yellow
            exit 1
        }
        
        # 开始构建
        Initialize-BuildDirectories
        
        if (-not (Build-RustBackend)) {
            Write-Error "后端构建失败"
            exit 1
        }
        
        if (-not (Build-NextjsFrontend)) {
            Write-Error "前端构建失败"
            exit 1
        }
        
        Create-LinuxDeploymentScripts
        Create-DeploymentPackage
        Show-BuildSummary
        
        Write-Host "`n✨ 恭喜！Ubuntu 22.04 兼容的部署包已就绪！" -ForegroundColor Green
    }
    catch {
        Write-Host "`n💥 构建过程中发生错误:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host "堆栈信息:" -ForegroundColor Yellow
        Write-Host $_.ScriptStackTrace -ForegroundColor Gray
        exit 1
    }
}

# 脚本入口
if ($args -contains "-h" -or $args -contains "--help") {
    Write-Host @"
🐧 PortfolioPulse Linux 交叉编译脚本

用法:
  .\build_linux_binaries.ps1 [选项]

选项:
  -InstallTools    安装交叉编译工具链
  -CheckOnly       仅检查环境，不进行构建
  -Verbose         显示详细的构建信息
  -h, --help       显示此帮助信息

示例:
  .\build_linux_binaries.ps1                    # 标准构建
  .\build_linux_binaries.ps1 -InstallTools     # 安装工具并构建
  .\build_linux_binaries.ps1 -CheckOnly        # 仅检查环境
  .\build_linux_binaries.ps1 -Verbose          # 详细模式构建

目标系统: Ubuntu 22.04 LTS (x86_64)
"@
    exit 0
}

# 执行主函数
Main
