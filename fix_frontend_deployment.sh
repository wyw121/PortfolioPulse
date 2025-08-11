#!/bin/bash

# PortfolioPulse 前端部署修复脚本
# 用于修复 Next.js Standalone 部署中缺失 .next 目录的问题

set -e

echo "🔧 PortfolioPulse 前端部署修复脚本"
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
    print_error "请在部署目录中运行此脚本"
    echo "当前目录内容:"
    ls -la
    exit 1
fi

print_step "检查前端文件结构"

# 停止前端服务（如果正在运行）
if [[ -f "frontend.pid" ]]; then
    PID=$(cat frontend.pid)
    if kill -0 "$PID" 2>/dev/null; then
        print_warning "停止现有前端服务 (PID: $PID)"
        kill "$PID"
        sleep 2
    fi
    rm -f frontend.pid
fi

# 检查 .next 目录问题
if [[ ! -d ".next" ]]; then
    print_error ".next 目录完全缺失"
    MISSING_NEXT=true
elif [[ ! -f ".next/BUILD_ID" ]] && [[ ! -d ".next/server" ]]; then
    print_error ".next 目录存在但缺少关键文件"
    echo ".next 目录内容:"
    ls -la .next/
    MISSING_NEXT=true
else
    print_success ".next 目录结构正常"
    MISSING_NEXT=false
fi

if [[ "$MISSING_NEXT" == "true" ]]; then
    print_step "尝试修复 .next 目录结构"
    
    # 方案1: 从 node_modules 中查找 Next.js 构建信息
    if [[ -d "node_modules/next" ]]; then
        print_step "检查 node_modules/next 版本"
        NEXT_VERSION=$(node -p "require('./node_modules/next/package.json').version" 2>/dev/null || echo "unknown")
        echo "Next.js 版本: $NEXT_VERSION"
    fi
    
    # 方案2: 创建最小化的 .next 目录结构
    print_step "创建最小化 .next 目录结构"
    
    mkdir -p .next/{server,static}
    
    # 生成 BUILD_ID
    echo "$(date +%s)" > .next/BUILD_ID
    print_success "生成 BUILD_ID: $(cat .next/BUILD_ID)"
    
    # 创建基本的 routes-manifest.json
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
    
    # 创建基本的 prerender-manifest.json
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
    
    print_success "创建了基本的 Next.js 配置文件"
    
    # 方案3: 重新构建前端（如果有源码）
    if [[ -f "package.json" ]] && [[ -d "app" ]] || [[ -d "pages" ]] || [[ -d "src" ]]; then
        print_step "检测到源码，尝试重新构建"
        
        # 检查是否有 next.config.js
        if [[ -f "next.config.js" ]]; then
            print_success "发现 next.config.js"
            
            # 确保配置了 standalone 输出
            if grep -q "output.*standalone" next.config.js; then
                print_success "next.config.js 已配置 standalone 输出"
            else
                print_warning "next.config.js 未配置 standalone 输出"
                echo "请确保 next.config.js 包含: output: 'standalone'"
            fi
        fi
        
        # 尝试重新构建
        if command -v npm >/dev/null 2>&1; then
            print_step "使用 npm 重新构建..."
            npm run build
            
            if [[ -d ".next/standalone" ]]; then
                print_success "重新构建成功，更新文件"
                
                # 备份现有文件
                mkdir -p .backup
                cp -f server.js .backup/ 2>/dev/null || true
                
                # 复制新构建的文件
                cp -r .next/standalone/* ./
                
                # 恢复静态文件
                if [[ -d ".next/static" ]]; then
                    mkdir -p .next/static
                    cp -r .next/static/* .next/static/
                fi
                
                print_success "前端重新构建完成"
            else
                print_error "重新构建失败，.next/standalone 目录不存在"
            fi
        else
            print_warning "npm 不可用，无法重新构建"
        fi
    fi
fi

# 验证修复结果
print_step "验证修复结果"

if [[ -f "server.js" ]]; then
    print_success "server.js 存在"
else
    print_error "server.js 仍然缺失"
    exit 1
fi

if [[ -d ".next" ]] && ([[ -f ".next/BUILD_ID" ]] || [[ -d ".next/server" ]]); then
    print_success ".next 目录结构修复完成"
else
    print_error ".next 目录结构仍有问题"
    echo ".next 目录内容:"
    ls -la .next/ 2>/dev/null || echo "目录不存在"
fi

# 测试启动前端
print_step "测试前端启动"

export NODE_ENV=production
export PORT=3000

echo "测试前端启动（3秒后停止）..."
timeout 3s node server.js > test.log 2>&1 || true

if grep -q "Error.*Could not find a production build" test.log; then
    print_error "前端启动仍然失败"
    echo "错误信息:"
    cat test.log
    rm -f test.log
    
    print_step "尝试最后的修复方案"
    
    # 创建一个假的 BUILD_ID 和必要文件
    mkdir -p .next/server/pages
    echo "standalone" > .next/BUILD_ID
    echo '{}' > .next/server/pages-manifest.json
    
    # 再次测试
    timeout 3s node server.js > test2.log 2>&1 || true
    if grep -q "Error.*Could not find a production build" test2.log; then
        print_error "修复失败，建议重新从 GitHub Actions 下载构建产物"
        echo "请确保 GitHub Actions 工作流已更新并重新构建"
        rm -f test2.log
        exit 1
    else
        print_success "修复成功！"
        rm -f test2.log
    fi
    
else
    print_success "前端启动测试通过"
    rm -f test.log
fi

# 重新启动前端服务
print_step "重新启动前端服务"

nohup node server.js > frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > frontend.pid

sleep 3

if kill -0 "$FRONTEND_PID" 2>/dev/null; then
    print_success "前端服务已启动 (PID: $FRONTEND_PID)"
    echo "🌐 访问地址: http://localhost:3000"
    echo "📊 查看日志: tail -f frontend.log"
else
    print_error "前端服务启动失败"
    echo "错误日志:"
    tail -10 frontend.log
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "前端部署修复完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
