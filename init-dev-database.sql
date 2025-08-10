-- PortfolioPulse 开发环境数据库初始化脚本

-- 删除现有数据库（谨慎！仅在开发环境使用）
DROP DATABASE IF EXISTS portfolio_pulse_dev;

-- 创建数据库
CREATE DATABASE portfolio_pulse_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE portfolio_pulse_dev;

-- 创建用户和权限（如果不存在）
CREATE USER IF NOT EXISTS 'portfoliopulse'@'localhost' IDENTIFIED BY 'testpass123';
GRANT ALL PRIVILEGES ON portfolio_pulse_dev.* TO 'portfoliopulse'@'localhost';
FLUSH PRIVILEGES;

-- 创建projects表
CREATE TABLE IF NOT EXISTS projects (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    html_url VARCHAR(500) NOT NULL,
    homepage VARCHAR(500),
    language VARCHAR(100),
    stargazers_count INT DEFAULT 0,
    forks_count INT DEFAULT 0,
    topics JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_name (name),
    INDEX idx_language (language),
    INDEX idx_is_active (is_active),
    INDEX idx_updated_at (updated_at)
);

-- 创建git_activities表
CREATE TABLE IF NOT EXISTS git_activities (
    id CHAR(36) PRIMARY KEY,
    project_id CHAR(36) NOT NULL,
    date DATE NOT NULL,
    commits INT DEFAULT 0,
    additions INT DEFAULT 0,
    deletions INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    UNIQUE KEY unique_project_date (project_id, date),
    INDEX idx_date (date),
    INDEX idx_project_id (project_id)
);

-- 创建commits表
CREATE TABLE IF NOT EXISTS commits (
    id CHAR(36) PRIMARY KEY,
    project_id CHAR(36) NOT NULL,
    sha VARCHAR(40) NOT NULL UNIQUE,
    message TEXT NOT NULL,
    author VARCHAR(255) NOT NULL,
    author_email VARCHAR(255) NOT NULL,
    date TIMESTAMP NOT NULL,
    additions INT DEFAULT 0,
    deletions INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    UNIQUE KEY unique_sha (sha),
    INDEX idx_project_id (project_id),
    INDEX idx_date (date),
    INDEX idx_author (author)
);

-- 创建learning_records表
CREATE TABLE IF NOT EXISTS learning_records (
    id CHAR(36) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    tags JSON,
    category VARCHAR(100),
    status ENUM('draft', 'published', 'archived') DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_category (category),
    INDEX idx_status (status),
    INDEX idx_updated_at (updated_at)
);

-- 插入测试数据
INSERT INTO projects (id, name, description, html_url, homepage, language, stargazers_count, forks_count, topics, is_active) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'PortfolioPulse', 'A modern portfolio showcase and dynamic tracking platform', 'https://github.com/yourusername/PortfolioPulse', 'https://portfoliopulse.example.com', 'Rust', 25, 3, '["portfolio", "rust", "next.js"]', TRUE),
('550e8400-e29b-41d4-a716-446655440002', 'MyAwesomeApp', 'An awesome web application built with modern technologies', 'https://github.com/yourusername/MyAwesomeApp', 'https://myawesomeapp.com', 'TypeScript', 48, 7, '["web", "typescript", "react"]', TRUE),
('550e8400-e29b-41d4-a716-446655440003', 'DataAnalyzer', 'A powerful data analysis tool for developers', 'https://github.com/yourusername/DataAnalyzer', NULL, 'Python', 15, 2, '["data", "python", "analytics"]', TRUE);

-- 插入Git活动数据
INSERT INTO git_activities (id, project_id, date, commits, additions, deletions) VALUES
('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', '2025-08-10', 3, 145, 23),
('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', '2025-08-09', 2, 89, 15),
('660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', '2025-08-10', 1, 67, 5),
('660e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440003', '2025-08-08', 4, 234, 56);

-- 插入提交数据
INSERT INTO commits (id, project_id, sha, message, author, author_email, date, additions, deletions) VALUES
('770e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'abc123def456', 'feat: add project dashboard', 'Developer', 'dev@example.com', '2025-08-10 10:30:00', 95, 12),
('770e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'def456ghi789', 'fix: resolve API connection issue', 'Developer', 'dev@example.com', '2025-08-10 14:20:00', 25, 8),
('770e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', 'ghi789jkl012', 'docs: update README with deployment guide', 'Developer', 'dev@example.com', '2025-08-10 16:45:00', 25, 3),
('770e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440002', 'jkl012mno345', 'feat: implement user authentication', 'Developer', 'dev@example.com', '2025-08-10 09:15:00', 67, 5);

-- 插入学习记录数据
INSERT INTO learning_records (id, title, content, tags, category, status) VALUES
('880e8400-e29b-41d4-a716-446655440001', 'Rust Web Development with Axum', 'Learning how to build web APIs using Rust and Axum framework...', '["rust", "web", "axum"]', 'Programming', 'published'),
('880e8400-e29b-41d4-a716-446655440002', 'Next.js App Router Deep Dive', 'Exploring the new App Router in Next.js 13+ and its benefits...', '["nextjs", "react", "frontend"]', 'Web Development', 'published'),
('880e8400-e29b-41d4-a716-446655440003', 'Database Design Best Practices', 'Key principles for designing scalable and maintainable databases...', '["database", "mysql", "design"]', 'Database', 'draft');

-- 显示初始化结果
SELECT 'Projects' as Table_Name, COUNT(*) as Record_Count FROM projects
UNION ALL
SELECT 'Git Activities', COUNT(*) FROM git_activities
UNION ALL
SELECT 'Commits', COUNT(*) FROM commits
UNION ALL
SELECT 'Learning Records', COUNT(*) FROM learning_records;

-- 显示创建的表
SHOW TABLES;

-- 提示信息
SELECT '数据库初始化完成！' as Status,
       'portfolio_pulse_dev' as Database_Name,
       'portfoliopulse' as Username,
       'testpass123' as Password,
       'localhost:3306' as Connection;
