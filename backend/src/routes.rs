//! 路由配置模块
//! 
//! 将路由定义从 main.rs 分离,提供可测试、可维护的路由配置

use axum::{routing::get, Router};

use crate::handlers::*;
use crate::AppState;

/// 创建 API 路由
/// 
/// # 参数
/// * `state` - 应用状态,包含数据库连接池和GitHub令牌
/// 
/// # 返回
/// 配置好的 Router,包含所有 API 端点
/// 
/// # 路由列表
/// - GET `/health` - 健康检查
/// - GET `/projects` - 获取所有项目列表
/// - GET `/projects/:id` - 获取单个项目详情
/// - GET `/activity` - 获取Git活动记录
/// - GET `/commits` - 获取最近提交记录
/// - GET `/stats` - 获取统计数据
/// - GET `/blog/posts` - 获取博客文章列表
/// - GET `/blog/posts/:slug` - 获取单篇博客文章
/// - GET `/blog/featured` - 获取精选博客文章
/// - GET `/blog/categories` - 获取博客分类
pub fn create_api_routes(state: AppState) -> Router {
    Router::new()
        // 健康检查
        .route("/health", get(health_check))
        // 项目相关路由
        .route("/projects", get(get_projects))
        .route("/projects/:id", get(get_project))
        // Git 活动相关路由
        .route("/activity", get(get_activity))
        .route("/commits", get(get_recent_commits))
        // 统计数据路由
        .route("/stats", get(get_stats))
        // 博客相关路由(只读展示)
        .route("/blog/posts", get(get_blog_posts))
        .route("/blog/posts/:slug", get(get_blog_post))
        .route("/blog/featured", get(get_featured_blog_posts))
        .route("/blog/categories", get(get_blog_categories))
        // 绑定应用状态
        .with_state(state)
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_create_api_routes_compiles() {
        // 这个测试确保路由配置函数可以编译
        // 实际运行时测试需要真实的 AppState 实例
    }
}
