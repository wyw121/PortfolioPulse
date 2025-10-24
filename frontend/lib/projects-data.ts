/**
 * 项目数据配置文件
 * 集中管理所有项目信息
 */

export interface Project {
  id: number;
  title: string;
  description: string;
  technologies: string[];
  status: "active" | "completed" | "planning";
  github: string;
  demo?: string;
}

export const projects: Project[] = [
  {
    id: 1,
    title: "PortfolioPulse",
    description:
      "现代化的个人项目展示和动态追踪平台,集成博客、项目管理和动态展示功能。采用 Next.js 15 SSG 架构,无需后端服务。",
    technologies: ["Next.js 15", "TypeScript", "Tailwind CSS", "shadcn/ui"],
    status: "active",
    github: "https://github.com/wyw121/PortfolioPulse",
    demo: "https://portfoliopulse.vercel.app",
  },
  {
    id: 2,
    title: "Web Components Library",
    description: "基于现代Web标准的可复用组件库,支持React、Vue等多框架集成。",
    technologies: ["TypeScript", "Storybook", "Rollup", "CSS Variables"],
    status: "completed",
    github: "https://github.com/username/web-components",
    demo: "https://components.dev",
  },
  {
    id: 3,
    title: "AI Code Assistant",
    description:
      "基于大语言模型的代码辅助工具,支持代码生成、重构和文档自动生成。",
    technologies: ["Python", "FastAPI", "OpenAI API", "Docker"],
    status: "planning",
    github: "https://github.com/username/ai-code-assistant",
  },
];
