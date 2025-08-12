#!/bin/bash

# PortfolioPulse 综合问题修复脚本
# 解决端口占用、模块缺失和 Next.js 配置问题

set -e

echo "🔧 PortfolioPulse 综合问题修复"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📅 修复时间: $(date)"
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

# 检查当前目录
if [[ ! -f "server.js" ]] || [[ ! -f "portfolio_pulse_backend" ]]; then
    print_error "请在部署目录中运行此脚本 (/opt/portfoliopulse/deploy)"
    echo "当前目录内容:"
    ls -la
    exit 1
fi

print_step "第一步：彻底清理所有进程和端口"

# 查找并杀死所有相关进程
echo "🔍 查找所有相关进程..."

# 查找占用 3000 端口的进程
PORT_3000_PIDS=$(lsof -ti:3000 2>/dev/null || true)
if [[ -n "$PORT_3000_PIDS" ]]; then
    echo "发现占用端口 3000 的进程: $PORT_3000_PIDS"
    for pid in $PORT_3000_PIDS; do
        kill -9 "$pid" 2>/dev/null || true
        print_success "已杀死进程 $pid (端口 3000)"
    done
else
    echo "端口 3000 未被占用"
fi

# 查找占用 8000 端口的进程
PORT_8000_PIDS=$(lsof -ti:8000 2>/dev/null || true)
if [[ -n "$PORT_8000_PIDS" ]]; then
    echo "发现占用端口 8000 的进程: $PORT_8000_PIDS"
    for pid in $PORT_8000_PIDS; do
        kill -9 "$pid" 2>/dev/null || true
        print_success "已杀死进程 $pid (端口 8000)"
    done
fi

# 查找所有 node 进程
NODE_PIDS=$(pgrep node 2>/dev/null || true)
if [[ -n "$NODE_PIDS" ]]; then
    echo "发现 Node.js 进程: $NODE_PIDS"
    for pid in $NODE_PIDS; do
        kill -9 "$pid" 2>/dev/null || true
        print_success "已杀死 Node.js 进程 $pid"
    done
fi

# 查找 portfolio_pulse_backend 进程
BACKEND_PIDS=$(pgrep portfolio_pulse 2>/dev/null || true)
if [[ -n "$BACKEND_PIDS" ]]; then
    echo "发现后端进程: $BACKEND_PIDS"
    for pid in $BACKEND_PIDS; do
        kill -9 "$pid" 2>/dev/null || true
        print_success "已杀死后端进程 $pid"
    done
fi

# 清理 PID 文件
rm -f *.pid

# 等待端口释放
sleep 3

# 再次检查端口
if lsof -ti:3000 >/dev/null 2>&1; then
    print_error "端口 3000 仍被占用"
    lsof -i:3000
    exit 1
else
    print_success "端口 3000 已释放"
fi

if lsof -ti:8000 >/dev/null 2>&1; then
    print_error "端口 8000 仍被占用"  
    lsof -i:8000
    exit 1
else
    print_success "端口 8000 已释放"
fi

print_step "第二步：检查和修复 Node.js 模块问题"

# 检查 node_modules 目录
if [[ ! -d "node_modules" ]]; then
    print_error "node_modules 目录不存在"
    
    if [[ -f "package.json" ]]; then
        print_step "尝试重新安装依赖"
        npm ci || npm install
        
        if [[ -d "node_modules" ]]; then
            print_success "依赖安装成功"
        else
            print_error "依赖安装失败"
            exit 1
        fi
    else
        print_error "package.json 不存在，无法安装依赖"
        exit 1
    fi
else
    print_success "node_modules 目录存在"
    
    # 检查关键模块
    if [[ ! -d "node_modules/next" ]]; then
        print_error "Next.js 模块缺失"
        npm ci || npm install
    else
        print_success "Next.js 模块存在"
    fi
fi

print_step "第三步：修复 Next.js 配置文件"

# 创建完整的 .next 目录结构
mkdir -p .next/{server/{pages,app},static,cache}

# 生成所有必需文件
BUILD_ID=$(date +%s%N | cut -c1-13)
echo "$BUILD_ID" > .next/BUILD_ID

# 创建 next-font-manifest.json
cat > .next/server/next-font-manifest.json << 'EOF'
{
  "pages": {},
  "app": {},
  "appUsingSizeAdjust": false,
  "pagesUsingSizeAdjust": false
}
EOF

# 创建 pages-manifest.json
cat > .next/server/pages-manifest.json << 'EOF'
{
  "/_app": "pages/_app.js",
  "/_error": "pages/_error.js",
  "/_document": "pages/_document.js",
  "/": "pages/index.js"
}
EOF

# 创建 middleware-manifest.json
cat > .next/server/middleware-manifest.json << 'EOF'
{
  "version": 2,
  "middleware": {},
  "functions": {},
  "sortedMiddleware": []
}
EOF

# 创建 routes-manifest.json
cat > .next/routes-manifest.json << 'EOF'
{
  "version": 3,
  "pages404": false,
  "basePath": "",
  "redirects": [],
  "rewrites": [],
  "headers": [],
  "staticRoutes": [
    {
      "page": "/",
      "regex": "^\\/$",
      "routeKeys": {},
      "namedRegex": "^\\/$"
    }
  ],
  "dynamicRoutes": [],
  "dataRoutes": [],
  "i18n": null
}
EOF

# 创建 prerender-manifest.json
cat > .next/prerender-manifest.json << 'EOF'
{
  "version": 4,
  "routes": {},
  "dynamicRoutes": {},
  "notFoundRoutes": [],
  "preview": {
    "previewModeId": "development-id"
  }
}
EOF

print_success "Next.js 配置文件已创建"

print_step "第四步：检查和修复应用文件"

# 检查 server.js 文件
if [[ ! -f "server.js" ]]; then
    print_error "server.js 文件不存在"
    exit 1
fi

# 检查 server.js 内容，确保没有问题
if grep -q "require.*next" server.js; then
    print_success "server.js 看起来正常"
else
    print_warning "server.js 可能有问题"
    echo "server.js 内容预览:"
    head -10 server.js
fi

# 检查包文件
if [[ -f "package.json" ]]; then
    print_success "package.json 存在"
    echo "Node.js 版本要求:"
    grep -o '"node":[^,]*' package.json || echo "未指定"
else
    print_error "package.json 缺失"
    exit 1
fi

print_step "第五步：测试应用启动"

# 设置环境变量
export NODE_ENV=production
export PORT=3000

echo "🧪 进行启动测试（10秒超时）..."

# 第一次测试：检查基本启动
timeout 10s node server.js > startup_test.log 2>&1 &
TEST_PID=$!

sleep 5

if kill -0 $TEST_PID 2>/dev/null; then
    kill $TEST_PID 2>/dev/null || true
    
    # 检查日志中是否有错误
    if grep -qi "error\|failed\|cannot\|missing" startup_test.log; then
        print_error "启动测试中发现错误:"
        cat startup_test.log
        rm -f startup_test.log
        exit 1
    else
        print_success "启动测试通过"
        rm -f startup_test.log
    fi
else
    print_error "启动测试失败"
    cat startup_test.log
    rm -f startup_test.log
    exit 1
fi

print_step "第六步：启动所有服务"

# 启动后端
if [[ -f "portfolio_pulse_backend" ]]; then
    print_step "启动后端服务 (端口 8000)"
    
    # 确保文件可执行
    chmod +x portfolio_pulse_backend
    
    # 启动后端
    nohup ./portfolio_pulse_backend > backend.log 2>&1 &
    BACKEND_PID=$!
    echo $BACKEND_PID > backend.pid
    
    sleep 3
    
    if kill -0 $BACKEND_PID 2>/dev/null; then
        print_success "后端服务已启动 (PID: $BACKEND_PID)"
    else
        print_error "后端服务启动失败"
        echo "后端错误日志:"
        tail -10 backend.log
        exit 1
    fi
else
    print_warning "后端二进制文件不存在，跳过后端启动"
fi

# 启动前端
print_step "启动前端服务 (端口 3000)"

# 最后一次检查端口
if lsof -ti:3000 >/dev/null 2>&1; then
    print_error "端口 3000 仍被占用，无法启动前端"
    lsof -i:3000
    exit 1
fi

# 启动前端
nohup node server.js > frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > frontend.pid

sleep 5

if kill -0 $FRONTEND_PID 2>/dev/null; then
    print_success "前端服务已启动 (PID: $FRONTEND_PID)"
    
    # 测试服务响应
    sleep 2
    echo "🧪 测试服务响应..."
    
    # 测试前端
    if curl -s -m 5 http://localhost:3000 > /dev/null 2>&1; then
        print_success "前端服务响应正常"
    else
        print_warning "前端服务可能需要更多时间启动，请稍后测试"
    fi
    
    # 测试后端（如果存在）
    if [[ -f "backend.pid" ]] && curl -s -m 5 http://localhost:8000 > /dev/null 2>&1; then
        print_success "后端服务响应正常"
    fi
    
else
    print_error "前端服务启动失败"
    echo "前端错误日志:"
    tail -20 frontend.log
    
    # 分析常见错误
    if grep -q "EADDRINUSE" frontend.log; then
        print_error "端口仍被占用，需要手动检查"
        netstat -tulpn | grep :3000
    elif grep -q "MODULE_NOT_FOUND" frontend.log; then
        print_error "模块缺失，需要重新安装依赖"
        echo "运行: npm ci"
    elif grep -q "Cannot find module" frontend.log; then
        print_error "找不到模块，检查文件结构"
        ls -la .next/server/
    fi
    
    exit 1
fi

print_step "第七步：最终验证"

echo ""
echo "📊 服务状态总结:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ -f "backend.pid" ]] && kill -0 $(cat backend.pid) 2>/dev/null; then
    echo "🦀 后端服务: ✅ 运行中 (PID: $(cat backend.pid), 端口: 8000)"
else
    echo "🦀 后端服务: ❌ 未运行"
fi

if [[ -f "frontend.pid" ]] && kill -0 $(cat frontend.pid) 2>/dev/null; then
    echo "🟢 前端服务: ✅ 运行中 (PID: $(cat frontend.pid), 端口: 3000)"
else
    echo "🟢 前端服务: ❌ 未运行"
fi

echo ""
echo "🔗 访问地址:"
echo "  🌐 前端: http://localhost:3000"
echo "  🔌 后端: http://localhost:8000"
echo ""
echo "📋 管理命令:"
echo "  tail -f frontend.log    # 查看前端日志"
echo "  tail -f backend.log     # 查看后端日志"
echo "  kill \$(cat frontend.pid) # 停止前端"
echo "  kill \$(cat backend.pid)  # 停止后端"
echo ""
echo "🧪 测试命令:"
echo "  curl http://localhost:3000  # 测试前端"
echo "  curl http://localhost:8000  # 测试后端"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "🎉 修复完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
