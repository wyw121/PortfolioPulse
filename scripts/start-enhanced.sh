#!/bin/bash

# PortfolioPulse 增强启动脚本 - 详细调试版本
# 版本: 1.0
# 用途: 提供详细的启动过程信息和错误诊断

set -e  # 遇到错误立即退出

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
        $1 --version 2>/dev/null || echo "版本信息获取失败"
        return 0
    else
        log_error "❌ $1 未找到"
        return 1
    fi
}

# 检查端口是否被占用
check_port() {
    local port=$1
    local process=$(netstat -tulpn 2>/dev/null | grep ":$port ")

    if [ -n "$process" ]; then
        log_warning "⚠️  端口 $port 已被占用:"
        echo "$process"
        return 1
    else
        log_success "✅ 端口 $port 可用"
        return 0
    fi
}

# 检查文件是否存在且可执行
check_file() {
    local file=$1
    if [ -f "$file" ]; then
        if [ -x "$file" ]; then
            log_success "✅ $file 存在且可执行"
            ls -la "$file"
            return 0
        else
            log_warning "⚠️  $file 存在但不可执行"
            ls -la "$file"
            log_info "尝试添加执行权限..."
            chmod +x "$file"
            if [ -x "$file" ]; then
                log_success "✅ 已添加执行权限"
                return 0
            else
                log_error "❌ 无法添加执行权限"
                return 1
            fi
        fi
    else
        log_error "❌ $file 不存在"
        return 1
    fi
}

# 检查进程是否存在
check_process() {
    local pid_file=$1
    local service_name=$2

    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            log_warning "⚠️  $service_name 已在运行 (PID: $pid)"
            return 1
        else
            log_info "🧹 清理过期的 PID 文件: $pid_file"
            rm -f "$pid_file"
        fi
    fi
    return 0
}

# 等待服务启动
wait_for_service() {
    local port=$1
    local service_name=$2
    local max_attempts=30
    local attempt=1

    log_info "⏳ 等待 $service_name 启动 (端口 $port)..."

    while [ $attempt -le $max_attempts ]; do
        if curl -s "http://localhost:$port" >/dev/null 2>&1; then
            log_success "✅ $service_name 启动成功 (尝试 $attempt/$max_attempts)"
            return 0
        fi

        echo -n "."
        sleep 1
        attempt=$((attempt + 1))
    done

    log_error "❌ $service_name 启动超时"
    return 1
}

# 显示系统信息
show_system_info() {
    log_step "📋 系统信息检查"
    echo "操作系统: $(uname -a)"
    echo "当前用户: $(whoami)"
    echo "当前目录: $(pwd)"
    echo "磁盘空间:"
    df -h . | tail -1
    echo "内存使用:"
    free -h 2>/dev/null || log_warning "无法获取内存信息"
    echo "CPU 信息:"
    grep -m1 "model name" /proc/cpuinfo 2>/dev/null || log_warning "无法获取 CPU 信息"
}

# 检查环境变量
check_environment() {
    log_step "🌐 环境变量检查"

    # 必需的环境变量
    required_vars=("NODE_ENV")

    for var in "${required_vars[@]}"; do
        if [ -n "${!var}" ]; then
            log_success "✅ $var = ${!var}"
        else
            log_warning "⚠️  $var 未设置"
        fi
    done

    # 检查 .env 文件
    if [ -f ".env" ]; then
        log_success "✅ .env 文件存在"
        echo "环境变量数量: $(grep -c "=" .env)"
    else
        log_warning "⚠️  .env 文件不存在"
    fi
}

# 主启动函数
main() {
    echo -e "${CYAN}"
    echo "🚀 PortfolioPulse 增强启动脚本"
    echo "📅 启动时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "🏷️  版本: 1.0 Enhanced Debug"
    echo -e "${NC}"

    # 切换到部署目录
    DEPLOY_DIR="/opt/portfoliopulse"
    if [ -d "$DEPLOY_DIR" ]; then
        cd "$DEPLOY_DIR"
        log_success "✅ 已切换到部署目录: $DEPLOY_DIR"
    else
        log_error "❌ 部署目录不存在: $DEPLOY_DIR"
        exit 1
    fi

    # 系统信息检查
    show_system_info

    # 依赖检查
    log_step "🔧 依赖检查"
    deps_ok=true

    if ! check_command "node"; then
        deps_ok=false
    fi

    if ! check_command "mysql"; then
        log_warning "⚠️  MySQL 客户端未找到，将跳过数据库连接测试"
    fi

    if [ "$deps_ok" = false ]; then
        log_error "❌ 依赖检查失败，请安装缺失的依赖"
        exit 1
    fi

    # 环境变量检查
    check_environment

    # 加载环境变量
    if [ -f ".env" ]; then
        log_info "📂 加载环境变量..."
        set -a  # 自动导出变量
        source .env
        set +a
        log_success "✅ 已加载环境变量"
        export NODE_ENV=production
        export PORT=3000
    else
        log_warning "⚠️  .env 文件不存在，使用默认配置"
        export NODE_ENV=production
        export PORT=3000
    fi

    # 文件存在性检查
    log_step "📁 文件检查"
    files_ok=true

    # 检查后端二进制文件
    BACKEND_BINARY="./portfolio_pulse_backend"
    if [ ! -f "$BACKEND_BINARY" ]; then
        # 尝试其他可能的名称
        if [ -f "./portfolio_pulse" ]; then
            BACKEND_BINARY="./portfolio_pulse"
        elif [ -f "./backend" ]; then
            BACKEND_BINARY="./backend"
        else
            log_error "❌ 后端二进制文件未找到"
            echo "查找的路径:"
            echo "  - ./portfolio_pulse_backend"
            echo "  - ./portfolio_pulse"
            echo "  - ./backend"
            files_ok=false
        fi
    fi

    if [ "$files_ok" = true ]; then
        check_file "$BACKEND_BINARY"
    fi

    # 检查前端文件
    if [ -f "server.js" ]; then
        check_file "server.js"
    elif [ -f "frontend/server.js" ]; then
        log_info "✅ 前端服务器文件: frontend/server.js"
    else
        log_error "❌ 前端服务器文件未找到 (server.js 或 frontend/server.js)"
        files_ok=false
    fi

    if [ "$files_ok" = false ]; then
        log_error "❌ 文件检查失败"
        exit 1
    fi

    # 端口检查
    log_step "🔌 端口检查"
    check_port 8000  # 后端端口
    check_port 3000  # 前端端口

    # 进程检查
    log_step "🔍 进程检查"
    check_process "backend.pid" "后端服务"
    check_process "frontend.pid" "前端服务"

    # 数据库连接测试
    log_step "🗄️ 数据库连接测试"
    if command -v mysql >/dev/null 2>&1; then
        if [ -n "$DATABASE_URL" ]; then
            # 从 DATABASE_URL 提取连接信息
            # 格式: mysql://username:password@host:port/database
            DB_INFO=$(echo "$DATABASE_URL" | sed 's|mysql://||')
            if echo "$DB_INFO" | grep -q "@"; then
                DB_USER_PASS=$(echo "$DB_INFO" | cut -d'@' -f1)
                DB_HOST_DB=$(echo "$DB_INFO" | cut -d'@' -f2)
                DB_USER=$(echo "$DB_USER_PASS" | cut -d':' -f1)
                DB_PASS=$(echo "$DB_USER_PASS" | cut -d':' -f2)
                DB_HOST_PORT=$(echo "$DB_HOST_DB" | cut -d'/' -f1)
                DB_NAME=$(echo "$DB_HOST_DB" | cut -d'/' -f2)
                DB_HOST=$(echo "$DB_HOST_PORT" | cut -d':' -f1)
                DB_PORT=$(echo "$DB_HOST_PORT" | cut -d':' -f2)

                log_info "🔗 测试数据库连接: $DB_USER@$DB_HOST:$DB_PORT/$DB_NAME"

                if timeout 5 mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" -e "SELECT 1;" "$DB_NAME" >/dev/null 2>&1; then
                    log_success "✅ 数据库连接成功"
                else
                    log_error "❌ 数据库连接失败"
                    log_info "请检查数据库服务是否运行以及连接参数是否正确"
                fi
            else
                log_warning "⚠️  DATABASE_URL 格式不正确"
            fi
        else
            log_warning "⚠️  DATABASE_URL 未设置，跳过数据库连接测试"
        fi
    else
        log_warning "⚠️  跳过数据库连接测试 (mysql 客户端未安装)"
    fi

    # 启动后端服务
    log_step "🦀 启动后端服务 (端口 8000)"
    log_info "执行命令: nohup $BACKEND_BINARY > backend.log 2>&1 &"

    if nohup "$BACKEND_BINARY" > backend.log 2>&1 & then
        BACKEND_PID=$!
        echo $BACKEND_PID > backend.pid
        log_success "✅ 后端服务已启动 (PID: $BACKEND_PID)"

        # 等待后端服务启动
        if wait_for_service 8000 "后端服务"; then
            log_success "✅ 后端服务健康检查通过"
        else
            log_error "❌ 后端服务启动失败"
            log_info "📋 查看后端日志:"
            tail -20 backend.log || echo "无法读取后端日志"
            exit 1
        fi
    else
        log_error "❌ 后端服务启动失败"
        exit 1
    fi

    # 启动前端服务
    log_step "🟢 启动前端服务 (端口 3000)"

    FRONTEND_CMD="node server.js"
    if [ -f "frontend/server.js" ]; then
        cd frontend
        FRONTEND_CMD="node server.js"
    fi

    log_info "当前目录: $(pwd)"
    log_info "执行命令: nohup $FRONTEND_CMD > ../frontend.log 2>&1 &"

    if nohup $FRONTEND_CMD > ../frontend.log 2>&1 & then
        FRONTEND_PID=$!
        echo $FRONTEND_PID > ../frontend.pid
        cd "$DEPLOY_DIR"  # 切换回部署目录
        log_success "✅ 前端服务已启动 (PID: $FRONTEND_PID)"

        # 等待前端服务启动
        if wait_for_service 3000 "前端服务"; then
            log_success "✅ 前端服务健康检查通过"
        else
            log_error "❌ 前端服务启动失败"
            log_info "📋 查看前端日志:"
            tail -20 frontend.log || echo "无法读取前端日志"

            # 尝试清理
            if [ -f frontend.pid ]; then
                kill $(cat frontend.pid) 2>/dev/null || true
                rm frontend.pid
            fi
            if [ -f backend.pid ]; then
                kill $(cat backend.pid) 2>/dev/null || true
                rm backend.pid
            fi
            exit 1
        fi
    else
        log_error "❌ 前端服务启动失败"
        # 清理后端进程
        if [ -f backend.pid ]; then
            kill $(cat backend.pid) 2>/dev/null || true
            rm backend.pid
        fi
        exit 1
    fi

    # 启动成功
    echo -e "\n${GREEN}"
    echo "🎉 PortfolioPulse 启动成功!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 服务状态:"
    echo "  🦀 后端服务: 运行中 (PID: $BACKEND_PID) - http://localhost:8000"
    echo "  🟢 前端服务: 运行中 (PID: $FRONTEND_PID) - http://localhost:3000"
    echo ""
    echo "🌐 访问地址: http://localhost:3000"
    echo "📋 管理命令:"
    echo "  查看状态: ./status.sh"
    echo "  停止服务: ./stop.sh"
    echo "  查看日志: tail -f backend.log frontend.log"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${NC}"

    # 显示实时日志提示
    log_info "💡 提示: 使用以下命令查看实时日志:"
    echo "  后端日志: tail -f backend.log"
    echo "  前端日志: tail -f frontend.log"
    echo "  所有日志: tail -f backend.log frontend.log"
}

# 错误处理
trap 'log_error "脚本执行过程中发生错误，正在退出..."; exit 1' ERR

# 执行主函数
main "$@"
