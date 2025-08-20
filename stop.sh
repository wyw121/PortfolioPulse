#!/bin/bash
# PortfolioPulse 服务停止脚本

echo "🛑 停止 PortfolioPulse 服务..."

# 停止后端
if [ -f backend.pid ]; then
    PID=$(cat backend.pid)
    if kill -0 "$PID" 2>/dev/null; then
        echo "停止后端服务 (PID: $PID)"
        kill "$PID" 2>/dev/null || true
        sleep 2
    fi
    rm backend.pid
    echo "✅ 后端服务已停止"
else
    echo "📋 后端服务未运行"
fi

# 停止前端
if [ -f frontend.pid ]; then
    PID=$(cat frontend.pid)
    if kill -0 "$PID" 2>/dev/null; then
        echo "停止前端服务 (PID: $PID)"
        kill "$PID" 2>/dev/null || true
        sleep 2
    fi
    rm frontend.pid
    echo "✅ 前端服务已停止"
else
    echo "📋 前端服务未运行"
fi

# 清理可能遗留的进程
pkill -f portfolio_pulse_backend 2>/dev/null || true
pkill -f "node server.js" 2>/dev/null || true

echo "🎉 所有服务已停止"
