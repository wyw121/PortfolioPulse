/**
 * 项目演示管理器
 * 用于处理项目演示链接和预览功能
 */

interface DemoConfig {
  available: boolean;
  url?: string;
  description: string;
  features: string[];
}

interface ProjectDemo {
  [key: string]: DemoConfig;
}

export const PROJECT_DEMOS: ProjectDemo = {
  "AI Web Generator": {
    available: true,
    url: "https://ai-generator-demo.netlify.app",
    description: "在线体验DALL-E 3文生图功能，支持中文提示词",
    features: [
      "实时星空动画背景",
      "DALL-E 3图像生成",
      "响应式界面设计",
      "支持中英文提示词",
    ],
  },
  QuantConsole: {
    available: false, // 暂时不可用，准备部署中
    description: "加密货币交易控制台演示版本准备中",
    features: ["实时价格监控", "多交易所数据", "技术指标分析", "风险管理工具"],
  },
  "SmartCare Cloud": {
    available: false, // 暂时不可用，准备部署中
    description: "智慧医养平台演示版本准备中",
    features: ["老人档案管理", "健康监测预警", "设备管理系统", "数据分析报表"],
  },
};

/**
 * 获取项目演示配置
 */
export function getDemoConfig(projectTitle: string): DemoConfig | null {
  return PROJECT_DEMOS[projectTitle] || null;
}

/**
 * 检查演示是否可用
 */
export function isDemoAvailable(projectTitle: string): boolean {
  const config = getDemoConfig(projectTitle);
  return config?.available || false;
}

/**
 * 获取演示URL
 */
export function getDemoUrl(projectTitle: string): string | null {
  const config = getDemoConfig(projectTitle);
  return config?.url || null;
}

/**
 * 处理演示按钮点击
 */
export function handleDemoClick(projectTitle: string, githubUrl: string) {
  const config = getDemoConfig(projectTitle);

  if (config?.available && config.url) {
    // 如果演示可用，打开演示链接
    window.open(config.url, "_blank", "noopener,noreferrer");
  } else {
    // 如果演示不可用，显示即将上线的提示并跳转到GitHub
    const message = `${projectTitle} 演示版本正在准备中！\n\n${
      config?.description || "敬请期待..."
    }\n\n现在将跳转到GitHub查看源代码。`;

    if (confirm(message)) {
      window.open(githubUrl, "_blank", "noopener,noreferrer");
    }
  }
}
