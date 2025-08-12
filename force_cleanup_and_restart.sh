#!/bin/bash

# PortfolioPulse 强力清理和重启脚本
# 彻底解决端口占用问题

echo "🔧 PortfolioPulse 强力清理脚本"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📅 执行时间: $(date)"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

function print_step() {
    echo -e "${BLUE}🔹 $1${NC}"
}

function print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

function print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

function print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_step "第一步：识别并终止所有相关进程"

echo "🔍 当前端口占用情况:"
netstat -tulpn | grep -E ':(3000|8000)'

# 方法1：通过端口杀死进程
print_step "通过端口强制终止进程"

for port in 3000 8000; do
    echo "处理端口 $port..."
    
    # 查找占用端口的进程
    PIDS=$(lsof -ti:$port 2>/dev/null || true)
    
    if [[ -n "$PIDS" ]]; then
        echo "发现占用端口 $port 的进程: $PIDS"
        
        for pid in $PIDS; do
            # 查看进程信息
            PROCESS_INFO=$(ps -p $pid -o pid,ppid,cmd --no-headers 2>/dev/null || echo "进程不存在")
            echo "  进程信息: $PROCESS_INFO"
            
            # 尝试优雅终止
            echo "  尝试优雅终止 PID $pid..."
            kill -TERM $pid 2>/dev/null || true
            sleep 2
            
            # 检查是否还在运行
            if kill -0 $pid 2>/dev/null; then
                echo "  强制终止 PID $pid..."
                kill -KILL $pid 2>/dev/null || true
                sleep 1
                
                # 最终检查
                if kill -0 $pid 2>/dev/null; then
                    print_error "无法终止进程 $pid"
                else
                    print_success "已终止进程 $pid"
                fi
            else
                print_success "进程 $pid 已优雅终止"
            fi
        done
    else
        echo "端口 $port 未被占用"
    fi
done

# 方法2：通过进程名杀死进程
print_step "通过进程名终止相关进程"

PROCESS_PATTERNS=(
    "next-server"
    "node.*server.js"
    "portfolio_pulse"
    "node.*next"
)

for pattern in "${PROCESS_PATTERNS[@]}"; do
    echo "查找进程模式: $pattern"
    
    PIDS=$(pgrep -f "$pattern" 2>/dev/null || true)
    
    if [[ -n "$PIDS" ]]; then
        echo "发现匹配进程: $PIDS"
        
        for pid in $PIDS; do
            PROCESS_INFO=$(ps -p $pid -o pid,ppid,cmd --no-headers 2>/dev/null || echo "进程不存在")
            echo "  终止: $PROCESS_INFO"
            
            kill -KILL $pid 2>/dev/null || true
        done
        
        print_success "已终止所有匹配 '$pattern' 的进程"
    else
        echo "未找到匹配 '$pattern' 的进程"
    fi
done

# 方法3：使用 fuser 强制释放端口
print_step "使用 fuser 强制释放端口"

for port in 3000 8000; do
    echo "强制释放端口 $port..."
    fuser -k ${port}/tcp 2>/dev/null || true
    sleep 1
done

# 方法4：清理系统级进程
print_step "清理系统级相关进程"

# 杀死所有 node 进程（谨慎操作）
NODE_PIDS=$(pgrep node 2>/dev/null || true)
if [[ -n "$NODE_PIDS" ]]; then
    echo "发现 Node.js 进程: $NODE_PIDS"
    echo "将终止所有 Node.js 进程（这可能影响其他应用）"
    
    for pid in $NODE_PIDS; do
        PROCESS_INFO=$(ps -p $pid -o pid,ppid,cmd --no-headers 2>/dev/null || echo "进程不存在")
        echo "  终止 Node.js 进程: $PROCESS_INFO"
        kill -KILL $pid 2>/dev/null || true
    done
    
    print_success "已终止所有 Node.js 进程"
fi

# 清理残留的 PID 文件
rm -f *.pid

print_step "等待端口完全释放"
sleep 5

print_step "验证端口释放状态"

# 最终验证
for port in 3000 8000; do
    if lsof -ti:$port >/dev/null 2>&1; then
        print_error "端口 $port 仍被占用!"
        echo "占用详情:"
        lsof -i:$port
        
        # 最后手段：系统级端口重置
        echo "尝试系统级端口重置..."
        fuser -k ${port}/tcp 2>/dev/null || true
        sleep 2
        
        if lsof -ti:$port >/dev/null 2>&1; then
            print_error "无法释放端口 $port，可能需要重启系统"
            exit 1
        else
            print_success "端口 $port 已释放"
        fi
    else
        print_success "端口 $port 已释放"
    fi
done

print_step "重新启动服务"

# 设置环境变量
export NODE_ENV=production
export PORT=3000

# 启动后端（如果存在）
if [[ -f "portfolio_pulse_backend" ]]; then
    print_step "启动后端服务"
    chmod +x portfolio_pulse_backend
    
    # 检查后端端口
    if lsof -ti:8000 >/dev/null 2>&1; then
        print_error "端口 8000 仍被占用，无法启动后端"
    else
        nohup ./portfolio_pulse_backend > backend.log 2>&1 &
        BACKEND_PID=$!
        echo $BACKEND_PID > backend.pid
        
        sleep 2
        
        if kill -0 $BACKEND_PID 2>/dev/null; then
            print_success "后端已启动 (PID: $BACKEND_PID)"
        else
            print_error "后端启动失败"
            tail -5 backend.log
        fi
    fi
fi

# 启动前端
print_step "启动前端服务"

# 最后一次端口检查
if lsof -ti:3000 >/dev/null 2>&1; then
    print_error "端口 3000 仍被占用，无法启动前端"
    lsof -i:3000
    exit 1
fi

# 启动前端
echo "启动命令: node server.js"
nohup node server.js > frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > frontend.pid

echo "前端 PID: $FRONTEND_PID"

# 给前端更多时间启动
sleep 5

# 检查前端是否成功启动
if kill -0 $FRONTEND_PID 2>/dev/null; then
    print_success "前端服务已启动 (PID: $FRONTEND_PID)"
    
    # 测试连接
    echo "🧪 测试服务连接..."
    sleep 2
    
    # 测试前端响应
    if curl -s -m 10 http://localhost:3000 > /dev/null 2>&1; then
        print_success "前端服务响应正常"
    else
        print_warning "前端服务可能需要更多启动时间"
        echo "前端日志："
        tail -5 frontend.log
    fi
    
    # 测试后端响应
    if [[ -f "backend.pid" ]]; then
        if curl -s -m 5 http://localhost:8000 > /dev/null 2>&1; then
            print_success "后端服务响应正常"
        else
            print_warning "后端服务可能需要更多启动时间"
        fi
    fi
    
else
    print_error "前端服务启动失败"
    echo "前端错误日志："
    tail -10 frontend.log
    
    echo ""
    echo "🔍 诊断信息："
    echo "1. 进程状态："
    ps aux | grep -E "(node|portfolio)" | grep -v grep
    
    echo "2. 端口状态："
    netstat -tulpn | grep -E ':(3000|8000)'
    
    echo "3. 最新日志："
    echo "--- frontend.log ---"
    tail -20 frontend.log
    
    exit 1
fi

print_step "最终状态检查"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 服务启动完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📊 服务状态："
if [[ -f "backend.pid" ]] && kill -0 $(cat backend.pid) 2>/dev/null; then
    echo "  🦀 后端: ✅ 运行中 (PID: $(cat backend.pid), 端口: 8000)"
else
    echo "  🦀 后端: ❌ 未运行"
fi

if [[ -f "frontend.pid" ]] && kill -0 $(cat frontend.pid) 2>/dev/null; then
    echo "  🟢 前端: ✅ 运行中 (PID: $(cat frontend.pid), 端口: 3000)"
else
    echo "  🟢 前端: ❌ 未运行"
fi

echo ""
echo "🔗 访问地址："
echo "  🌐 前端应用: http://localhost:3000"
echo "  🔌 后端API:  http://localhost:8000"
echo ""
echo "📋 管理命令："
echo "  tail -f frontend.log    # 查看前端日志"
echo "  tail -f backend.log     # 查看后端日志"
echo "  ./stop.sh              # 停止服务"
echo ""
echo "🧪 测试命令："
echo "  curl http://localhost:3000  # 测试前端"
echo "  curl http://localhost:8000  # 测试后端"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
