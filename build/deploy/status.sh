#!/bin/bash
# PortfolioPulse 状态检查脚本

echo "📊 PortfolioPulse 服务状态"
echo "=========================="

# 检查后端状态
if [ -f backend.pid ]; then
    BACKEND_PID=$(cat backend.pid)
    if ps -p $BACKEND_PID > /dev/null; then
        echo "🦀 后端服务: ✅ 运行中 (PID: $BACKEND_PID)"
        echo "   端口: 8000"
        echo "   日志: tail -f backend.log"
    else
        echo "🦀 后端服务: ❌ 已停止 (PID 文件存在但进程不存在)"
    fi
else
    echo "🦀 后端服务: ❌ 未启动"
fi

# 检查前端状态
if [ -f frontend.pid ]; then
    FRONTEND_PID=$(cat frontend.pid)
    if ps -p $FRONTEND_PID > /dev/null; then
        echo "🟢 前端服务: ✅ 运行中 (PID: $FRONTEND_PID)"
        echo "   端口: 3000"
        echo "   日志: tail -f frontend.log"
    else
        echo "🟢 前端服务: ❌ 已停止 (PID 文件存在但进程不存在)"
    fi
else
    echo "🟢 前端服务: ❌ 未启动"
fi

echo ""
echo "🌐 访问地址:"
echo "   前端: http://localhost:3000"
echo "   后端: http://localhost:8000"

# 检查端口占用
echo ""
echo "📡 端口占用情况:"
if command -v netstat >/dev/null 2>&1; then
    echo "端口 3000:" $(netstat -tlpn 2>/dev/null | grep :3000 || echo "未占用")
    echo "端口 8000:" $(netstat -tlpn 2>/dev/null | grep :8000 || echo "未占用")
else
    echo "netstat 命令不可用，无法检查端口占用"
fi
