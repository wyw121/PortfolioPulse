#!/bin/bash

# PortfolioPulse 部署验证脚本
# 用于验证从 GitHub Actions 下载的构建产物是否正确

set -e

echo "🔍 PortfolioPulse 部署验证脚本"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📅 验证时间: $(date)"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function print_step() {
    echo -e "${BLUE}🔹 $1${NC}"
}

function print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

function print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

function print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 检查系统环境
print_step "检查系统环境"

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "$OS" != "Linux" ]]; then
    print_error "此脚本只能在 Linux 系统上运行，当前系统: $OS"
    exit 1
fi

if [[ "$ARCH" != "x86_64" ]]; then
    print_warning "架构不是 x86_64，当前: $ARCH，可能存在兼容性问题"
fi

print_success "系统环境: $OS $ARCH"

# 检查关键文件
print_step "检查关键文件"

CRITICAL_FILES=(
    "portfolio_pulse_backend"
    "server.js"
    "package.json"
    ".env.example"
    "start.sh"
    "stop.sh"
)

MISSING_FILES=()

for file in "${CRITICAL_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        print_success "$file 存在"
    else
        print_error "$file 缺失"
        MISSING_FILES+=("$file")
    fi
done

if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
    print_error "缺少关键文件，部署无法继续"
    exit 1
fi

# 验证后端二进制文件
print_step "验证后端二进制文件"

if [[ -f "portfolio_pulse_backend" ]]; then
    FILE_TYPE=$(file portfolio_pulse_backend)
    FILE_SIZE=$(du -h portfolio_pulse_backend | cut -f1)

    echo "文件类型: $FILE_TYPE"
    echo "文件大小: $FILE_SIZE"

    if [[ "$FILE_TYPE" == *"ELF 64-bit"* && "$FILE_TYPE" == *"x86-64"* ]]; then
        print_success "后端二进制文件格式正确 (ELF 64-bit x86-64)"
    elif [[ "$FILE_TYPE" == *"PE32+"* || "$FILE_TYPE" == *"executable"* && "$FILE_TYPE" == *"Windows"* ]]; then
        print_error "后端文件是 Windows 格式，无法在 Linux 运行！"
        print_error "请检查构建流程，确保使用 Linux 交叉编译"
        exit 1
    else
        print_warning "后端文件格式未知: $FILE_TYPE"
    fi

    # 检查可执行权限
    if [[ -x "portfolio_pulse_backend" ]]; then
        print_success "后端文件具有可执行权限"
    else
        print_warning "后端文件缺少可执行权限，将自动修复"
        chmod +x portfolio_pulse_backend
        print_success "已添加可执行权限"
    fi
else
    print_error "后端二进制文件不存在"
    exit 1
fi

# 验证前端文件结构
print_step "验证前端文件结构"

# 检查 server.js
if [[ -f "server.js" ]]; then
    print_success "server.js 存在"
else
    print_error "server.js 缺失"
    exit 1
fi

# 检查 .next 目录结构（关键检查）
if [[ -d ".next" ]]; then
    print_success ".next 目录存在"
    
    # 检查关键的 Next.js 构建文件
    NEXT_FILES_MISSING=()
    
    if [[ ! -f ".next/BUILD_ID" ]]; then
        NEXT_FILES_MISSING+=("BUILD_ID")
    fi
    
    if [[ ! -d ".next/server" ]] && [[ ! -f ".next/routes-manifest.json" ]]; then
        NEXT_FILES_MISSING+=("server目录或routes-manifest.json")
    fi
    
    if [[ ${#NEXT_FILES_MISSING[@]} -gt 0 ]]; then
        print_error ".next 目录缺少关键文件:"
        for missing in "${NEXT_FILES_MISSING[@]}"; do
            echo "  - $missing"
        done
        print_warning "这会导致前端启动失败: 'Could not find a production build'"
        echo ""
        echo "🔧 修复建议:"
        echo "1. 运行修复脚本: ./fix_frontend_deployment.sh"
        echo "2. 或者重新从 GitHub Actions 下载最新构建产物"
    else
        print_success ".next 目录结构完整"
    fi
    
    echo "  .next 目录内容:"
    ls -la .next/ | head -10
else
    print_error ".next 目录不存在"
    print_error "这是导致前端启动失败的主要原因"
    echo ""
    echo "🔧 修复建议:"
    echo "1. 运行修复脚本: ./fix_frontend_deployment.sh"  
    echo "2. 或者重新从 GitHub Actions 下载最新构建产物"
fi

FRONTEND_PATHS=(
    ".next/static"
    "public"
)

for path in "${FRONTEND_PATHS[@]}"; do
    if [[ -d "$path" ]]; then
        print_success "$path 目录存在"
        
        # 检查目录是否为空
        if [[ -n "$(ls -A "$path" 2>/dev/null)" ]]; then
            print_success "$path 包含文件"
        else
            print_warning "$path 目录为空"
        fi
    else
        print_warning "$path 目录不存在，可能影响前端功能"
    fi
done# 验证 Node.js 依赖
print_step "验证 Node.js 环境"

if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_success "Node.js 已安装: $NODE_VERSION"

    # 检查版本是否符合要求 (>= 18)
    NODE_MAJOR=$(echo "$NODE_VERSION" | sed 's/v\([0-9]*\).*/\1/')
    if [[ "$NODE_MAJOR" -ge 18 ]]; then
        print_success "Node.js 版本符合要求 (>= 18)"
    else
        print_error "Node.js 版本过低，需要 >= 18，当前: $NODE_VERSION"
        echo "升级命令: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs"
        exit 1
    fi
else
    print_error "Node.js 未安装"
    echo "安装命令: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs"
    exit 1
fi

if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    print_success "npm 已安装: $NPM_VERSION"
else
    print_error "npm 未安装"
    exit 1
fi

# 验证脚本权限
print_step "验证管理脚本"

SCRIPTS=("start.sh" "stop.sh")

for script in "${SCRIPTS[@]}"; do
    if [[ -f "$script" ]]; then
        if [[ -x "$script" ]]; then
            print_success "$script 具有可执行权限"
        else
            print_warning "$script 缺少可执行权限，正在修复..."
            chmod +x "$script"
            print_success "已为 $script 添加可执行权限"
        fi

        # 简单检查脚本语法
        if bash -n "$script"; then
            print_success "$script 语法检查通过"
        else
            print_error "$script 语法错误"
        fi
    fi
done

# 检查端口占用
print_step "检查端口占用情况"

PORTS=(3000 8000)

for port in "${PORTS[@]}"; do
    if netstat -tln 2>/dev/null | grep -q ":$port "; then
        print_warning "端口 $port 已被占用"
        PROCESS=$(lsof -ti:$port 2>/dev/null | head -1)
        if [[ -n "$PROCESS" ]]; then
            PROCESS_NAME=$(ps -p "$PROCESS" -o comm= 2>/dev/null || echo "未知")
            echo "         占用进程: $PROCESS_NAME (PID: $PROCESS)"
        fi
    else
        print_success "端口 $port 可用"
    fi
done

# 检查系统资源
print_step "检查系统资源"

# 内存检查
MEM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
MEM_AVAILABLE=$(free -m | awk '/^Mem:/{print $7}')

echo "总内存: ${MEM_TOTAL}MB"
echo "可用内存: ${MEM_AVAILABLE}MB"

if [[ "$MEM_AVAILABLE" -lt 200 ]]; then
    print_warning "可用内存较少 (${MEM_AVAILABLE}MB)，可能影响服务运行"
else
    print_success "内存充足"
fi

# 磁盘空间检查
DISK_USAGE=$(df . | tail -1 | awk '{print $5}' | sed 's/%//')
DISK_AVAILABLE=$(df -h . | tail -1 | awk '{print $4}')

echo "磁盘使用率: ${DISK_USAGE}%"
echo "可用空间: $DISK_AVAILABLE"

if [[ "$DISK_USAGE" -gt 90 ]]; then
    print_warning "磁盘空间不足 (使用率: ${DISK_USAGE}%)"
else
    print_success "磁盘空间充足"
fi

# 环境变量配置建议
print_step "环境变量配置检查"

if [[ -f ".env" ]]; then
    print_success ".env 文件存在"

    # 检查关键配置项
    if grep -q "DATABASE_URL" .env; then
        print_success "数据库配置存在"
    else
        print_warning "缺少 DATABASE_URL 配置"
    fi

    if grep -q "NODE_ENV=production" .env; then
        print_success "生产环境配置正确"
    else
        print_warning "建议设置 NODE_ENV=production"
    fi
else
    print_warning ".env 文件不存在，请复制 .env.example 并配置"
    echo "命令: cp .env.example .env && nano .env"
fi

# 最终验证结果
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 验证完成总结"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ ${#MISSING_FILES[@]} -eq 0 ]]; then
    print_success "所有关键文件存在"
    print_success "后端二进制文件格式正确"
    print_success "前端文件结构完整"
    print_success "系统环境符合要求"

    echo ""
    echo -e "${GREEN}🎉 验证通过！可以开始部署${NC}"
    echo ""
    echo "📋 下一步操作："
    echo "1. 配置环境变量: cp .env.example .env && nano .env"
    echo "2. 启动服务: ./start.sh"
    echo "3. 验证服务: curl http://localhost:3000 && curl http://localhost:8000"
    echo ""
else
    print_error "验证失败，请修复以上问题后重新部署"
    exit 1
fi
