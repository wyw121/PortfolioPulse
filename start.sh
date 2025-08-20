#!/bin/bash
# PortfolioPulse 前后端完整启动脚本
# 公网IP: 43.138.183.31

echo "🚀 启动 PortfolioPulse 完整服务..."
echo "🌐 公网IP: 43.138.183.31"
echo "=================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置变量
PUBLIC_IP="43.138.183.31"
BACKEND_PORT=8000
FRONTEND_PORT=3000

# 错误处理函数
error_exit() {
    echo -e "${RED}❌ 错误: $1${NC}"
    exit 1
}

# 成功消息函数
success_msg() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 信息消息函数
info_msg() {
    echo -e "${CYAN}📋 $1${NC}"
}

# 检查端口是否被占用
check_port() {
    local port=$1
    local service=$2
    if netstat -tulpn | grep -q ":$port "; then
        echo -e "${YELLOW}⚠️  端口 $port 已被占用 ($service)${NC}"
        echo "占用进程:"
        netstat -tulpn | grep ":$port "
        echo "是否要终止占用进程? (y/n)"
        read -r answer
        if [[ $answer =~ ^[Yy]$ ]]; then
            sudo fuser -k $port/tcp 2>/dev/null || true
            sleep 2
        else
            error_exit "端口 $port 被占用，无法启动 $service"
        fi
    fi
}

# 停止现有服务
stop_existing_services() {
    info_msg "停止现有服务..."

    # 停止后端
    if [ -f "backend.pid" ]; then
        local backend_pid=$(cat backend.pid)
        if kill -0 "$backend_pid" 2>/dev/null; then
            echo "停止后端服务 (PID: $backend_pid)"
            kill "$backend_pid" 2>/dev/null || true
            sleep 2
        fi
        rm -f backend.pid
    fi

    # 停止前端
    if [ -f "frontend.pid" ]; then
        local frontend_pid=$(cat frontend.pid)
        if kill -0 "$frontend_pid" 2>/dev/null; then
            echo "停止前端服务 (PID: $frontend_pid)"
            kill "$frontend_pid" 2>/dev/null || true
            sleep 2
        fi
        rm -f frontend.pid
    fi

    # 停止可能的PM2进程
    if command -v pm2 >/dev/null 2>&1; then
        pm2 delete all 2>/dev/null || true
    fi
}

# 验证数据库连接
verify_database() {
    info_msg "验证数据库连接..."

    # 检查MySQL服务
    if ! systemctl is-active --quiet mysql; then
        echo "启动MySQL服务..."
        sudo systemctl start mysql || error_exit "无法启动MySQL服务"
    fi

    # 测试数据库连接
    if ! mysql -u root -e "USE portfolio_pulse;" 2>/dev/null; then
        echo "创建数据库..."
        mysql -u root -e "CREATE DATABASE IF NOT EXISTS portfolio_pulse CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" || error_exit "无法创建数据库"
    fi

    success_msg "数据库连接正常"
}

# 启动后端服务
start_backend() {
    info_msg "启动后端服务..."

    # 检查后端二进制文件
    BACKEND_BINARY=""
    for possible_name in "portfolio_pulse_backend" "portfolio_pulse" "backend"; do
        if [ -f "./$possible_name" ]; then
            BACKEND_BINARY="./$possible_name"
            break
        fi
    done

    if [ -z "$BACKEND_BINARY" ]; then
        error_exit "后端二进制文件未找到 (portfolio_pulse_backend)"
    fi

    # 设置执行权限
    chmod +x "$BACKEND_BINARY"

    # 设置环境变量
    export DATABASE_URL="mysql://root:@localhost:3306/portfolio_pulse"
    export RUST_LOG=info
    export SERVER_HOST="0.0.0.0"
    export SERVER_PORT=$BACKEND_PORT
    export PUBLIC_URL="http://${PUBLIC_IP}:${BACKEND_PORT}"

    # 启动后端
    echo "🦀 启动后端服务 (端口 $BACKEND_PORT)..."
    nohup "$BACKEND_BINARY" > backend.log 2>&1 &
    BACKEND_PID=$!
    echo $BACKEND_PID > backend.pid

    # 等待后端启动
    echo "⏳ 等待后端启动..."
    sleep 5

    # 检查后端是否启动成功
    if kill -0 "$BACKEND_PID" 2>/dev/null; then
        success_msg "后端服务已启动 (PID: $BACKEND_PID)"

        # 健康检查
        for i in {1..10}; do
            if curl -f "http://localhost:$BACKEND_PORT" >/dev/null 2>&1; then
                success_msg "后端健康检查通过"
                return 0
            fi
            echo -n "."
            sleep 1
        done

        echo -e "\n${YELLOW}⚠️  后端可能仍在初始化中${NC}"
    else
        error_exit "后端启动失败，查看日志: tail -f backend.log"
    fi
}

# 启动前端服务
start_frontend() {
    info_msg "启动前端服务..."

    # 检查前端文件
    if [ -f "server.js" ]; then
        FRONTEND_DIR="."
        FRONTEND_SCRIPT="server.js"
    elif [ -f "frontend/server.js" ]; then
        FRONTEND_DIR="frontend"
        FRONTEND_SCRIPT="server.js"
    elif [ -f "package.json" ]; then
        FRONTEND_DIR="."
        FRONTEND_SCRIPT="npm start"
    else
        echo -e "${YELLOW}⚠️  前端文件未找到，跳过前端启动${NC}"
        return 0
    fi

    # 设置前端环境变量
    export NODE_ENV=production
    export PORT=$FRONTEND_PORT
    export HOSTNAME="0.0.0.0"
    export NEXT_PUBLIC_API_URL="http://${PUBLIC_IP}:${BACKEND_PORT}"
    export BACKEND_URL="http://localhost:${BACKEND_PORT}"

    # 启动前端
    echo "🟢 启动前端服务 (端口 $FRONTEND_PORT)..."
    cd "$FRONTEND_DIR"

    if [ "$FRONTEND_SCRIPT" = "server.js" ]; then
        nohup node server.js > ../frontend.log 2>&1 &
    else
        nohup npm start > ../frontend.log 2>&1 &
    fi

    FRONTEND_PID=$!
    echo $FRONTEND_PID > ../frontend.pid
    cd - >/dev/null

    # 等待前端启动
    echo "⏳ 等待前端启动..."
    sleep 5

    # 检查前端是否启动成功
    if kill -0 "$FRONTEND_PID" 2>/dev/null; then
        success_msg "前端服务已启动 (PID: $FRONTEND_PID)"

        # 健康检查
        for i in {1..10}; do
            if curl -f "http://localhost:$FRONTEND_PORT" >/dev/null 2>&1; then
                success_msg "前端健康检查通过"
                return 0
            fi
            echo -n "."
            sleep 1
        done

        echo -e "\n${YELLOW}⚠️  前端可能仍在初始化中${NC}"
    else
        echo -e "${YELLOW}⚠️  前端启动可能失败，查看日志: tail -f frontend.log${NC}"
    fi
}

# 显示服务状态
show_status() {
    echo ""
    echo -e "${GREEN}🎉 PortfolioPulse 启动完成！${NC}"
    echo "=================================="
    echo -e "${CYAN}📊 服务状态:${NC}"

    # 后端状态
    if [ -f "backend.pid" ] && kill -0 "$(cat backend.pid)" 2>/dev/null; then
        echo "  🦀 后端服务: ✅ 运行中 (PID: $(cat backend.pid))"
        echo "     - 本地访问: http://localhost:$BACKEND_PORT"
        echo "     - 公网访问: http://$PUBLIC_IP:$BACKEND_PORT"
    else
        echo "  🦀 后端服务: ❌ 未运行"
    fi

    # 前端状态
    if [ -f "frontend.pid" ] && kill -0 "$(cat frontend.pid)" 2>/dev/null; then
        echo "  🟢 前端服务: ✅ 运行中 (PID: $(cat frontend.pid))"
        echo "     - 本地访问: http://localhost:$FRONTEND_PORT"
        echo "     - 公网访问: http://$PUBLIC_IP:$FRONTEND_PORT"
    else
        echo "  🟢 前端服务: ❌ 未运行"
    fi

    echo ""
    echo -e "${CYAN}🌐 公网访问地址:${NC}"
    echo "  主应用: http://$PUBLIC_IP:$FRONTEND_PORT"
    echo "  API接口: http://$PUBLIC_IP:$BACKEND_PORT"
    echo ""
    echo -e "${CYAN}📋 管理命令:${NC}"
    echo "  查看后端日志: tail -f backend.log"
    echo "  查看前端日志: tail -f frontend.log"
    echo "  停止后端: kill \$(cat backend.pid)"
    echo "  停止前端: kill \$(cat frontend.pid)"
    echo "  查看进程: ps aux | grep portfolio"
    echo "  重启服务: ./start.sh"
    echo ""
    echo -e "${YELLOW}🔒 防火墙提醒:${NC}"
    echo "确保防火墙已开放端口 $BACKEND_PORT 和 $FRONTEND_PORT:"
    echo "  sudo ufw allow $BACKEND_PORT"
    echo "  sudo ufw allow $FRONTEND_PORT"
}

# 主执行流程
main() {
    # 检查权限
    if [ "$EUID" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  建议不要使用root用户运行此脚本${NC}"
    fi

    # 检查端口
    check_port $BACKEND_PORT "后端服务"
    check_port $FRONTEND_PORT "前端服务"

    # 停止现有服务
    stop_existing_services

    # 验证数据库
    verify_database

    # 启动后端
    start_backend

    # 启动前端
    start_frontend

    # 显示状态
    show_status

    # 记录启动时间
    date > .last_startup
}

# 错误处理
trap 'echo -e "\n${RED}❌ 启动过程中发生错误${NC}"; exit 1' ERR

# 执行主函数
main "$@"
