# 📦 生成 portfoliopulse-frontend.zip 部署包

## 手动打包步骤（Windows PowerShell）

由于自动化脚本可能无法执行，请手动执行以下步骤：

### 步骤 1: 准备文件

```powershell
# 进入前端目录
cd d:\repositories\PortfolioPulse\frontend

# 创建临时打包目录
New-Item -ItemType Directory -Force -Path "deploy-pkg"

# 复制 standalone 核心文件
Copy-Item -Recurse ".next/standalone/*" "deploy-pkg/"

# 创建 .next/static 目录
New-Item -ItemType Directory -Force -Path "deploy-pkg/.next/static"

# 复制静态文件
Copy-Item -Recurse ".next/static/*" "deploy-pkg/.next/static/"

# 复制 public 目录（如果存在）
if (Test-Path "public") {
    New-Item -ItemType Directory -Force -Path "deploy-pkg/public"
    Copy-Item -Recurse "public/*" "deploy-pkg/public/"
}

# 复制部署脚本
Copy-Item "deploy-temp/start.sh" "deploy-pkg/"
Copy-Item "deploy-temp/stop.sh" "deploy-pkg/"
Copy-Item "deploy-temp/portfoliopulse-frontend.service" "deploy-pkg/"
Copy-Item "deploy-temp/README.md" "deploy-pkg/"
```

### 步骤 2: 打包成 ZIP

```powershell
# 压缩成 ZIP 文件
Compress-Archive -Path "deploy-pkg/*" -DestinationPath "portfoliopulse-frontend.zip" -Force

# 显示文件信息
Get-Item "portfoliopulse-frontend.zip" | Select-Object Name, @{Name="Size(MB)";Expression={[math]::Round($_.Length/1MB,2)}}

# 清理临时目录
Remove-Item -Recurse -Force "deploy-pkg"
```

### 步骤 3: 验证 ZIP 文件

```powershell
# 查看 ZIP 内容
Add-Type -Assembly System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::OpenRead("portfoliopulse-frontend.zip").Entries.FullName | Select-Object -First 20
```

---

## 或者使用文件管理器手动打包

### 方法 1: 使用 7-Zip（推荐）

1. 打开 `d:\repositories\PortfolioPulse\frontend\`
2. 创建新文件夹 `deploy-pkg`
3. 复制以下内容到 `deploy-pkg`:
   - `.next/standalone/*` 的所有内容（包括 server.js）
   - `.next/static/*` 复制到 `deploy-pkg/.next/static/`
   - `public/*` 复制到 `deploy-pkg/public/`
   - `deploy-temp/start.sh`
   - `deploy-temp/stop.sh`
   - `deploy-temp/portfoliopulse-frontend.service`
   - `deploy-temp/README.md`
4. 选中 `deploy-pkg` 文件夹内的所有文件
5. 右键 → 7-Zip → Add to archive
6. 命名为 `portfoliopulse-frontend.zip`
7. 格式选择 ZIP
8. 点击 OK

### 方法 2: 使用 Windows 内置压缩

1. 按照方法 1 准备好 `deploy-pkg` 文件夹
2. 进入 `deploy-pkg` 文件夹
3. 全选所有文件（Ctrl+A）
4. 右键 → 发送到 → 压缩(zipped)文件夹
5. 重命名为 `portfoliopulse-frontend.zip`
6. 将 ZIP 文件移动到 `d:\repositories\PortfolioPulse\frontend\`

---

## ✅ 检查清单

确保 ZIP 文件包含以下内容（解压后查看）：

```
portfoliopulse-frontend/
├── server.js                    ✓ Next.js 服务器入口
├── package.json                 ✓ 依赖清单
├── .next/                       ✓ 构建产物
│   ├── static/                 ✓ 静态资源（重要！）
│   │   ├── chunks/
│   │   ├── css/
│   │   └── media/
│   └── server/                 ✓ 服务端代码
├── node_modules/                ✓ 依赖包（已包含）
├── public/                      ✓ 公共资源
├── content/                     ✓ 博客内容
├── start.sh                     ✓ 启动脚本
├── stop.sh                      ✓ 停止脚本
├── portfoliopulse-frontend.service  ✓ systemd 服务
└── README.md                    ✓ 部署说明
```

**关键文件**:
- ✅ `server.js` - 必须存在
- ✅ `.next/static/` - 必须包含（CSS、JS、图片等）
- ✅ `node_modules/` - 必须包含（运行时依赖）
- ✅ `start.sh` 和 `stop.sh` - 启动/停止脚本

---

## 📤 上传到服务器

### 方式 A: 使用 SCP（命令行）

```powershell
# 在 PowerShell 中执行
scp portfoliopulse-frontend.zip username@your-server-ip:~/opt/
```

### 方式 B: 使用 WinSCP（图形界面）

1. 下载并安装 WinSCP: https://winscp.net/
2. 连接到你的服务器
3. 上传 `portfoliopulse-frontend.zip` 到 `/home/username/opt/`

### 方式 C: 使用 FileZilla（图形界面）

1. 下载并安装 FileZilla: https://filezilla-project.org/
2. 连接到你的服务器（SFTP 协议）
3. 上传 `portfoliopulse-frontend.zip` 到 `/home/username/opt/`

---

## 🚀 服务器部署命令（完整）

上传完成后，在服务器上执行：

```bash
# 1. 进入目录
cd ~/opt

# 2. 解压文件
unzip portfoliopulse-frontend.zip

# 3. 进入项目目录
cd portfoliopulse-frontend

# 4. 设置执行权限
chmod +x start.sh stop.sh

# 5. 安装 PM2（如果没有）
sudo npm install -g pm2

# 6. 启动应用
pm2 start server.js --name portfoliopulse-frontend

# 7. 设置开机自启
pm2 startup
# 执行上面命令输出的 sudo 命令
pm2 save

# 8. 查看状态
pm2 status

# 9. 查看日志
pm2 logs portfoliopulse-frontend

# 10. 测试访问
curl http://localhost:3000
```

---

## 📋 完整流程总结

### 本地操作（Windows）

1. ✅ 构建项目: `npm run build`
2. ✅ 打包文件: 手动或使用 PowerShell 脚本
3. ✅ 上传 ZIP: 使用 SCP/WinSCP/FileZilla

### 服务器操作（Ubuntu 22.04）

```bash
cd ~/opt
unzip portfoliopulse-frontend.zip
cd portfoliopulse-frontend
chmod +x start.sh stop.sh
sudo npm install -g pm2
pm2 start server.js --name portfoliopulse-frontend
pm2 startup
pm2 save
pm2 status
```

完成！应用运行在 `http://your-server-ip:3000`

---

## 🆘 遇到问题？

查看详细文档: `SERVER-DEPLOYMENT-GUIDE.md`

常见问题:
- **端口被占用**: `sudo lsof -i :3000` → `sudo kill -9 <PID>`
- **Node.js 版本**: `node -v` 应该 >= 18.17.0
- **查看日志**: `pm2 logs portfoliopulse-frontend`
