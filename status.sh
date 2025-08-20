#!/bin/bash
# PortfolioPulse 服务状态检查脚本

echo "📊 PortfolioPulse 服务状态检查"
echo "=================================="
echo "🕒 检查时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "🌐 公网IP: 43.138.183.31"
echo ""

# 检查后端服务
echo "🦀 后端服务状态:"
if [ -f backend.pid ]; then
    PID=$(cat backend.pid)
    if kill -0 "$PID" 2>/dev/null; then
        echo "  ✅ 运行中 (PID: $PID)"
        echo "  📍 本地访问: http://localhost:8000"
        echo "  🌐 公网访问: http://43.138.183.31:8000"

        # 健康检查
        if curl -s -f "http://localhost:8000" >/dev/null 2>&1; then
            echo "  💚 健康检查: 通过"
        else
            echo "  💛 健康检查: 服务可能仍在启动中"
        fi
    else
        echo "  ❌ 进程不存在 (PID文件存在但进程已退出)"
        rm -f backend.pid
    fi
else
    echo "  ❌ 未运行 (无PID文件)"
fi

echo ""

# 检查前端服务
echo "🟢 前端服务状态:"
if [ -f frontend.pid ]; then
    PID=$(cat frontend.pid)
    if kill -0 "$PID" 2>/dev/null; then
        echo "  ✅ 运行中 (PID: $PID)"
        echo "  📍 本地访问: http://localhost:3000"
        echo "  🌐 公网访问: http://43.138.183.31:3000"

        # 健康检查
        if curl -s -f "http://localhost:3000" >/dev/null 2>&1; then
            echo "  💚 健康检查: 通过"
        else
            echo "  💛 健康检查: 服务可能仍在启动中"
        fi
    else
        echo "  ❌ 进程不存在 (PID文件存在但进程已退出)"
        rm -f frontend.pid
    fi
else
    echo "  ❌ 未运行 (无PID文件)"
fi

echo ""

# 检查端口占用
echo "🔌 端口状态:"
if netstat -tulpn 2>/dev/null | grep -E ":(3000|8000|3306) " >/dev/null; then
    netstat -tulpn | grep -E ":(3000|8000|3306) " | while read line; do
        port=$(echo "$line" | grep -oE ":[0-9]+" | head -1 | cut -d: -f2)
        case $port in
            3000) echo "  📍 端口 3000 (前端): 监听中" ;;
            8000) echo "  📍 端口 8000 (后端): 监听中" ;;
            3306) echo "  📍 端口 3306 (MySQL): 监听中" ;;
        esac
    done
else
    echo "  📋 无相关端口监听"
fi

echo ""

# 检查MySQL服务
echo "🗄️ MySQL 数据库状态:"
if systemctl is-active --quiet mysql 2>/dev/null; then
    echo "  ✅ MySQL 服务运行中"

    # 检查数据库
    if mysql -u root -e "USE portfolio_pulse;" 2>/dev/null; then
        echo "  ✅ portfolio_pulse 数据库存在"
    else
        echo "  ⚠️  portfolio_pulse 数据库不存在或连接失败"
    fi
else
    echo "  ❌ MySQL 服务未运行"
fi

echo ""

# 显示日志信息
echo "📋 最新日志 (最后5行):"
if [ -f backend.log ]; then
    echo "  后端日志:"
    tail -5 backend.log | sed 's/^/    /'
else
    echo "  📋 无后端日志文件"
fi

if [ -f frontend.log ]; then
    echo "  前端日志:"
    tail -5 frontend.log | sed 's/^/    /'
else
    echo "  📋 无前端日志文件"
fi

echo ""
echo "🔧 管理命令:"
echo "  启动服务: ./start.sh"
echo "  停止服务: ./stop.sh"
echo "  查看后端日志: tail -f backend.log"
echo "  查看前端日志: tail -f frontend.log"
echo "  重启服务: ./stop.sh && ./start.sh"
