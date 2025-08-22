#!/bin/bash
# PortfolioPulse 停止脚本

echo "🛑 停止 PortfolioPulse 服务..."

# 停止前端
if [ -f frontend.pid ]; then
    FRONTEND_PID=$(cat frontend.pid)
    if ps -p $FRONTEND_PID > /dev/null; then
        kill $FRONTEND_PID
        echo "✅ 前端服务已停止 (PID: $FRONTEND_PID)"
    else
        echo "⚠️  前端服务已不在运行"
    fi
    rm -f frontend.pid
fi

# 停止后端
if [ -f backend.pid ]; then
    BACKEND_PID=$(cat backend.pid)
    if ps -p $BACKEND_PID > /dev/null; then
        kill $BACKEND_PID
        echo "✅ 后端服务已停止 (PID: $BACKEND_PID)"
    else
        echo "⚠️  后端服务已不在运行"
    fi
    rm -f backend.pid
fi

echo "🎉 PortfolioPulse 已完全停止!"
