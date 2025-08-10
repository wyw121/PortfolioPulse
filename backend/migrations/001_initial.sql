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
    INDEX idx_project_id (project_id),
    INDEX idx_date (date),
    INDEX idx_sha (sha),
    INDEX idx_author (author)
);
