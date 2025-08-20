/**
 * API客户端 - 用于与后端服务通信
 */

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";

export interface Project {
  id: string;
  name: string;
  description: string;
  html_url: string;
  homepage?: string;
  language: string;
  stargazers_count: number;
  forks_count: number;
  topics: string[];
  updated_at: string;
}

export interface ApiError {
  error: string;
}

/**
 * 获取所有项目
 */
export async function getProjects(): Promise<Project[]> {
  try {
    const response = await fetch(`${API_BASE_URL}/api/projects`);

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const projects = await response.json();
    return projects;
  } catch (error) {
    console.error("获取项目列表失败:", error);
    // 如果API调用失败，返回前端静态数据作为备用
    return getFallbackProjects();
  }
}

/**
 * 获取单个项目详情
 */
export async function getProject(id: string): Promise<Project | null> {
  try {
    const response = await fetch(`${API_BASE_URL}/api/projects/${id}`);

    if (!response.ok) {
      if (response.status === 404) {
        return null;
      }
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const project = await response.json();
    return project;
  } catch (error) {
    console.error(`获取项目详情失败 (ID: ${id}):`, error);
    return null;
  }
}

/**
 * 备用项目数据 - 当API不可用时使用
 */
function getFallbackProjects(): Project[] {
  return [
    {
      id: "1",
      name: "AI Web Generator",
      description:
        "基于DALL-E 3的智能网页图像生成器，集成前端星空动画和后端Rust服务，支持实时文生图功能。采用Actix-Web框架和OpenAI API，提供流畅的用户交互体验。",
      html_url: "https://github.com/wyw121/ai_web_generator",
      homepage: "https://demo.ai-generator.com",
      language: "Rust",
      stargazers_count: 15,
      forks_count: 3,
      topics: [
        "rust",
        "actix-web",
        "openai-api",
        "dall-e",
        "javascript",
        "html5-canvas",
      ],
      updated_at: new Date().toISOString(),
    },
    {
      id: "2",
      name: "QuantConsole",
      description:
        "专业级加密货币短线交易控制台，支持多交易所实时数据、价格监控预警、技术指标分析。集成Binance和OKX API，提供永续合约交易、用户认证和风险管理功能。",
      html_url: "https://github.com/wyw121/QuantConsole",
      homepage: "https://demo.quantconsole.com",
      language: "TypeScript",
      stargazers_count: 45,
      forks_count: 12,
      topics: [
        "react",
        "typescript",
        "rust",
        "cryptocurrency",
        "trading",
        "binance-api",
        "mysql",
        "redis",
      ],
      updated_at: new Date().toISOString(),
    },
    {
      id: "3",
      name: "SmartCare Cloud",
      description:
        "智慧医养大数据公共服务平台，实现医养结合的数字化服务。包含老人档案管理、健康监测预警、医疗设备管理和大数据分析，支持多角色权限控制。",
      html_url: "https://github.com/wyw121/SmartCare_Cloud",
      homepage: "https://demo.smartcare-cloud.com",
      language: "Java",
      stargazers_count: 32,
      forks_count: 8,
      topics: [
        "vue",
        "element-plus",
        "spring-boot",
        "mybatis-plus",
        "mysql",
        "healthcare",
        "big-data",
      ],
      updated_at: new Date().toISOString(),
    },
  ];
}
