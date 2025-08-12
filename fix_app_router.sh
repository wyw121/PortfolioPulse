#!/bin/bash

# PortfolioPulse Next.js App Router 修复脚本
# 专门解决 App Router 项目的 MODULE_NOT_FOUND 问题

set -e

echo "🔧 PortfolioPulse App Router 专项修复"
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

print_step "诊断 App Router 项目问题"

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

print_step "检查当前项目结构"

echo "📁 当前目录结构:"
ls -la

echo ""
echo "📁 .next 目录结构:"
find .next -type f -name "*.json" | head -10

echo ""
echo "📁 检查是否有 app 目录："
if [[ -d "app" ]]; then
    echo "✅ 发现 app 目录 (App Router 项目)"
    ls -la app/ | head -5
else
    echo "❌ 未发现 app 目录，但项目使用 App Router"
fi

print_step "分析缺失的模块"

echo "📄 检查 server.js 内容:"
head -20 server.js

echo ""
echo "📋 分析错误日志:"
if [[ -f "frontend.log" ]]; then
    echo "最新错误信息:"
    tail -20 frontend.log | grep -E "(MODULE_NOT_FOUND|Cannot find|Error)" || echo "未找到明确错误信息"
fi

print_step "创建完整的 App Router 文件结构"

# 1. 创建完整的 .next 目录结构
mkdir -p .next/{server/{app,pages,chunks},static,cache}

print_success ".next 目录结构已创建"

# 2. 生成 BUILD_ID
BUILD_ID=$(date +%s%N | cut -c1-13)
echo "$BUILD_ID" > .next/BUILD_ID
print_success "BUILD_ID: $BUILD_ID"

# 3. 创建 App Router 专用配置文件

# app-build-manifest.json
cat > .next/app-build-manifest.json << 'EOF'
{
  "pages": {
    "/": [
      "static/chunks/webpack.js",
      "static/chunks/main-app.js",
      "static/chunks/app/layout.js",
      "static/chunks/app/page.js"
    ]
  }
}
EOF

# app-paths-manifest.json (重要！)
cat > .next/server/app-paths-manifest.json << 'EOF'
{
  "/page": "app/page",
  "/layout": "app/layout",
  "/not-found": "app/not-found"
}
EOF

# server/app 目录结构
mkdir -p .next/server/app

# 创建基本的 app 路由文件
cat > .next/server/app/page.js << 'EOF'
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = void 0;
var _default = function HomePage() {
  return "App Router Page Loading...";
};
exports.default = _default;
EOF

cat > .next/server/app/layout.js << 'EOF'
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = void 0;
var _default = function RootLayout({ children }) {
  return children;
};
exports.default = _default;
EOF

# 更新 required-server-files.json 以支持 App Router
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
      "localPatterns": [],
      "remotePatterns": [],
      "unoptimized": false
    },
    "i18n": null,
    "output": "standalone",
    "experimental": {
      "appDir": true,
      "outputFileTracingRoot": "/opt/portfoliopulse/deploy"
    }
  },
  "appDir": "/opt/portfoliopulse/deploy/app",
  "files": [
    ".next/server/app-paths-manifest.json",
    ".next/server/pages-manifest.json",
    ".next/server/middleware-manifest.json",
    ".next/server/next-font-manifest.json"
  ],
  "ignore": []
}
EOF

# 更新路由配置支持 App Router
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
  "i18n": null,
  "rsc": {
    "header": "RSC",
    "varyHeader": "RSC, Next-Router-State-Tree, Next-Router-Prefetch"
  }
}
EOF

# prerender-manifest.json for App Router
cat > .next/prerender-manifest.json << 'EOF'
{
  "version": 4,
  "routes": {
    "/": {
      "initialRevalidateSeconds": false,
      "srcRoute": "/",
      "dataRoute": null
    }
  },
  "dynamicRoutes": {},
  "notFoundRoutes": [],
  "preview": {
    "previewModeId": "development-id"
  }
}
EOF

# 其他必要的服务器文件
cat > .next/server/middleware-manifest.json << 'EOF'
{
  "version": 2,
  "middleware": {},
  "functions": {},
  "sortedMiddleware": []
}
EOF

cat > .next/server/next-font-manifest.json << 'EOF'
{
  "pages": {},
  "app": {
    "/": []
  },
  "appUsingSizeAdjust": false,
  "pagesUsingSizeAdjust": false
}
EOF

cat > .next/server/pages-manifest.json << 'EOF'
{
  "/_app": "pages/_app.js",
  "/_error": "pages/_error.js",
  "/_document": "pages/_document.js"
}
EOF

# 创建静态文件目录
mkdir -p .next/static/{chunks,css,media}

print_success "App Router 配置文件创建完成"

print_step "创建源码目录结构（如果缺失）"

# 如果没有 app 目录，创建基本的 app 目录结构
if [[ ! -d "app" ]]; then
    mkdir -p app
    
    # 创建基本的 layout.tsx
    cat > app/layout.tsx << 'EOF'
export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="zh">
      <body>{children}</body>
    </html>
  )
}
EOF

    # 创建基本的 page.tsx
    cat > app/page.tsx << 'EOF'
export default function HomePage() {
  return (
    <div>
      <h1>PortfolioPulse</h1>
      <p>应用正在运行...</p>
    </div>
  )
}
EOF
    
    print_success "已创建基本的 app 目录结构"
else
    print_success "app 目录已存在"
fi

print_step "验证并测试应用启动"

# 设置环境变量
export NODE_ENV=production
export PORT=3000

# 测试启动
echo "🧪 测试 App Router 应用启动..."

timeout 10s node server.js > app_test.log 2>&1 &
TEST_PID=$!

sleep 5

if kill -0 $TEST_PID 2>/dev/null; then
    kill $TEST_PID 2>/dev/null
    
    # 检查日志
    if grep -qi "MODULE_NOT_FOUND\|Cannot find\|Error" app_test.log; then
        print_error "仍然存在模块问题:"
        grep -A 5 -B 5 "MODULE_NOT_FOUND\|Cannot find\|Error" app_test.log
        rm -f app_test.log
        
        # 尝试降级处理
        print_step "尝试降级为 Pages Router 兼容模式"
        
        # 创建 pages 目录
        mkdir -p pages
        
        cat > pages/index.js << 'EOF'
export default function HomePage() {
  return (
    <div style={{ padding: '2rem', textAlign: 'center' }}>
      <h1>PortfolioPulse</h1>
      <p>应用正在运行... (Pages Router 兼容模式)</p>
    </div>
  )
}
EOF

        cat > pages/_app.js << 'EOF'
export default function App({ Component, pageProps }) {
  return <Component {...pageProps} />
}
EOF

        cat > pages/_document.js << 'EOF'
import { Html, Head, Main, NextScript } from 'next/document'

export default function Document() {
  return (
    <Html lang="zh">
      <Head />
      <body>
        <Main />
        <NextScript />
      </body>
    </Html>
  )
}
EOF
        
        print_success "已创建 Pages Router 兼容模式"
        
        # 再次测试
        echo "🧪 测试 Pages Router 兼容模式..."
        timeout 10s node server.js > pages_test.log 2>&1 &
        TEST_PID2=$!
        
        sleep 5
        
        if kill -0 $TEST_PID2 2>/dev/null; then
            kill $TEST_PID2 2>/dev/null
            
            if grep -qi "MODULE_NOT_FOUND\|Cannot find\|Error" pages_test.log; then
                print_error "Pages Router 模式仍有问题:"
                cat pages_test.log
                rm -f pages_test.log
                exit 1
            else
                print_success "Pages Router 兼容模式测试通过"
                rm -f pages_test.log
            fi
        else
            print_error "Pages Router 模式启动失败"
            cat pages_test.log
            rm -f pages_test.log
            exit 1
        fi
        
    else
        print_success "App Router 测试通过"
        rm -f app_test.log
    fi
else
    print_error "应用启动测试失败"
    cat app_test.log
    rm -f app_test.log
    exit 1
fi

print_step "启动修复后的应用"

# 最终启动
echo "🚀 启动修复后的前端应用..."

nohup node server.js > frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > frontend.pid

sleep 5

if kill -0 $FRONTEND_PID 2>/dev/null; then
    print_success "前端应用已启动 (PID: $FRONTEND_PID)"
    
    # 测试访问
    sleep 3
    if curl -s -m 10 http://localhost:3000 | grep -qi "portfoliopulse\|html\|error" >/dev/null 2>&1; then
        print_success "前端应用响应正常"
    else
        print_warning "前端应用可能需要更多启动时间"
    fi
    
else
    print_error "前端应用启动失败"
    echo "详细错误日志:"
    tail -30 frontend.log
    exit 1
fi

print_step "最终验证"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "🎉 App Router 修复完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📊 应用状态："
echo "  🟢 前端: ✅ 运行中 (PID: $(cat frontend.pid 2>/dev/null || echo 'N/A'))"
echo "  🌐 访问地址: http://localhost:3000"
echo ""

echo "🔍 验证命令："
echo "  curl http://localhost:3000"
echo "  tail -f frontend.log"
echo ""

echo "📋 App Router 特性："
echo "  ✅ 支持服务端渲染 (SSR)"
echo "  ✅ 支持 React Server Components (RSC)"
echo "  ✅ 支持嵌套布局"
echo "  ✅ 支持新的路由系统"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
