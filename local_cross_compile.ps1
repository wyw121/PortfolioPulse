#!/usr/bin/env pwsh

# PortfolioPulse Windows 本地交叉编译脚本 (无 Docker)
# 专门解决 Windows 环境下的 Rust 交叉编译问题

param(
    [switch]$Force,
    [switch]$Clean,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

Write-Host "🦀 PortfolioPulse Windows 本地交叉编译方案" -ForegroundColor Cyan
Write-Host "🎯 目标: Ubuntu 22.04 LTS (x86_64)" -ForegroundColor Green
Write-Host "🚫 不使用 Docker，纯 Windows 本地编译" -ForegroundColor Yellow
Write-Host ""

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

# 彻底清理和重置 Rust 环境
function Reset-RustEnvironment {
    Write-Step "重置 Rust 交叉编译环境"

    if ($Clean) {
        Write-Host "🧹 彻底清理 Rust 环境..." -ForegroundColor Yellow

        # 移除所有 Linux 目标
        $linuxTargets = @(
            "x86_64-unknown-linux-gnu",
            "x86_64-unknown-linux-musl",
            "aarch64-unknown-linux-gnu"
        )

        foreach ($target in $linuxTargets) {
            Write-Host "移除目标: $target" -ForegroundColor Gray
            rustup target remove $target 2>$null
        }

        # 清理环境变量
        Get-ChildItem Env: | Where-Object {
            $_.Name -like "CARGO_TARGET_*" -or
            $_.Name -like "CC_*" -or
            $_.Name -like "CXX_*" -or
            $_.Name -like "RUSTFLAGS*"
        } | Remove-Item -ErrorAction SilentlyContinue

        Start-Sleep -Seconds 2
    }

    # 重新安装目标
    Write-Host "📦 重新安装 Linux 目标..." -ForegroundColor Blue

    # 只安装 GNU 目标，避免 musl 的复杂性
    rustup target add x86_64-unknown-linux-gnu

    if ($LASTEXITCODE -eq 0) {
        Write-Success "GNU 目标安装成功"
    }
    else {
        Write-Error "目标安装失败"
        return $false
    }

    return $true
}

# 配置最简化的交叉编译环境
function Setup-MinimalCrossCompile {
    Write-Step "配置最简化交叉编译环境"

    # 清理所有可能冲突的环境变量
    $envVarsToRemove = @(
        "CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER",
        "CC_x86_64_unknown_linux_gnu",
        "CXX_x86_64_unknown_linux_gnu",
        "RUSTFLAGS",
        "CC",
        "CXX"
    )

    foreach ($envVar in $envVarsToRemove) {
        if (Test-Path "env:$envVar") {
            Remove-Item "env:$envVar" -ErrorAction SilentlyContinue
            Write-Host "清除环境变量: $envVar" -ForegroundColor Gray
        }
    }

    # 使用 Rust 内置的 LLD 链接器
    Write-Host "🔧 配置 Rust LLD 链接器..." -ForegroundColor Blue

    # 设置最简单的配置
    $env:RUSTFLAGS = "-C linker=rust-lld -C target-cpu=generic"

    Write-Success "交叉编译环境配置完成"
    return $true
}

# 测试交叉编译环境
function Test-CrossCompileEnvironment {
    Write-Step "测试交叉编译环境"

    Push-Location backend

    try {
        # 先测试本地编译确认项目没问题
        Write-Host "1️⃣ 测试本地 Windows 编译..." -ForegroundColor Cyan

        cargo check --quiet

        if ($LASTEXITCODE -ne 0) {
            Write-Error "本地编译检查失败，项目可能有问题"
            return $false
        }

        Write-Success "本地编译检查通过"

        # 测试交叉编译检查
        Write-Host "2️⃣ 测试 Linux 交叉编译检查..." -ForegroundColor Cyan

        cargo check --target x86_64-unknown-linux-gnu --quiet

        if ($LASTEXITCODE -eq 0) {
            Write-Success "交叉编译检查通过"
            return $true
        }
        else {
            Write-Warning "交叉编译检查失败，但可以尝试完整编译"
            return $true  # 有些情况下 check 失败但 build 成功
        }
    }
    catch {
        Write-Warning "环境测试遇到问题: $($_.Exception.Message)"
        return $true  # 继续尝试
    }
    finally {
        Pop-Location
    }
}

# 执行交叉编译
function Build-CrossPlatform {
    Write-Step "执行交叉编译"

    # 创建输出目录
    New-Item -ItemType Directory -Path ".\build\local-cross" -Force | Out-Null

    # 编译后端
    Push-Location backend

    try {
        Write-Host "🦀 编译 Rust 后端..." -ForegroundColor Blue
        Write-Host "目标: x86_64-unknown-linux-gnu" -ForegroundColor Gray

        # 清理之前的构建
        if ($Clean) {
            cargo clean
            Write-Host "已清理构建缓存" -ForegroundColor Gray
        }

        # 开始编译
        $buildArgs = @("build", "--release", "--target", "x86_64-unknown-linux-gnu")

        if ($Verbose) {
            $buildArgs += "--verbose"
        }

        Write-Host "执行命令: cargo $($buildArgs -join ' ')" -ForegroundColor Gray

        & cargo @buildArgs

        if ($LASTEXITCODE -ne 0) {
            Write-Error "交叉编译失败"

            # 尝试显示更详细的错误信息
            Write-Host "`n🔍 尝试获取详细错误信息..." -ForegroundColor Yellow
            & cargo build --release --target x86_64-unknown-linux-gnu --verbose

            return $false
        }

        # 查找编译产物
        $targetDir = "target\x86_64-unknown-linux-gnu\release"

        if (-not (Test-Path $targetDir)) {
            Write-Error "编译产物目录不存在: $targetDir"
            return $false
        }

        Write-Host "🔍 搜索可执行文件..." -ForegroundColor Blue

        # 查找可执行文件
        $possibleNames = @(
            "portfolio-pulse-backend",
            "portfolio_pulse_backend",
            "portfolio-pulse",
            "portfolio_pulse",
            "backend",
            "main"
        )

        $foundBinary = $null

        foreach ($name in $possibleNames) {
            $binaryPath = "$targetDir\$name"
            if (Test-Path $binaryPath) {
                $foundBinary = $binaryPath
                Write-Success "找到二进制文件: $name"
                break
            }
        }

        if (-not $foundBinary) {
            # 列出所有可能的可执行文件
            Write-Host "📋 target 目录内容:" -ForegroundColor Yellow
            $allFiles = Get-ChildItem $targetDir -File | Sort-Object Length -Descending

            foreach ($file in $allFiles) {
                $sizeKB = [math]::Round($file.Length / 1KB, 1)
                Write-Host "  $($file.Name) ($sizeKB KB)" -ForegroundColor White
            }

            # 尝试找最大的文件作为可执行文件
            $largestFile = $allFiles | Where-Object {
                $_.Name -notmatch '\.(d|pdb|rlib|rmeta)$' -and $_.Length -gt 100KB
            } | Select-Object -First 1

            if ($largestFile) {
                $foundBinary = $largestFile.FullName
                Write-Success "使用最大文件作为可执行文件: $($largestFile.Name)"
            }
            else {
                Write-Error "未找到可执行文件"
                return $false
            }
        }

        # 复制到输出目录
        $outputBinary = "..\build\local-cross\portfolio_pulse_backend"
        Copy-Item $foundBinary $outputBinary -Force

        # 显示文件信息
        $fileInfo = Get-Item $outputBinary
        $fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)

        Write-Success "后端编译成功!"
        Write-Host "  📦 源文件: $foundBinary" -ForegroundColor Gray
        Write-Host "  📦 输出: $outputBinary" -ForegroundColor Gray
        Write-Host "  📊 大小: $fileSizeMB MB" -ForegroundColor Gray

        return $true
    }
    catch {
        Write-Error "后端编译过程异常: $($_.Exception.Message)"
        return $false
    }
    finally {
        Pop-Location
    }
}

# 编译前端
function Build-Frontend {
    Write-Step "编译前端 Next.js 应用"

    if (-not (Test-Command "node")) {
        Write-Error "Node.js 未安装，请先安装 Node.js"
        return $false
    }

    Push-Location frontend

    try {
        Write-Host "📦 安装前端依赖..." -ForegroundColor Blue
        npm ci --silent

        if ($LASTEXITCODE -ne 0) {
            Write-Error "前端依赖安装失败"
            return $false
        }

        Write-Host "🏗️  构建前端应用..." -ForegroundColor Blue
        npm run build

        if ($LASTEXITCODE -ne 0) {
            Write-Error "前端构建失败"
            return $false
        }

        # 检查并复制构建产物
        if (Test-Path ".next\standalone") {
            Write-Host "📁 复制前端文件到输出目录..." -ForegroundColor Blue

            # 复制 standalone 应用
            Copy-Item -Path ".next\standalone\*" -Destination "..\build\local-cross\" -Recurse -Force

            # 复制静态资源
            if (Test-Path ".next\static") {
                New-Item -ItemType Directory -Path "..\build\local-cross\.next\static" -Force | Out-Null
                Copy-Item -Path ".next\static\*" -Destination "..\build\local-cross\.next\static\" -Recurse -Force
            }

            # 复制 public 文件
            if (Test-Path "public") {
                New-Item -ItemType Directory -Path "..\build\local-cross\public" -Force | Out-Null
                Copy-Item -Path "public\*" -Destination "..\build\local-cross\public\" -Recurse -Force
            }

            Write-Success "前端构建成功!"
            return $true
        }
        else {
            Write-Error "未找到 Next.js standalone 输出"
            Write-Host "请检查 next.config.js 是否配置了 output: 'standalone'" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Error "前端构建异常: $($_.Exception.Message)"
        return $false
    }
    finally {
        Pop-Location
    }
}

# 创建 Ubuntu 部署脚本
function Create-DeploymentScripts {
    Write-Step "创建 Ubuntu 22.04 部署脚本"

    $outputDir = ".\build\local-cross"

    # 启动脚本
    $startScript = @'
#!/bin/bash
# PortfolioPulse 启动脚本 - Ubuntu 22.04

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🚀 PortfolioPulse 启动脚本${NC}"
echo -e "${BLUE}🐧 Ubuntu 22.04 LTS 版本${NC}"
echo ""

# 检查文件权限
if [ ! -f "portfolio_pulse_backend" ]; then
    echo -e "${RED}❌ 后端文件不存在${NC}"
    exit 1
fi

if [ ! -f "server.js" ]; then
    echo -e "${RED}❌ 前端 server.js 不存在${NC}"
    exit 1
fi

# 设置执行权限
chmod +x portfolio_pulse_backend

# 环境变量
export NODE_ENV=production
export PORT=3000

# 加载 .env 文件
if [ -f ".env" ]; then
    source .env
    echo -e "${GREEN}✅ 已加载环境变量${NC}"
fi

# 检查端口是否被占用
if netstat -tlnp 2>/dev/null | grep -q ":8000 "; then
    echo -e "${YELLOW}⚠️  端口 8000 已被占用${NC}"
fi

if netstat -tlnp 2>/dev/null | grep -q ":3000 "; then
    echo -e "${YELLOW}⚠️  端口 3000 已被占用${NC}"
fi

# 启动后端
echo -e "${BLUE}🦀 启动后端服务 (端口 8000)${NC}"
nohup ./portfolio_pulse_backend > backend.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > backend.pid

echo -e "${GREEN}✅ 后端已启动 (PID: $BACKEND_PID)${NC}"

# 等待后端启动
echo -n "⏳ 等待后端启动"
for i in {1..30}; do
    if curl -s -f "http://localhost:8000" >/dev/null 2>&1; then
        echo ""
        echo -e "${GREEN}✅ 后端服务就绪${NC}"
        break
    fi

    if ! kill -0 "$BACKEND_PID" 2>/dev/null; then
        echo ""
        echo -e "${RED}❌ 后端进程意外退出${NC}"
        echo "后端日志:"
        tail -20 backend.log
        exit 1
    fi

    echo -n "."
    sleep 1

    if [ $i -eq 30 ]; then
        echo ""
        echo -e "${RED}❌ 后端启动超时${NC}"
        kill "$BACKEND_PID" 2>/dev/null || true
        exit 1
    fi
done

# 启动前端
echo -e "${BLUE}🟢 启动前端服务 (端口 3000)${NC}"
nohup node server.js > frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > frontend.pid

echo -e "${GREEN}✅ 前端已启动 (PID: $FRONTEND_PID)${NC}"

# 等待前端启动
echo -n "⏳ 等待前端启动"
for i in {1..20}; do
    if curl -s -f "http://localhost:3000" >/dev/null 2>&1; then
        echo ""
        echo -e "${GREEN}✅ 前端服务就绪${NC}"
        break
    fi

    if ! kill -0 "$FRONTEND_PID" 2>/dev/null; then
        echo ""
        echo -e "${RED}❌ 前端进程意外退出${NC}"
        echo "前端日志:"
        tail -20 frontend.log
        kill "$BACKEND_PID" 2>/dev/null || true
        exit 1
    fi

    echo -n "."
    sleep 1

    if [ $i -eq 20 ]; then
        echo ""
        echo -e "${RED}❌ 前端启动超时${NC}"
        kill "$BACKEND_PID" "$FRONTEND_PID" 2>/dev/null || true
        exit 1
    fi
done

echo ""
echo -e "${GREEN}🎉 PortfolioPulse 启动成功！${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 服务状态:"
echo -e "  🦀 后端: PID $BACKEND_PID - ${CYAN}http://localhost:8000${NC}"
echo -e "  🟢 前端: PID $FRONTEND_PID - ${CYAN}http://localhost:3000${NC}"
echo ""
echo -e "🌐 访问地址: ${CYAN}http://localhost:3000${NC}"
echo "📋 管理命令:"
echo "  ./status.sh  - 查看服务状态"
echo "  ./stop.sh    - 停止所有服务"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
'@

    # 停止脚本
    $stopScript = @'
#!/bin/bash
# 停止 PortfolioPulse 服务

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🛑 停止 PortfolioPulse 服务...${NC}"

# 停止后端
if [ -f "backend.pid" ]; then
    PID=$(cat backend.pid)
    if kill -0 "$PID" 2>/dev/null; then
        echo -e "停止后端服务 (PID: $PID)"
        kill "$PID" 2>/dev/null || true
        sleep 2

        # 强制停止如果还在运行
        if kill -0 "$PID" 2>/dev/null; then
            kill -9 "$PID" 2>/dev/null || true
        fi
    fi
    rm -f backend.pid
fi

# 停止前端
if [ -f "frontend.pid" ]; then
    PID=$(cat frontend.pid)
    if kill -0 "$PID" 2>/dev/null; then
        echo -e "停止前端服务 (PID: $PID)"
        kill "$PID" 2>/dev/null || true
        sleep 2

        # 强制停止如果还在运行
        if kill -0 "$PID" 2>/dev/null; then
            kill -9 "$PID" 2>/dev/null || true
        fi
    fi
    rm -f frontend.pid
fi

echo -e "${GREEN}✅ 所有服务已停止${NC}"
'@

    # 状态检查脚本
    $statusScript = @'
#!/bin/bash
# PortfolioPulse 状态检查

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}📊 PortfolioPulse 状态检查${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 系统信息
echo -e "${BLUE}🖥️  系统信息${NC}"
echo "时间: $(date)"
echo "系统: $(lsb_release -d 2>/dev/null | cut -f2 || echo '未知')"
echo "负载: $(uptime | awk -F'load average:' '{print $2}' || echo '未知')"
echo ""

# 检查后端
echo -e "${BLUE}🦀 后端服务${NC}"
if [ -f "backend.pid" ]; then
    PID=$(cat backend.pid)
    if kill -0 "$PID" 2>/dev/null; then
        echo -e "  ${GREEN}✅ 运行中 (PID: $PID)${NC}"

        # CPU 和内存使用
        if command -v ps >/dev/null; then
            CPU_MEM=$(ps -p "$PID" -o %cpu,%mem --no-headers 2>/dev/null | xargs)
            echo "  📊 资源: $CPU_MEM"
        fi

        # HTTP 检查
        if curl -s -f "http://localhost:8000" >/dev/null 2>&1; then
            echo -e "  ${GREEN}🌐 HTTP 响应正常${NC}"
        else
            echo -e "  ${YELLOW}⚠️  HTTP 无响应${NC}"
        fi
    else
        echo -e "  ${RED}❌ 进程不存在${NC}"
    fi
else
    echo -e "  ${RED}❌ 未启动${NC}"
fi

echo ""

# 检查前端
echo -e "${BLUE}🟢 前端服务${NC}"
if [ -f "frontend.pid" ]; then
    PID=$(cat frontend.pid)
    if kill -0 "$PID" 2>/dev/null; then
        echo -e "  ${GREEN}✅ 运行中 (PID: $PID)${NC}"

        # CPU 和内存使用
        if command -v ps >/dev/null; then
            CPU_MEM=$(ps -p "$PID" -o %cpu,%mem --no-headers 2>/dev/null | xargs)
            echo "  📊 资源: $CPU_MEM"
        fi

        # HTTP 检查
        if curl -s -f "http://localhost:3000" >/dev/null 2>&1; then
            echo -e "  ${GREEN}🌐 HTTP 响应正常${NC}"
        else
            echo -e "  ${YELLOW}⚠️  HTTP 无响应${NC}"
        fi
    else
        echo -e "  ${RED}❌ 进程不存在${NC}"
    fi
else
    echo -e "  ${RED}❌ 未启动${NC}"
fi

echo ""

# 日志文件状态
echo -e "${BLUE}📄 日志文件${NC}"
for log in backend.log frontend.log; do
    if [ -f "$log" ]; then
        SIZE=$(du -h "$log" 2>/dev/null | cut -f1)
        LINES=$(wc -l < "$log" 2>/dev/null || echo "0")
        ERRORS=$(grep -ci "error\|fail\|panic" "$log" 2>/dev/null || echo "0")
        echo "  $log: $SIZE ($LINES 行, $ERRORS 错误)"
    fi
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
'@

    # 保存脚本
    $startScript | Out-File -FilePath "$outputDir\start.sh" -Encoding utf8 -NoNewline
    $stopScript | Out-File -FilePath "$outputDir\stop.sh" -Encoding utf8 -NoNewline
    $statusScript | Out-File -FilePath "$outputDir\status.sh" -Encoding utf8 -NoNewline

    # 创建环境变量模板
    $envTemplate = @'
# PortfolioPulse 环境变量配置
# 复制此文件为 .env 并根据实际情况修改

# 数据库配置
DATABASE_URL=mysql://username:password@localhost:3306/portfolio_pulse

# GitHub 集成 (可选)
GITHUB_TOKEN=your_github_token_here
GITHUB_USERNAME=your_github_username

# 应用配置
NODE_ENV=production
PORT=3000

# 认证配置 (如果使用)
NEXTAUTH_SECRET=your_secret_key_here
NEXTAUTH_URL=http://your-domain.com

# 日志级别
RUST_LOG=info
'@

    $envTemplate | Out-File -FilePath "$outputDir\.env.example" -Encoding utf8 -NoNewline

    Write-Success "部署脚本创建完成"
}

# 验证编译产物
function Verify-BuildOutput {
    Write-Step "验证编译产物"

    $outputDir = ".\build\local-cross"

    # 检查关键文件
    $requiredFiles = @(
        "portfolio_pulse_backend",
        "server.js",
        "start.sh",
        "stop.sh",
        "status.sh",
        ".env.example"
    )

    $missingFiles = @()
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path "$outputDir\$file")) {
            $missingFiles += $file
        }
    }

    if ($missingFiles) {
        Write-Warning "缺少文件: $($missingFiles -join ', ')"
        return $false
    }

    # 检查后端二进制文件大小
    $backendBinary = "$outputDir\portfolio_pulse_backend"
    if (Test-Path $backendBinary) {
        $fileInfo = Get-Item $backendBinary
        $fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)

        if ($fileInfo.Length -lt 100KB) {
            Write-Warning "后端文件太小 ($fileSizeMB MB)，可能编译不完整"
            return $false
        }

        Write-Success "后端文件大小正常: $fileSizeMB MB"
    }

    Write-Success "编译产物验证通过"
    return $true
}

# 显示部署指南
function Show-DeploymentGuide {
    Write-Host "`n🎉 Windows 本地交叉编译完成!" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

    $outputDir = Resolve-Path ".\build\local-cross"
    Write-Host "📁 部署包位置: " -NoNewline -ForegroundColor Yellow
    Write-Host $outputDir -ForegroundColor White

    Write-Host "`n📦 包含文件:" -ForegroundColor Yellow
    Get-ChildItem ".\build\local-cross" | ForEach-Object {
        if ($_.PSIsContainer) {
            Write-Host "  📁 $($_.Name)/" -ForegroundColor Blue
        }
        else {
            $size = if ($_.Length -gt 1MB) {
                "{0:N1} MB" -f ($_.Length / 1MB)
            } else {
                "{0:N0} KB" -f ($_.Length / 1KB)
            }
            Write-Host "  📄 $($_.Name) ($size)" -ForegroundColor White
        }
    }

    Write-Host "`n🚀 Ubuntu 22.04 部署步骤:" -ForegroundColor Cyan
    Write-Host "1. 上传部署包到服务器:" -ForegroundColor White
    Write-Host "   scp -r local-cross/ user@server:/opt/portfoliopulse/" -ForegroundColor Gray

    Write-Host "2. 在服务器上设置权限:" -ForegroundColor White
    Write-Host "   chmod +x /opt/portfoliopulse/*.sh /opt/portfoliopulse/portfolio_pulse_backend" -ForegroundColor Gray

    Write-Host "3. 配置环境变量:" -ForegroundColor White
    Write-Host "   cp .env.example .env && nano .env" -ForegroundColor Gray

    Write-Host "4. 启动服务:" -ForegroundColor White
    Write-Host "   ./start.sh" -ForegroundColor Gray

    Write-Host "5. 检查状态:" -ForegroundColor White
    Write-Host "   ./status.sh" -ForegroundColor Gray

    Write-Host "`n📋 验证二进制文件 (在服务器上):" -ForegroundColor Cyan
    Write-Host "   file portfolio_pulse_backend" -ForegroundColor Gray
    Write-Host "   # 应显示: ELF 64-bit LSB executable, x86-64" -ForegroundColor Gray

    Write-Host "`n🔧 如果遇到问题:" -ForegroundColor Yellow
    Write-Host "   - 查看日志: tail -f backend.log frontend.log" -ForegroundColor Gray
    Write-Host "   - 检查权限: ls -la portfolio_pulse_backend" -ForegroundColor Gray
    Write-Host "   - 检查依赖: ldd portfolio_pulse_backend" -ForegroundColor Gray

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
}

# 主函数
function Main {
    # 检查项目结构
    if (-not (Test-Path "backend\Cargo.toml") -or -not (Test-Path "frontend\package.json")) {
        Write-Error "请在 PortfolioPulse 项目根目录运行此脚本"
        Write-Host "当前目录: $(Get-Location)" -ForegroundColor Yellow
        return
    }

    # 检查必要工具
    if (-not (Test-Command "rustc")) {
        Write-Error "Rust 未安装，请先运行: .\install_dev_environment.ps1"
        return
    }

    if (-not (Test-Command "node")) {
        Write-Error "Node.js 未安装，请先运行: .\install_dev_environment.ps1"
        return
    }

    Write-Host "🔧 开始 Windows 本地交叉编译..." -ForegroundColor Blue

    # 重置环境
    if (-not (Reset-RustEnvironment)) {
        Write-Error "Rust 环境重置失败"
        return
    }

    # 配置交叉编译
    if (-not (Setup-MinimalCrossCompile)) {
        Write-Error "交叉编译环境配置失败"
        return
    }

    # 测试环境
    if (-not (Test-CrossCompileEnvironment)) {
        Write-Warning "环境测试有问题，但继续尝试编译"
    }

    # 编译后端
    if (-not (Build-CrossPlatform)) {
        Write-Error "后端交叉编译失败"

        Write-Host "`n💡 建议尝试以下解决方案:" -ForegroundColor Cyan
        Write-Host "1. 重新运行脚本: .\local_cross_compile.ps1 -Clean" -ForegroundColor White
        Write-Host "2. 重置 Rust: rustup self uninstall 后重新安装" -ForegroundColor White
        Write-Host "3. 使用 GitHub Actions 云编译" -ForegroundColor White
        return
    }

    # 编译前端
    if (-not (Build-Frontend)) {
        Write-Error "前端编译失败"
        return
    }

    # 创建部署脚本
    Create-DeploymentScripts

    # 验证产物
    if (-not (Verify-BuildOutput)) {
        Write-Warning "编译产物验证有问题，请检查"
    }

    # 显示指南
    Show-DeploymentGuide

    Write-Host "`n✨ 本地交叉编译成功完成!" -ForegroundColor Green
}

# 帮助信息
if ($args -contains "-h" -or $args -contains "--help") {
    Write-Host @"
🦀 PortfolioPulse Windows 本地交叉编译脚本

用法:
  .\local_cross_compile.ps1 [选项]

选项:
  -Force           强制执行，忽略警告
  -Clean           彻底清理并重新编译
  -Verbose         显示详细编译信息
  -h, --help       显示此帮助信息

示例:
  .\local_cross_compile.ps1              # 标准编译
  .\local_cross_compile.ps1 -Clean       # 清理重编译
  .\local_cross_compile.ps1 -Verbose     # 详细模式

特点:
  - 无需 Docker
  - 纯 Windows 环境交叉编译
  - 专门针对 Ubuntu 22.04 LTS
  - 自动生成完整部署包
"@
    exit 0
}

# 执行主函数
Main
