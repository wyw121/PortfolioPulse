"use client";

import { AnimatedContainer } from "@/components/ui/effects";
import { useTranslation } from "@/hooks/use-translation";
import { motion } from "framer-motion";

// 技术标签数据(不需要翻译)
const technologiesData = {
  "2023": ["Next.js", "Rust", "TypeScript", "Tailwind CSS"],
  "2022": ["React", "Vue.js", "Node.js", "MongoDB"],
  "2021": ["HTML", "CSS", "JavaScript", "Python"],
};

export function AboutExperience() {
  const { dict } = useTranslation();

  return (
    <section className="py-20 px-6">
      <div className="max-w-6xl mx-auto">
        {/* 工作经验 */}
        <AnimatedContainer direction="up" duration={350} fastResponse={true}>
          <div className="mb-16">
            <h2 className="text-3xl md:text-4xl font-bold mb-4 text-gray-900 dark:text-white text-center">
              {dict.about.experience}
            </h2>
            <p className="text-lg text-gray-600 dark:text-gray-300 text-center mb-12">
              {dict.about.experienceSubtitle}
            </p>
          </div>
        </AnimatedContainer>

        <div className="space-y-8 mb-20">
          {dict.about.experiences.map(
            (
              exp: {
                title: string;
                company: string;
                period: string;
                description: string;
                highlights: string[];
              },
              index: number
            ) => (
              <AnimatedContainer
                key={index}
                direction="up"
                duration={350}
                delay={100 + index * 80}
                fastResponse={true}
              >
              <motion.div
                className="relative pl-8 border-l-2 border-blue-200 dark:border-blue-800"
                initial={{ opacity: 0, y: 15 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{
                  delay: 0.2 + index * 0.08,
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
                      {technologiesData[
                        index === 0 ? "2023" : index === 1 ? "2022" : "2021"
                      ].map((tech) => (
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
                    {exp.highlights.map((highlight: string, idx: number) => (
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
              {dict.about.education}
            </h2>
          </div>
        </AnimatedContainer>

        <div className="space-y-8">
          {dict.about.educationList.map(
            (
              edu: {
                degree: string;
                school: string;
                period: string;
                description: string;
                achievements: string[];
              },
              index: number
            ) => (
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
                  {edu.achievements.map((achievement: string, idx: number) => (
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
