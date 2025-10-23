/**
 * 核心数据模型类型定义
 * 
 * 这些类型与后端 API 响应结构保持一致
 * 
 * 对应关系:
 * - Project ↔ backend::models::ProjectResponse
 * - BlogPost ↔ backend::models::BlogPostResponse
 * - Activity ↔ backend::models::ActivityResponse
 * - CommitInfo ↔ backend::models::CommitResponse
 * - Stats ↔ backend::models::StatsResponse
 */

// ============= 项目相关类型 =============

/**
 * 项目信息
 * 对应后端: ProjectResponse
 */
export interface Project {
  /** 项目唯一ID */
  id: string;
  /** 项目名称 */
  name: string;
  /** 项目描述 */
  description: string;
  /** GitHub仓库链接 */
  html_url: string;
  /** 项目主页链接(可选) */
  homepage?: string;
  /** 主要编程语言 */
  language: string;
  /** GitHub星星数量 */
  stargazers_count: number;
  /** GitHub分叉数量 */
  forks_count: number;
  /** 项目标签列表 */
  topics: string[];
  /** 最后更新时间 (ISO 8601 格式) */
  updated_at: string;
}

// ============= 博客相关类型 =============

/**
 * 博客文章
 * 对应后端: BlogPostResponse
 */
export interface BlogPost {
  /** 文章唯一ID */
  id: string;
  /** 文章标题 */
  title: string;
  /** URL友好的标识符 */
  slug: string;
  /** 文章完整内容 (Markdown) */
  content: string;
  /** 文章摘要(可选) */
  excerpt?: string;
  /** 封面图片链接(可选) */
  cover_image?: string;
  /** 文章分类(可选) */
  category?: string;
  /** 文章标签列表 */
  tags: string[];
  /** 文章状态 */
  status: string;
  /** 浏览次数 */
  view_count: number;
  /** 是否为精选文章 */
  is_featured: boolean;
  /** 创建时间 (ISO 8601 格式) */
  created_at: string;
  /** 更新时间 (ISO 8601 格式) */
  updated_at: string;
  /** 发布时间 (ISO 8601 格式，可选) */
  published_at?: string;
}

/**
 * 博客分类
 * 对应后端: BlogCategory
 */
export interface BlogCategory {
  /** 分类名称 */
  name: string;
  /** URL友好的分类标识符 */
  slug: string;
  /** 该分类下的文章数量 */
  count: number;
}

// ============= 活动相关类型 =============

/**
 * Git活动记录
 * 对应后端: ActivityResponse
 */
export interface Activity {
  /** 日期 (YYYY-MM-DD 格式) */
  date: string;
  /** 提交次数 */
  commits: number;
  /** 新增代码行数 */
  additions: number;
  /** 删除代码行数 */
  deletions: number;
}

/**
 * 提交信息
 * 对应后端: CommitResponse
 */
export interface CommitInfo {
  /** 提交SHA值 */
  sha: string;
  /** 提交信息 */
  message: string;
  /** 提交作者 */
  author: string;
  /** 提交时间 (ISO 8601 格式) */
  date: string;
  /** 所属仓库名称 */
  repository: string;
}

// ============= 统计相关类型 =============

/**
 * 编程语言统计
 */
export interface LanguageStat {
  /** 语言名称 */
  name: string;
  /** 项目数量 */
  count: number;
  /** 占比百分比 */
  percentage: number;
}

/**
 * 整体统计数据
 * 对应后端: StatsResponse
 */
export interface Stats {
  /** 总项目数 */
  total_projects: number;
  /** 总提交数 */
  total_commits: number;
  /** 总新增行数 */
  total_additions: number;
  /** 总删除行数 */
  total_deletions: number;
  /** 各编程语言统计 */
  languages: LanguageStat[];
}

// ============= 通用类型 =============

/**
 * 分页查询参数
 */
export interface PaginationParams {
  /** 页码 (从1开始) */
  page?: number;
  /** 每页数量 */
  page_size?: number;
}

/**
 * API响应基础结构
 */
export interface ApiResponse<T> {
  /** 响应数据 */
  data: T;
  /** 是否成功 */
  success: boolean;
  /** 错误信息(可选) */
  message?: string;
}

/**
 * 错误响应结构
 */
export interface ApiError {
  /** 错误信息 */
  error: string;
  /** 错误代码(可选) */
  code?: string;
}