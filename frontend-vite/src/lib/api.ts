/**
 * API客户端 - 用于与后端服务通信
 * 
 * 升级版本，集成统一错误处理、重试机制和请求拦截
 */

import type { Project, BlogPost } from '@/types';
import { ApiError, ApiErrorHandler, ApiErrorCode, createApiError } from './apiError';

// 配置
const API_BASE_URL = import.meta.env.VITE_API_URL || "";
const DEFAULT_TIMEOUT = 10000; // 10秒超时
const MAX_RETRIES = 3;

/**
 * 增强的 fetch 封装
 * 支持超时、重试和统一错误处理
 */
async function enhancedFetch(
  url: string, 
  options: RequestInit & { timeout?: number; retries?: number } = {}
): Promise<Response> {
  const { timeout = DEFAULT_TIMEOUT, retries = MAX_RETRIES, ...fetchOptions } = options;
  
  // 创建AbortController用于超时控制
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  try {
    const response = await fetch(url, {
      ...fetchOptions,
      signal: controller.signal
    });
    
    clearTimeout(timeoutId);
    
    // 处理HTTP错误状态
    if (!response.ok) {
      const apiError = await ApiErrorHandler.parseErrorResponse(response);
      throw apiError;
    }
    
    return response;
  } catch (error) {
    clearTimeout(timeoutId);
    
    // 如果是ApiError，直接抛出
    if (error instanceof ApiError) {
      throw error;
    }
    
    // 解析网络错误
    const apiError = ApiErrorHandler.parseNetworkError(error);
    
    // 如果可以重试且还有重试次数
    if (apiError.isRetryable() && retries > 0) {
      console.warn(`Request failed, retrying... (${MAX_RETRIES - retries + 1}/${MAX_RETRIES})`);
      await new Promise(resolve => setTimeout(resolve, 1000 * (MAX_RETRIES - retries + 1))); // 指数退避
      return enhancedFetch(url, { ...options, retries: retries - 1 });
    }
    
    throw apiError;
  }
}

/**
 * 获取所有项目
 */
export async function getProjects(): Promise<Project[]> {
  try {
    const response = await enhancedFetch(`${API_BASE_URL}/api/projects`);
    const projects = await response.json();
    return projects;
  } catch (error) {
    // 记录错误
    if (error instanceof ApiError) {
      ApiErrorHandler.logError(error, { context: 'getProjects' });
      
      // 对于网络错误，可以返回缓存数据作为降级
      if (error.isNetworkError()) {
        console.warn("网络错误，返回备用数据");
        return getFallbackProjects();
      }
    }
    
    // 重新抛出错误，让调用方处理
    throw error;
  }
}

/**
 * 获取单个项目详情
 */
export async function getProjectBySlug(slug: string): Promise<Project> {
  if (!slug) {
    throw createApiError.badRequest("项目ID不能为空");
  }

  try {
    const response = await enhancedFetch(`${API_BASE_URL}/api/projects/${encodeURIComponent(slug)}`);
    const project = await response.json();
    return project;
  } catch (error) {
    if (error instanceof ApiError) {
      ApiErrorHandler.logError(error, { context: 'getProjectBySlug', slug });
    }
    throw error;
  }
}

/**
 * 获取博客文章列表
 */
export async function getBlogPosts(): Promise<BlogPost[]> {
  try {
    const response = await enhancedFetch(`${API_BASE_URL}/api/blog/posts`);
    const posts = await response.json();
    return posts;
  } catch (error) {
    if (error instanceof ApiError) {
      ApiErrorHandler.logError(error, { context: 'getBlogPosts' });
      
      // 对于博客文章，如果获取失败可以返回空数组
      if (error.isNetworkError()) {
        console.warn("网络错误，返回空博客列表");
        return [];
      }
    }
    throw error;
  }
}

/**
 * 获取单个博客文章
 */
export async function getBlogPost(slug: string): Promise<BlogPost | null> {
  if (!slug) {
    throw createApiError.badRequest("博客文章slug不能为空");
  }

  try {
    const response = await enhancedFetch(`${API_BASE_URL}/api/blog/posts/${encodeURIComponent(slug)}`);
    const post = await response.json();
    return post;
  } catch (error) {
    if (error instanceof ApiError) {
      ApiErrorHandler.logError(error, { context: 'getBlogPost', slug });
      
      // 404错误返回null，其他错误重新抛出
      if (error.code === ApiErrorCode.NOT_FOUND) {
        return null;
      }
    }
    throw error;
  }
}

/**
 * 获取项目统计数据
 */
export async function getProjectStats() {
  try {
    const response = await enhancedFetch(`${API_BASE_URL}/api/stats`);
    return await response.json();
  } catch (error) {
    if (error instanceof ApiError) {
      ApiErrorHandler.logError(error, { context: 'getProjectStats' });
      
      // 对于统计数据，如果获取失败返回默认值
      if (error.isNetworkError()) {
        console.warn("网络错误，返回默认统计数据");
        return {
          total_projects: 0,
          total_stars: 0,
          total_forks: 0,
          languages: [],
        };
      }
    }
    throw error;
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
