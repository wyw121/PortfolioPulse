# PortfolioPulse 本地测试命令

## 🚀 启动服务（在不同终端窗口中运行）

### 启动后端 (终端 1):
cd backend
$env:DATABASE_URL="mysql://portfoliopulse:testpass123@localhost:3306/portfolio_pulse_dev"
cargo run

### 启动前端 (终端 2):
cd frontend
npm run dev

## 📊 访问地址
- 前端: http://localhost:3000
- 后端 API: http://localhost:8000

## 🔧 测试命令
- 测试后端健康: curl http://localhost:8000/
- 测试 API: curl http://localhost:8000/api/projects

## 🛑 停止服务
Ctrl+C 在各自终端中停止服务
