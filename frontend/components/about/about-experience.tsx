"use client";

import { AnimatedContainer } from "@/components/ui/effects";
import { motion } from "framer-motion";

const experiences = [
  {
    period: "2023 - 至今",
    title: "全栈开发者",
    company: "个人项目",
    description:
      "专注于现代Web技术栈的探索，开发多个开源项目，包括PortfolioPulse个人作品展示平台。",
    technologies: ["Next.js", "Rust", "TypeScript", "Tailwind CSS"],
    highlights: [
      "设计并开发了完整的全栈应用架构",
      "实现了高性能的后端API服务",
      "优化前端性能，提升用户体验",
    ],
  },
  {
    period: "2022 - 2023",
    title: "前端工程师",
    company: "科技创业公司",
    description: "负责公司核心产品的前端开发，参与产品架构设计和技术选型。",
    technologies: ["React", "Vue.js", "Node.js", "MongoDB"],
    highlights: [
      "重构了老旧的前端架构，提升开发效率50%",
      "实现了响应式设计，适配多种设备",
      "建立了完善的组件库和开发规范",
    ],
  },
  {
    period: "2021 - 2022",
    title: "Web开发实习生",
    company: "互联网公司",
    description: "参与多个Web项目的开发，学习现代前端框架和后端技术。",
    technologies: ["HTML", "CSS", "JavaScript", "Python"],
    highlights: [
      "完成了多个功能模块的开发",
      "学习了敏捷开发和团队协作",
      "积极参与代码review和技术分享",
    ],
  },
];

const education = [
  {
    period: "2018 - 2022",
    degree: "计算机科学与技术",
    school: "某知名大学",
    description: "系统学习了计算机科学基础知识，包括数据结构、算法、数据库等。",
    achievements: [
      "获得优秀学生奖学金",
      "参与多个校内外编程竞赛",
      "完成毕业设计项目获得优秀评价",
    ],
  },
];

export function AboutExperience() {
  return (
    <section className="py-20 px-6">
      <div className="max-w-6xl mx-auto">
        {/* 工作经验 */}
        <AnimatedContainer direction="up" duration={600}>
          <div className="mb-16">
            <h2 className="text-3xl md:text-4xl font-bold mb-4 text-gray-900 dark:text-white text-center">
              工作经验
            </h2>
            <p className="text-lg text-gray-600 dark:text-gray-300 text-center mb-12">
              在不同阶段的学习和实践经历
            </p>
          </div>
        </AnimatedContainer>

        <div className="space-y-8 mb-20">
          {experiences.map((exp, index) => (
            <AnimatedContainer
              key={index}
              direction="up"
              duration={600}
              delay={200 + index * 100}
            >
              <motion.div
                className="relative pl-8 border-l-2 border-blue-200 dark:border-blue-800"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 + index * 0.1 }}
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
        <AnimatedContainer direction="up" duration={600}>
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
