"use client";

import { AnimatedContainer } from "@/components/ui/effects";
import { motion } from "framer-motion";

const experiences = [
  {
    period: "2024年12月 - 2025年1月",
    title: "智慧医养云平台",
    company: "SmartCare_Cloud 开源项目",
    description:
      "开发智慧医养大数据公共服务平台，专注于医疗设备管理模块的全栈开发实现。",
    technologies: ["Vue 3", "Spring Boot", "Element Plus", "MySQL", "MyBatis-Plus"],
    highlights: [
      "完成设备管理模块的前后端完整开发",
      "设计RESTful API接口和数据库表结构",
      "实现设备接入指南和技术文档编写",
      "掌握Vue 3组件化开发和Spring Boot后端架构",
    ],
  },
  {
    period: "2024年9月 - 2024年12月",
    title: "量化交易控制台",
    company: "QuantConsole 开源项目",
    description:
      "构建全栈加密货币交易平台，实现用户认证、实时数据推送和交易管理功能。",
    technologies: ["React 18", "TypeScript", "Rust", "MySQL", "WebSocket", "Docker"],
    highlights: [
      "搭建React 18 + TypeScript现代前端架构",
      "实现Rust后端服务和WebSocket实时通信",
      "完成用户认证系统和交易仪表板开发",
      "掌握Docker容器化部署和安全系统设计",
    ],
  },
  {
    period: "2024年5月 - 2024年8月",
    title: "AI图像生成平台",
    company: "ai_web_generator 开源项目",
    description:
      "基于DALL-E API的AI图像生成Web应用，前后端分离架构实现智能图像创作功能。",
    technologies: ["Rust", "Actix-web", "JavaScript", "OpenAI API", "Canvas", "Serde"],
    highlights: [
      "完成Rust (Actix-web) 后端API服务开发",
      "集成OpenAI DALL-E API实现AI图像生成",
      "实现Canvas动画效果和图像处理优化",
      "掌握Serde数据序列化和前端异步交互",
    ],
  },
];

const education = [
  {
    period: "2023 - 2027",
    degree: "软件工程",
    school: "中南大学",
    description:
      "专注于现代Web开发技术栈和系统架构设计，致力于全栈开发能力提升。",
    achievements: [
      "深度实践Next.js + Rust全栈开发，独立完成多个项目",
      "熟练掌握现代部署方案，包括Docker容器化和CI/CD自动化",
      "具备跨平台开发经验，Windows/Linux双环境开发部署",
      "实战经验丰富，注重代码质量和用户体验优化",
    ],
  },
];

export function AboutExperience() {
  return (
    <section className="py-20 px-6">
      <div className="max-w-6xl mx-auto">
        {/* 项目经验 */}
        <AnimatedContainer direction="up" duration={350} fastResponse={true}>
          <div className="mb-16">
            <h2 className="text-3xl md:text-4xl font-bold mb-4 text-gray-900 dark:text-white text-center">
              项目经验
            </h2>
            <p className="text-lg text-gray-600 dark:text-gray-300 text-center mb-12">
              在技术学习和项目实践中积累的开发经验
            </p>
          </div>
        </AnimatedContainer>

        <div className="space-y-8 mb-20">
          {experiences.map((exp, index) => (
            <AnimatedContainer
              key={index}
              direction="up"
              duration={350}
              delay={100 + index * 80} // 减少延迟间隔
              fastResponse={true}
            >
              <motion.div
                className="relative pl-8 border-l-2 border-blue-200 dark:border-blue-800"
                initial={{ opacity: 0, y: 15 }} // 减少移动距离
                animate={{ opacity: 1, y: 0 }}
                transition={{
                  delay: 0.2 + index * 0.08, // 减少延迟
                  duration: 0.4,
                }}
              >
                {/* 时间线圆点 */}
                <div className="absolute -left-2 top-0 w-4 h-4 bg-blue-500 rounded-full"></div>

                <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700 ml-4">
                  <div className="flex flex-col md:flex-row md:items-center md:justify-between mb-4">
                    <div>
                      <h3 className="text-xl font-semibold text-gray-900 dark:text-white">
                        {exp.title}
                      </h3>
                      <p className="text-blue-600 dark:text-blue-400 font-medium">
                        {exp.company}
                      </p>
                    </div>
                    <span className="text-gray-500 dark:text-gray-400 text-sm font-medium">
                      {exp.period}
                    </span>
                  </div>

                  <p className="text-gray-600 dark:text-gray-300 mb-4">
                    {exp.description}
                  </p>

                  <div className="mb-4">
                    <div className="flex flex-wrap gap-2">
                      {exp.technologies.map((tech) => (
                        <span
                          key={tech}
                          className="px-3 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 rounded-full text-sm"
                        >
                          {tech}
                        </span>
                      ))}
                    </div>
                  </div>

                  <div className="space-y-2">
                    {exp.highlights.map((highlight, idx) => (
                      <div key={idx} className="flex items-start space-x-2">
                        <div className="w-1.5 h-1.5 bg-green-500 rounded-full mt-2 flex-shrink-0"></div>
                        <p className="text-gray-600 dark:text-gray-300 text-sm">
                          {highlight}
                        </p>
                      </div>
                    ))}
                  </div>
                </div>
              </motion.div>
            </AnimatedContainer>
          ))}
        </div>

        {/* 教育背景 */}
        <AnimatedContainer direction="up" duration={350} fastResponse={true}>
          <div className="mb-12">
            <h2 className="text-3xl md:text-4xl font-bold mb-4 text-gray-900 dark:text-white text-center">
              教育背景
            </h2>
          </div>
        </AnimatedContainer>

        <div className="space-y-8">
          {education.map((edu, index) => (
            <AnimatedContainer
              key={index}
              direction="up"
              duration={600}
              delay={200}
            >
              <motion.div
                className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.5 }}
              >
                <div className="flex flex-col md:flex-row md:items-center md:justify-between mb-4">
                  <div>
                    <h3 className="text-xl font-semibold text-gray-900 dark:text-white">
                      {edu.degree}
                    </h3>
                    <p className="text-purple-600 dark:text-purple-400 font-medium">
                      {edu.school}
                    </p>
                  </div>
                  <span className="text-gray-500 dark:text-gray-400 text-sm font-medium">
                    {edu.period}
                  </span>
                </div>

                <p className="text-gray-600 dark:text-gray-300 mb-4">
                  {edu.description}
                </p>

                <div className="space-y-2">
                  {edu.achievements.map((achievement, idx) => (
                    <div key={idx} className="flex items-start space-x-2">
                      <div className="w-1.5 h-1.5 bg-purple-500 rounded-full mt-2 flex-shrink-0"></div>
                      <p className="text-gray-600 dark:text-gray-300 text-sm">
                        {achievement}
                      </p>
                    </div>
                  ))}
                </div>
              </motion.div>
            </AnimatedContainer>
          ))}
        </div>
      </div>
    </section>
  );
}
