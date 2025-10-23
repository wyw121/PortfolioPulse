---
name: "QuantConsole"
description: "专业级加密货币短线交易控制台"
url: "https://github.com/wyw121/QuantConsole"
homepage: "https://demo.quantconsole.com"
language: "TypeScript"
stars: 45
forks: 12
topics: ["react", "typescript", "rust", "cryptocurrency", "trading", "binance-api", "mysql", "redis"]
status: "active"
featured: true
createdAt: "2023-06-10"
updatedAt: "2024-10-22"
---

## 项目简介

QuantConsole 是一个专业级加密货币短线交易控制台，支持多交易所实时数据、价格监控预警、技术指标分析。集成 Binance 和 OKX API，提供永续合约交易、用户认证和风险管理功能。

## 核心功能

### 📊 实时数据监控
- 多交易所行情聚合 (Binance, OKX)
- WebSocket 实时价格推送
- K线图表，多时间周期切换
- 深度图、成交记录展示

### 🚨 智能预警系统
- 价格突破预警
- 技术指标触发通知
- 波动率异常监测
- 自定义预警规则

### 📈 技术分析工具
- 多种技术指标 (MA, MACD, RSI, BOLL)
- 趋势线绘制
- 支撑阻力位标注
- 形态识别

### ⚡ 快速交易
- 一键下单
- 止盈止损设置
- 仓位管理
- 交易历史记录

## 技术架构

### 前端
- **框架**: React 18 + TypeScript
- **状态管理**: Zustand
- **图表**: Lightweight Charts
- **样式**: Tailwind CSS

### 后端
- **API 服务**: Rust + Axum
- **数据库**: MySQL (用户/订单)
- **缓存**: Redis (实时行情)
- **消息队列**: RabbitMQ (预警推送)

### 基础设施
- **容器化**: Docker Compose
- **反向代理**: Nginx
- **监控**: Prometheus + Grafana

## 安全特性

- JWT 令牌认证
- API 密钥加密存储
- 请求签名验证
- 风险限额控制
- 操作日志审计

## 快速部署

```bash
# 克隆项目
git clone https://github.com/wyw121/QuantConsole.git

# 配置环境变量
cp .env.example .env
# 编辑 .env 填入 API 密钥

# 启动服务
docker-compose up -d

# 访问控制台
open http://localhost:3000
```

## 系统要求

- Node.js 18+
- Rust 1.70+
- MySQL 8.0+
- Redis 6.0+

## 性能指标

- WebSocket 延迟: <50ms
- 行情更新频率: 100ms
- 并发用户: 1000+
- 数据可靠性: 99.99%

## 路线图

- [ ] 支持更多交易所 (Bybit, Bitget)
- [ ] 量化策略回测模块
- [ ] 移动端 App
- [ ] AI 行情预测

## 免责声明

本项目仅供学习交流，不构成投资建议。加密货币交易存在风险，请谨慎决策。

## 开源协议

MIT License
