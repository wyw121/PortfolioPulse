/**
 * 自定义 Hooks - 项目数据管理
 * 
 * 封装数据获取逻辑,提供统一的API
 */

import { useEffect } from 'react';
import { useProjectStore } from '@/store/projectStore';
import { getProjects, getProjectBySlug } from '@/lib/api';

/**
 * Hook: 获取所有项目
 * 
 * 特性:
 * - 自动缓存,避免重复请求
 * - 统一的加载和错误状态
 * - 5分钟缓存有效期
 */
export function useProjects() {
  const { 
    projects, 
    isLoading, 
    error,
    setProjects,
    setLoading,
    setError,
    shouldRefetch
  } = useProjectStore();

  useEffect(() => {
    // 如果有缓存且未过期,不重新获取
    if (projects.length > 0 && !shouldRefetch()) {
      return;
    }

    // 获取项目列表
    const fetchProjects = async () => {
      setLoading(true);
      try {
        const data = await getProjects();
        setProjects(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : '获取项目列表失败');
      } finally {
        setLoading(false);
      }
    };

    fetchProjects();
  }, [projects.length, shouldRefetch, setProjects, setLoading, setError]);

  return { projects, isLoading, error };
}

/**
 * Hook: 获取单个项目详情
 * 
 * @param slug - 项目 slug
 * 
 * 特性:
 * - 优先使用内存缓存
 * - 如果列表中已有数据,直接返回
 * - 否则单独请求详情
 */
export function useProject(slug: string | undefined) {
  const {
    projects,
    isLoading,
    error,
    getProjectDetail,
    setProjectDetail,
    setLoading,
    setError
  } = useProjectStore();

  useEffect(() => {
    if (!slug) return;

    // 1. 检查详情缓存
    const cached = getProjectDetail(slug);
    if (cached) return;

    // 2. 检查列表中是否已有
    const fromList = projects.find(p => p.id === slug);
    if (fromList) {
      setProjectDetail(slug, fromList);
      return;
    }

    // 3. 单独请求详情
    const fetchProject = async () => {
      setLoading(true);
      try {
        const data = await getProjectBySlug(slug);
        setProjectDetail(slug, data);
      } catch (err) {
        setError(err instanceof Error ? err.message : '获取项目详情失败');
      } finally {
        setLoading(false);
      }
    };

    fetchProject();
  }, [slug, projects, getProjectDetail, setProjectDetail, setLoading, setError]);

  const project = slug ? getProjectDetail(slug) : undefined;
  
  return { project, isLoading, error };
}

/**
 * Hook: 获取特色项目 (前3个)
 */
export function useFeaturedProjects() {
  const { projects, isLoading, error } = useProjects();
  
  const featuredProjects = projects.slice(0, 3);
  
  return { projects: featuredProjects, isLoading, error };
}
