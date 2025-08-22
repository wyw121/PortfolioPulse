#!/bin/bash
# PortfolioPulse 启动脚本 - Ubuntu 22.04

set -e

echo "🚀 启动 PortfolioPulse..."

# 检查必要的文件
if [ ! -f "portfolio_pulse_backend" ]; then
    echo "❌ 后端二进制文件不存在"
    exit 1
fi

if [ ! -f "server.js" ]; then
    echo "❌ 前端服务器文件不存在"
    exit 1
fi

# 设置环境变量
export NODE_ENV=production
export PORT=3000

# 如果存在 .env 文件，加载它
if [ -f ".env" ]; then
    source .env
    echo "✅ 已加载环境变量"
fi

# 给后端二进制文件添加执行权限
chmod +x portfolio_pulse_backend

# 启动后端服务
echo "🦀 启动后端服务 (端口 8000)..."
nohup ./portfolio_pulse_backend > backend.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > backend.pid

# 等待后端启动
echo "⏳ 等待后端服务启动..."
sleep 5

# 检查后端是否启动成功
if ps -p $BACKEND_PID > /dev/null; then
    echo "✅ 后端服务启动成功 (PID: $BACKEND_PID)"
else
    echo "❌ 后端服务启动失败"
    exit 1
fi

# 启动前端服务
echo "🟢 启动前端服务 (端口 3000)..."
nohup node server.js > frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > frontend.pid

# 等待前端启动
sleep 3

# 检查前端是否启动成功
if ps -p $FRONTEND_PID > /dev/null; then
    echo "✅ 前端服务启动成功 (PID: $FRONTEND_PID)"
else
    echo "❌ 前端服务启动失败"
    kill $BACKEND_PID 2>/dev/null || true
    exit 1
fi

echo ""
echo "🎉 PortfolioPulse 启动成功!"
echo "📊 服务状态:"
echo "   🦀 后端: http://localhost:8000 (PID: $BACKEND_PID)"
echo "   🟢 前端: http://localhost:3000 (PID: $FRONTEND_PID)"
echo "📋 管理命令:"
echo "   停止服务: ./stop.sh"
echo "   查看日志: tail -f backend.log 或 tail -f frontend.log"
echo "   检查状态: ./status.sh"
