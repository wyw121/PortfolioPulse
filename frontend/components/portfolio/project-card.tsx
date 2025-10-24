"use client";

import { AnimatedContainer, GradientBorderCard } from "@/components/ui/effects";
import { motion } from "framer-motion";
import type { Project } from "@/lib/projects-data";

interface ProjectCardProps {
  project: Project;
  index: number;
}

export const ProjectCard = ({ project, index }: ProjectCardProps) => {
  const statusColors = {
    active: "bg-green-500",
    completed: "bg-blue-500",
    planning: "bg-yellow-500",
  };

  const statusText = {
    active: "进行中",
    completed: "已完成",
    planning: "计划中",
  };

  return (
    <AnimatedContainer direction="up" delay={index * 100}>
      <GradientBorderCard className="group h-full">
        <div className="flex flex-col h-full">
          {/* 项目状态指示器 */}
          <div className="flex items-center justify-between mb-4">
            <span
              className={`px-3 py-1 rounded-full text-xs font-medium text-white ${
                statusColors[project.status]
              }`}
            >
              {statusText[project.status]}
            </span>
          </div>

          {/* 项目信息 */}
          <div className="flex-1">
            <h3 className="text-xl font-bold mb-3 text-gray-900 dark:text-white group-hover:text-transparent group-hover:bg-gradient-to-r group-hover:from-blue-500 group-hover:to-purple-500 group-hover:bg-clip-text transition-all duration-300">
              {project.title}
            </h3>

            <p className="text-gray-600 dark:text-gray-300 mb-4 line-clamp-3">
              {project.description}
            </p>

            {/* 技术栈 */}
            <div className="flex flex-wrap gap-2 mb-4">
              {project.technologies.map((tech, i) => (
                <span
                  key={i}
                  className="px-2 py-1 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 text-xs rounded-md font-medium"
                >
                  {tech}
                </span>
              ))}
            </div>
          </div>

          {/* 操作按钮 */}
          <div className="flex gap-3 mt-auto">
            {project.github && (
              <motion.a
                href={project.github}
                target="_blank"
                rel="noopener noreferrer"
                className="flex-1 py-2 px-4 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 rounded-lg text-center text-sm font-medium hover:border-gray-400 dark:hover:border-gray-500 transition-colors"
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                代码
              </motion.a>
            )}
            {project.demo && (
              <motion.a
                href={project.demo}
                target="_blank"
                rel="noopener noreferrer"
                className="flex-1 py-2 px-4 bg-gradient-to-r from-blue-500 to-purple-500 text-white rounded-lg text-center text-sm font-medium hover:from-blue-600 hover:to-purple-600 transition-all"
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                演示
              </motion.a>
            )}
          </div>
        </div>
      </GradientBorderCard>
    </AnimatedContainer>
  );
};
