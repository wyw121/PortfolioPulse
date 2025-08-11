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

# 停止服务函数
stop_service() {
    local pid_file=$1
    local service_name=$2
    local port=$3

    log_step "停止 $service_name"

    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        log_info "发现 PID 文件: $pid_file (PID: $pid)"

        # 检查进程是否存在
        if kill -0 "$pid" 2>/dev/null; then
            log_info "正在停止进程 $pid..."

            # 优雅关闭 (SIGTERM)
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

                # 强制关闭 (SIGKILL)
                log_warning "⚠️  优雅停止超时，强制结束进程..."
                if kill -KILL "$pid" 2>/dev/null; then
                    log_success "✅ $service_name 已强制停止"
                    rm -f "$pid_file"
                    return 0
                else
                    log_error "❌ 无法停止进程 $pid"
                    return 1
                fi
            else
                log_warning "⚠️  无法发送停止信号给进程 $pid"
                return 1
            fi
        else
            log_warning "⚠️  进程 $pid 不存在，清理 PID 文件"
            rm -f "$pid_file"
            return 0
        fi
    else
        log_info "📄 PID 文件不存在: $pid_file"

        # 尝试通过端口查找进程
        if command -v netstat >/dev/null 2>&1; then
            local port_pid=$(netstat -tulpn 2>/dev/null | grep ":$port " | awk '{print $7}' | cut -d'/' -f1 | head -1)
            if [ -n "$port_pid" ] && [ "$port_pid" != "-" ]; then
                log_warning "⚠️  发现端口 $port 被进程 $port_pid 占用"
                log_info "尝试停止进程 $port_pid..."
                if kill -TERM "$port_pid" 2>/dev/null; then
                    sleep 2
                    if ! kill -0 "$port_pid" 2>/dev/null; then
                        log_success "✅ 通过端口找到的进程已停止"
                        return 0
                    else
                        kill -KILL "$port_pid" 2>/dev/null
                        log_success "✅ 通过端口找到的进程已强制停止"
                        return 0
                    fi
                fi
            fi
        fi

        log_info "✅ $service_name 未运行"
        return 0
    fi
}

# 清理临时文件
cleanup_temp_files() {
    log_step "清理临时文件"

    local cleaned=false

    # 清理 PID 文件
    for pid_file in backend.pid frontend.pid; do
        if [ -f "$pid_file" ]; then
            rm -f "$pid_file"
            log_info "🗑️  已删除: $pid_file"
            cleaned=true
        fi
    done

    # 清理锁文件
    for lock_file in *.lock .portfolio_pulse.lock; do
        if [ -f "$lock_file" ]; then
            rm -f "$lock_file"
            log_info "🗑️  已删除锁文件: $lock_file"
            cleaned=true
        fi
    done

    # 清理临时目录
    for temp_dir in tmp/ temp/ .tmp/; do
        if [ -d "$temp_dir" ]; then
            rm -rf "$temp_dir"
            log_info "🗑️  已删除临时目录: $temp_dir"
            cleaned=true
        fi
    done

    if [ "$cleaned" = false ]; then
        log_info "✅ 无需清理临时文件"
    fi
}

# 检查端口是否已释放
check_ports_released() {
    log_step "检查端口释放状态"

    local all_clear=true

    for port in 3000 8000; do
        if command -v netstat >/dev/null 2>&1; then
            local port_usage=$(netstat -tulpn 2>/dev/null | grep ":$port ")
            if [ -n "$port_usage" ]; then
                log_warning "⚠️  端口 $port 仍被占用:"
                echo "$port_usage" | sed 's/^/   /'
                all_clear=false
            else
                log_success "✅ 端口 $port 已释放"
            fi
        fi
    done

    if [ "$all_clear" = true ]; then
        log_success "✅ 所有端口已释放"
    fi
}

# 显示服务统计
show_service_stats() {
    log_step "显示服务统计信息"

    # 显示日志大小
    if [ -f "backend.log" ]; then
        local backend_size=$(du -h backend.log 2>/dev/null | cut -f1)
        local backend_lines=$(wc -l < backend.log 2>/dev/null)
        echo "🦀 后端日志: $backend_size ($backend_lines 行)"
    fi

    if [ -f "frontend.log" ]; then
        local frontend_size=$(du -h frontend.log 2>/dev/null | cut -f1)
        local frontend_lines=$(wc -l < frontend.log 2>/dev/null)
        echo "🟢 前端日志: $frontend_size ($frontend_lines 行)"
    fi

    # 显示运行时长（如果有时间戳）
    if [ -f ".startup_time" ]; then
        local startup_time=$(cat .startup_time 2>/dev/null)
        local current_time=$(date +%s)
        if [ -n "$startup_time" ] && [[ "$startup_time" =~ ^[0-9]+$ ]]; then
            local uptime=$((current_time - startup_time))
            local hours=$((uptime / 3600))
            local minutes=$(((uptime % 3600) / 60))
            local seconds=$((uptime % 60))
            echo "⏰ 运行时长: ${hours}小时 ${minutes}分钟 ${seconds}秒"
            rm -f .startup_time
        fi
    fi
}

# 主函数
main() {
    echo -e "${CYAN}"
    echo "🛑 PortfolioPulse 服务停止"
    echo "📅 停止时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${NC}"

    # 切换到部署目录
    DEPLOY_DIR="/opt/portfoliopulse"
    if [ -d "$DEPLOY_DIR" ]; then
        cd "$DEPLOY_DIR"
        log_success "✅ 当前目录: $DEPLOY_DIR"
    else
        log_error "❌ 部署目录不存在: $DEPLOY_DIR"
        # 尝试在当前目录查找
        if [ -f "backend.pid" ] || [ -f "frontend.pid" ]; then
            log_info "🔍 在当前目录查找到服务文件"
        else
            exit 1
        fi
    fi

    # 记录开始停止的时间
    local stop_start_time=$(date +%s)

    # 停止服务
    local frontend_result=0
    local backend_result=0

    stop_service "frontend.pid" "前端服务" "3000" || frontend_result=1
    stop_service "backend.pid" "后端服务" "8000" || backend_result=1

    # 等待一段时间确保进程完全退出
    log_info "⏳ 等待进程完全退出..."
    sleep 2

    # 检查端口释放
    check_ports_released

    # 清理临时文件
    cleanup_temp_files

    # 显示统计信息
    show_service_stats

    # 计算停止耗时
    local stop_end_time=$(date +%s)
    local stop_duration=$((stop_end_time - stop_start_time))

    # 总结
    echo -e "\n${CYAN}📋 停止结果总结${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ $frontend_result -eq 0 ] && [ $backend_result -eq 0 ]; then
        echo -e "${GREEN}✅ 所有服务已成功停止${NC}"
    else
        echo -e "${YELLOW}⚠️  部分服务停止时遇到问题${NC}"
        if [ $frontend_result -ne 0 ]; then
            echo "  - 前端服务停止异常"
        fi
        if [ $backend_result -ne 0 ]; then
            echo "  - 后端服务停止异常"
        fi
    fi

    echo "⏱️  停止耗时: ${stop_duration}秒"

    echo -e "\n💡 管理命令:"
    echo "  启动服务: ./start.sh"
    echo "  检查状态: ./status.sh"
    echo "  查看日志: tail -f backend.log frontend.log"

    # 建议日志管理
    if [ -f "backend.log" ] || [ -f "frontend.log" ]; then
        echo -e "\n📄 日志文件管理建议:"
        echo "  备份日志: mkdir -p logs/\$(date +%Y%m%d) && mv *.log logs/\$(date +%Y%m%d)/"
        echo "  清空日志: > backend.log && > frontend.log"
    fi
}

# 错误处理
trap 'log_error "停止脚本执行过程中发生错误"; exit 1' ERR

# 执行主函数
main "$@"
