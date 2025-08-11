#!/bin/bash

# PortfolioPulse 状态检查脚本
# 用途: 检查服务状态、性能指标和健康状况

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

# 检查服务状态
check_service_status() {
    local pid_file=$1
    local service_name=$2
    local port=$3

    echo -e "\n${PURPLE}▶${NC} $service_name 状态检查"

    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            log_success "✅ 进程运行中 (PID: $pid)"

            # 检查端口
            if netstat -tulpn 2>/dev/null | grep -q ":$port "; then
                log_success "✅ 端口 $port 监听中"
            else
                log_warning "⚠️  端口 $port 未监听"
            fi

            # HTTP 健康检查
            if curl -s "http://localhost:$port" >/dev/null 2>&1; then
                log_success "✅ HTTP 响应正常"
            else
                log_warning "⚠️  HTTP 无响应"
            fi

            # 进程资源使用
            local cpu_mem=$(ps -p "$pid" -o %cpu,%mem --no-headers 2>/dev/null)
            if [ -n "$cpu_mem" ]; then
                log_info "📊 资源使用: CPU ${cpu_mem%% *}%, 内存 ${cpu_mem##* }%"
            fi

            # 运行时长
            local start_time=$(ps -p "$pid" -o lstart --no-headers 2>/dev/null)
            if [ -n "$start_time" ]; then
                log_info "⏰ 启动时间: $start_time"
            fi

            return 0
        else
            log_error "❌ 进程不存在 (PID: $pid)"
            return 1
        fi
    else
        log_error "❌ PID 文件不存在: $pid_file"
        return 1
    fi
}

# 显示系统状态
show_system_status() {
    echo -e "\n${CYAN}📋 系统状态${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 系统负载
    if command -v uptime >/dev/null 2>&1; then
        echo "🖥️  系统负载: $(uptime)"
    fi

    # 内存使用
    if command -v free >/dev/null 2>&1; then
        echo "🧠 内存使用:"
        free -h | head -2
    fi

    # 磁盘使用
    echo "💾 磁盘使用:"
    df -h / | tail -1

    # 网络连接
    echo "🌐 网络连接:"
    netstat -tulpn 2>/dev/null | grep -E ":(3000|8000|3306) " || echo "  无相关端口监听"
}

# 显示日志摘要
show_log_summary() {
    echo -e "\n${CYAN}📄 日志摘要${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 后端日志
    if [ -f "backend.log" ]; then
        local backend_lines=$(wc -l < backend.log)
        local backend_errors=$(grep -ic "error\|fail\|panic" backend.log 2>/dev/null || echo "0")
        echo "🦀 后端日志: $backend_lines 行, $backend_errors 个错误"

        if [ "$backend_errors" -gt 0 ]; then
            echo "   最近错误:"
            grep -i "error\|fail\|panic" backend.log | tail -3 | sed 's/^/     /'
        fi
    else
        log_warning "⚠️  后端日志文件不存在"
    fi

    # 前端日志
    if [ -f "frontend.log" ]; then
        local frontend_lines=$(wc -l < frontend.log)
        local frontend_errors=$(grep -ic "error\|fail" frontend.log 2>/dev/null || echo "0")
        echo "🟢 前端日志: $frontend_lines 行, $frontend_errors 个错误"

        if [ "$frontend_errors" -gt 0 ]; then
            echo "   最近错误:"
            grep -i "error\|fail" frontend.log | tail -3 | sed 's/^/     /'
        fi
    else
        log_warning "⚠️  前端日志文件不存在"
    fi
}

# 性能检查
check_performance() {
    echo -e "\n${CYAN}⚡ 性能检查${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # HTTP 响应时间测试
    local backend_response_time=$(curl -o /dev/null -s -w "%{time_total}" "http://localhost:8000" 2>/dev/null || echo "超时")
    local frontend_response_time=$(curl -o /dev/null -s -w "%{time_total}" "http://localhost:3000" 2>/dev/null || echo "超时")

    echo "🦀 后端响应时间: ${backend_response_time}s"
    echo "🟢 前端响应时间: ${frontend_response_time}s"

    # 检查进程资源占用
    if [ -f "backend.pid" ] && [ -f "frontend.pid" ]; then
        local backend_pid=$(cat backend.pid)
        local frontend_pid=$(cat frontend.pid)

        echo "📊 资源使用情况:"
        ps -p "$backend_pid,$frontend_pid" -o pid,comm,%cpu,%mem,vsz,rss --no-headers 2>/dev/null | while read line; do
            echo "   $line"
        done
    fi
}

# 主函数
main() {
    echo -e "${CYAN}"
    echo "📊 PortfolioPulse 状态检查"
    echo "📅 检查时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${NC}"

    # 切换到部署目录
    DEPLOY_DIR="/opt/portfoliopulse"
    if [ -d "$DEPLOY_DIR" ]; then
        cd "$DEPLOY_DIR"
        log_success "✅ 当前目录: $DEPLOY_DIR"
    else
        log_error "❌ 部署目录不存在: $DEPLOY_DIR"
        exit 1
    fi

    # 服务状态检查
    local backend_status=0
    local frontend_status=0

    check_service_status "backend.pid" "后端服务" "8000" || backend_status=1
    check_service_status "frontend.pid" "前端服务" "3000" || frontend_status=1

    # 系统状态
    show_system_status

    # 日志摘要
    show_log_summary

    # 性能检查
    check_performance

    # 总结
    echo -e "\n${CYAN}📋 状态总结${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ $backend_status -eq 0 ] && [ $frontend_status -eq 0 ]; then
        echo -e "${GREEN}✅ 所有服务正常运行${NC}"
        echo "🌐 访问地址: http://localhost:3000"
    elif [ $backend_status -eq 0 ]; then
        echo -e "${YELLOW}⚠️  只有后端服务在运行${NC}"
        echo "🔧 请检查前端服务状态"
    elif [ $frontend_status -eq 0 ]; then
        echo -e "${YELLOW}⚠️  只有前端服务在运行${NC}"
        echo "🔧 请检查后端服务状态"
    else
        echo -e "${RED}❌ 所有服务都未运行${NC}"
        echo "🔧 请使用 ./start.sh 启动服务"
    fi

    echo -e "\n💡 管理命令:"
    echo "  启动服务: ./start.sh"
    echo "  停止服务: ./stop.sh"
    echo "  查看日志: tail -f backend.log frontend.log"
}

# 执行主函数
main "$@"
