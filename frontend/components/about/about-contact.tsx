"use client";

import { AnimatedContainer } from "@/components/ui/effects";
import { motion } from "framer-motion";

const contactMethods = [
  {
    icon: "📧",
    label: "邮箱",
    value: "contact@example.com",
    href: "mailto:contact@example.com",
    description: "随时欢迎技术交流和合作咨询",
  },
  {
    icon: "💬",
    label: "微信",
    value: "WeChat ID",
    href: "#",
    description: "添加微信，获取更及时的回复",
  },
  {
    icon: "🐙",
    label: "GitHub",
    value: "github.com/wyw121",
    href: "https://github.com/wyw121",
    description: "查看我的开源项目和代码",
  },
  {
    icon: "🐦",
    label: "Twitter",
    value: "@wywyw12121",
    href: "https://twitter.com/wywyw12121",
    description: "关注我的技术动态和思考",
  },
];

const interests = [
  { icon: "💻", text: "编程与技术" },
  { icon: "📚", text: "阅读与学习" },
  { icon: "🎮", text: "游戏与娱乐" },
  { icon: "🎵", text: "音乐与艺术" },
  { icon: "🏃", text: "运动健身" },
  { icon: "🌍", text: "旅行探索" },
];

export function AboutContact() {
  return (
    <section
      id="contact"
      className="py-20 px-6 bg-gray-50/50 dark:bg-gray-800/50"
    >
      <div className="max-w-6xl mx-auto">
        <AnimatedContainer direction="up" duration={600}>
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold mb-4 text-gray-900 dark:text-white">
              联系方式
            </h2>
            <p className="text-lg text-gray-600 dark:text-gray-300">
              很高兴能与您交流，期待我们的合作机会
            </p>
          </div>
        </AnimatedContainer>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mb-16">
          {contactMethods.map((contact, index) => (
            <AnimatedContainer
              key={contact.label}
              direction="up"
              duration={600}
              delay={200 + index * 100}
            >
              <motion.a
                href={contact.href}
                target={contact.href.startsWith("http") ? "_blank" : "_self"}
                rel={
                  contact.href.startsWith("http") ? "noopener noreferrer" : ""
                }
                className="block bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700 hover:shadow-lg transition-all duration-300 group"
                whileHover={{ y: -4 }}
                whileTap={{ scale: 0.95 }}
              >
                <div className="text-center">
                  <div className="text-3xl mb-3 group-hover:scale-110 transition-transform duration-300">
                    {contact.icon}
                  </div>
                  <h3 className="font-semibold text-gray-900 dark:text-white mb-1">
                    {contact.label}
                  </h3>
                  <p className="text-blue-600 dark:text-blue-400 text-sm font-medium mb-2">
                    {contact.value}
                  </p>
                  <p className="text-xs text-gray-500 dark:text-gray-400">
                    {contact.description}
                  </p>
                </div>
              </motion.a>
            </AnimatedContainer>
          ))}
        </div>

        {/* 兴趣爱好 */}
        <AnimatedContainer direction="up" duration={600} delay={600}>
          <div className="bg-white dark:bg-gray-800 rounded-2xl p-8 shadow-sm border border-gray-200 dark:border-gray-700">
            <h3 className="text-2xl font-bold mb-6 text-gray-900 dark:text-white text-center">
              兴趣爱好
            </h3>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
              {interests.map((interest, index) => (
                <motion.div
                  key={interest.text}
                  className="flex items-center space-x-3 p-3 rounded-lg bg-gray-50 dark:bg-gray-700/50"
                  initial={{ opacity: 0, scale: 0.8 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ delay: 0.8 + index * 0.1 }}
                  whileHover={{ scale: 1.05 }}
                >
                  <span className="text-xl">{interest.icon}</span>
                  <span className="text-gray-700 dark:text-gray-300 font-medium">
                    {interest.text}
                  </span>
                </motion.div>
              ))}
            </div>
          </div>
        </AnimatedContainer>

        {/* 底部信息 */}
        <AnimatedContainer direction="up" duration={600} delay={800}>
          <div className="text-center mt-12 p-6 bg-gradient-to-r from-blue-50 to-purple-50 dark:from-gray-800 dark:to-gray-900 rounded-xl">
            <p className="text-gray-600 dark:text-gray-300 mb-4">
              &ldquo;代码改变世界，创新驱动未来&rdquo;
            </p>
            <p className="text-sm text-gray-500 dark:text-gray-400">
              期待与您的交流合作，一起创造更多可能！
            </p>
          </div>
        </AnimatedContainer>
      </div>
    </section>
  );
}
