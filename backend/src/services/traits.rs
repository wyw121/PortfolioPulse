//! Service 层的 Trait 定义
//! 
//! 通过 Trait 定义统一的接口，实现依赖注入和更好的测试性

use crate::models::*;
use anyhow::Result;
use async_trait::async_trait;

// ============= 项目服务 Trait =============

#[async_trait]
pub trait ProjectService: Send + Sync {
    /// 获取所有项目
    async fn get_all_projects(&self) -> Result<Vec<ProjectResponse>>;
    
    /// 根据 slug 获取项目
    async fn get_project_by_slug(&self, slug: &str) -> Result<Option<ProjectResponse>>;
    
    /// 获取精选项目
    async fn get_featured_projects(&self) -> Result<Vec<ProjectResponse>>;
}

// ============= 博客服务 Trait =============

#[async_trait]
pub trait BlogService: Send + Sync {
    /// 获取已发布的博客文章
    async fn get_published_posts(&self, page: u32, page_size: u32) -> Result<Vec<BlogPost>>;
    
    /// 根据 slug 获取博客文章
    async fn get_post_by_slug(&self, slug: &str) -> Result<Option<BlogPost>>;
    
    /// 获取精选博客文章
    async fn get_featured_posts(&self, limit: usize) -> Result<Vec<BlogPost>>;
}

// ============= 活动服务 Trait =============

#[async_trait]
pub trait ActivityService: Send + Sync {
    /// 获取最近N天的活动数据
    async fn get_recent(&self, days: i32) -> Result<Vec<ActivityResponse>>;
}

// ============= 提交服务 Trait =============

#[async_trait]
pub trait CommitService: Send + Sync {
    /// 获取最近的提交记录
    async fn get_recent(&self, limit: i32) -> Result<Vec<CommitResponse>>;
}

// ============= 统计服务 Trait =============

#[async_trait]
pub trait StatsService: Send + Sync {
    /// 获取整体统计数据
    async fn get_overall(&self) -> Result<StatsResponse>;
}