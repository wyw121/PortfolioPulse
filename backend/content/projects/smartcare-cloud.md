---
name: "SmartCare Cloud"
description: "智慧医养大数据公共服务平台"
url: "https://github.com/wyw121/SmartCare_Cloud"
homepage: "https://demo.smartcare-cloud.com"
language: "Java"
stars: 32
forks: 8
topics: ["vue", "element-plus", "spring-boot", "mybatis-plus", "mysql", "healthcare", "big-data"]
status: "active"
featured: true
createdAt: "2023-03-20"
updatedAt: "2024-10-18"
---

## 项目简介

SmartCare Cloud 是一个智慧医养大数据公共服务平台，实现医养结合的数字化服务。包含老人档案管理、健康监测预警、医疗设备管理和大数据分析，支持多角色权限控制。

## 核心模块

### 👴 老人档案管理
- 基本信息录入
- 健康档案建立
- 家属联系人管理
- 医疗历史记录

### 💓 健康监测预警
- 生命体征实时监控
- 异常数据智能预警
- 健康趋势分析
- 用药提醒服务

### 🏥 医疗设备管理
- 设备档案管理
- 维护保养记录
- 设备状态监控
- 故障报修流程

### 📊 大数据分析
- 健康数据统计
- 疾病趋势分析
- 服务质量评估
- 决策支持报表

### 👥 多角色权限
- 管理员：系统配置
- 医生：诊疗记录
- 护士：日常护理
- 家属：信息查看

## 技术架构

### 前端
- **框架**: Vue 3 + TypeScript
- **UI 组件**: Element Plus
- **状态管理**: Pinia
- **图表**: ECharts
- **构建工具**: Vite

### 后端
- **框架**: Spring Boot 3.x
- **ORM**: MyBatis Plus
- **数据库**: MySQL 8.0
- **缓存**: Redis
- **安全**: Spring Security + JWT

### 部署
- **容器化**: Docker
- **反向代理**: Nginx
- **CI/CD**: GitHub Actions

## 功能特性

### 🔒 安全可靠
- 用户身份认证
- 细粒度权限控制
- 数据加密传输
- 操作日志审计
- 定期数据备份

### 📱 多端适配
- PC 端管理系统
- 移动端 H5 应用
- 响应式设计
- 离线数据缓存

### 🔔 智能预警
- 健康指标异常报警
- 设备故障及时通知
- 用药时间提醒
- 定期体检提醒

### 📈 数据可视化
- 健康趋势图表
- 服务统计看板
- 设备使用率分析
- 自定义报表生成

## 快速启动

```bash
# 克隆项目
git clone https://github.com/wyw121/SmartCare_Cloud.git

# 后端启动
cd backend
mvn spring-boot:run

# 前端启动
cd ../frontend
npm install
npm run dev

# 访问系统
open http://localhost:5173
```

## 系统要求

- JDK 17+
- Node.js 18+
- MySQL 8.0+
- Redis 6.0+
- Maven 3.8+

## 数据库设计

### 核心表结构
- `elderly_info` - 老人基本信息
- `health_records` - 健康记录
- `medical_devices` - 医疗设备
- `alert_rules` - 预警规则
- `system_users` - 系统用户

## 性能指标

- 响应时间: <200ms (95%)
- 并发用户: 500+
- 数据准确率: 99.9%
- 系统可用性: 99.95%

## 应用场景

- 养老院智慧管理
- 社区居家养老服务
- 医养结合机构
- 康复中心管理

## 合规认证

- 符合《个人信息保护法》
- 医疗数据安全规范
- 卫生信息标准化

## 未来规划

- [ ] AI 健康风险评估
- [ ] 远程医疗会诊
- [ ] 智能硬件接入 (IoT)
- [ ] 区块链数据存证

## 开源协议

Apache License 2.0
