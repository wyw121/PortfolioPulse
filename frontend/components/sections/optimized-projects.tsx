"use client";

import { AnimatedContainer } from "@/components/animations/animated-container";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Clock, ExternalLink, GitFork, Github, Star } from "lucide-react";
import { useCallback, useEffect, useMemo, useState } from "react";

interface Project {
  id: number;
  name: string;
  description: string;
  html_url: string;
  homepage?: string;
  language: string;
  stargazers_count: number;
  forks_count: number;
  updated_at: string;
  topics: string[];
}

// 预定义数据，避免重复创建
const MOCK_PROJECTS: Project[] = [
  {
    id: 1,
    name: "PortfolioPulse",
    description:
      "现代化的个人项目展示和动态追踪平台，采用 Next.js + Rust 技术栈",
    html_url: "https://github.com/user/PortfolioPulse",
    homepage: "https://portfoliopulse.dev",
    language: "TypeScript",
    stargazers_count: 42,
    forks_count: 8,
    updated_at: "2024-01-15T10:30:00Z",
    topics: ["nextjs", "react", "typescript", "portfolio", "rust"],
  },
  {
    id: 2,
    name: "WebAPI-Framework",
    description: "基于 Rust 的高性能 Web API 框架，提供快速开发和部署解决方案",
    html_url: "https://github.com/user/webapi-framework",
    language: "Rust",
    stargazers_count: 128,
    forks_count: 23,
    updated_at: "2024-01-10T14:20:00Z",
    topics: ["rust", "webapi", "performance", "framework", "async"],
  },
  {
    id: 3,
    name: "DataViz-Tools",
    description: "交互式数据可视化工具集，支持多种图表类型和实时数据更新",
    html_url: "https://github.com/user/dataviz-tools",
    homepage: "https://dataviz-tools.demo.com",
    language: "Python",
    stargazers_count: 67,
    forks_count: 15,
    updated_at: "2024-01-08T09:15:00Z",
    topics: ["python", "visualization", "data-analysis", "charts", "dashboard"],
  },
  {
    id: 4,
    name: "Financial-Analytics",
    description: "金融数据分析平台，提供股票分析、投资组合管理等功能",
    html_url: "https://github.com/user/financial-analytics",
    homepage: "https://finance-analytics.demo.com",
    language: "Python",
    stargazers_count: 89,
    forks_count: 19,
    updated_at: "2024-01-05T16:45:00Z",
    topics: ["finance", "analytics", "stocks", "portfolio", "quantitative"],
  },
  {
    id: 5,
    name: "ML-Toolkit",
    description: "机器学习工具包，包含常用算法实现和数据处理工具",
    html_url: "https://github.com/user/ml-toolkit",
    language: "Python",
    stargazers_count: 156,
    forks_count: 34,
    updated_at: "2024-01-03T11:20:00Z",
    topics: ["machine-learning", "ai", "data-science", "algorithms", "python"],
  },
  {
    id: 6,
    name: "React-UI-Components",
    description: "可复用的 React UI 组件库，基于 Tailwind CSS 和 shadcn/ui",
    html_url: "https://github.com/user/react-ui-components",
    homepage: "https://ui-components.demo.com",
    language: "TypeScript",
    stargazers_count: 73,
    forks_count: 12,
    updated_at: "2024-01-01T08:30:00Z",
    topics: ["react", "ui", "components", "tailwind", "design-system"],
  },
];

export function OptimizedProjectsSection() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);

  // 使用 useCallback 避免重复渲染
  const loadProjects = useCallback(() => {
    setProjects(MOCK_PROJECTS);
    setLoading(false);
  }, []);

  useEffect(() => {
    loadProjects();
  }, [loadProjects]);

  // 缓存日期格式化函数
  const formatDate = useMemo(() => {
    return (dateString: string) => {
      return new Date(dateString).toLocaleDateString("zh-CN", {
        year: "numeric",
        month: "short",
        day: "numeric",
      });
    };
  }, []);

  // 缓存语言颜色映射
  const getLanguageColor = useCallback((language: string) => {
    const colors: Record<string, string> = {
      TypeScript: "bg-blue-500",
      JavaScript: "bg-yellow-500",
      Python: "bg-green-500",
      Rust: "bg-red-500",
      Go: "bg-cyan-500",
      Java: "bg-orange-500",
    };
    return colors[language] || "bg-gray-500";
  }, []);

  if (loading) {
    return (
      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-12">项目展示</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[1, 2, 3, 4, 5, 6].map((i) => (
              <div
                key={i}
                className="h-80 bg-muted rounded-lg animate-pulse"
              ></div>
            ))}
          </div>
        </div>
      </section>
    );
  }

  return (
    <section className="py-16 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto">
        <AnimatedContainer
          direction="fade"
          duration={800}
          className="text-center mb-12"
        >
          <h2 className="text-3xl font-bold mb-4">项目展示</h2>
          <p className="text-muted-foreground max-w-2xl mx-auto">
            这些是我正在开发和维护的一些项目，涵盖了全栈开发、数据分析、机器学习等多个领域
          </p>
        </AnimatedContainer>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {projects.map((project, index) => (
            <AnimatedContainer
              key={project.id}
              direction="up"
              duration={600}
              delay={200 + index * 100}
            >
              <Card className="flex flex-col h-full hover:shadow-lg transition-shadow duration-200 tech-card">
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <CardTitle className="text-lg">{project.name}</CardTitle>
                    <div className="flex items-center gap-2">
                      <div
                        className={`w-3 h-3 rounded-full ${getLanguageColor(
                          project.language
                        )}`}
                      />
                      <span className="text-sm text-muted-foreground">
                        {project.language}
                      </span>
                    </div>
                  </div>
                  <CardDescription className="line-clamp-3">
                    {project.description}
                  </CardDescription>
                </CardHeader>

                <CardContent className="flex-1 flex flex-col">
                  {/* 标签 */}
                  <div className="flex flex-wrap gap-1 mb-4">
                    {project.topics.slice(0, 4).map((topic) => (
                      <Badge
                        key={topic}
                        variant="secondary"
                        className="text-xs"
                      >
                        {topic}
                      </Badge>
                    ))}
                    {project.topics.length > 4 && (
                      <Badge variant="outline" className="text-xs">
                        +{project.topics.length - 4}
                      </Badge>
                    )}
                  </div>

                  {/* 统计信息 */}
                  <div className="flex items-center gap-4 mb-4 text-sm text-muted-foreground">
                    <div className="flex items-center gap-1">
                      <Star className="w-4 h-4" />
                      <span>{project.stargazers_count}</span>
                    </div>
                    <div className="flex items-center gap-1">
                      <GitFork className="w-4 h-4" />
                      <span>{project.forks_count}</span>
                    </div>
                    <div className="flex items-center gap-1">
                      <Clock className="w-4 h-4" />
                      <span>{formatDate(project.updated_at)}</span>
                    </div>
                  </div>

                  {/* 按钮区域 */}
                  <div className="mt-auto flex items-center gap-2">
                    <Button
                      variant="outline"
                      size="sm"
                      className="flex-1"
                      asChild
                    >
                      <a
                        href={project.html_url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="flex items-center gap-1"
                      >
                        <Github className="w-4 h-4" />
                        代码
                      </a>
                    </Button>

                    {project.homepage && (
                      <Button size="sm" className="flex-1" asChild>
                        <a
                          href={project.homepage}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="flex items-center gap-1"
                        >
                          <ExternalLink className="w-4 h-4" />
                          预览
                        </a>
                      </Button>
                    )}
                  </div>
                </CardContent>
              </Card>
            </AnimatedContainer>
          ))}
        </div>

        {/* 更多项目提示 */}
        <AnimatedContainer
          direction="up"
          duration={600}
          delay={800}
          className="text-center mt-12"
        >
          <p className="text-muted-foreground mb-4">想要查看更多项目？</p>
          <Button
            variant="outline"
            asChild
            className="gradient-border hover-lift"
          >
            <a
              href="https://github.com/your-username"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2"
            >
              <Github className="w-4 h-4" />
              查看 GitHub
            </a>
          </Button>
        </AnimatedContainer>
      </div>
    </section>
  );
}
