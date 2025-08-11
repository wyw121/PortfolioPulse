-- 插入示例项目数据
INSERT INTO projects (
    id,
    name,
    description,
    html_url,
    homepage,
    language,
    stargazers_count,
    forks_count,
    topics,
    is_active
) VALUES
(
    '550e8400-e29b-41d4-a716-446655440001',
    'PortfolioPulse',
    '现代化的个人项目展示和动态追踪平台',
    'https://github.com/user/PortfolioPulse',
    'https://portfoliopulse.dev',
    'TypeScript',
    42,
    8,
    '["nextjs", "react", "typescript", "portfolio"]',
    TRUE
),
(
    '550e8400-e29b-41d4-a716-446655440002',
    'WebAPI-Framework',
    '基于 Rust 的高性能 Web API 框架',
    'https://github.com/user/webapi-framework',
    NULL,
    'Rust',
    128,
    23,
    '["rust", "webapi", "performance", "framework"]',
    TRUE
),
(
    '550e8400-e29b-41d4-a716-446655440003',
    'DataViz-Tools',
    '交互式数据可视化工具集',
    'https://github.com/user/dataviz-tools',
    'https://dataviz-tools.demo.com',
    'Python',
    67,
    15,
    '["python", "visualization", "data-analysis", "charts"]',
    TRUE
);

-- 插入活动数据
INSERT INTO git_activities (
    id,
    project_id,
    date,
    commits,
    additions,
    deletions
) VALUES
(
    '660e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440001',
    '2024-01-15',
    5,
    150,
    32
),
(
    '660e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440001',
    '2024-01-14',
    3,
    89,
    15
),
(
    '660e8400-e29b-41d4-a716-446655440003',
    '550e8400-e29b-41d4-a716-446655440002',
    '2024-01-13',
    8,
    234,
    67
);

-- 插入提交数据
INSERT INTO commits (
    id,
    project_id,
    sha,
    message,
    author,
    author_email,
    date,
    additions,
    deletions
) VALUES
(
    '770e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440001',
    'a1b2c3d4e5f6789012345678901234567890abcd',
    '添加项目动态展示功能',
    'Developer',
    'developer@example.com',
    '2024-01-15 10:30:00',
    45,
    12
),
(
    '770e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440002',
    'e4f5g6h7i8j9012345678901234567890123abcd',
    '优化数据库查询性能',
    'Developer',
    'developer@example.com',
    '2024-01-15 09:15:00',
    23,
    8
),
(
    '770e8400-e29b-41d4-a716-446655440003',
    '550e8400-e29b-41d4-a716-446655440001',
    'i7j8k9l0m1n2345678901234567890123456abcd',
    '修复响应式布局问题',
    'Developer',
    'developer@example.com',
    '2024-01-14 16:45:00',
    15,
    3
);
