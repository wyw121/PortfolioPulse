"use client";

import { AnimatedContainer } from "@/components/ui/effects";
import { useTranslation } from "@/hooks/use-translation";
import { motion } from "framer-motion";

const skillsData = {
  zh: [
    {
      category: "前端技术",
      items: [
        { name: "React", level: 90, icon: "⚛️" },
        { name: "Next.js", level: 85, icon: "▲" },
        { name: "TypeScript", level: 88, icon: "📘" },
        { name: "Tailwind CSS", level: 92, icon: "🎨" },
        { name: "Vue.js", level: 75, icon: "💚" },
      ],
    },
    {
      category: "后端技术",
      items: [
        { name: "Rust", level: 80, icon: "🦀" },
        { name: "Node.js", level: 85, icon: "🟢" },
        { name: "Python", level: 78, icon: "🐍" },
        { name: "PostgreSQL", level: 82, icon: "🐘" },
        { name: "MySQL", level: 88, icon: "🗃️" },
      ],
    },
    {
      category: "工具与平台",
      items: [
        { name: "Docker", level: 85, icon: "🐳" },
        { name: "Git", level: 90, icon: "📚" },
        { name: "Linux", level: 83, icon: "🐧" },
        { name: "AWS", level: 70, icon: "☁️" },
        { name: "Figma", level: 75, icon: "🎯" },
      ],
    },
  ],
  en: [
    {
      category: "Frontend",
      items: [
        { name: "React", level: 90, icon: "⚛️" },
        { name: "Next.js", level: 85, icon: "▲" },
        { name: "TypeScript", level: 88, icon: "📘" },
        { name: "Tailwind CSS", level: 92, icon: "🎨" },
        { name: "Vue.js", level: 75, icon: "💚" },
      ],
    },
    {
      category: "Backend",
      items: [
        { name: "Rust", level: 80, icon: "🦀" },
        { name: "Node.js", level: 85, icon: "🟢" },
        { name: "Python", level: 78, icon: "🐍" },
        { name: "PostgreSQL", level: 82, icon: "🐘" },
        { name: "MySQL", level: 88, icon: "🗃️" },
      ],
    },
    {
      category: "Tools & Platforms",
      items: [
        { name: "Docker", level: 85, icon: "🐳" },
        { name: "Git", level: 90, icon: "📚" },
        { name: "Linux", level: 83, icon: "🐧" },
        { name: "AWS", level: 70, icon: "☁️" },
        { name: "Figma", level: 75, icon: "🎯" },
      ],
    },
  ],
};

export function AboutSkills() {
  const { dict, locale } = useTranslation();
  const skills = skillsData[locale];

  return (
    <section className="py-20 px-6 bg-gray-50/50 dark:bg-gray-800/50">
      <div className="max-w-6xl mx-auto">
        <AnimatedContainer direction="up" duration={350} fastResponse={true}>
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold mb-4 text-gray-900 dark:text-white">
              {dict.about.skills}
            </h2>
            <p className="text-lg text-gray-600 dark:text-gray-300">
              {dict.about.skillsSubtitle}
            </p>
          </div>
        </AnimatedContainer>

        <div className="grid md:grid-cols-3 gap-8">
          {skills.map((skillGroup, groupIndex) => (
            <AnimatedContainer
              key={skillGroup.category}
              direction="up"
              duration={350}
              delay={100 + groupIndex * 80} // 减少延迟间隔
              fastResponse={true}
            >
              <div className="bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-sm border border-gray-200 dark:border-gray-700">
                <h3 className="text-xl font-semibold mb-6 text-gray-900 dark:text-white">
                  {skillGroup.category}
                </h3>

                <div className="space-y-4">
                  {skillGroup.items.map((skill, index) => (
                    <motion.div
                      key={skill.name}
                      initial={{ opacity: 0, x: -15 }} // 减少移动距离
                      animate={{ opacity: 1, x: 0 }}
                      transition={{
                        delay: 0.3 + groupIndex * 0.08 + index * 0.04, // 减少延迟
                        duration: 0.35,
                      }}
                    >
                      <div className="flex items-center justify-between mb-2">
                        <div className="flex items-center space-x-2">
                          <span className="text-lg">{skill.icon}</span>
                          <span className="font-medium text-gray-900 dark:text-white">
                            {skill.name}
                          </span>
                        </div>
                        <span className="text-sm text-gray-500 dark:text-gray-400">
                          {skill.level}%
                        </span>
                      </div>

                      <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
                        <motion.div
                          className="bg-gradient-to-r from-blue-500 to-purple-500 h-2 rounded-full"
                          initial={{ width: 0 }}
                          animate={{ width: `${skill.level}%` }}
                          transition={{
                            delay: 0.5 + groupIndex * 0.08 + index * 0.04, // 减少延迟
                            duration: 0.8, // 进度条动画稍微快一些
                            ease: "easeOut",
                          }}
                        />
                      </div>
                    </motion.div>
                  ))}
                </div>
              </div>
            </AnimatedContainer>
          ))}
        </div>
      </div>
    </section>
  );
}
