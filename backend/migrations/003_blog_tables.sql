-- 创建blog_posts表 (博客文章)
CREATE TABLE IF NOT EXISTS blog_posts (
    id CHAR(36) PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    slug VARCHAR(500) NOT NULL UNIQUE,
    content LONGTEXT NOT NULL,
    excerpt TEXT,
    cover_image VARCHAR(500),
    category VARCHAR(100),
    tags JSON,
    status ENUM('draft', 'published', 'archived') DEFAULT 'draft',
    view_count INT DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    published_at TIMESTAMP NULL,

    INDEX idx_slug (slug),
    INDEX idx_status (status),
    INDEX idx_category (category),
    INDEX idx_published_at (published_at),
    INDEX idx_is_featured (is_featured),
    INDEX idx_created_at (created_at),
    FULLTEXT idx_content (title, content, excerpt)
);

-- 创建blog_categories表 (博客分类)
CREATE TABLE IF NOT EXISTS blog_categories (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7) DEFAULT '#3B82F6',
    post_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_slug (slug),
    INDEX idx_name (name)
);

-- 创建admin_sessions表 (管理员会话)
CREATE TABLE IF NOT EXISTS admin_sessions (
    id CHAR(36) PRIMARY KEY,
    session_token VARCHAR(500) NOT NULL UNIQUE,
    user_id VARCHAR(100) NOT NULL,
    user_name VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_session_token (session_token),
    INDEX idx_user_id (user_id),
    INDEX idx_expires_at (expires_at)
);

-- 创建blog_uploads表 (上传文件管理)
CREATE TABLE IF NOT EXISTS blog_uploads (
    id CHAR(36) PRIMARY KEY,
    original_name VARCHAR(500) NOT NULL,
    file_name VARCHAR(500) NOT NULL,
    file_path VARCHAR(1000) NOT NULL,
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    upload_type ENUM('image', 'document', 'html') NOT NULL,
    post_id CHAR(36) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (post_id) REFERENCES blog_posts(id) ON DELETE SET NULL,
    INDEX idx_post_id (post_id),
    INDEX idx_upload_type (upload_type),
    INDEX idx_created_at (created_at)
);

-- 插入默认的博客分类
INSERT IGNORE INTO blog_categories (id, name, slug, description, color) VALUES
(UUID(), '金融学习', 'finance', '金融相关的学习笔记和心得分享', '#10B981'),
(UUID(), '技术分享', 'technology', '编程和技术相关的文章', '#3B82F6'),
(UUID(), '生活感悟', 'life', '个人生活和感悟分享', '#F59E0B'),
(UUID(), '学习笔记', 'notes', '各种学习笔记和总结', '#8B5CF6');
