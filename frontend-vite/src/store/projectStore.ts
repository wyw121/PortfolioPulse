/**
 * Zustand Store - 项目状态管理
 * 
 * 统一管理项目数据,避免重复请求和状态不一致
 */

import { create } from 'zustand';
import { devtools } from 'zustand/middleware';
import type { Project } from '@/types';

interface ProjectState {
  // 状态
  projects: Project[];
  isLoading: boolean;
  error: string | null;
  lastFetch: number | null;
  
  // 单个项目详情缓存
  projectDetails: Record<string, Project>;
  
  // Actions
  setProjects: (projects: Project[]) => void;
  setLoading: (isLoading: boolean) => void;
  setError: (error: string | null) => void;
  
  // 缓存项目详情
  setProjectDetail: (slug: string, project: Project) => void;
  getProjectDetail: (slug: string) => Project | undefined;
  
  // 清除缓存
  clearCache: () => void;
  
  // 辅助方法
  shouldRefetch: () => boolean;
}

// 缓存时间: 5分钟
const CACHE_TIME = 5 * 60 * 1000;

export const useProjectStore = create<ProjectState>()(
  devtools(
    (set, get) => ({
      // 初始状态
      projects: [],
      isLoading: false,
      error: null,
      lastFetch: null,
      projectDetails: {},
      
      // 设置项目列表
      setProjects: (projects) => set({ 
        projects, 
        lastFetch: Date.now(),
        error: null 
      }),
      
      // 设置加载状态
      setLoading: (isLoading) => set({ isLoading }),
      
      // 设置错误信息
      setError: (error) => set({ error, isLoading: false }),
      
      // 缓存项目详情
      setProjectDetail: (slug, project) => set((state) => ({
        projectDetails: {
          ...state.projectDetails,
          [slug]: project
        }
      })),
      
      // 获取缓存的项目详情
      getProjectDetail: (slug) => get().projectDetails[slug],
      
      // 清除所有缓存
      clearCache: () => set({
        projects: [],
        projectDetails: {},
        lastFetch: null,
        error: null
      }),
      
      // 判断是否需要重新获取数据
      shouldRefetch: () => {
        const { lastFetch } = get();
        if (!lastFetch) return true;
        return Date.now() - lastFetch > CACHE_TIME;
      }
    }),
    { name: 'ProjectStore' }
  )
);
