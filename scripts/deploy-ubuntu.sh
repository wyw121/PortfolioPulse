#!/bin/bash

# PortfolioPulse Ubuntu 部署脚本
# 用途: 在 Ubuntu 22.04 服务器上快速部署应用

set -e

echo "======================================"
echo "  PortfolioPulse Ubuntu 部署工具"
echo "======================================"
echo ""

# 检查是否以 root 运行
if [ "$EUID" -eq 0 ]; then 
   echo "⚠ 请不要使用 root 用户运行此脚本"
   exit 1
fi

# 配置变量
APP_NAME="portfoliopulse"
APP_DIR="$HOME/$APP_NAME"
ZIP_FILE="$HOME/portfoliopulse.zip"
PORT=3000

# 步骤 1: 检查 Node.js
echo "[1/6] 检查 Node.js..."
if ! command -v node &> /dev/null; then
    echo "⚠ Node.js 未安装，正在安装..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
else
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 18 ]; then
        echo "⚠ Node.js 版本过低（需要 >= 18.x），正在更新..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt install -y nodejs
    fi
fi

echo "✓ Node.js $(node -v)"
echo "✓ npm $(npm -v)"

# 步骤 2: 检查 PM2
echo "[2/6] 检查 PM2..."
if ! command -v pm2 &> /dev/null; then
    echo "⚠ PM2 未安装，正在安装..."
    sudo npm install -g pm2
fi
echo "✓ PM2 已安装"

# 步骤 3: 检查部署包
echo "[3/6] 检查部署包..."
if [ ! -f "$ZIP_FILE" ]; then
    echo "✖ 错误: 找不到 $ZIP_FILE"
    echo ""
    echo "请先上传部署包:"
    echo "  scp portfoliopulse.zip $(whoami)@$(hostname -I | awk '{print $1}'):~/"
    echo ""
    exit 1
fi
echo "✓ 找到部署包"

# 步骤 4: 备份旧版本
echo "[4/6] 备份旧版本..."
if [ -d "$APP_DIR" ]; then
    BACKUP_DIR="${APP_DIR}.bak.$(date +%Y%m%d_%H%M%S)"
    echo "  备份到: $BACKUP_DIR"
    mv "$APP_DIR" "$BACKUP_DIR"
fi

# 步骤 5: 解压新版本
echo "[5/6] 解压部署包..."
mkdir -p "$APP_DIR"
unzip -q "$ZIP_FILE" -d "$APP_DIR"
echo "✓ 解压完成"

# 检查关键文件
if [ ! -f "$APP_DIR/server.js" ]; then
    echo "✖ 错误: 找不到 server.js，部署包可能损坏"
    exit 1
fi

# 步骤 6: 启动/重启应用
echo "[6/6] 启动应用..."

# 停止旧进程
if pm2 describe $APP_NAME &> /dev/null; then
    echo "  停止旧进程..."
    pm2 delete $APP_NAME
fi

# 启动新进程
cd "$APP_DIR"
pm2 start server.js --name $APP_NAME --time

# 保存 PM2 配置
pm2 save

# 设置开机自启（仅首次需要）
if [ ! -f "$HOME/.pm2-startup-configured" ]; then
    echo "  配置开机自启..."
    PM2_STARTUP=$(pm2 startup | tail -n 1)
    sudo bash -c "$PM2_STARTUP"
    touch "$HOME/.pm2-startup-configured"
fi

# 显示状态
echo ""
echo "======================================"
echo "✓ 部署完成！"
echo "======================================"
echo ""
echo "应用信息:"
echo "  名称: $APP_NAME"
echo "  目录: $APP_DIR"
echo "  端口: $PORT"
echo ""
echo "访问地址:"
echo "  http://$(hostname -I | awk '{print $1}'):$PORT"
echo ""
echo "常用命令:"
echo "  查看状态: pm2 status"
echo "  查看日志: pm2 logs $APP_NAME"
echo "  重启应用: pm2 restart $APP_NAME"
echo "  停止应用: pm2 stop $APP_NAME"
echo ""
echo "正在显示日志（Ctrl+C 退出）..."
sleep 2
pm2 logs $APP_NAME
