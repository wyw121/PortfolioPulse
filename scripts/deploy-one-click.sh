#!/bin/bash

# PortfolioPulse 一键增强脚本部署
# 使用方法: curl -sSL https://raw.githubusercontent.com/your-repo/scripts/deploy-enhanced-scripts.sh | sudo bash

echo "🚀 PortfolioPulse 增强脚本一键部署"
echo "========================================"

# 检查权限
if [ "$EUID" -ne 0 ]; then
    echo "❌ 请使用 sudo 运行此脚本"
    exit 1
fi

# 设置部署目录
DEPLOY_DIR="/opt/portfoliopulse"
if [ ! -d "$DEPLOY_DIR" ]; then
    echo "❌ 部署目录不存在: $DEPLOY_DIR"
    echo "请先确保 PortfolioPulse 已正确部署"
    exit 1
fi

cd "$DEPLOY_DIR"
echo "✅ 切换到部署目录: $DEPLOY_DIR"

# 备份现有脚本
if [ -f "start.sh" ]; then
    cp start.sh start.sh.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ 已备份现有启动脚本"
fi

# 创建增强启动脚本
echo "📝 创建增强启动脚本..."
cat > start.sh << 'ENHANCED_START_SCRIPT'
#!/bin/bash
# PortfolioPulse 增强启动脚本 - 详细调试版本

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

# 检查命令
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        log_success "✅ $1 已安装 ($(which $1))"
        $1 --version 2>/dev/null | head -1 || echo "版本信息获取失败"
        return 0
    else
        log_error "❌ $1 未找到"
        return 1
    fi
}

# 检查端口
check_port() {
    local port=$1
    if netstat -tulpn 2>/dev/null | grep -q ":$port "; then
        log_warning "⚠️  端口 $port 已被占用"
        netstat -tulpn 2>/dev/null | grep ":$port " | head -1
        return 1
    else
        log_success "✅ 端口 $port 可用"
        return 0
    fi
}

# 检查文件
check_file() {
    local file=$1
    if [ -f "$file" ]; then
        if [ -x "$file" ]; then
            log_success "✅ $file 存在且可执行"
        else
            log_warning "⚠️  $file 存在但不可执行，正在修复..."
            chmod +x "$file"
            log_success "✅ 已添加执行权限"
        fi
        ls -la "$file"
        return 0
    else
        log_error "❌ $file 不存在"
        return 1
    fi
}

# 等待服务启动
wait_for_service() {
    local port=$1
    local name=$2
    local max_wait=30

    log_info "⏳ 等待 $name 启动 (端口 $port)..."

    for i in $(seq 1 $max_wait); do
        if curl -s -f "http://localhost:$port" >/dev/null 2>&1; then
            log_success "✅ $name 启动成功 (尝试 $i/$max_wait)"
            return 0
        fi
        echo -n "."
        sleep 1
    done

    log_error "❌ $name 启动超时"
    return 1
}

# 主函数
main() {
    echo -e "${CYAN}"
    echo "🚀 PortfolioPulse 增强启动脚本"
    echo "📅 启动时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "📍 当前目录: $(pwd)"
    echo "👤 当前用户: $(whoami)"
    echo -e "${NC}"

    # 系统信息
    log_step "📋 系统环境检查"
    echo "操作系统: $(uname -a)"
    echo "磁盘使用: $(df -h . | tail -1 | awk '{print $4 " 可用"}')"
    free -h 2>/dev/null | head -2 || log_info "内存信息获取失败"

    # 依赖检查
    log_step "🔧 依赖检查"
    deps_ok=true
    check_command "node" || deps_ok=false
    check_command "curl" || deps_ok=false

    if ! command -v mysql >/dev/null 2>&1; then
        log_warning "⚠️  mysql 客户端未找到，跳过数据库测试"
    else
        check_command "mysql"
    fi

    if [ "$deps_ok" = false ]; then
        log_error "❌ 关键依赖缺失，请先安装 Node.js 和 curl"
        exit 1
    fi

    # 环境变量
    log_step "🌐 环境配置"
    if [ -f ".env" ]; then
        log_success "✅ .env 文件存在"
        source .env
        log_info "环境变量已加载"
    else
        log_warning "⚠️  .env 文件不存在，使用默认配置"
    fi
    export NODE_ENV=production PORT=3000

    # 文件检查
    log_step "📁 应用文件检查"

    # 查找后端二进制文件
    BACKEND_BINARY=""
    for name in "portfolio_pulse_backend" "portfolio_pulse" "backend"; do
        if [ -f "./$name" ]; then
            BACKEND_BINARY="./$name"
            break
        fi
    done

    if [ -z "$BACKEND_BINARY" ]; then
        log_error "❌ 后端二进制文件未找到"
        echo "检查的文件:"
        echo "  - ./portfolio_pulse_backend"
        echo "  - ./portfolio_pulse"
        echo "  - ./backend"
        echo ""
        log_info "当前目录文件列表:"
        ls -la | grep -E "\.(exe|bin|out)?$|^-.*x.*"
        exit 1
    fi

    check_file "$BACKEND_BINARY" || exit 1

    # 查找前端服务文件
    FRONTEND_DIR="."
    if [ -f "server.js" ]; then
        log_success "✅ 前端服务: ./server.js"
    elif [ -f "frontend/server.js" ]; then
        log_success "✅ 前端服务: ./frontend/server.js"
        FRONTEND_DIR="frontend"
    else
        log_error "❌ 前端服务文件未找到"
        echo "检查的文件:"
        echo "  - ./server.js"
        echo "  - ./frontend/server.js"
        exit 1
    fi

    # 端口检查
    log_step "🔌 端口状态检查"
    check_port 8000
    check_port 3000

    # 清理旧进程
    log_step "🧹 清理旧进程"
    if [ -f "backend.pid" ]; then
        old_pid=$(cat backend.pid)
        if kill -0 "$old_pid" 2>/dev/null; then
            log_warning "⚠️  发现旧的后端进程 ($old_pid)，正在停止..."
            kill "$old_pid" 2>/dev/null || true
            sleep 2
        fi
        rm -f backend.pid
    fi

    if [ -f "frontend.pid" ]; then
        old_pid=$(cat frontend.pid)
        if kill -0 "$old_pid" 2>/dev/null; then
            log_warning "⚠️  发现旧的前端进程 ($old_pid)，正在停止..."
            kill "$old_pid" 2>/dev/null || true
            sleep 2
        fi
        rm -f frontend.pid
    fi

    # 启动后端
    log_step "🦀 启动后端服务 (端口 8000)"
    log_info "执行命令: nohup $BACKEND_BINARY > backend.log 2>&1 &"

    if nohup "$BACKEND_BINARY" > backend.log 2>&1 & then
        BACKEND_PID=$!
        echo $BACKEND_PID > backend.pid
        log_success "✅ 后端进程已启动 (PID: $BACKEND_PID)"

        if wait_for_service 8000 "后端服务"; then
            log_success "✅ 后端服务就绪"
        else
            log_error "❌ 后端服务启动失败"
            echo ""
            log_info "📋 后端日志 (最后20行):"
            tail -20 backend.log 2>/dev/null || echo "无法读取日志"

            # 清理
            kill $BACKEND_PID 2>/dev/null || true
            rm -f backend.pid
            exit 1
        fi
    else
        log_error "❌ 后端进程启动失败"
        exit 1
    fi

    # 启动前端
    log_step "🟢 启动前端服务 (端口 3000)"

    cd "$FRONTEND_DIR"
    log_info "当前目录: $(pwd)"
    log_info "执行命令: nohup node server.js > ../frontend.log 2>&1 &"

    if nohup node server.js > ../frontend.log 2>&1 & then
        FRONTEND_PID=$!
        echo $FRONTEND_PID > ../frontend.pid
        cd - >/dev/null
        log_success "✅ 前端进程已启动 (PID: $FRONTEND_PID)"

        if wait_for_service 3000 "前端服务"; then
            log_success "✅ 前端服务就绪"
        else
            log_error "❌ 前端服务启动失败"
            echo ""
            log_info "📋 前端日志 (最后20行):"
            tail -20 frontend.log 2>/dev/null || echo "无法读取日志"

            # 清理所有进程
            kill $FRONTEND_PID 2>/dev/null || true
            kill $BACKEND_PID 2>/dev/null || true
            rm -f frontend.pid backend.pid
            exit 1
        fi
    else
        log_error "❌ 前端进程启动失败"
        kill $BACKEND_PID 2>/dev/null || true
        rm -f backend.pid
        exit 1
    fi

    # 启动成功
    echo ""
    echo -e "${GREEN}"
    echo "🎉 PortfolioPulse 启动完成!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 服务状态:"
    echo "  🦀 后端服务: 运行中 (PID: $BACKEND_PID) - http://localhost:8000"
    echo "  🟢 前端服务: 运行中 (PID: $FRONTEND_PID) - http://localhost:3000"
    echo ""
    echo "🌐 访问地址: http://localhost:3000"
    echo "📋 管理命令:"
    echo "  查看状态: ./status.sh"
    echo "  停止服务: ./stop.sh"
    echo "  查看日志: tail -f *.log"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${NC}"

    # 记录启动时间
    date +%s > .startup_time
}

# 错误处理
trap 'echo -e "\n${RED}❌ 启动过程中发生错误${NC}"; exit 1' ERR

# 执行主函数
main "$@"
ENHANCED_START_SCRIPT

# 创建增强停止脚本
echo "📝 创建增强停止脚本..."
cat > stop.sh << 'ENHANCED_STOP_SCRIPT'
#!/bin/bash
# PortfolioPulse 增强停止脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

stop_service() {
    local pid_file=$1
    local service_name=$2

    echo -e "\n🛑 停止 $service_name"

    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            log_info "正在停止进程 $pid..."

            # 优雅停止
            if kill -TERM "$pid" 2>/dev/null; then
                # 等待优雅退出
                for i in {1..10}; do
                    if ! kill -0 "$pid" 2>/dev/null; then
                        log_success "✅ $service_name 已优雅停止"
                        rm -f "$pid_file"
                        return 0
                    fi
                    echo -n "."
                    sleep 1
                done

                # 强制停止
                log_warning "优雅停止超时，强制结束..."
                kill -KILL "$pid" 2>/dev/null
                log_success "✅ $service_name 已强制停止"
            fi
        else
            log_info "进程不存在，清理PID文件"
        fi
        rm -f "$pid_file"
    else
        log_info "$service_name 未运行"
    fi
}

echo -e "${CYAN}"
echo "🛑 PortfolioPulse 服务停止"
echo "📅 停止时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "${NC}"

stop_service "frontend.pid" "前端服务"
stop_service "backend.pid" "后端服务"

# 清理临时文件
echo -e "\n🧹 清理临时文件"
for file in *.pid *.lock .startup_time; do
    if [ -f "$file" ]; then
        rm -f "$file"
        log_info "已删除: $file"
    fi
done

echo -e "\n${GREEN}✅ 所有服务已停止${NC}"
echo "💡 使用 ./start.sh 重新启动服务"
ENHANCED_STOP_SCRIPT

# 创建状态检查脚本
echo "📝 创建状态检查脚本..."
cat > status.sh << 'ENHANCED_STATUS_SCRIPT'
#!/bin/bash
# PortfolioPulse 状态检查脚本

# 颜色定义
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

    echo -e "\n${CYAN}▶ $service_name 状态${NC}"

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

            # HTTP检查
            if curl -s -f "http://localhost:$port" >/dev/null 2>&1; then
                echo -e "${GREEN}✅ HTTP响应正常${NC}"
                local response_time=$(curl -o /dev/null -s -w "%{time_total}" "http://localhost:$port" 2>/dev/null)
                echo -e "${BLUE}⏱️  响应时间: ${response_time}s${NC}"
            else
                echo -e "${YELLOW}⚠️  HTTP无响应${NC}"
            fi

            # 资源使用
            local cpu_mem=$(ps -p "$pid" -o %cpu,%mem --no-headers 2>/dev/null)
            if [ -n "$cpu_mem" ]; then
                echo -e "${BLUE}📊 资源: CPU ${cpu_mem%% *}%, 内存 ${cpu_mem##* }%${NC}"
            fi

            return 0
        else
            echo -e "${RED}❌ 进程不存在 (PID: $pid)${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ PID文件不存在${NC}"
        return 1
    fi
}

echo -e "${CYAN}📊 PortfolioPulse 状态检查${NC}"
echo "📅 检查时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "📁 当前目录: $(pwd)"

# 系统状态
echo -e "\n${CYAN}🖥️  系统状态${NC}"
echo "负载: $(uptime | awk -F'load average:' '{ print $2 }')"
free -h 2>/dev/null | head -2 || echo "内存信息获取失败"
echo "磁盘: $(df -h . | tail -1 | awk '{print $4 " 可用"}')"

# 服务状态
backend_ok=0
frontend_ok=0

check_service "backend.pid" "后端服务" "8000" || backend_ok=1
check_service "frontend.pid" "前端服务" "3000" || frontend_ok=1

# 日志状态
echo -e "\n${CYAN}📄 日志状态${NC}"
for log in backend.log frontend.log; do
    if [ -f "$log" ]; then
        local size=$(du -h "$log" | cut -f1)
        local lines=$(wc -l < "$log")
        local errors=$(grep -ic "error\|fail" "$log" 2>/dev/null || echo "0")
        echo "$log: $size ($lines 行, $errors 错误)"
    fi
done

# 总结
echo -e "\n${CYAN}📋 状态总结${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $backend_ok -eq 0 ] && [ $frontend_ok -eq 0 ]; then
    echo -e "${GREEN}✅ 所有服务正常运行${NC}"
    echo "🌐 访问地址: http://localhost:3000"
else
    echo -e "${YELLOW}⚠️  部分服务异常${NC}"
    echo "🔧 使用 ./start.sh 重启服务"
fi
ENHANCED_STATUS_SCRIPT

# 添加执行权限
chmod +x start.sh stop.sh status.sh
echo "✅ 已添加执行权限"

# 验证部署
echo ""
echo "🔍 验证部署..."
for script in start.sh stop.sh status.sh; do
    if [ -f "$script" ] && [ -x "$script" ]; then
        echo "✅ $script 已就绪"
    else
        echo "❌ $script 部署失败"
        exit 1
    fi
done

echo ""
echo -e "${GREEN}"
echo "🎉 增强脚本部署完成!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 部署位置: $DEPLOY_DIR"
echo "📜 可用命令:"
echo "  🚀 ./start.sh  - 详细启动脚本"
echo "  🛑 ./stop.sh   - 优雅停止脚本"
echo "  📊 ./status.sh - 状态检查脚本"
echo ""
echo "🚀 现在可以启动服务:"
echo "  cd $DEPLOY_DIR && ./start.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"
