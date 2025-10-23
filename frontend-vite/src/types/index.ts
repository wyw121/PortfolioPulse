/**
 * 类型定义统一导出
 * 
 * 提供项目中所有类型的集中导入点
 * 
 * 使用方式:
 * ```typescript
 * import { Project, BlogPost, ApiConfig } from '@/types';
 * ```
 */

// ============= 核心数据模型 =============
export type {
  // 项目相关
  Project,
  
  // 博客相关
  BlogPost,
  BlogCategory,
  
  // 活动相关
  Activity,
  CommitInfo,
  
  // 统计相关
  LanguageStat,
  Stats,
  
  // 通用类型
  PaginationParams,
  ApiResponse,
  ApiError
} from './models';

// ============= API 相关类型 =============
export type {
  // 请求参数
  BlogQueryParams,
  ActivityQueryParams,
  CommitQueryParams,
  
  // 响应类型
  ProjectsResponse,
  ProjectResponse,
  BlogPostsResponse,
  BlogPostResponse,
  BlogCategoriesResponse,
  ActivitiesResponse,
  CommitsResponse,
  StatsResponse,
  
  // 客户端配置
  ApiConfig,
  ApiRequestOptions,
  
  // 错误处理
  NetworkError,
  BusinessError,
  TimeoutError,
  ApiErrorType,
  
  // 缓存相关
  CacheEntry,
  CacheKey,
  
  // 工具类型
  ApiMethod,
  ApiMethodWithParams,
  ApiMethodWithId
} from './api';

// ============= 组件相关类型(预留) =============

/**
 * React 组件通用 Props
 */
export interface ComponentProps {
  /** CSS 类名 */
  className?: string;
  /** 子元素 */
  children?: React.ReactNode;
}

/**
 * 页面组件 Props
 */
export interface PageProps extends ComponentProps {
  /** 页面标题 */
  title?: string;
  /** 页面描述 */
  description?: string;
}

/**
 * 加载状态
 */
export type LoadingState = 'idle' | 'loading' | 'success' | 'error';

/**
 * 主题配置
 */
export interface ThemeConfig {
  /** 主题模式 */
  mode: 'light' | 'dark' | 'system';
  /** 主色调 */
  primaryColor?: string;
  /** 字体配置 */
  font?: {
    family: string;
    size: string;
  };
}

// ============= 状态管理相关类型(Zustand) =============

/**
 * 基础状态接口
 */
export interface BaseState {
  /** 加载状态 */
  loading: LoadingState;
  /** 错误信息 */
  error: string | null;
  /** 最后更新时间 */
  lastUpdated: number | null;
}

/**
 * 缓存状态接口
 */
export interface CacheState {
  /** 数据缓存时间(毫秒) */
  cacheTime: number;
  /** 是否需要刷新 */
  shouldRefetch: (cacheTime: number, maxAge: number) => boolean;
}

// ============= 路由相关类型 =============

/**
 * 路由参数
 */
export interface RouteParams {
  /** 项目slug */
  projectSlug?: string;
  /** 博客文章slug */
  blogSlug?: string;
  /** 分类slug */
  categorySlug?: string;
}

/**
 * 面包屑项
 */
export interface BreadcrumbItem {
  /** 显示文本 */
  label: string;
  /** 链接地址(可选) */
  href?: string;
  /** 是否为当前页面 */
  active?: boolean;
}

// ============= 表单相关类型 =============

/**
 * 表单字段验证规则
 */
export interface ValidationRule {
  /** 是否必填 */
  required?: boolean;
  /** 最小长度 */
  minLength?: number;
  /** 最大长度 */
  maxLength?: number;
  /** 正则表达式模式 */
  pattern?: RegExp;
  /** 自定义验证函数 */
  validator?: (value: any) => string | null;
}

/**
 * 表单字段状态
 */
export interface FieldState {
  /** 字段值 */
  value: any;
  /** 是否被触摸过 */
  touched: boolean;
  /** 错误信息 */
  error: string | null;
}

// ============= 工具类型扩展 =============

/**
 * 深度可选类型
 */
export type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

/**
 * 深度必需类型  
 */
export type DeepRequired<T> = {
  [P in keyof T]-?: T[P] extends object ? DeepRequired<T[P]> : T[P];
};

/**
 * 选择性必需类型
 */
export type PartialBy<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;

/**
 * 选择性可选类型
 */
export type RequiredBy<T, K extends keyof T> = Omit<T, K> & Required<Pick<T, K>>;