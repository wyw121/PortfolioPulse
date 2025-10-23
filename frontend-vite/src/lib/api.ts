/**
 * API客户端 - 用于与后端服务通信
 */

// 在生产环境中，API 和前端在同一个域名下
const API_BASE_URL = import.meta.env.VITE_API_URL || "";

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

export interface BlogPost {
  id: string;
  title: string;
  excerpt: string;
  content: string;
  published_at: string;
  tags: string[];
  slug: string;
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
export async function getProjectBySlug(slug: string): Promise<Project> {
  try {
    const response = await fetch(`${API_BASE_URL}/api/projects/${slug}`);

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const project = await response.json();
    return project;
  } catch (error) {
    console.error(`获取项目 ${slug} 失败:`, error);
    throw error;
  }
}

/**
 * 获取博客文章列表
 */
export async function getBlogPosts(): Promise<BlogPost[]> {
  try {
    const response = await fetch(`${API_BASE_URL}/api/blog`);

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const posts = await response.json();
    return posts;
  } catch (error) {
    console.error("获取博客文章失败:", error);
    return [];
  }
}

/**
 * 获取单个博客文章
 */
export async function getBlogPost(slug: string): Promise<BlogPost | null> {
  try {
    const response = await fetch(`${API_BASE_URL}/api/blog/${slug}`);

    if (!response.ok) {
      if (response.status === 404) {
        return null;
      }
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const post = await response.json();
    return post;
  } catch (error) {
    console.error("获取博客文章失败:", error);
    return null;
  }
}

/**
 * 获取项目统计数据
 */
export async function getProjectStats() {
  try {
    const response = await fetch(`${API_BASE_URL}/api/stats`);

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error("获取统计数据失败:", error);
    return {
      total_projects: 0,
      total_stars: 0,
      total_forks: 0,
      languages: [],
    };
  }
}

/**
 * 备用项目数据（当API不可用时使用）
 */
function getFallbackProjects(): Project[] {
  return [
    {
      id: "1",
      name: "PortfolioPulse",
      description: "个人项目集动态平台 - 现代化的项目展示和追踪平台",
      html_url: "https://github.com/wyw121/PortfolioPulse",
      homepage: "",
      language: "TypeScript",
      stargazers_count: 0,
      forks_count: 0,
      topics: ["react", "typescript", "rust", "portfolio"],
      updated_at: new Date().toISOString(),
    },
    {
      id: "2",
      name: "示例项目",
      description: "这是一个示例项目",
      html_url: "https://github.com/example/project",
      homepage: "",
      language: "JavaScript",
      stargazers_count: 5,
      forks_count: 2,
      topics: ["javascript", "example"],
      updated_at: new Date().toISOString(),
    },
  ];
}
