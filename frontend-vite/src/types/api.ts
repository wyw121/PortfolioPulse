/**
 * API 客户端相关类型定义
 * 
 * 包含请求参数、响应类型、错误处理等
 */

import type { 
  Project, 
  BlogPost, 
  BlogCategory, 
  Activity, 
  CommitInfo, 
  Stats,
  PaginationParams,
  ApiError 
} from './models';

// ============= API 请求参数类型 =============

/**
 * 博客查询参数
 */
export interface BlogQueryParams extends PaginationParams {
  /** 分类过滤 */
  category?: string;
  /** 标签过滤 */
  tag?: string;
  /** 搜索关键词 */
  search?: string;
  /** 是否只显示精选 */
  featured?: boolean;
}

/**
 * 活动查询参数
 */
export interface ActivityQueryParams {
  /** 查询天数 */
  days?: number;
}

/**
 * 提交查询参数
 */
export interface CommitQueryParams {
  /** 限制数量 */
  limit?: number;
  /** 仓库过滤 */
  repository?: string;
}

// ============= API 响应类型 =============

/**
 * 项目列表响应
 */
export type ProjectsResponse = Project[];

/**
 * 单个项目响应
 */
export type ProjectResponse = Project;

/**
 * 博客文章列表响应
 */
export type BlogPostsResponse = BlogPost[];

/**
 * 单篇博客文章响应
 */
export type BlogPostResponse = BlogPost;

/**
 * 博客分类列表响应
 */
export type BlogCategoriesResponse = BlogCategory[];

/**
 * 活动列表响应
 */
export type ActivitiesResponse = Activity[];

/**
 * 提交列表响应
 */
export type CommitsResponse = CommitInfo[];

/**
 * 统计数据响应
 */
export type StatsResponse = Stats;

// ============= API 客户端配置 =============

/**
 * API 客户端配置
 */
export interface ApiConfig {
  /** API 基础URL */
  baseUrl: string;
  /** 请求超时时间(毫秒) */
  timeout?: number;
  /** 默认请求头 */
  defaultHeaders?: Record<string, string>;
  /** 是否启用缓存 */
  cache?: boolean;
  /** 缓存过期时间(毫秒) */
  cacheTimeout?: number;
}

/**
 * API 请求选项
 */
export interface ApiRequestOptions extends RequestInit {
  /** 是否跳过缓存 */
  skipCache?: boolean;
  /** 自定义超时时间 */
  timeout?: number;
}

// ============= 错误处理类型 =============

/**
 * 网络错误
 */
export interface NetworkError extends Error {
  code: 'NETWORK_ERROR';
  status?: number;
  statusText?: string;
}

/**
 * API 业务错误
 */
export interface BusinessError extends Error {
  code: 'BUSINESS_ERROR';
  apiError: ApiError;
}

/**
 * 超时错误
 */
export interface TimeoutError extends Error {
  code: 'TIMEOUT_ERROR';
  timeout: number;
}

/**
 * 所有可能的API错误类型
 */
export type ApiErrorType = NetworkError | BusinessError | TimeoutError;

// ============= 缓存相关类型 =============

/**
 * 缓存条目
 */
export interface CacheEntry<T> {
  /** 缓存数据 */
  data: T;
  /** 缓存时间戳 */
  timestamp: number;
  /** 过期时间(毫秒) */
  expiry: number;
}

/**
 * 缓存键类型
 */
export type CacheKey = 
  | 'projects'
  | 'featured-projects'
  | `project:${string}`
  | 'blog-posts'
  | 'featured-blog-posts'
  | `blog-post:${string}`
  | 'blog-categories'
  | 'activities'
  | 'commits'
  | 'stats';

// ============= 工具类型 =============

/**
 * API 方法返回类型
 */
export type ApiMethod<T> = () => Promise<T>;

/**
 * 带参数的 API 方法返回类型
 */
export type ApiMethodWithParams<T, P> = (params: P) => Promise<T>;

/**
 * 带ID参数的 API 方法返回类型
 */
export type ApiMethodWithId<T> = (id: string) => Promise<T>;