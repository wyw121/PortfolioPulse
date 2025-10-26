#!/bin/bash
# Next.js Standalone 停止脚本

echo "正在停止 PortfolioPulse Frontend..."

# 查找并终止进程
PID=$(lsof -t -i:3000)
if [ -z "$PID" ]; then
    echo "未找到运行在端口 3000 的进程"
else
    kill $PID
    echo "已停止进程 (PID: $PID)"
fi
