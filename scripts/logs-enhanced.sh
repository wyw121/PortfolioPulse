#!/bin/bash

# PortfolioPulse 日志监控脚本
# 用途: 实时监控服务日志，提供彩色输出和错误高亮

# ANSI 颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# 高亮关键词函数
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

        # 高亮错误关键词
        if echo "$line" | grep -qiE "(error|err|fail|panic|exception|fatal)"; then
            colored_line=$(echo "$line" | sed -E "s/(error|err|fail|panic|exception|fatal)/${RED}&${NC}/gi")
        # 高亮警告关键词
        elif echo "$line" | grep -qiE "(warn|warning|caution)"; then
            colored_line=$(echo "$line" | sed -E "s/(warn|warning|caution)/${YELLOW}&${NC}/gi")
        # 高亮成功关键词
        elif echo "$line" | grep -qiE "(success|ok|done|complete|ready|started)"; then
            colored_line=$(echo "$line" | sed -E "s/(success|ok|done|complete|ready|started)/${GREEN}&${NC}/gi")
        # 高亮信息关键词
        elif echo "$line" | grep -qiE "(info|debug|trace)"; then
            colored_line=$(echo "$line" | sed -E "s/(info|debug|trace)/${BLUE}&${NC}/gi")
        fi

        # 高亮 HTTP 状态码
        colored_line=$(echo "$colored_line" | sed -E "s/([2][0-9][0-9])/${GREEN}&${NC}/g")  # 2xx 成功
        colored_line=$(echo "$colored_line" | sed -E "s/([3][0-9][0-9])/${YELLOW}&${NC}/g") # 3xx 重定向
        colored_line=$(echo "$colored_line" | sed -E "s/([4][0-9][0-9])/${YELLOW}&${NC}/g") # 4xx 客户端错误
        colored_line=$(echo "$colored_line" | sed -E "s/([5][0-9][0-9])/${RED}&${NC}/g")    # 5xx 服务器错误

        # 高亮 IP 地址
        colored_line=$(echo "$colored_line" | sed -E "s/([0-9]{1,3}\.){3}[0-9]{1,3}/${PURPLE}&${NC}/g")

        # 输出带时间戳的日志行
        echo -e "${GRAY}[$timestamp]${NC} $prefix_color $colored_line"
    done
}

# 检查日志文件是否存在
check_log_files() {
    local backend_log="backend.log"
    local frontend_log="frontend.log"
    local missing_files=()

    if [ ! -f "$backend_log" ]; then
        missing_files+=("$backend_log")
    fi

    if [ ! -f "$frontend_log" ]; then
        missing_files+=("$frontend_log")
    fi

    if [ ${#missing_files[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️  以下日志文件不存在:${NC}"
        for file in "${missing_files[@]}"; do
            echo "   - $file"
        done
        echo ""
        echo -e "${BLUE}💡 提示:${NC}"
        echo "   - 确保服务已启动: ./start.sh"
        echo "   - 或者手动创建日志文件: touch backend.log frontend.log"
        echo ""

        # 询问是否继续
        read -p "是否继续监控现有日志? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# 显示帮助信息
show_help() {
    echo -e "${CYAN}PortfolioPulse 日志监控脚本${NC}"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示此帮助信息"
    echo "  -b, --backend  仅监控后端日志"
    echo "  -f, --frontend 仅监控前端日志"
    echo "  -n, --lines N  显示最后 N 行日志 (默认: 50)"
    echo "  -t, --tail     只跟踪新日志 (不显示历史)"
    echo ""
    echo "示例:"
    echo "  $0                # 监控所有日志"
    echo "  $0 -b            # 仅监控后端日志"
    echo "  $0 -f            # 仅监控前端日志"
    echo "  $0 -n 100        # 显示最后 100 行"
    echo "  $0 -t            # 仅跟踪新日志"
    echo ""
    echo "快捷键:"
    echo "  Ctrl+C  退出监控"
    echo "  Ctrl+Z  暂停监控 (使用 fg 恢复)"
}

# 解析命令行参数
parse_args() {
    MONITOR_BACKEND=true
    MONITOR_FRONTEND=true
    LINES=50
    TAIL_ONLY=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -b|--backend)
                MONITOR_BACKEND=true
                MONITOR_FRONTEND=false
                shift
                ;;
            -f|--frontend)
                MONITOR_BACKEND=false
                MONITOR_FRONTEND=true
                shift
                ;;
            -n|--lines)
                LINES="$2"
                if ! [[ "$LINES" =~ ^[0-9]+$ ]]; then
                    echo -e "${RED}错误: 行数必须是数字${NC}"
                    exit 1
                fi
                shift 2
                ;;
            -t|--tail)
                TAIL_ONLY=true
                shift
                ;;
            *)
                echo -e "${RED}未知选项: $1${NC}"
                echo "使用 -h 或 --help 查看帮助"
                exit 1
                ;;
        esac
    done
}

# 主监控函数
main() {
    # 解析参数
    parse_args "$@"

    # 切换到部署目录
    DEPLOY_DIR="/opt/portfoliopulse"
    if [ -d "$DEPLOY_DIR" ]; then
        cd "$DEPLOY_DIR"
    elif [ -f "backend.log" ] || [ -f "frontend.log" ]; then
        echo -e "${BLUE}[INFO]${NC} 在当前目录监控日志文件"
    else
        echo -e "${RED}[ERROR]${NC} 未找到部署目录或日志文件"
        exit 1
    fi

    # 检查日志文件
    check_log_files

    # 显示监控开始信息
    echo -e "${CYAN}📊 PortfolioPulse 日志监控${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📅 开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "📁 监控目录: $(pwd)"

    if [ "$MONITOR_BACKEND" = true ] && [ "$MONITOR_FRONTEND" = true ]; then
        echo "🔍 监控范围: 后端 + 前端日志"
    elif [ "$MONITOR_BACKEND" = true ]; then
        echo "🔍 监控范围: 仅后端日志"
    else
        echo "🔍 监控范围: 仅前端日志"
    fi

    if [ "$TAIL_ONLY" = true ]; then
        echo "📄 显示模式: 仅新日志"
    else
        echo "📄 显示模式: 最后 $LINES 行 + 新日志"
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GRAY}💡 使用 Ctrl+C 退出监控${NC}"
    echo ""

    # 构建 tail 命令
    local tail_cmd=""
    local tail_options=""

    if [ "$TAIL_ONLY" = true ]; then
        tail_options="-f"
    else
        tail_options="-n $LINES -f"
    fi

    # 根据监控范围构建命令
    if [ "$MONITOR_BACKEND" = true ] && [ "$MONITOR_FRONTEND" = true ]; then
        if [ -f "backend.log" ] && [ -f "frontend.log" ]; then
            # 同时监控两个日志文件
            (tail $tail_options backend.log | highlight_log "backend") &
            (tail $tail_options frontend.log | highlight_log "frontend") &
        elif [ -f "backend.log" ]; then
            tail $tail_options backend.log | highlight_log "backend"
        elif [ -f "frontend.log" ]; then
            tail $tail_options frontend.log | highlight_log "frontend"
        fi
    elif [ "$MONITOR_BACKEND" = true ]; then
        if [ -f "backend.log" ]; then
            tail $tail_options backend.log | highlight_log "backend"
        else
            echo -e "${RED}错误: backend.log 文件不存在${NC}"
            exit 1
        fi
    else
        if [ -f "frontend.log" ]; then
            tail $tail_options frontend.log | highlight_log "frontend"
        else
            echo -e "${RED}错误: frontend.log 文件不存在${NC}"
            exit 1
        fi
    fi

    # 等待用户中断
    wait
}

# 信号处理
cleanup() {
    echo -e "\n${YELLOW}📊 日志监控已停止${NC}"
    echo "📅 结束时间: $(date '+%Y-%m-%d %H:%M:%S')"

    # 终止所有子进程
    jobs -p | xargs -r kill 2>/dev/null

    exit 0
}

# 捕获中断信号
trap cleanup SIGINT SIGTERM

# 执行主函数
main "$@"
