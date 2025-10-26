# Next.js Standalone 部署包打包脚本
# 用途：将构建产物打包成 zip 文件用于服务器部署

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Next.js Standalone 部署包生成工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查构建产物
if (-not (Test-Path ".next/standalone")) {
    Write-Host "错误: 未找到 .next/standalone 目录" -ForegroundColor Red
    Write-Host "请先运行: npm run build" -ForegroundColor Yellow
    exit 1
}

# 创建临时目录
$tempDir = "deploy-temp"
if (Test-Path $tempDir) {
    Remove-Item -Recurse -Force $tempDir
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

Write-Host "📦 正在准备部署文件..." -ForegroundColor Green

# 1. 复制 standalone 目录
Write-Host "  ├─ 复制 standalone 核心文件..."
Copy-Item -Recurse ".next/standalone/*" $tempDir

# 2. 复制静态文件
Write-Host "  ├─ 复制静态资源文件..."
New-Item -ItemType Directory -Force -Path "$tempDir/.next/static" | Out-Null
Copy-Item -Recurse ".next/static/*" "$tempDir/.next/static/"

# 3. 复制 public 文件（如果存在）
if (Test-Path "public") {
    Write-Host "  ├─ 复制 public 目录..."
    New-Item -ItemType Directory -Force -Path "$tempDir/public" | Out-Null
    Copy-Item -Recurse "public/*" "$tempDir/public/"
}

# 4. 创建启动脚本
Write-Host "  ├─ 生成启动脚本..."

# Linux 启动脚本
$startScript = @'
#!/bin/bash
# Next.js Standalone 启动脚本

# 设置环境变量
export NODE_ENV=production
export PORT=3000
export HOSTNAME=0.0.0.0

echo "=========================================="
echo "启动 PortfolioPulse Frontend"
echo "=========================================="
echo "环境: $NODE_ENV"
echo "端口: $PORT"
echo "主机: $HOSTNAME"
echo "=========================================="

# 启动应用
node server.js
'@

$startScript | Out-File -FilePath "$tempDir/start.sh" -Encoding UTF8 -NoNewline

# Linux 停止脚本
$stopScript = @'
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
'@

$stopScript | Out-File -FilePath "$tempDir/stop.sh" -Encoding UTF8 -NoNewline

# systemd 服务文件
$serviceFile = @'
[Unit]
Description=PortfolioPulse Frontend Service
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/portfoliopulse-frontend
Environment=NODE_ENV=production
Environment=PORT=3000
Environment=HOSTNAME=0.0.0.0
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=portfoliopulse-frontend

[Install]
WantedBy=multi-user.target
'@

$serviceFile | Out-File -FilePath "$tempDir/portfoliopulse-frontend.service" -Encoding UTF8 -NoNewline

# 5. 创建 README
Write-Host "  ├─ 生成部署说明..."
$readme = @'
# PortfolioPulse Frontend - 部署说明

## 📦 部署包内容

```
portfoliopulse-frontend/
├── server.js              # Next.js 服务器入口
├── .next/                 # 构建产物
│   ├── static/           # 静态资源
│   └── ...
├── public/               # 公共资源
├── start.sh              # 启动脚本
├── stop.sh               # 停止脚本
├── portfoliopulse-frontend.service  # systemd 服务文件
└── README.md             # 本文件
```

## 🚀 部署步骤

### 1. 上传文件

将 `portfoliopulse-frontend.zip` 上传到服务器 `~/opt/` 目录

### 2. 解压文件

```bash
cd ~/opt
unzip portfoliopulse-frontend.zip
cd portfoliopulse-frontend
```

### 3. 设置权限

```bash
chmod +x start.sh stop.sh
```

### 4. 方式一：直接运行（开发/测试）

```bash
# 启动
./start.sh

# 停止（新终端）
./stop.sh
```

### 5. 方式二：使用 systemd（生产推荐）

```bash
# 复制服务文件
sudo cp portfoliopulse-frontend.service /etc/systemd/system/

# 修改服务文件中的用户和路径
sudo nano /etc/systemd/system/portfoliopulse-frontend.service
# 将 User=www-data 改为你的用户名
# 将 WorkingDirectory=/opt/portfoliopulse-frontend 改为实际路径

# 重载 systemd
sudo systemctl daemon-reload

# 启动服务
sudo systemctl start portfoliopulse-frontend

# 开机自启
sudo systemctl enable portfoliopulse-frontend

# 查看状态
sudo systemctl status portfoliopulse-frontend

# 查看日志
sudo journalctl -u portfoliopulse-frontend -f
```

## 🔧 环境要求

- **Node.js**: >= 18.17.0
- **系统**: Ubuntu 22.04 LTS
- **端口**: 3000（可在启动脚本中修改）

## 🌐 Nginx 反向代理配置（可选）

如果需要通过域名访问，配置 Nginx：

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 📝 常用命令

```bash
# 启动服务
sudo systemctl start portfoliopulse-frontend

# 停止服务
sudo systemctl stop portfoliopulse-frontend

# 重启服务
sudo systemctl restart portfoliopulse-frontend

# 查看状态
sudo systemctl status portfoliopulse-frontend

# 查看实时日志
sudo journalctl -u portfoliopulse-frontend -f

# 查看最近日志
sudo journalctl -u portfoliopulse-frontend -n 100
```

## 🔄 更新部署

1. 停止当前服务
2. 备份旧版本
3. 解压新版本到同一目录
4. 重启服务

```bash
# 停止服务
sudo systemctl stop portfoliopulse-frontend

# 备份（可选）
cp -r /opt/portfoliopulse-frontend /opt/portfoliopulse-frontend.backup

# 解压新版本（覆盖）
cd ~/opt
unzip -o portfoliopulse-frontend.zip

# 重启服务
sudo systemctl start portfoliopulse-frontend
```

## 🐛 故障排查

### 端口被占用

```bash
# 查看端口占用
sudo lsof -i :3000

# 终止进程
sudo kill -9 <PID>
```

### 权限问题

```bash
# 确保文件所有权正确
sudo chown -R $USER:$USER /opt/portfoliopulse-frontend
```

### 查看详细错误

```bash
# 查看服务日志
sudo journalctl -u portfoliopulse-frontend -n 50 --no-pager
```

## 📞 支持

项目地址: https://github.com/wyw121/PortfolioPulse
'@

$readme | Out-File -FilePath "$tempDir/README.md" -Encoding UTF8

# 6. 打包成 zip
Write-Host "  └─ 正在打包..." -ForegroundColor Green

$zipFile = "portfoliopulse-frontend.zip"
if (Test-Path $zipFile) {
    Remove-Item $zipFile
}

Compress-Archive -Path "$tempDir/*" -DestinationPath $zipFile -CompressionLevel Optimal

# 清理临时目录
Remove-Item -Recurse -Force $tempDir

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✅ 部署包生成成功！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "📦 文件位置: $PWD\$zipFile" -ForegroundColor Cyan
Write-Host "📊 文件大小: $([math]::Round((Get-Item $zipFile).Length / 1MB, 2)) MB" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 下一步操作:" -ForegroundColor Yellow
Write-Host "  1. 将 $zipFile 上传到服务器 ~/opt/ 目录" -ForegroundColor White
Write-Host "  2. 在服务器执行:" -ForegroundColor White
Write-Host "     cd ~/opt" -ForegroundColor Gray
Write-Host "     unzip portfoliopulse-frontend.zip" -ForegroundColor Gray
Write-Host "     cd portfoliopulse-frontend" -ForegroundColor Gray
Write-Host "     chmod +x start.sh stop.sh" -ForegroundColor Gray
Write-Host "     ./start.sh" -ForegroundColor Gray
Write-Host ""
Write-Host "📖 详细部署说明请查看压缩包内的 README.md" -ForegroundColor Yellow
Write-Host ""
