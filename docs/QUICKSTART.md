# 🚀 快速部署指南

## Windows 端操作（开发机器）

### 一键打包
```powershell
# 进入项目目录
cd D:\repositories\PortfolioPulse

# 运行打包脚本
.\scripts\build-deploy.ps1
```

等待几分钟后，会生成 `portfoliopulse.zip`（约 20-50 MB）

### 上传到服务器
```powershell
# 替换为你的服务器信息
scp portfoliopulse.zip username@your_server_ip:~/
```

---

## Ubuntu 服务器操作

### 方式 1: 使用自动脚本（推荐）

```bash
# SSH 登录服务器
ssh username@your_server_ip

# 上传部署脚本（仅首次需要）
# 在 Windows PowerShell 执行:
# scp scripts/deploy-ubuntu.sh username@your_server_ip:~/

# 添加执行权限
chmod +x ~/deploy-ubuntu.sh

# 运行部署
./deploy-ubuntu.sh
```

脚本会自动完成：
- ✓ 安装 Node.js 18.x
- ✓ 安装 PM2
- ✓ 解压部署包
- ✓ 启动应用
- ✓ 配置开机自启

### 方式 2: 手动部署

```bash
# 1. 安装 Node.js（如果未安装）
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# 2. 安装 PM2
sudo npm install -g pm2

# 3. 解压部署包
mkdir -p ~/portfoliopulse
cd ~/portfoliopulse
unzip ~/portfoliopulse.zip

# 4. 启动应用
pm2 start server.js --name portfoliopulse

# 5. 开机自启
pm2 startup
pm2 save
```

---

## 访问网站

打开浏览器访问:
```
http://your_server_ip:3000
```

---

## 常用命令

```bash
# 查看应用状态
pm2 status

# 查看实时日志
pm2 logs portfoliopulse

# 重启应用
pm2 restart portfoliopulse

# 停止应用
pm2 stop portfoliopulse

# 查看详细信息
pm2 show portfoliopulse
```

---

## 更新部署

当你修改了代码需要更新时：

**Windows 端:**
```powershell
.\scripts\build-deploy.ps1
scp portfoliopulse.zip username@your_server_ip:~/
```

**Ubuntu 端:**
```bash
./deploy-ubuntu.sh
```

---

## 配置域名（可选）

### 安装 Nginx
```bash
sudo apt install -y nginx
```

### 配置反向代理
```bash
sudo nano /etc/nginx/sites-available/portfoliopulse
```

粘贴配置:
```nginx
server {
    listen 80;
    server_name your_domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

启用配置:
```bash
sudo ln -s /etc/nginx/sites-available/portfoliopulse /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 配置 HTTPS
```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your_domain.com
```

---

## 故障排查

### 应用无法访问
```bash
# 检查应用是否运行
pm2 status

# 查看错误日志
pm2 logs portfoliopulse --lines 50

# 检查端口占用
sudo netstat -tulpn | grep :3000
```

### 重新部署
```bash
# 删除旧应用
pm2 delete portfoliopulse
rm -rf ~/portfoliopulse

# 重新运行部署脚本
./deploy-ubuntu.sh
```

---

## 需要帮助？

详细文档: `DEPLOY.md`
