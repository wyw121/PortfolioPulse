//! 请求模型模块
//! 
//! 集中管理所有API请求的查询参数和请求体模型

use serde::Deserialize;

/// Git 活动查询参数
/// 
/// # 查询参数
/// - `days`: 查询最近N天的活动(默认7天)
/// 
/// # 示例
/// ```
/// GET /api/activity?days=30
/// ```
#[derive(Debug, Deserialize)]
pub struct ActivityQuery {
    /// 查询最近N天的活动,默认7天
    pub days: Option<i32>,
}

/// 提交记录查询参数
/// 
/// # 查询参数
/// - `limit`: 返回的最大提交数量(默认10条)
/// 
/// # 示例
/// ```
/// GET /api/commits?limit=20
/// ```
#[derive(Debug, Deserialize)]
pub struct CommitQuery {
    /// 返回的最大提交数量,默认10条
    pub limit: Option<u32>,
}

/// 博客文章查询参数
/// 
/// # 查询参数
/// - `page`: 页码(默认1)
/// - `page_size`: 每页数量(默认10)
/// - `category`: 分类筛选(可选)
/// - `search`: 搜索关键词(可选)
/// 
/// # 示例
/// ```
/// GET /api/blog/posts?page=2&page_size=20&category=技术&search=Rust
/// ```
#[derive(Debug, Deserialize)]
pub struct BlogQuery {
    /// 页码,默认1
    pub page: Option<u32>,
    /// 每页数量,默认10
    pub page_size: Option<u32>,
    /// 分类筛选(可选)
    pub category: Option<String>,
    /// 搜索关键词(可选)
    pub search: Option<String>,
}

impl ActivityQuery {
    /// 获取查询天数,未指定则返回默认值7天
    pub fn days_or_default(&self) -> i32 {
        self.days.unwrap_or(7)
    }
}

impl CommitQuery {
    /// 获取限制数量,未指定则返回默认值10
    pub fn limit_or_default(&self) -> i32 {
        self.limit.unwrap_or(10) as i32
    }
}

impl BlogQuery {
    /// 获取页码,未指定则返回默认值1
    pub fn page_or_default(&self) -> u32 {
        self.page.unwrap_or(1)
    }

    /// 获取每页数量,未指定则返回默认值10
    pub fn page_size_or_default(&self) -> u32 {
        self.page_size.unwrap_or(10)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_activity_query_defaults() {
        let query = ActivityQuery { days: None };
        assert_eq!(query.days_or_default(), 7);

        let query = ActivityQuery { days: Some(30) };
        assert_eq!(query.days_or_default(), 30);
    }

    #[test]
    fn test_commit_query_defaults() {
        let query = CommitQuery { limit: None };
        assert_eq!(query.limit_or_default(), 10);

        let query = CommitQuery { limit: Some(50) };
        assert_eq!(query.limit_or_default(), 50);
    }

    #[test]
    fn test_blog_query_defaults() {
        let query = BlogQuery {
            page: None,
            page_size: None,
            category: None,
            search: None,
        };
        assert_eq!(query.page_or_default(), 1);
        assert_eq!(query.page_size_or_default(), 10);

        let query = BlogQuery {
            page: Some(5),
            page_size: Some(20),
            category: Some("技术".to_string()),
            search: Some("Rust".to_string()),
        };
        assert_eq!(query.page_or_default(), 5);
        assert_eq!(query.page_size_or_default(), 20);
    }
}
