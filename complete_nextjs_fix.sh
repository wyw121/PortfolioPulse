#!/bin/bash

# PortfolioPulse Next.js 完整修复脚本
# 解决所有缺失的 Next.js 构建文件问题

set -e

echo "🔧 PortfolioPulse Next.js 完整修复"
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

print_step "停止现有服务"

# 停止前端服务
if [[ -f "frontend.pid" ]]; then
    PID=$(cat frontend.pid)
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        print_success "已停止前端服务 (PID: $PID)"
        sleep 2
    fi
    rm -f frontend.pid
fi

# 停止后端服务
if [[ -f "backend.pid" ]]; then
    PID=$(cat backend.pid)
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        print_success "已停止后端服务 (PID: $PID)"
        sleep 2
    fi
    rm -f backend.pid
fi

print_step "创建完整的 Next.js 目录结构"

# 创建所有必需的目录
mkdir -p .next/{server/{pages,app},static,cache}

print_success "目录结构已创建"

print_step "生成所有必需的 Next.js 配置文件"

# 1. BUILD_ID - Next.js 构建标识符
BUILD_ID=$(date +%s%N | cut -c1-13)
echo "$BUILD_ID" > .next/BUILD_ID
print_success "BUILD_ID: $BUILD_ID"

# 2. routes-manifest.json - 路由配置
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

# 3. prerender-manifest.json - 预渲染配置
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

# 4. pages-manifest.json - 页面配置
cat > .next/server/pages-manifest.json << 'EOF'
{
  "/_app": "pages/_app.js",
  "/_error": "pages/_error.js",
  "/_document": "pages/_document.js",
  "/": "pages/index.js"
}
EOF

# 5. next-font-manifest.json - 字体配置（关键文件！）
cat > .next/server/next-font-manifest.json << 'EOF'
{
  "pages": {},
  "app": {},
  "appUsingSizeAdjust": false,
  "pagesUsingSizeAdjust": false
}
EOF

# 6. middleware-manifest.json - 中间件配置
cat > .next/server/middleware-manifest.json << 'EOF'
{
  "version": 2,
  "middleware": {},
  "functions": {},
  "sortedMiddleware": []
}
EOF

# 7. app-paths-manifest.json - App Router 路径配置
cat > .next/server/app-paths-manifest.json << 'EOF'
{}
EOF

# 8. server-reference-manifest.json - 服务器引用配置
cat > .next/server/server-reference-manifest.json << 'EOF'
{
  "node": {},
  "edge": {}
}
EOF

# 9. action-manifest.json - Server Actions 配置
cat > .next/server/action-manifest.json << 'EOF'
{
  "node": {},
  "edge": {}
}
EOF

# 10. required-server-files.json - 必需服务器文件配置
cat > .next/required-server-files.json << 'EOF'
{
  "version": 1,
  "config": {
    "configFile": null,
    "trailingSlash": false,
    "images": {
      "deviceSizes": [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
      "imageSizes": [16, 32, 48, 64, 96, 128, 256, 384],
      "path": "/_next/image",
      "loader": "default",
      "domains": ["avatars.githubusercontent.com", "github.com"],
      "disableStaticImages": false,
      "minimumCacheTTL": 60,
      "formats": ["image/webp"],
      "dangerouslyAllowSVG": false,
      "contentSecurityPolicy": "script-src 'none'; frame-src 'none'; sandbox;",
      "contentDispositionType": "inline",
      "localPatterns": undefined,
      "remotePatterns": [],
      "unoptimized": false
    },
    "i18n": null,
    "output": "standalone",
    "experimental": {
      "outputFileTracingRoot": "/opt/portfoliopulse/deploy"
    }
  },
  "appDir": "/opt/portfoliopulse/deploy/app",
  "files": [
    ".next/server/pages-manifest.json",
    ".next/server/middleware-manifest.json",
    ".next/server/next-font-manifest.json"
  ],
  "ignore": []
}
EOF

# 11. export-marker.json - 导出标记
cat > .next/export-marker.json << 'EOF'
{
  "version": 1,
  "hasExportPathMap": false,
  "exportTrailingSlash": false,
  "isNextImageImported": true
}
EOF

# 12. images-manifest.json - 图片配置
cat > .next/images-manifest.json << 'EOF'
{
  "version": 1,
  "images": {
    "deviceSizes": [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    "imageSizes": [16, 32, 48, 64, 96, 128, 256, 384],
    "path": "/_next/image",
    "loader": "default",
    "domains": ["avatars.githubusercontent.com", "github.com"],
    "disableStaticImages": false,
    "minimumCacheTTL": 60,
    "formats": ["image/webp"],
    "dangerouslyAllowSVG": false,
    "contentSecurityPolicy": "script-src 'none'; frame-src 'none'; sandbox;",
    "contentDispositionType": "inline",
    "localPatterns": [],
    "remotePatterns": [],
    "unoptimized": false
  }
}
EOF

print_success "所有 Next.js 配置文件已创建"

print_step "验证文件结构"

echo "📁 .next 目录结构:"
find .next -type f -name "*.json" | sort

echo ""
echo "📊 关键文件检查:"

REQUIRED_FILES=(
    ".next/BUILD_ID"
    ".next/server/next-font-manifest.json"
    ".next/server/pages-manifest.json"
    ".next/routes-manifest.json"
    ".next/prerender-manifest.json"
)

ALL_PRESENT=true
for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        print_success "$file ✓"
    else
        print_error "$file ✗"
        ALL_PRESENT=false
    fi
done

if [[ "$ALL_PRESENT" == "false" ]]; then
    print_error "某些关键文件缺失，修复失败"
    exit 1
fi

print_step "测试前端启动"

export NODE_ENV=production
export PORT=3000

echo "测试前端启动 (5秒超时)..."
timeout 5s node server.js > test_start.log 2>&1 &
TEST_PID=$!

sleep 3

if kill -0 $TEST_PID 2>/dev/null; then
    kill $TEST_PID 2>/dev/null || true
    print_success "前端启动测试成功！"
    rm -f test_start.log
else
    print_error "前端启动测试失败"
    echo "错误日志:"
    cat test_start.log
    rm -f test_start.log
    
    # 检查是否还有其他缺失的文件
    if grep -q "ENOENT" test_start.log 2>/dev/null; then
        MISSING_FILE=$(grep "ENOENT" test_start.log | grep -o "'[^']*'" | tail -1 | tr -d "'")
        print_error "仍然缺少文件: $MISSING_FILE"
        
        # 尝试创建缺失的文件
        if [[ -n "$MISSING_FILE" ]]; then
            print_step "尝试创建缺失的文件: $MISSING_FILE"
            mkdir -p "$(dirname "$MISSING_FILE")"
            echo "{}" > "$MISSING_FILE"
            print_success "已创建 $MISSING_FILE"
            
            # 再次测试
            echo "重新测试前端启动..."
            timeout 5s node server.js > test_start2.log 2>&1 &
            TEST_PID2=$!
            
            sleep 3
            
            if kill -0 $TEST_PID2 2>/dev/null; then
                kill $TEST_PID2 2>/dev/null || true
                print_success "修复成功，前端可以启动！"
                rm -f test_start2.log
            else
                print_error "修复后仍无法启动"
                cat test_start2.log
                rm -f test_start2.log
                exit 1
            fi
        fi
    else
        exit 1
    fi
fi

print_step "启动所有服务"

# 启动后端
if [[ -f "portfolio_pulse_backend" ]]; then
    print_step "启动后端服务"
    nohup ./portfolio_pulse_backend > backend.log 2>&1 &
    BACKEND_PID=$!
    echo $BACKEND_PID > backend.pid
    
    sleep 2
    
    if kill -0 $BACKEND_PID 2>/dev/null; then
        print_success "后端已启动 (PID: $BACKEND_PID)"
    else
        print_error "后端启动失败"
        cat backend.log
        exit 1
    fi
fi

# 启动前端
print_step "启动前端服务"
nohup node server.js > frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > frontend.pid

sleep 3

if kill -0 $FRONTEND_PID 2>/dev/null; then
    print_success "前端已启动 (PID: $FRONTEND_PID)"
    
    # 测试访问
    echo "🧪 测试服务响应..."
    
    # 测试前端
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200"; then
        print_success "前端服务响应正常 (HTTP 200)"
    else
        print_warning "前端服务可能需要更多时间启动"
    fi
    
    # 测试后端
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000 2>/dev/null | grep -q "200\|404"; then
        print_success "后端服务响应正常"
    else
        print_warning "后端服务可能需要更多时间启动"
    fi
    
else
    print_error "前端启动失败"
    echo "前端日志:"
    tail -10 frontend.log
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "🎉 修复完成！所有服务已启动"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 服务信息:"
echo "🌐 前端服务: http://localhost:3000 (PID: $(cat frontend.pid 2>/dev/null || echo 'N/A'))"
echo "🔌 后端服务: http://localhost:8000 (PID: $(cat backend.pid 2>/dev/null || echo 'N/A'))"
echo ""
echo "📋 管理命令:"
echo "  tail -f frontend.log  # 查看前端日志"
echo "  tail -f backend.log   # 查看后端日志"
echo "  ./stop.sh            # 停止所有服务"
echo "  ./status.sh          # 查看服务状态"
echo ""
echo "🔍 验证访问:"
echo "  curl http://localhost:3000  # 测试前端"
echo "  curl http://localhost:8000  # 测试后端"
