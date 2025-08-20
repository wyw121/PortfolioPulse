#!/bin/bash
# PortfolioPulse 简化启动脚本
# 公网IP: 43.138.183.31

PUBLIC_IP="43.138.183.31"

echo "🚀 启动 PortfolioPulse (公网IP: $PUBLIC_IP)"

# 停止现有服务
[ -f backend.pid ] && kill $(cat backend.pid) 2>/dev/null || true
[ -f frontend.pid ] && kill $(cat frontend.pid) 2>/dev/null || true
rm -f *.pid

# 确保MySQL运行
sudo systemctl start mysql 2>/dev/null || true

# 创建数据库
mysql -u root -e "CREATE DATABASE IF NOT EXISTS portfolio_pulse;" 2>/dev/null || true

# 启动后端
echo "🦀 启动后端 (端口 8000)..."
export DATABASE_URL="mysql://root:@localhost:3306/portfolio_pulse"
export RUST_LOG=info
export SERVER_HOST="0.0.0.0"
export SERVER_PORT=8000

chmod +x portfolio_pulse_backend 2>/dev/null || chmod +x portfolio_pulse 2>/dev/null || true
nohup ./portfolio_pulse_backend > backend.log 2>&1 &
echo $! > backend.pid
echo "✅ 后端已启动 (PID: $(cat backend.pid))"

# 等待后端启动
sleep 3

# 启动前端（如果存在）
if [ -f "server.js" ] || [ -f "frontend/server.js" ]; then
    echo "🟢 启动前端 (端口 3000)..."
    export NODE_ENV=production
    export PORT=3000
    export HOSTNAME="0.0.0.0"
    export NEXT_PUBLIC_API_URL="http://$PUBLIC_IP:8000"

    if [ -f "server.js" ]; then
        nohup node server.js > frontend.log 2>&1 &
    else
        cd frontend && nohup node server.js > ../frontend.log 2>&1 &
        cd ..
    fi
    echo $! > frontend.pid
    echo "✅ 前端已启动 (PID: $(cat frontend.pid))"
fi

# 显示状态
echo ""
echo "🎉 启动完成！"
echo "🌐 访问地址:"
echo "  前端: http://$PUBLIC_IP:3000"
echo "  后端: http://$PUBLIC_IP:8000"
echo ""
echo "📋 管理命令:"
echo "  查看后端日志: tail -f backend.log"
echo "  查看前端日志: tail -f frontend.log"
echo "  停止服务: kill \$(cat backend.pid) && kill \$(cat frontend.pid)"

# 防火墙提醒
echo ""
echo "🔒 确保防火墙开放端口:"
echo "  sudo ufw allow 8000"
echo "  sudo ufw allow 3000"
