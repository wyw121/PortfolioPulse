#!/bin/bash

# PortfolioPulse 前端快速修复脚本
# 针对缺失 .next 目录的问题进行紧急修复

set -e

echo "🔧 PortfolioPulse 前端紧急修复"
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

print_step "当前目录结构诊断"
ls -la

# 停止现有服务
print_step "停止现有服务"
if [[ -f "frontend.pid" ]]; then
    PID=$(cat frontend.pid)
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        print_success "已停止前端服务 (PID: $PID)"
    fi
    rm -f frontend.pid
fi

if [[ -f "backend.pid" ]]; then
    PID=$(cat backend.pid)
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        print_success "已停止后端服务 (PID: $PID)"
    fi
    rm -f backend.pid
fi

# 分析问题
print_step "问题分析"

if [[ ! -d ".next" ]]; then
    print_error ".next 目录完全缺失"
    PROBLEM="missing_next_dir"
elif [[ -d ".next" ]] && [[ ! -f ".next/BUILD_ID" ]]; then
    print_error ".next 目录存在但缺少 BUILD_ID"
    PROBLEM="missing_build_id"
else
    print_warning "未检测到明显问题，但前端可能仍无法启动"
    PROBLEM="unknown"
fi

echo ""
echo "📋 问题原因：GitHub Actions 构建产物不完整"
echo "🎯 解决方案：手动重建前端应用"

# 检查 Node.js 环境
print_step "检查 Node.js 环境"
if ! command -v node >/dev/null 2>&1; then
    print_error "Node.js 未安装"
    echo "安装命令："
    echo "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -"
    echo "sudo apt-get install -y nodejs"
    exit 1
fi

NODE_VERSION=$(node --version)
print_success "Node.js 版本: $NODE_VERSION"

if ! command -v npm >/dev/null 2>&1; then
    print_error "npm 未安装"
    exit 1
fi

NPM_VERSION=$(npm --version)
print_success "npm 版本: $NPM_VERSION"

# 方案1: 直接修复（适用于缺少 .next 目录的情况）
if [[ "$PROBLEM" == "missing_next_dir" ]] || [[ "$PROBLEM" == "missing_build_id" ]]; then
    print_step "方案1：手动创建 Next.js 构建文件"

    # 创建 .next 目录结构
    mkdir -p .next/{server/pages,static}

    # 生成 BUILD_ID
    BUILD_ID=$(date +%s%N | cut -c1-13)
    echo "$BUILD_ID" > .next/BUILD_ID
    print_success "生成 BUILD_ID: $BUILD_ID"

    # 创建基本的路由配置
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

    # 创建预渲染配置
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

    # 创建页面配置
    cat > .next/server/pages-manifest.json << 'EOF'
{
  "/_app": "pages/_app.js",
  "/_error": "pages/_error.js",
  "/": "pages/index.js"
}
EOF

    print_success "基本 Next.js 配置文件创建完成"
fi

# 方案2: 尝试本地重建（如果有源码）
print_step "方案2：检查是否可以本地重建"

# 检查是否有 Next.js 源码结构
HAS_SOURCE=false
if [[ -d "app" ]] || [[ -d "pages" ]] || [[ -d "src" ]]; then
    HAS_SOURCE=true
    print_success "检测到 Next.js 源码结构"
elif [[ -f "package.json" ]] && grep -q "next" package.json; then
    HAS_SOURCE=true
    print_success "检测到 Next.js 项目配置"
else
    print_warning "未检测到 Next.js 源码，跳过重建"
fi

if [[ "$HAS_SOURCE" == "true" ]]; then
    print_step "尝试本地重建前端"

    # 检查 package.json 中的构建脚本
    if [[ -f "package.json" ]] && grep -q '"build"' package.json; then
        print_step "执行 npm run build"

        # 备份现有的 server.js
        if [[ -f "server.js" ]]; then
            cp server.js server.js.backup
            print_success "已备份 server.js"
        fi

        # 尝试重建
        if npm run build; then
            print_success "前端重建成功"

            # 检查新的构建产物
            if [[ -d ".next/standalone" ]]; then
                print_step "更新部署文件"

                # 复制新构建的文件
                cp -f .next/standalone/server.js ./

                # 复制或更新 .next 目录
                if [[ -d ".next/standalone/.next" ]]; then
                    rm -rf .next
                    cp -r .next/standalone/.next ./
                fi

                # 复制静态文件
                if [[ -d ".next/static" ]]; then
                    mkdir -p .next/static
                    cp -r .next/static/* .next/static/ 2>/dev/null || true
                fi

                print_success "部署文件更新完成"
            else
                print_warning "重建完成但未找到 standalone 输出"
            fi
        else
            print_error "前端重建失败"

            # 恢复备份
            if [[ -f "server.js.backup" ]]; then
                mv server.js.backup server.js
                print_success "已恢复 server.js 备份"
            fi
        fi
    else
        print_warning "package.json 中未找到 build 脚本"
    fi
fi

# 最终验证
print_step "验证修复结果"

echo "当前目录结构:"
ls -la

if [[ -d ".next" ]]; then
    echo ""
    echo ".next 目录内容:"
    ls -la .next/

    if [[ -f ".next/BUILD_ID" ]]; then
        print_success ".next/BUILD_ID 存在: $(cat .next/BUILD_ID)"
    else
        print_warning ".next/BUILD_ID 缺失"
    fi
fi

# 测试前端启动
print_step "测试前端启动"

export NODE_ENV=production
export PORT=3000

echo "测试前端启动 (5秒超时)..."
timeout 5s node server.js > test_start.log 2>&1 &
TEST_PID=$!

sleep 2

if kill -0 $TEST_PID 2>/dev/null; then
    print_success "前端启动测试成功"
    kill $TEST_PID 2>/dev/null || true
    rm -f test_start.log
else
    print_error "前端启动测试失败"
    echo "错误日志:"
    cat test_start.log
    rm -f test_start.log

    if grep -q "Could not find a production build" test_start.log 2>/dev/null; then
        print_error "仍然是 .next 目录问题"
        echo ""
        echo "🎯 建议解决方案："
        echo "1. 等待新的 GitHub Actions 构建完成"
        echo "2. 重新下载最新的构建产物"
        echo "3. 或者在本地重新构建整个项目"
    fi
    exit 1
fi

# 启动服务
print_step "启动服务"

# 启动后端
if [[ -f "portfolio_pulse_backend" ]]; then
    nohup ./portfolio_pulse_backend > backend.log 2>&1 &
    echo $! > backend.pid
    print_success "后端已启动 (PID: $(cat backend.pid))"
fi

# 启动前端
nohup node server.js > frontend.log 2>&1 &
echo $! > frontend.pid

sleep 3

if kill -0 $(cat frontend.pid) 2>/dev/null; then
    print_success "前端已启动 (PID: $(cat frontend.pid))"
    echo ""
    echo "🎉 修复完成！"
    echo "🌐 访问地址: http://localhost:3000"
    echo "🔌 后端API: http://localhost:8000"
    echo "📊 查看前端日志: tail -f frontend.log"
    echo "📊 查看后端日志: tail -f backend.log"
else
    print_error "前端启动失败"
    echo "前端日志:"
    tail -10 frontend.log
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "紧急修复完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
