# PortfolioPulse 部署指南

## 📋 项目架构确认

**当前架构**: 纯前端项目（Next.js 15）
- ✅ 无后端服务
- ✅ 无数据库
- ✅ 博客内容存储在 Markdown 文件 (`frontend/content/blog/`)
- ✅ 项目数据硬编码在代码中 (`frontend/lib/projects-data.ts`)

## 🚀 部署方案: Ubuntu 22.04

### 方案选择

推荐使用 **Next.js Standalone 模式** + **PM2** 部署：
- 构建体积小（仅包含必要文件）
- 启动速度快
- 进程管理方便
- 无需额外 Web 服务器

---

## 📦 步骤 1: Windows 端构建

### 1.1 修改配置启用 Standalone 输出

编辑 `frontend/next.config.js`：

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',  // ← 添加这一行
  images: {
    domains: ["avatars.githubusercontent.com", "github.com"],
  },
  env: {
    CUSTOM_KEY: "my-value",
  },
  compiler: {
    removeConsole: process.env.NODE_ENV === "production",
  },
  reactStrictMode: true,
  eslint: {
    ignoreDuringBuilds: true,
  },
};

module.exports = nextConfig;
```

### 1.2 构建生产版本

```powershell
# 进入前端目录
cd D:\repositories\PortfolioPulse\frontend

# 安装依赖（如果还没有）
npm install

# 构建
npm run build
```

构建完成后，生成以下目录：
```
frontend/
├── .next/
│   ├── standalone/     ← 可独立运行的 Node.js 应用
│   └── static/         ← 静态资源 (JS/CSS/图片)
├── public/             ← 公共文件
└── content/            ← Markdown 博客文章
```

### 1.3 打包部署文件

```powershell
# 在项目根目录执行

# 创建部署目录
New-Item -ItemType Directory -Force -Path ".\deploy"

# 复制 standalone 应用（这是主体）
Copy-Item -Path ".\frontend\.next\standalone\*" -Destination ".\deploy\" -Recurse

# 复制静态资源（CRITICAL: 必须放到正确位置）
New-Item -ItemType Directory -Force -Path ".\deploy\.next\static"
Copy-Item -Path ".\frontend\.next\static\*" -Destination ".\deploy\.next\static\" -Recurse

# 复制 public 文件夹
Copy-Item -Path ".\frontend\public" -Destination ".\deploy\public" -Recurse

# 复制博客内容
Copy-Item -Path ".\frontend\content" -Destination ".\deploy\content" -Recurse

# 压缩打包
Compress-Archive -Path ".\deploy\*" -DestinationPath "portfoliopulse.zip" -Force
```

现在你得到了 `portfoliopulse.zip` 文件，大小约 20-50 MB。

---

## 🖥️ 步骤 2: Ubuntu 服务器部署

### 2.1 准备服务器环境

```bash
# SSH 登录服务器
ssh your_username@your_server_ip

# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装 Node.js 18.x (Next.js 15 需要)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# 验证安装
node --version  # 应该是 v18.x.x
npm --version

# 安装 PM2 进程管理器
sudo npm install -g pm2
```

### 2.2 上传并解压文件

```bash
# 创建部署目录
mkdir -p ~/portfoliopulse
cd ~/portfoliopulse

# 方式 1: 使用 scp 从 Windows 上传（在 Windows PowerShell 执行）
scp D:\repositories\PortfolioPulse\portfoliopulse.zip your_username@your_server_ip:~/portfoliopulse/

# 方式 2: 或使用 SFTP 工具（FileZilla/WinSCP）上传

# 在 Ubuntu 服务器上解压
unzip portfoliopulse.zip
rm portfoliopulse.zip

# 检查文件结构
ls -la
# 应该看到: server.js, .next/, public/, content/ 等
```

### 2.3 配置环境变量（可选）

```bash
# 创建 .env 文件
nano .env
```

添加内容：
```env
NODE_ENV=production
PORT=3000
HOSTNAME=0.0.0.0
```

### 2.4 启动应用

```bash
# 方式 1: 使用 PM2 启动（推荐）
pm2 start server.js --name portfoliopulse

# 查看状态
pm2 status

# 查看日志
pm2 logs portfoliopulse

# 设置开机自启
pm2 startup
pm2 save

# 方式 2: 直接运行（测试用）
node server.js
```

访问: `http://your_server_ip:3000`

---

## 🔧 步骤 3: 配置 Nginx 反向代理（可选）

如果需要使用域名和 HTTPS：

### 3.1 安装 Nginx

```bash
sudo apt install -y nginx
```

### 3.2 配置站点

```bash
sudo nano /etc/nginx/sites-available/portfoliopulse
```

添加配置：
```nginx
server {
    listen 80;
    server_name your_domain.com;  # 替换为你的域名

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

启用站点：
```bash
sudo ln -s /etc/nginx/sites-available/portfoliopulse /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 3.3 配置 HTTPS（使用 Let's Encrypt）

```bash
# 安装 Certbot
sudo apt install -y certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d your_domain.com

# 自动续期
sudo certbot renew --dry-run
```

---

## 🔄 后续更新流程

当你修改了代码需要更新时：

### Windows 端：
```powershell
# 1. 重新构建
cd D:\repositories\PortfolioPulse\frontend
npm run build

# 2. 重新打包（执行步骤 1.3 的打包命令）

# 3. 上传到服务器
scp portfoliopulse.zip your_username@your_server_ip:~/
```

### Ubuntu 端：
```bash
# 1. 备份旧版本
cd ~
mv portfoliopulse portfoliopulse.bak

# 2. 解压新版本
mkdir portfoliopulse
cd portfoliopulse
unzip ../portfoliopulse.zip

# 3. 重启应用
pm2 restart portfoliopulse

# 4. 确认正常后删除备份
# rm -rf ~/portfoliopulse.bak
```

---

## 📊 常用 PM2 命令

```bash
# 查看所有进程
pm2 list

# 查看日志
pm2 logs portfoliopulse

# 重启应用
pm2 restart portfoliopulse

# 停止应用
pm2 stop portfoliopulse

# 删除应用
pm2 delete portfoliopulse

# 查看详细信息
pm2 show portfoliopulse

# 监控
pm2 monit
```

---

## 🐛 故障排查

### 应用无法启动
```bash
# 检查日志
pm2 logs portfoliopulse --lines 100

# 检查端口占用
sudo netstat -tulpn | grep :3000

# 手动运行查看错误
cd ~/portfoliopulse
node server.js
```

### 静态资源 404
检查 `.next/static/` 目录是否存在且有内容：
```bash
ls -la ~/portfoliopulse/.next/static/
```

### 博客文章不显示
检查 `content/blog/` 目录是否存在：
```bash
ls -la ~/portfoliopulse/content/blog/
```

---

## 📝 注意事项

1. **Node.js 版本**: 确保服务器 Node.js >= 18.17
2. **文件权限**: 确保应用目录有读取权限
3. **防火墙**: 开放 3000 端口（如果使用 Nginx 则开放 80/443）
4. **内存**: 确保服务器至少有 512MB 可用内存
5. **博客内容**: 所有博客文章都会打包到应用中，修改文章需要重新构建部署

---

## ✅ 部署清单

- [ ] 修改 `next.config.js` 添加 `output: 'standalone'`
- [ ] Windows 端执行 `npm run build`
- [ ] 打包部署文件并压缩
- [ ] 上传到 Ubuntu 服务器
- [ ] 服务器安装 Node.js 18.x 和 PM2
- [ ] 解压文件到 `~/portfoliopulse`
- [ ] 使用 PM2 启动应用
- [ ] 配置 PM2 开机自启
- [ ] （可选）配置 Nginx 反向代理
- [ ] （可选）配置 HTTPS 证书
- [ ] 测试访问网站

---

## 🎉 完成

部署完成后访问:
- HTTP: `http://your_server_ip:3000`
- 通过 Nginx: `http://your_domain.com` 或 `https://your_domain.com`

享受你的在线作品集吧！
