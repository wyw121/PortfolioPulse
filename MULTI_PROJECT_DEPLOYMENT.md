# 多项目服务器部署策略

## 🎯 多项目架构设计

```
单服务器多项目架构：
├── 端口 80/443 → Nginx (主入口，域名/路径分发)
├── 端口 3000-3009 → 前端项目们
├── 端口 8000-8009 → 后端 API 们
├── 端口 3306 → MySQL (共享数据库)
└── 端口 6379 → Redis (共享缓存，可选)
```

## 📁 服务器目录结构

```
/opt/projects/
├── portfoliopulse/          # 项目1: PortfolioPulse
│   ├── frontend/
│   ├── backend/
│   ├── portfolio_pulse      # Rust 二进制
│   ├── start.sh
│   └── .env
├── blog-system/             # 项目2: 个人博客
│   ├── frontend/
│   ├── backend/
│   ├── blog_server          # 另一个 Rust 二进制
│   ├── start.sh
│   └── .env
├── ecommerce-api/           # 项目3: 电商 API
│   ├── ecommerce_api        # Go/Rust/Node.js 二进制
│   ├── start.sh
│   └── .env
├── shared/                  # 共享资源
│   ├── nginx/
│   │   └── nginx.conf
│   ├── ssl/
│   └── scripts/
└── logs/                    # 统一日志目录
    ├── portfoliopulse/
    ├── blog-system/
    └── ecommerce-api/
```

## 🌐 Nginx 主配置（域名/路径分发）

```nginx
# /opt/projects/shared/nginx/nginx.conf

# 上游服务定义
upstream portfoliopulse_frontend {
    server localhost:3000;
}

upstream portfoliopulse_api {
    server localhost:8000;
}

upstream blog_frontend {
    server localhost:3001;
}

upstream blog_api {
    server localhost:8001;
}

upstream ecommerce_api {
    server localhost:8002;
}

# 主域名配置
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    # 项目1: PortfolioPulse (主站)
    location / {
        proxy_pass http://portfoliopulse_frontend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # PortfolioPulse API
    location /api/ {
        proxy_pass http://portfoliopulse_api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # 项目2: 博客系统 (子路径)
    location /blog/ {
        proxy_pass http://blog_frontend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # 博客 API
    location /blog/api/ {
        proxy_pass http://blog_api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # 项目3: 电商 API (纯 API，无前端)
    location /ecommerce/api/ {
        proxy_pass http://ecommerce_api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

# 子域名配置（可选）
server {
    listen 80;
    server_name blog.yourdomain.com;

    location / {
        proxy_pass http://blog_frontend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api/ {
        proxy_pass http://blog_api/;
    }
}

server {
    listen 80;
    server_name api.yourdomain.com;

    # 集中 API 入口
    location /portfoliopulse/ {
        proxy_pass http://portfoliopulse_api/;
    }

    location /blog/ {
        proxy_pass http://blog_api/;
    }

    location /ecommerce/ {
        proxy_pass http://ecommerce_api/;
    }
}
```

## 🎛️ 端口分配策略

| 项目 | 前端端口 | 后端端口 | 域名访问 |
|------|---------|---------|----------|
| PortfolioPulse | 3000 | 8000 | yourdomain.com |
| 博客系统 | 3001 | 8001 | yourdomain.com/blog 或 blog.yourdomain.com |
| 电商API | 无前端 | 8002 | yourdomain.com/ecommerce/api |
| 项目管理 | 3002 | 8003 | yourdomain.com/projects |
| 图床服务 | 3003 | 8004 | img.yourdomain.com |

## 🚀 统一启动管理脚本

### 主控制脚本
```bash
#!/bin/bash
# /opt/projects/master-control.sh

PROJECTS_DIR="/opt/projects"
PROJECTS=("portfoliopulse" "blog-system" "ecommerce-api")

case "$1" in
    start)
        echo "🚀 Starting all projects..."
        for project in "${PROJECTS[@]}"; do
            if [ -d "$PROJECTS_DIR/$project" ]; then
                echo "Starting $project..."
                cd "$PROJECTS_DIR/$project"
                ./start.sh
                sleep 2
            fi
        done
        echo "✅ All projects started!"
        ;;

    stop)
        echo "🛑 Stopping all projects..."
        for project in "${PROJECTS[@]}"; do
            if [ -d "$PROJECTS_DIR/$project" ]; then
                echo "Stopping $project..."
                cd "$PROJECTS_DIR/$project"
                ./stop.sh
            fi
        done
        echo "✅ All projects stopped!"
        ;;

    status)
        echo "📊 Projects Status:"
        echo "===================="
        for project in "${PROJECTS[@]}"; do
            echo -n "$project: "
            if pgrep -f "$project" > /dev/null; then
                echo "🟢 Running"
            else
                echo "🔴 Stopped"
            fi
        done

        echo ""
        echo "📡 Port Usage:"
        echo "===================="
        netstat -tulpn | grep -E ":(3000|3001|3002|8000|8001|8002)" | while read line; do
            echo "$line"
        done
        ;;

    restart)
        echo "🔄 Restarting all projects..."
        $0 stop
        sleep 3
        $0 start
        ;;

    logs)
        if [ -z "$2" ]; then
            echo "📋 Available projects: ${PROJECTS[*]}"
            echo "Usage: $0 logs <project_name>"
        else
            echo "📋 Showing logs for $2..."
            tail -f "/opt/projects/logs/$2/"*.log
        fi
        ;;

    *)
        echo "Usage: $0 {start|stop|status|restart|logs <project>}"
        echo ""
        echo "Available commands:"
        echo "  start   - Start all projects"
        echo "  stop    - Stop all projects"
        echo "  status  - Show status of all projects"
        echo "  restart - Restart all projects"
        echo "  logs    - Show logs for a specific project"
        exit 1
        ;;
esac
```

### 项目专用启动脚本模板
```bash
#!/bin/bash
# 项目启动脚本模板 (例如: portfoliopulse/start.sh)

PROJECT_NAME="portfoliopulse"
PROJECT_DIR="/opt/projects/$PROJECT_NAME"
LOG_DIR="/opt/projects/logs/$PROJECT_NAME"
FRONTEND_PORT=3000
BACKEND_PORT=8000

# 创建日志目录
mkdir -p "$LOG_DIR"

# 设置环境变量
export NODE_ENV=production
export DATABASE_URL="mysql://portfoliopulse:password@localhost:3306/portfolio_pulse"
export GITHUB_TOKEN="your_token"
export GITHUB_USERNAME="your_username"

cd "$PROJECT_DIR"

# 检查端口是否被占用
check_port() {
    if netstat -tulpn | grep -q ":$1 "; then
        echo "❌ Port $1 is already in use!"
        echo "Process using port $1:"
        netstat -tulpn | grep ":$1 "
        return 1
    fi
    return 0
}

echo "🚀 Starting $PROJECT_NAME..."

# 检查端口可用性
if ! check_port $BACKEND_PORT; then
    exit 1
fi

if [ -f "frontend/server.js" ] && ! check_port $FRONTEND_PORT; then
    exit 1
fi

# 启动后端
echo "🦀 Starting backend on port $BACKEND_PORT..."
nohup ./portfolio_pulse > "$LOG_DIR/backend.log" 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > "$PROJECT_DIR/backend.pid"

# 等待后端启动
sleep 3

# 检查后端是否启动成功
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo "❌ Backend failed to start!"
    cat "$LOG_DIR/backend.log"
    exit 1
fi

# 启动前端（如果存在）
if [ -f "frontend/server.js" ]; then
    echo "🟢 Starting frontend on port $FRONTEND_PORT..."
    cd frontend
    nohup node server.js > "$LOG_DIR/frontend.log" 2>&1 &
    FRONTEND_PID=$!
    echo $FRONTEND_PID > "$PROJECT_DIR/frontend.pid"
    cd ..
fi

echo "✅ $PROJECT_NAME started successfully!"
echo "Backend PID: $BACKEND_PID (port $BACKEND_PORT)"
[ ! -z "$FRONTEND_PID" ] && echo "Frontend PID: $FRONTEND_PID (port $FRONTEND_PORT)"

# 健康检查
sleep 2
if curl -f "http://localhost:$BACKEND_PORT/api/health" >/dev/null 2>&1; then
    echo "✅ Backend health check passed"
else
    echo "⚠️  Backend health check failed (this might be normal if no health endpoint)"
fi

if [ ! -z "$FRONTEND_PID" ] && curl -f "http://localhost:$FRONTEND_PORT" >/dev/null 2>&1; then
    echo "✅ Frontend health check passed"
fi
```

## 🗄️ 数据库管理策略

### 选项1: 共享数据库，独立 Schema
```sql
-- 为每个项目创建独立数据库
CREATE DATABASE portfolio_pulse;
CREATE DATABASE blog_system;
CREATE DATABASE ecommerce_api;

-- 创建项目专用用户
CREATE USER 'portfoliopulse'@'localhost' IDENTIFIED BY 'password1';
CREATE USER 'blog_user'@'localhost' IDENTIFIED BY 'password2';
CREATE USER 'ecommerce_user'@'localhost' IDENTIFIED BY 'password3';

-- 分配权限
GRANT ALL PRIVILEGES ON portfolio_pulse.* TO 'portfoliopulse'@'localhost';
GRANT ALL PRIVILEGES ON blog_system.* TO 'blog_user'@'localhost';
GRANT ALL PRIVILEGES ON ecommerce_api.* TO 'ecommerce_user'@'localhost';
```

### 选项2: 完全独立的数据库实例
```bash
# 使用 Docker 为每个项目运行独立数据库
docker run --name portfoliopulse-db -p 3306:3306 -d mysql:8.0
docker run --name blog-db -p 3307:3306 -d mysql:8.0
docker run --name ecommerce-db -p 3308:3306 -d mysql:8.0
```

## 📊 监控和管理

### 统一监控脚本
```bash
#!/bin/bash
# /opt/projects/monitoring.sh

echo "🖥️  System Resources:"
echo "===================="
echo "CPU Usage: $(top -bn1 | grep load | awk '{printf "%.2f%%\t\t\n", $(NF-2)}' )"
echo "Memory Usage: $(free | grep Mem | awk '{printf("%.2f%%\n", $3/$2 * 100.0)}')"
echo "Disk Usage: $(df -h / | awk 'NR==2{printf "%s/%s (%s)\n", $3, $2, $5}')"

echo ""
echo "🌐 Network Connections:"
echo "===================="
netstat -tulpn | grep -E ":(80|443|3000|3001|3002|8000|8001|8002)" | \
    awk '{print $1, $4}' | sort

echo ""
echo "⚡ Active Processes:"
echo "===================="
ps aux | grep -E "(portfolio|blog|ecommerce)" | grep -v grep | \
    awk '{printf "%-20s PID: %-8s CPU: %-6s MEM: %-6s\n", $11, $2, $3"%", $4"%"}'

echo ""
echo "📋 Recent Logs (Errors):"
echo "===================="
find /opt/projects/logs -name "*.log" -exec grep -l "ERROR\|FATAL\|Exception" {} \; 2>/dev/null | \
    head -5 | while read logfile; do
        echo "📄 $logfile:"
        grep -E "ERROR|FATAL|Exception" "$logfile" | tail -2
        echo ""
    done
```

## 🚀 部署和更新流程

### 零停机更新脚本
```bash
#!/bin/bash
# /opt/projects/deploy.sh <project_name>

PROJECT_NAME="$1"
PROJECT_DIR="/opt/projects/$PROJECT_NAME"
BACKUP_DIR="/opt/projects/backups/$PROJECT_NAME"

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: $0 <project_name>"
    exit 1
fi

echo "🚀 Deploying $PROJECT_NAME..."

# 1. 创建备份
echo "📦 Creating backup..."
mkdir -p "$BACKUP_DIR"
cp -r "$PROJECT_DIR" "$BACKUP_DIR/$(date +%Y%m%d_%H%M%S)/"

# 2. 停止旧版本
echo "🛑 Stopping old version..."
cd "$PROJECT_DIR"
./stop.sh

# 3. 更新文件（这里假设文件已经上传到 PROJECT_DIR/new/）
echo "🔄 Updating files..."
if [ -d "$PROJECT_DIR/new" ]; then
    cp -r "$PROJECT_DIR/new/"* "$PROJECT_DIR/"
    rm -rf "$PROJECT_DIR/new"
fi

# 4. 启动新版本
echo "🚀 Starting new version..."
./start.sh

# 5. 健康检查
echo "🏥 Health check..."
sleep 5
if curl -f "http://localhost:8000/api/health" >/dev/null 2>&1; then
    echo "✅ Deployment successful!"

    # 清理旧备份（保留最近5个）
    cd "$BACKUP_DIR"
    ls -t | tail -n +6 | xargs rm -rf
else
    echo "❌ Health check failed, rolling back..."
    ./stop.sh

    # 恢复最新备份
    LATEST_BACKUP=$(ls -t "$BACKUP_DIR" | head -1)
    cp -r "$BACKUP_DIR/$LATEST_BACKUP/"* "$PROJECT_DIR/"
    ./start.sh

    echo "🔄 Rollback completed"
    exit 1
fi
```

## 📋 总结

### ✅ 你的多项目部署完全可行：

1. **一台服务器多个项目** ✅
2. **每个项目独立的二进制文件** ✅
3. **不同端口运行** ✅
4. **统一域名访问** ✅

### 🎯 推荐的实施步骤：

1. **先部署一个项目**（PortfolioPulse）验证流程
2. **完善 Nginx 配置**和域名解析
3. **逐步添加新项目**，测试端口和路径分发
4. **建立监控和备份机制**

### 💡 关键注意事项：

- **端口管理**：提前规划端口分配，避免冲突
- **资源监控**：定期检查 CPU、内存使用情况
- **日志管理**：统一日志收集和轮转
- **备份策略**：定期备份项目文件和数据库

这种方案非常适合个人或小团队的多项目部署需求！
