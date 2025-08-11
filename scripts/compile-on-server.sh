#!/bin/bash

# PortfolioPulse 服务器端编译脚本
# 在 Linux 服务器上直接编译后端和前端

set -e

# ANSI 颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "\n${PURPLE}▶${NC} $1"
}

# 检查命令是否存在
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        log_success "✅ $1 已安装"
        return 0
    else
        log_error "❌ $1 未找到"
        return 1
    fi
}

# 安装依赖
install_dependencies() {
    log_step "📦 安装系统依赖"

    # 检测系统类型
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu
        log_info "检测到 Debian/Ubuntu 系统"

        sudo apt update

        # 安装基础依赖
        sudo apt install -y curl wget git build-essential pkg-config libssl-dev

        # 安装 Node.js
        if ! check_command "node"; then
            log_info "安装 Node.js..."
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt-get install -y nodejs
        fi

        # 安装 Rust
        if ! check_command "cargo"; then
            log_info "安装 Rust..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source ~/.cargo/env
        fi

    elif [ -f /etc/redhat-release ]; then
        # RHEL/CentOS/Fedora
        log_info "检测到 RHEL/CentOS/Fedora 系统"

        # 检测包管理器
        if command -v dnf >/dev/null 2>&1; then
            PKG_MGR="dnf"
        elif command -v yum >/dev/null 2>&1; then
            PKG_MGR="yum"
        fi

        sudo $PKG_MGR update -y
        sudo $PKG_MGR install -y curl wget git gcc gcc-c++ make pkgconfig openssl-devel

        # 安装 Node.js
        if ! check_command "node"; then
            log_info "安装 Node.js..."
            curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
            sudo $PKG_MGR install -y nodejs
        fi

        # 安装 Rust
        if ! check_command "cargo"; then
            log_info "安装 Rust..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source ~/.cargo/env
        fi

    else
        log_warning "⚠️  未识别的系统类型，请手动安装依赖"
        log_info "需要安装的依赖: curl, git, build-essential, nodejs, cargo"
    fi
}

# 验证依赖
verify_dependencies() {
    log_step "🔍 验证依赖"

    local deps_ok=true

    # 检查 Node.js
    if check_command "node"; then
        echo "Node.js 版本: $(node --version)"
        echo "npm 版本: $(npm --version)"
    else
        deps_ok=false
    fi

    # 检查 Rust
    if check_command "cargo"; then
        echo "Rust 版本: $(rustc --version)"
        echo "Cargo 版本: $(cargo --version)"
    else
        deps_ok=false
    fi

    # 检查编译工具
    if check_command "gcc"; then
        echo "GCC 版本: $(gcc --version | head -1)"
    else
        deps_ok=false
    fi

    if [ "$deps_ok" = false ]; then
        log_error "❌ 依赖检查失败，请先安装缺失的依赖"
        return 1
    fi

    log_success "✅ 所有依赖已就绪"
    return 0
}

# 编译后端
compile_backend() {
    log_step "🦀 编译 Rust 后端"

    if [ ! -d "backend" ]; then
        log_error "❌ backend 目录不存在"
        return 1
    fi

    cd backend

    log_info "清理之前的构建..."
    cargo clean

    log_info "编译 Release 版本..."
    if cargo build --release; then
        log_success "✅ 后端编译成功"

        # 查找编译后的二进制文件
        local binary_path=""
        for name in "portfolio-pulse-backend" "portfolio_pulse_backend" "portfolio_pulse" "backend" "main"; do
            if [ -f "target/release/$name" ]; then
                binary_path="target/release/$name"
                break
            fi
        done

        if [ -n "$binary_path" ]; then
            # 复制到根目录
            cp "$binary_path" "../portfolio_pulse_backend"
            chmod +x "../portfolio_pulse_backend"
            log_success "✅ 后端二进制文件已复制到根目录"

            # 显示文件信息
            echo "文件信息:"
            file "../portfolio_pulse_backend"
            ls -la "../portfolio_pulse_backend"
        else
            log_error "❌ 未找到编译后的二进制文件"
            echo "target/release 目录内容:"
            ls -la target/release/
            return 1
        fi
    else
        log_error "❌ 后端编译失败"
        return 1
    fi

    cd ..
}

# 编译前端
compile_frontend() {
    log_step "🟢 编译 Next.js 前端"

    if [ ! -d "frontend" ]; then
        log_error "❌ frontend 目录不存在"
        return 1
    fi

    cd frontend

    log_info "安装依赖..."
    npm ci

    log_info "编译前端应用..."
    if npm run build; then
        log_success "✅ 前端编译成功"

        # 检查 standalone 输出
        if [ -d ".next/standalone" ]; then
            log_success "✅ Standalone 构建已生成"

            # 复制文件到根目录
            cp -r .next/standalone/* ../

            # 复制静态文件
            if [ -d ".next/static" ]; then
                mkdir -p ../.next/static
                cp -r .next/static/* ../.next/static/
            fi

            # 复制 public 文件
            if [ -d "public" ]; then
                cp -r public ../
            fi

            log_success "✅ 前端文件已复制到根目录"
        else
            log_error "❌ 未找到 Standalone 输出"
            log_info "请检查 next.config.js 是否配置了 output: 'standalone'"
            return 1
        fi
    else
        log_error "❌ 前端编译失败"
        return 1
    fi

    cd ..
}

# 创建启动脚本
create_startup_scripts() {
    log_step "📜 创建启动脚本"

    # 增强版启动脚本
    cat > start.sh << 'EOF'
#!/bin/bash
# PortfolioPulse 增强启动脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "\n${PURPLE}▶${NC} $1"; }

echo -e "${CYAN}🚀 PortfolioPulse 启动脚本${NC}"
echo "📅 启动时间: $(date '+%Y-%m-%d %H:%M:%S')"

# 系统信息
log_step "📋 系统信息"
echo "操作系统: $(uname -a)"
echo "当前目录: $(pwd)"
echo "磁盘空间: $(df -h . | tail -1 | awk '{print $4 " 可用"}')"

# 依赖检查
log_step "🔧 依赖检查"
if command -v node >/dev/null 2>&1; then
    log_success "✅ Node.js $(node --version)"
else
    log_error "❌ Node.js 未安装"
    exit 1
fi

# 环境变量
log_step "🌐 环境配置"
export NODE_ENV=production
export PORT=3000

if [ -f ".env" ]; then
    source .env
    log_success "✅ 已加载 .env 文件"
else
    log_warning "⚠️  .env 文件不存在"
fi

# 文件检查
log_step "📁 文件检查"
if [ -f "portfolio_pulse_backend" ]; then
    if [ -x "portfolio_pulse_backend" ]; then
        log_success "✅ 后端文件就绪"
        echo "文件信息: $(file portfolio_pulse_backend)"
    else
        chmod +x portfolio_pulse_backend
        log_success "✅ 已添加执行权限"
    fi
else
    log_error "❌ 后端二进制文件不存在"
    exit 1
fi

if [ -f "server.js" ]; then
    log_success "✅ 前端文件就绪"
else
    log_error "❌ 前端 server.js 不存在"
    exit 1
fi

# 清理旧进程
log_step "🧹 清理旧进程"
for pid_file in backend.pid frontend.pid; do
    if [ -f "$pid_file" ]; then
        old_pid=$(cat "$pid_file")
        if kill -0 "$old_pid" 2>/dev/null; then
            log_warning "停止旧进程: $old_pid"
            kill "$old_pid" 2>/dev/null || true
            sleep 2
        fi
        rm -f "$pid_file"
    fi
done

# 启动后端
log_step "🦀 启动后端服务 (端口 8000)"
nohup ./portfolio_pulse_backend > backend.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > backend.pid
log_success "✅ 后端启动 (PID: $BACKEND_PID)"

# 等待后端启动
log_info "⏳ 等待后端启动..."
for i in {1..30}; do
    if curl -s -f "http://localhost:8000" >/dev/null 2>&1; then
        log_success "✅ 后端服务就绪"
        break
    fi
    if ! kill -0 "$BACKEND_PID" 2>/dev/null; then
        log_error "❌ 后端进程已退出"
        echo "📋 后端日志:"
        tail -20 backend.log
        exit 1
    fi
    echo -n "."
    sleep 1
done

if ! curl -s -f "http://localhost:8000" >/dev/null 2>&1; then
    log_error "❌ 后端启动超时"
    kill "$BACKEND_PID" 2>/dev/null || true
    exit 1
fi

# 启动前端
log_step "🟢 启动前端服务 (端口 3000)"
nohup node server.js > frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > frontend.pid
log_success "✅ 前端启动 (PID: $FRONTEND_PID)"

# 等待前端启动
log_info "⏳ 等待前端启动..."
for i in {1..20}; do
    if curl -s -f "http://localhost:3000" >/dev/null 2>&1; then
        log_success "✅ 前端服务就绪"
        break
    fi
    if ! kill -0 "$FRONTEND_PID" 2>/dev/null; then
        log_error "❌ 前端进程已退出"
        echo "📋 前端日志:"
        tail -20 frontend.log
        kill "$BACKEND_PID" 2>/dev/null || true
        exit 1
    fi
    echo -n "."
    sleep 1
done

if ! curl -s -f "http://localhost:3000" >/dev/null 2>&1; then
    log_error "❌ 前端启动超时"
    kill "$BACKEND_PID" "$FRONTEND_PID" 2>/dev/null || true
    exit 1
fi

# 启动成功
echo ""
echo -e "${GREEN}🎉 PortfolioPulse 启动成功!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 服务状态:"
echo "  🦀 后端: PID $BACKEND_PID - http://localhost:8000"
echo "  🟢 前端: PID $FRONTEND_PID - http://localhost:3000"
echo ""
echo "🌐 访问地址: http://localhost:3000"
echo "📋 管理命令:"
echo "  查看日志: tail -f backend.log frontend.log"
echo "  停止服务: ./stop.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
EOF

    # 停止脚本
    cat > stop.sh << 'EOF'
#!/bin/bash
# PortfolioPulse 停止脚本

echo "🛑 停止 PortfolioPulse..."

for service in frontend backend; do
    if [ -f "${service}.pid" ]; then
        pid=$(cat "${service}.pid")
        if kill -0 "$pid" 2>/dev/null; then
            echo "停止 $service (PID: $pid)..."
            kill "$pid" 2>/dev/null || true
            sleep 2

            # 强制停止
            if kill -0 "$pid" 2>/dev/null; then
                kill -9 "$pid" 2>/dev/null || true
            fi
        fi
        rm -f "${service}.pid"
    fi
done

echo "✅ 所有服务已停止"
EOF

    # 状态检查脚本
    cat > status.sh << 'EOF'
#!/bin/bash
# PortfolioPulse 状态检查脚本

echo "📊 PortfolioPulse 状态检查"
echo "📅 时间: $(date '+%Y-%m-%d %H:%M:%S')"

for service in backend frontend; do
    echo ""
    echo "🔍 $service 服务:"

    if [ -f "${service}.pid" ]; then
        pid=$(cat "${service}.pid")
        if kill -0 "$pid" 2>/dev/null; then
            echo "  ✅ 运行中 (PID: $pid)"

            # 资源使用
            cpu_mem=$(ps -p "$pid" -o %cpu,%mem --no-headers 2>/dev/null)
            if [ -n "$cpu_mem" ]; then
                echo "  📊 资源: CPU ${cpu_mem%% *}%, 内存 ${cpu_mem##* }%"
            fi

            # HTTP 检查
            port=""
            case $service in
                backend) port=8000;;
                frontend) port=3000;;
            esac

            if [ -n "$port" ]; then
                if curl -s -f "http://localhost:$port" >/dev/null 2>&1; then
                    echo "  🌐 HTTP 响应正常 (端口 $port)"
                else
                    echo "  ⚠️  HTTP 无响应 (端口 $port)"
                fi
            fi
        else
            echo "  ❌ 进程不存在 (PID: $pid)"
        fi
    else
        echo "  ❌ 未运行 (无 PID 文件)"
    fi
done

echo ""
echo "📄 日志文件:"
for log in backend.log frontend.log; do
    if [ -f "$log" ]; then
        size=$(du -h "$log" | cut -f1)
        lines=$(wc -l < "$log")
        echo "  $log: $size ($lines 行)"
    fi
done
EOF

    # 添加执行权限
    chmod +x start.sh stop.sh status.sh

    log_success "✅ 启动脚本已创建"
}

# 测试编译结果
test_compilation() {
    log_step "🧪 测试编译结果"

    # 测试后端二进制
    if [ -f "portfolio_pulse_backend" ]; then
        log_info "测试后端二进制文件..."
        if ./portfolio_pulse_backend --version 2>/dev/null || ./portfolio_pulse_backend --help 2>/dev/null || timeout 3 ./portfolio_pulse_backend 2>/dev/null; then
            log_success "✅ 后端二进制文件正常"
        else
            log_warning "⚠️  后端二进制文件可能有问题，但已编译成功"
        fi
    fi

    # 测试前端
    if [ -f "server.js" ]; then
        log_info "测试前端文件..."
        if node -c server.js 2>/dev/null; then
            log_success "✅ 前端 JavaScript 语法正确"
        else
            log_warning "⚠️  前端文件可能有语法问题"
        fi
    fi
}

# 主函数
main() {
    echo -e "${CYAN}"
    echo "🚀 PortfolioPulse 服务器端编译脚本"
    echo "📅 编译时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "🖥️  系统信息: $(uname -a)"
    echo -e "${NC}"

    # 检查是否在正确目录
    if [ ! -f "backend/Cargo.toml" ] || [ ! -f "frontend/package.json" ]; then
        log_error "❌ 请在项目根目录运行此脚本"
        echo "当前目录: $(pwd)"
        echo "需要包含: backend/Cargo.toml 和 frontend/package.json"
        exit 1
    fi

    # 询问是否安装依赖
    echo "是否需要安装系统依赖? (y/n)"
    read -r install_deps

    if [[ $install_deps =~ ^[Yy]$ ]]; then
        install_dependencies
    fi

    # 验证依赖
    if ! verify_dependencies; then
        log_error "❌ 依赖验证失败"
        exit 1
    fi

    # 编译后端
    if ! compile_backend; then
        log_error "❌ 后端编译失败"
        exit 1
    fi

    # 编译前端
    if ! compile_frontend; then
        log_error "❌ 前端编译失败"
        exit 1
    fi

    # 创建启动脚本
    create_startup_scripts

    # 测试编译结果
    test_compilation

    # 完成
    echo ""
    echo -e "${GREEN}🎉 编译完成!${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📁 生成的文件:"
    echo "  🦀 portfolio_pulse_backend - 后端二进制"
    echo "  🟢 server.js - 前端服务器"
    echo "  📜 start.sh - 启动脚本"
    echo "  📜 stop.sh - 停止脚本"
    echo "  📜 status.sh - 状态检查"
    echo ""
    echo "🚀 启动服务:"
    echo "  ./start.sh"
    echo ""
    echo "📊 检查状态:"
    echo "  ./status.sh"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 错误处理
trap 'echo -e "\n${RED}❌ 编译过程中发生错误${NC}"; exit 1' ERR

# 执行主函数
main "$@"
