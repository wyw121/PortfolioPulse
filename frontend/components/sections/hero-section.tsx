"use client";

import { AnimatedContainer } from "@/components/ui/effects";
import { useTranslation } from "@/hooks/use-translation";
import { motion } from "framer-motion";
import Link from "next/link";

export const HeroSection = () => {
  const { dict, locale } = useTranslation();

  return (
    <section className="min-h-screen flex items-center justify-center pt-16 px-6">
      <div className="max-w-4xl mx-auto text-center">
        <AnimatedContainer direction="up" duration={800}>
          <h1 className="text-5xl md:text-7xl font-bold mb-8">
            <span className="bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 bg-clip-text text-transparent">
              {dict.common.siteName}
            </span>
          </h1>
        </AnimatedContainer>

        <AnimatedContainer direction="up" duration={800} delay={200}>
          <p className="text-xl md:text-2xl text-gray-600 dark:text-gray-300 mb-12 max-w-3xl mx-auto leading-relaxed">
            {locale === 'zh' 
              ? '个人项目动态追踪平台，展示技术作品，记录学习成长，分享开发经验'
              : 'Personal project tracking platform showcasing tech creations, documenting learning journey, and sharing development experiences'
            }
          </p>
        </AnimatedContainer>

        <AnimatedContainer direction="up" duration={600} delay={400}>
          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <Link href="/projects">
              <motion.button
                className="px-8 py-4 bg-gradient-to-r from-blue-500 to-purple-500 text-white rounded-lg font-semibold text-lg shadow-lg hover:shadow-xl"
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
              >
                {dict.hero.cta}
              </motion.button>
            </Link>

            <Link href="/about">
              <motion.button
                className="px-8 py-4 border-2 border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 rounded-lg font-semibold text-lg hover:border-gray-400 dark:hover:border-gray-500"
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
              >
                {dict.actions.learnMore}
              </motion.button>
            </Link>
          </div>
        </AnimatedContainer>

        {/* 技术栈指示器 */}
        <AnimatedContainer direction="up" duration={600} delay={600}>
          <div className="mt-16 flex justify-center items-center space-x-8 opacity-70">
            <div className="text-sm text-gray-500 dark:text-gray-400">
              {locale === 'zh' ? '技术栈:' : 'Tech Stack:'}
            </div>
            <div className="flex space-x-4">
              {["Next.js", "TypeScript", "Tailwind"].map((tech, index) => (
                <motion.span
                  key={tech}
                  className="px-3 py-1 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 rounded-full text-sm font-medium"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.8 + index * 0.1 }}
                >
                  {tech}
                </motion.span>
              ))}
            </div>
          </div>
        </AnimatedContainer>
      </div>
    </section>
  );
};
