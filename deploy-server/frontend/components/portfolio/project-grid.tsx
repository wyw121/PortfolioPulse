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
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {projects.map((project, index) => (
            <ProjectCard key={project.id} project={project} index={index} />
          ))}
        </div>
      </div>
    </section>
  );
};
