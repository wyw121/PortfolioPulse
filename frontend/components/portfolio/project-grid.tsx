"use client";

import { getProjects, type Project as ApiProject } from "@/lib/api";
import { useEffect, useState } from "react";
import { ProjectCard } from "./project-card";

// 前端项目类型，兼容ProjectCard组件
interface Project {
  id: number;
  title: string;
  description: string;
  technologies: string[];
  status: "active" | "completed" | "planning";
  image?: string;
  github?: string;
  demo?: string;
}

// 转换API项目到前端项目格式
function convertApiProject(apiProject: ApiProject, index: number): Project {
  // 根据项目状态决定技术栈和状态
  const techMap: { [key: string]: string[] } = {
    Rust: ["Rust", "Actix-Web", "OpenAI API", "JavaScript", "HTML5 Canvas"],
    TypeScript: [
      "React 18",
      "TypeScript",
      "Rust",
      "Actix-Web",
      "MySQL",
      "Redis",
    ],
    Java: ["Vue.js 3", "Element Plus", "Spring Boot", "MyBatis-Plus", "MySQL"],
  };

  const statusMap: { [key: string]: "active" | "completed" | "planning" } = {
    "AI Web Generator": "completed",
    QuantConsole: "active",
    "SmartCare Cloud": "active",
  };

  return {
    id: index + 1,
    title: apiProject.name,
    description: apiProject.description,
    technologies: techMap[apiProject.language] || apiProject.topics.slice(0, 5),
    status: statusMap[apiProject.name] || "active",
    github: apiProject.html_url,
    demo: apiProject.homepage || undefined,
    image: `/images/projects/${apiProject.name
      .toLowerCase()
      .replace(/\s+/g, "-")}.jpg`,
  };
}

export const ProjectGrid = () => {
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchProjects() {
      try {
        setLoading(true);
        const apiProjects = await getProjects();
        const convertedProjects = apiProjects.map(convertApiProject);
        setProjects(convertedProjects);
      } catch (err) {
        console.error("加载项目失败:", err);
        setError("加载项目失败，请稍后重试");
      } finally {
        setLoading(false);
      }
    }

    fetchProjects();
  }, []);

  if (loading) {
    return (
      <section className="py-20">
        <div className="max-w-6xl mx-auto px-6">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[1, 2, 3].map((i) => (
              <div key={i} className="animate-pulse">
                <div className="bg-gray-200 dark:bg-gray-800 rounded-lg h-96"></div>
              </div>
            ))}
          </div>
        </div>
      </section>
    );
  }

  if (error) {
    return (
      <section className="py-20">
        <div className="max-w-6xl mx-auto px-6 text-center">
          <div className="text-red-500 dark:text-red-400 mb-4">⚠️ {error}</div>
          <button
            onClick={() => window.location.reload()}
            className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
          >
            重新加载
          </button>
        </div>
      </section>
    );
  }

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
