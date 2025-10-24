"use client";

import { AnimatedContainer } from "@/components/ui/effects";
import { useTranslation } from "@/hooks/use-translation";
import { motion } from "framer-motion";

export function AboutHero() {
  const { dict, locale } = useTranslation();

  return (
    <section className="py-20 px-6">
      <div className="max-w-6xl mx-auto">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* 左侧文字内容 */}
          <div>
            <AnimatedContainer
              direction="left"
              duration={350}
              fastResponse={true}
            >
              <h1 className="text-4xl md:text-5xl font-bold mb-6">
                <span className="bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 bg-clip-text text-transparent">
                  {dict.about.title}
                </span>
              </h1>
            </AnimatedContainer>

            <AnimatedContainer
              direction="left"
              duration={350}
              delay={100}
              fastResponse={true}
            >
              <p className="text-xl text-gray-600 dark:text-gray-300 mb-6 leading-relaxed">
                {dict.about.bio}
              </p>
            </AnimatedContainer>

            <AnimatedContainer
              direction="left"
              duration={350}
              delay={200}
              fastResponse={true}
            >
              <div className="space-y-4 text-gray-600 dark:text-gray-300">
                <p>
                  {locale === 'zh' 
                    ? '拥有多年的前端和后端开发经验，熟练掌握React、Next.js、TypeScript、Rust等技术栈。热衷于开源项目，致力于构建高质量、高性能的Web应用。'
                    : 'With years of frontend and backend development experience, proficient in React, Next.js, TypeScript, Rust and other tech stacks. Passionate about open source projects and dedicated to building high-quality, high-performance web applications.'
                  }
                </p>
                <p>
                  {locale === 'zh'
                    ? '除了技术开发，我还喜欢写作分享，通过博客记录学习过程和技术思考，希望能够帮助更多的开发者成长。'
                    : 'Besides technical development, I also enjoy writing and sharing. Through my blog, I document learning processes and technical thoughts, hoping to help more developers grow.'
                  }
                </p>
              </div>
            </AnimatedContainer>

            <AnimatedContainer
              direction="left"
              duration={350}
              delay={300}
              fastResponse={true}
            >
              <div className="flex flex-wrap gap-4 mt-8">
                <motion.a
                  href="https://github.com/wyw121"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="px-6 py-3 bg-gradient-to-r from-blue-500 to-purple-500 text-white rounded-lg font-semibold shadow-lg hover:shadow-xl"
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                >
                  {locale === 'zh' ? '查看GitHub' : 'View GitHub'}
                </motion.a>
                <motion.a
                  href="#contact"
                  className="px-6 py-3 border-2 border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 rounded-lg font-semibold hover:border-gray-400 dark:hover:border-gray-500"
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                >
                  {dict.about.getInTouch}
                </motion.a>
              </div>
            </AnimatedContainer>
          </div>

          {/* 右侧头像 */}
          <AnimatedContainer
            direction="right"
            duration={350}
            delay={150}
            fastResponse={true}
          >
            <div className="flex justify-center lg:justify-end">
              <div className="relative">
                <div className="w-80 h-80 rounded-full overflow-hidden shadow-2xl border-4 border-white dark:border-gray-800">
                  <div className="w-full h-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-white text-6xl font-bold">
                    WY
                  </div>
                </div>
                {/* 装饰性元素 */}
                <div className="absolute -top-4 -right-4 w-24 h-24 bg-gradient-to-r from-pink-400 to-red-400 rounded-full opacity-20 blur-xl"></div>
                <div className="absolute -bottom-4 -left-4 w-32 h-32 bg-gradient-to-r from-blue-400 to-cyan-400 rounded-full opacity-20 blur-xl"></div>
              </div>
            </div>
          </AnimatedContainer>
        </div>
      </div>
    </section>
  );
}
