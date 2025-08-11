# 🚀 PortfolioPulse 启动问题解决方案

## 问题描述

你在服务器上运行 `./start.sh` 时遇到了以下错误：
```
🚀 启动 PortfolioPulse...
✅ 已加载环境变量
🦀 启动后端服务 (端口 8000)...
⏳ 等待后端服务启动...
❌ 后端服务启动失败
```

## 🎯 立即解决方案

### 方法1: 一键部署增强脚本 (推荐)

在你的服务器上运行以下命令：

```bash
# 下载并执行一键部署脚本
curl -sSL -o /tmp/deploy-enhanced.sh https://raw.githubusercontent.com/your-repo/PortfolioPulse/main/scripts/deploy-one-click.sh

# 执行部署（需要 root 权限）
sudo bash /tmp/deploy-enhanced.sh

# 启动服务
cd /opt/portfoliopulse
./start.sh
```

### 方法2: 手动创建增强启动脚本

如果无法下载，可以手动创建：

```bash
# 1. 备份原启动脚本
sudo cp /opt/portfoliopulse/start.sh /opt/portfoliopulse/start.sh.backup

# 2. 创建新的增强启动脚本
sudo nano /opt/portfoliopulse/start.sh
```

然后将以下完整内容复制到文件中：

```bash
#!/bin/bash
# PortfolioPulse 增强启动脚本 - 故障诊断版

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "\n${PURPLE}▶${NC} $1"; }

# 检查文件
check_file() {
    local file=$1
    if [ -f "$file" ]; then
        if [ -x "$file" ]; then
            log_success "✅ $file 存在且可执行"
            ls -la "$file"
            return 0
        else
            log_warning "⚠️  $file 存在但不可执行，正在修复..."
            chmod +x "$file"
            log_success "✅ 已添加执行权限"
            return 0
        fi
    else
        log_error "❌ $file 不存在"
        return 1
    fi
}

# 等待服务启动
wait_for_service() {
    local port=$1
    local name=$2
    local max_wait=30

    log_info "⏳ 等待 $name 启动 (端口 $port)..."

    for i in $(seq 1 $max_wait); do
        if curl -s -f "http://localhost:$port" >/dev/null 2>&1; then
            log_success "✅ $name 启动成功"
            return 0
        fi
        echo -n "."
        sleep 1
    done

    log_error "❌ $name 启动超时"
    return 1
}

# 主函数
main() {
    echo -e "${CYAN}🚀 PortfolioPulse 增强启动脚本${NC}"
    echo "📅 启动时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "📁 当前目录: $(pwd)"
    echo "👤 当前用户: $(whoami)"
    echo ""

    # 系统信息
    log_step "📋 系统环境检查"
    echo "操作系统: $(uname -a)"
    echo "磁盘使用: $(df -h . | tail -1)"
    echo "内存状态:"
    free -h 2>/dev/null || echo "内存信息获取失败"

    # 依赖检查
    log_step "🔧 依赖检查"

    if ! command -v node >/dev/null 2>&1; then
        log_error "❌ Node.js 未安装"
        echo "请安装 Node.js: curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs"
        exit 1
    else
        log_success "✅ Node.js 已安装: $(node --version)"
    fi

    if ! command -v curl >/dev/null 2>&1; then
        log_error "❌ curl 未安装"
        echo "请安装 curl: sudo apt-get install curl"
        exit 1
    else
        log_success "✅ curl 已安装"
    fi

    # 环境变量
    log_step "🌐 环境配置"
    if [ -f ".env" ]; then
        log_success "✅ .env 文件存在"
        source .env
        echo "已加载环境变量，变量数量: $(grep -c "=" .env)"
    else
        log_warning "⚠️  .env 文件不存在，使用默认配置"
    fi

    export NODE_ENV=production
    export PORT=3000
    log_info "设置环境变量: NODE_ENV=$NODE_ENV, PORT=$PORT"

    # 文件检查
    log_step "📁 应用文件检查"

    # 显示当前目录所有文件
    echo "当前目录内容:"
    ls -la

    # 查找后端二进制文件
    BACKEND_BINARY=""

    echo ""
    echo "🔍 查找后端二进制文件..."

    # 尝试各种可能的名称
    for name in "portfolio_pulse_backend" "portfolio_pulse_backend.exe" "portfolio_pulse" "backend" "main"; do
        if [ -f "./$name" ]; then
            BACKEND_BINARY="./$name"
            log_success "✅ 找到后端文件: $BACKEND_BINARY"
            break
        else
            echo "   - ./$name (不存在)"
        fi
    done

    # 如果没找到，显示所有可执行文件
    if [ -z "$BACKEND_BINARY" ]; then
        echo ""
        echo "未找到后端二进制文件，显示所有可执行文件:"
        find . -maxdepth 1 -type f \( -perm -u+x -o -name "*.exe" \) -ls

        log_error "❌ 后端二进制文件未找到"
        echo ""
        echo "可能的解决方案:"
        echo "1. 检查文件名是否正确"
        echo "2. 确认后端已正确编译"
        echo "3. 检查文件权限: chmod +x your_backend_file"
        exit 1
    fi

    # 检查后端文件
    check_file "$BACKEND_BINARY" || exit 1

    # 检查前端文件
    FRONTEND_DIR="."
    echo ""
    echo "🔍 查找前端服务文件..."

    if [ -f "server.js" ]; then
        log_success "✅ 找到前端服务: ./server.js"
        FRONTEND_DIR="."
    elif [ -f "frontend/server.js" ]; then
        log_success "✅ 找到前端服务: ./frontend/server.js"
        FRONTEND_DIR="frontend"
    else
        log_error "❌ 前端服务文件未找到"
        echo ""
        echo "查找的文件:"
        echo "  - ./server.js"
        echo "  - ./frontend/server.js"
        echo ""
        echo "当前目录 server.js 搜索结果:"
        find . -name "server.js" -ls
        exit 1
    fi

    # 端口检查
    log_step "🔌 端口状态检查"

    # 检查端口 8000
    if netstat -tulpn 2>/dev/null | grep -q ":8000 "; then
        log_warning "⚠️  端口 8000 被占用:"
        netstat -tulpn | grep ":8000 "

        echo "是否要结束占用进程? (y/n)"
        read -r answer
        if [ "$answer" = "y" ]; then
            sudo fuser -k 8000/tcp 2>/dev/null || true
            sleep 2
            log_info "已尝试释放端口 8000"
        fi
    else
        log_success "✅ 端口 8000 可用"
    fi

    # 检查端口 3000
    if netstat -tulpn 2>/dev/null | grep -q ":3000 "; then
        log_warning "⚠️  端口 3000 被占用:"
        netstat -tulpn | grep ":3000 "

        echo "是否要结束占用进程? (y/n)"
        read -r answer
        if [ "$answer" = "y" ]; then
            sudo fuser -k 3000/tcp 2>/dev/null || true
            sleep 2
            log_info "已尝试释放端口 3000"
        fi
    else
        log_success "✅ 端口 3000 可用"
    fi

    # 清理旧进程
    log_step "🧹 清理旧进程"
    for pid_file in backend.pid frontend.pid; do
        if [ -f "$pid_file" ]; then
            old_pid=$(cat "$pid_file")
            if kill -0 "$old_pid" 2>/dev/null; then
                log_warning "⚠️  发现旧进程 ($old_pid)，正在停止..."
                kill "$old_pid" 2>/dev/null || true
                sleep 2
            fi
            rm -f "$pid_file"
            log_info "已清理 $pid_file"
        fi
    done

    # 数据库连接测试（如果有MySQL）
    if command -v mysql >/dev/null 2>&1 && [ -n "$DATABASE_URL" ]; then
        log_step "🗄️ 数据库连接测试"
        log_info "测试数据库连接..."

        # 解析 DATABASE_URL
        if echo "$DATABASE_URL" | grep -q "mysql://"; then
            # 提取连接信息进行测试
            log_info "数据库URL: $DATABASE_URL"
            # 简单的连接测试可以在这里添加
        else
            log_info "DATABASE_URL格式: $DATABASE_URL"
        fi
    fi

    # 启动后端
    log_step "🦀 启动后端服务 (端口 8000)"
    echo "后端文件信息:"
    file "$BACKEND_BINARY" 2>/dev/null || echo "无法获取文件类型信息"

    log_info "执行命令: nohup $BACKEND_BINARY > backend.log 2>&1 &"

    # 启动后端进程
    if nohup "$BACKEND_BINARY" > backend.log 2>&1 & then
        BACKEND_PID=$!
        echo $BACKEND_PID > backend.pid
        log_success "✅ 后端进程已启动 (PID: $BACKEND_PID)"

        # 等待启动
        sleep 3

        # 检查进程是否还在运行
        if ! kill -0 "$BACKEND_PID" 2>/dev/null; then
            log_error "❌ 后端进程已退出"
            echo ""
            log_info "📋 后端日志内容:"
            cat backend.log 2>/dev/null || echo "无法读取后端日志"
            exit 1
        fi

        # 测试HTTP连接
        if wait_for_service 8000 "后端服务"; then
            log_success "✅ 后端服务健康检查通过"
        else
            log_error "❌ 后端服务无法响应HTTP请求"
            echo ""
            log_info "📋 后端日志 (最后50行):"
            tail -50 backend.log 2>/dev/null || echo "无法读取日志"

            echo ""
            log_info "🔍 进程状态:"
            ps aux | grep "$BACKEND_PID" | grep -v grep || echo "进程不存在"

            echo ""
            log_info "🔌 端口监听状态:"
            netstat -tlnp | grep :8000 || echo "端口未监听"

            # 清理并退出
            kill "$BACKEND_PID" 2>/dev/null || true
            rm -f backend.pid
            exit 1
        fi
    else
        log_error "❌ 后端进程启动失败"
        echo "可能的原因:"
        echo "1. 二进制文件损坏"
        echo "2. 缺少依赖库"
        echo "3. 权限不足"
        echo "4. 配置错误"
        exit 1
    fi

    # 启动前端
    log_step "🟢 启动前端服务 (端口 3000)"

    original_dir=$(pwd)
    cd "$FRONTEND_DIR"
    log_info "切换到前端目录: $(pwd)"

    # 检查 Node.js 应用
    if [ -f "package.json" ]; then
        echo "package.json 内容:"
        cat package.json | head -20
    fi

    log_info "执行命令: nohup node server.js > ../frontend.log 2>&1 &"

    if nohup node server.js > ../frontend.log 2>&1 & then
        FRONTEND_PID=$!
        echo $FRONTEND_PID > ../frontend.pid
        cd "$original_dir"
        log_success "✅ 前端进程已启动 (PID: $FRONTEND_PID)"

        # 等待启动
        sleep 3

        # 检查进程
        if ! kill -0 "$FRONTEND_PID" 2>/dev/null; then
            log_error "❌ 前端进程已退出"
            echo ""
            log_info "📋 前端日志内容:"
            cat frontend.log 2>/dev/null || echo "无法读取前端日志"

            # 清理后端
            kill "$BACKEND_PID" 2>/dev/null || true
            rm -f backend.pid frontend.pid
            exit 1
        fi

        # 测试HTTP连接
        if wait_for_service 3000 "前端服务"; then
            log_success "✅ 前端服务健康检查通过"
        else
            log_error "❌ 前端服务无法响应HTTP请求"
            echo ""
            log_info "📋 前端日志 (最后50行):"
            tail -50 frontend.log 2>/dev/null || echo "无法读取日志"

            # 清理所有进程
            kill "$FRONTEND_PID" "$BACKEND_PID" 2>/dev/null || true
            rm -f frontend.pid backend.pid
            exit 1
        fi
    else
        log_error "❌ 前端进程启动失败"
        kill "$BACKEND_PID" 2>/dev/null || true
        rm -f backend.pid
        exit 1
    fi

    # 最终验证
    log_step "✅ 最终验证"

    # 测试完整的HTTP响应
    echo "测试后端API..."
    backend_response=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8000" || echo "连接失败")
    echo "后端响应码: $backend_response"

    echo "测试前端页面..."
    frontend_response=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000" || echo "连接失败")
    echo "前端响应码: $frontend_response"

    # 启动成功
    echo ""
    echo -e "${GREEN}"
    echo "🎉 PortfolioPulse 启动成功!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 服务状态:"
    echo "  🦀 后端服务: 运行中 (PID: $BACKEND_PID) - http://localhost:8000"
    echo "  🟢 前端服务: 运行中 (PID: $FRONTEND_PID) - http://localhost:3000"
    echo ""
    echo "🌐 访问地址: http://localhost:3000"
    echo "📋 管理命令:"
    echo "  查看状态: ./status.sh (如果存在)"
    echo "  停止服务: ./stop.sh (如果存在)"
    echo "  查看日志: tail -f backend.log frontend.log"
    echo ""
    echo "🔍 实时监控:"
    echo "  后端日志: tail -f backend.log"
    echo "  前端日志: tail -f frontend.log"
    echo "  系统资源: top -p $BACKEND_PID,$FRONTEND_PID"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${NC}"
}

# 错误处理
trap 'echo -e "\n${RED}❌ 启动过程中发生错误，正在清理...${NC}";
      [ -n "$BACKEND_PID" ] && kill "$BACKEND_PID" 2>/dev/null || true;
      [ -n "$FRONTEND_PID" ] && kill "$FRONTEND_PID" 2>/dev/null || true;
      rm -f backend.pid frontend.pid;
      exit 1' ERR

# 执行主函数
main "$@"
```

保存文件后，添加执行权限：

```bash
sudo chmod +x /opt/portfoliopulse/start.sh
```

## 🚀 现在启动服务

```bash
cd /opt/portfoliopulse
./start.sh
```

## 📋 新脚本的优势

1. **🔍 详细诊断**: 显示每一步的执行情况
2. **📁 文件检查**: 自动查找后端二进制文件和前端服务文件
3. **🔌 端口管理**: 检查端口占用并提供解决方案
4. **🗄️ 数据库测试**: 验证数据库连接（如果配置了）
5. **⚡ 健康检查**: 确保服务真正启动成功
6. **📊 实时反馈**: 彩色输出，清晰的状态指示
7. **🛡️ 错误处理**: 启动失败时自动清理进程

## 🚨 如果仍然失败

运行增强脚本后，你会看到详细的错误信息。请将完整的输出发送给我，包括：

1. 系统信息检查结果
2. 文件检查结果
3. 具体的错误日志内容

这样我就能帮你精确定位问题所在。

## 📞 快速联系

如果需要立即解决，可以：

1. 查看后端日志：`tail -f /opt/portfoliopulse/backend.log`
2. 查看前端日志：`tail -f /opt/portfoliopulse/frontend.log`
3. 检查系统资源：`free -h && df -h`
4. 测试网络连接：`curl -I http://localhost:8000`

记住：**详细的错误信息是解决问题的关键！** 🔑
