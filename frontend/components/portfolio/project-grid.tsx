"use client";

import { ProjectCard } from "./project-card";

// 示例项目数据 - 实际应用中应该从API或数据库获取
const projects = [
  {
    id: 1,
    title: "PortfolioPulse",
    description:
      "现代化的个人项目展示和动态追踪平台，集成Git提交历史、学习记录和项目管理功能。",
    technologies: ["Next.js", "Rust", "MySQL", "Tailwind CSS"],
    status: "active" as const,
    github: "https://github.com/username/portfoliopulse",
    demo: "https://portfoliopulse.dev",
  },
  {
    id: 2,
    title: "Web Components Library",
    description: "基于现代Web标准的可复用组件库，支持React、Vue等多框架集成。",
    technologies: ["TypeScript", "Storybook", "Rollup", "CSS Variables"],
    status: "completed" as const,
    github: "https://github.com/username/web-components",
    demo: "https://components.dev",
  },
  {
    id: 3,
    title: "AI Code Assistant",
    description:
      "基于大语言模型的代码辅助工具，支持代码生成、重构和文档自动生成。",
    technologies: ["Python", "FastAPI", "OpenAI API", "Docker"],
    status: "planning" as const,
    github: "https://github.com/username/ai-code-assistant",
  },
];

export const ProjectGrid = () => {
  return (
    <section className="py-20">
      <div className="max-w-6xl mx-auto px-6">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-bold mb-4 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 bg-clip-text text-transparent">
            精选项目
          </h2>
          <p className="text-lg text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
            展示我的技术项目作品集，涵盖前端开发、后端服务、工具库等多个领域
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {projects.map((project, index) => (
            <ProjectCard key={project.id} project={project} index={index} />
          ))}
        </div>
      </div>
    </section>
  );
};
