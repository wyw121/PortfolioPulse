#!/bin/bash

# PortfolioPulse 增强脚本部署工具
# 用途: 将增强的启动/停止/监控脚本部署到服务器

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

# 创建增强启动脚本内容
create_enhanced_start_script() {
    cat > "$1" << 'EOL'
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

# 主启动函数
main() {
    echo -e "${CYAN}"
    echo "🚀 PortfolioPulse 增强启动脚本"
    echo "📅 启动时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "🏷️  版本: 1.0 Enhanced Debug"
    echo -e "${NC}"

    # 记录启动时间戳
    date +%s > .startup_time

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

    # 加载环境变量
    log_step "🌐 环境变量检查"
    if [ -f ".env" ]; then
        log_info "📂 加载环境变量..."
        set -a  # 自动导出变量
        source .env
        set +a
        log_success "✅ 已加载环境变量"
    else
        log_warning "⚠️  .env 文件不存在，使用默认配置"
    fi

    export NODE_ENV=production
    export PORT=3000

    # 文件存在性检查
    log_step "📁 文件检查"
    files_ok=true

    # 检查后端二进制文件
    BACKEND_BINARY=""
    for possible_name in "portfolio_pulse_backend" "portfolio_pulse" "backend"; do
        if [ -f "./$possible_name" ]; then
            BACKEND_BINARY="./$possible_name"
            break
        fi
    done

    if [ -z "$BACKEND_BINARY" ]; then
        log_error "❌ 后端二进制文件未找到"
        echo "查找的路径:"
        echo "  - ./portfolio_pulse_backend"
        echo "  - ./portfolio_pulse"
        echo "  - ./backend"
        files_ok=false
    else
        check_file "$BACKEND_BINARY" || files_ok=false
    fi

    # 检查前端文件
    FRONTEND_DIR="."
    if [ -f "server.js" ]; then
        log_success "✅ 前端服务器文件: server.js"
    elif [ -f "frontend/server.js" ]; then
        log_success "✅ 前端服务器文件: frontend/server.js"
        FRONTEND_DIR="frontend"
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

    local original_dir=$(pwd)
    cd "$FRONTEND_DIR"
    log_info "当前目录: $(pwd)"
    log_info "执行命令: nohup node server.js > ../frontend.log 2>&1 &"

    if nohup node server.js > ../frontend.log 2>&1 & then
        FRONTEND_PID=$!
        echo $FRONTEND_PID > ../frontend.pid
        cd "$original_dir"
        log_success "✅ 前端服务已启动 (PID: $FRONTEND_PID)"

        # 等待前端服务启动
        if wait_for_service 3000 "前端服务"; then
            log_success "✅ 前端服务健康检查通过"
        else
            log_error "❌ 前端服务启动失败"
            log_info "📋 查看前端日志:"
            tail -20 frontend.log || echo "无法读取前端日志"

            # 清理进程
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
    echo "  监控日志: ./logs.sh"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${NC}"
}

# 错误处理
trap 'log_error "脚本执行过程中发生错误，正在退出..."; exit 1' ERR

# 执行主函数
main "$@"
EOL
}

# 主部署函数
main() {
    echo -e "${CYAN}"
    echo "🚀 PortfolioPulse 增强脚本部署工具"
    echo "📅 部署时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${NC}"

    # 检查部署目录
    DEPLOY_DIR="/opt/portfoliopulse"

    if [ "$1" = "local" ]; then
        # 本地测试模式
        DEPLOY_DIR="./deploy-test"
        log_info "🧪 本地测试模式，部署到: $DEPLOY_DIR"
        mkdir -p "$DEPLOY_DIR"
    else
        if [ ! -d "$DEPLOY_DIR" ]; then
            log_error "❌ 部署目录不存在: $DEPLOY_DIR"
            echo "请先确保 PortfolioPulse 已正确部署到服务器"
            exit 1
        fi

        if [ ! -w "$DEPLOY_DIR" ]; then
            log_error "❌ 没有写入权限: $DEPLOY_DIR"
            echo "请使用 sudo 运行此脚本或检查目录权限"
            exit 1
        fi
    fi

    cd "$DEPLOY_DIR"
    log_success "✅ 切换到部署目录: $DEPLOY_DIR"

    # 备份现有脚本
    log_info "📦 备份现有脚本..."
    if [ -f "start.sh" ] || [ -f "stop.sh" ] || [ -f "status.sh" ]; then
        local backup_dir="scripts_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"

        for script in start.sh stop.sh status.sh logs.sh; do
            if [ -f "$script" ]; then
                cp "$script" "$backup_dir/"
                log_success "✅ 已备份: $script -> $backup_dir/"
            fi
        done
    fi

    # 创建增强启动脚本
    log_info "📝 创建增强启动脚本..."
    create_enhanced_start_script "start.sh"
    chmod +x start.sh
    log_success "✅ start.sh 创建完成"

    # 创建增强停止脚本
    log_info "📝 创建增强停止脚本..."
    cat > "stop.sh" << 'EOL'
#!/bin/bash

# PortfolioPulse 增强停止脚本
# 用途: 安全停止所有服务并清理资源

# ANSI 颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

stop_service() {
    local pid_file=$1
    local service_name=$2

    log_step "停止 $service_name"

    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        log_info "发现 PID 文件: $pid_file (PID: $pid)"

        if kill -0 "$pid" 2>/dev/null; then
            log_info "正在停止进程 $pid..."

            # 优雅关闭
            if kill -TERM "$pid" 2>/dev/null; then
                log_info "已发送 SIGTERM 信号"

                # 等待进程优雅退出
                local wait_count=0
                while [ $wait_count -lt 10 ]; do
                    if ! kill -0 "$pid" 2>/dev/null; then
                        log_success "✅ $service_name 已优雅停止"
                        rm -f "$pid_file"
                        return 0
                    fi
                    echo -n "."
                    sleep 1
                    wait_count=$((wait_count + 1))
                done

                # 强制关闭
                log_warning "⚠️  优雅停止超时，强制结束进程..."
                if kill -KILL "$pid" 2>/dev/null; then
                    log_success "✅ $service_name 已强制停止"
                    rm -f "$pid_file"
                    return 0
                fi
            fi
        else
            log_warning "⚠️  进程 $pid 不存在，清理 PID 文件"
            rm -f "$pid_file"
            return 0
        fi
    else
        log_info "✅ $service_name 未运行"
        return 0
    fi
}

main() {
    echo -e "${CYAN}"
    echo "🛑 PortfolioPulse 服务停止"
    echo "📅 停止时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${NC}"

    local stop_start_time=$(date +%s)

    # 停止服务
    stop_service "frontend.pid" "前端服务"
    stop_service "backend.pid" "后端服务"

    # 等待进程完全退出
    log_info "⏳ 等待进程完全退出..."
    sleep 2

    # 清理临时文件
    log_step "清理临时文件"
    for file in *.pid *.lock .startup_time; do
        if [ -f "$file" ]; then
            rm -f "$file"
            log_info "🗑️  已删除: $file"
        fi
    done

    local stop_end_time=$(date +%s)
    local stop_duration=$((stop_end_time - stop_start_time))

    echo -e "\n${GREEN}✅ 所有服务已停止${NC}"
    echo "⏱️  停止耗时: ${stop_duration}秒"
    echo ""
    echo "💡 管理命令:"
    echo "  启动服务: ./start.sh"
    echo "  检查状态: ./status.sh"
    echo "  监控日志: ./logs.sh"
}

main "$@"
EOL

    chmod +x stop.sh
    log_success "✅ stop.sh 创建完成"

    # 创建状态检查脚本
    log_info "📝 创建状态检查脚本..."
    cat > "status.sh" << 'EOL'
#!/bin/bash

# PortfolioPulse 状态检查脚本

# ANSI 颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

check_service() {
    local pid_file=$1
    local service_name=$2
    local port=$3

    echo -e "\n${CYAN}▶ $service_name 状态检查${NC}"

    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "${GREEN}✅ 进程运行中 (PID: $pid)${NC}"

            # 检查端口
            if netstat -tulpn 2>/dev/null | grep -q ":$port "; then
                echo -e "${GREEN}✅ 端口 $port 监听中${NC}"
            else
                echo -e "${YELLOW}⚠️  端口 $port 未监听${NC}"
            fi

            # HTTP 检查
            if curl -s "http://localhost:$port" >/dev/null 2>&1; then
                echo -e "${GREEN}✅ HTTP 响应正常${NC}"
            else
                echo -e "${YELLOW}⚠️  HTTP 无响应${NC}"
            fi

            return 0
        else
            echo -e "${RED}❌ 进程不存在 (PID: $pid)${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ PID 文件不存在${NC}"
        return 1
    fi
}

echo -e "${CYAN}📊 PortfolioPulse 状态检查${NC}"
echo "📅 检查时间: $(date '+%Y-%m-%d %H:%M:%S')"

backend_status=0
frontend_status=0

check_service "backend.pid" "后端服务" "8000" || backend_status=1
check_service "frontend.pid" "前端服务" "3000" || frontend_status=1

echo -e "\n${CYAN}📋 状态总结${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $backend_status -eq 0 ] && [ $frontend_status -eq 0 ]; then
    echo -e "${GREEN}✅ 所有服务正常运行${NC}"
    echo "🌐 访问地址: http://localhost:3000"
else
    echo -e "${YELLOW}⚠️  部分或全部服务未运行${NC}"
    echo "🔧 请使用 ./start.sh 启动服务"
fi
EOL

    chmod +x status.sh
    log_success "✅ status.sh 创建完成"

    # 创建日志监控脚本
    log_info "📝 创建日志监控脚本..."
    cat > "logs.sh" << 'EOL'
#!/bin/bash

# PortfolioPulse 日志监控脚本

# ANSI 颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

highlight_log() {
    local log_type=$1
    local prefix_color=""

    case $log_type in
        "backend")
            prefix_color="${CYAN}[后端]${NC}"
            ;;
        "frontend")
            prefix_color="${GREEN}[前端]${NC}"
            ;;
    esac

    while IFS= read -r line; do
        local colored_line="$line"
        local timestamp=$(date '+%H:%M:%S')

        # 高亮错误
        if echo "$line" | grep -qiE "(error|err|fail|panic|exception)"; then
            colored_line=$(echo "$line" | sed -E "s/(error|err|fail|panic|exception)/${RED}&${NC}/gi")
        # 高亮警告
        elif echo "$line" | grep -qiE "(warn|warning)"; then
            colored_line=$(echo "$line" | sed -E "s/(warn|warning)/${YELLOW}&${NC}/gi")
        # 高亮成功
        elif echo "$line" | grep -qiE "(success|ok|done|ready|started)"; then
            colored_line=$(echo "$line" | sed -E "s/(success|ok|done|ready|started)/${GREEN}&${NC}/gi")
        fi

        echo -e "[${timestamp}] $prefix_color $colored_line"
    done
}

echo -e "${CYAN}📊 PortfolioPulse 日志监控${NC}"
echo "📅 开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "💡 使用 Ctrl+C 退出监控"
echo ""

# 检查日志文件
if [ ! -f "backend.log" ] && [ ! -f "frontend.log" ]; then
    echo -e "${RED}❌ 未找到日志文件${NC}"
    echo "请确保服务已启动: ./start.sh"
    exit 1
fi

# 监控日志
if [ -f "backend.log" ] && [ -f "frontend.log" ]; then
    (tail -f backend.log | highlight_log "backend") &
    (tail -f frontend.log | highlight_log "frontend") &
elif [ -f "backend.log" ]; then
    tail -f backend.log | highlight_log "backend"
elif [ -f "frontend.log" ]; then
    tail -f frontend.log | highlight_log "frontend"
fi

# 等待中断
wait
EOL

    chmod +x logs.sh
    log_success "✅ logs.sh 创建完成"

    # 验证脚本
    log_info "🔍 验证脚本..."
    local all_good=true

    for script in start.sh stop.sh status.sh logs.sh; do
        if [ -f "$script" ] && [ -x "$script" ]; then
            log_success "✅ $script 就绪"
        else
            log_error "❌ $script 创建失败"
            all_good=false
        fi
    done

    if [ "$all_good" = true ]; then
        echo -e "\n${GREEN}"
        echo "🎉 增强脚本部署完成!"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📁 部署位置: $DEPLOY_DIR"
        echo "📜 可用脚本:"
        echo "  🚀 ./start.sh  - 增强启动脚本 (详细诊断)"
        echo "  🛑 ./stop.sh   - 优雅停止脚本"
        echo "  📊 ./status.sh - 服务状态检查"
        echo "  📄 ./logs.sh   - 实时日志监控"
        echo ""
        echo "🔧 快速使用:"
        echo "  启动服务: ./start.sh"
        echo "  检查状态: ./status.sh"
        echo "  监控日志: ./logs.sh"
        echo "  停止服务: ./stop.sh"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo -e "${NC}"

        if [ "$1" != "local" ]; then
            echo -e "${BLUE}💡 现在可以使用以下命令启动服务:${NC}"
            echo "cd $DEPLOY_DIR && ./start.sh"
        fi
    else
        log_error "❌ 部分脚本创建失败，请检查权限和磁盘空间"
        exit 1
    fi
}

# 执行主函数
main "$@"
