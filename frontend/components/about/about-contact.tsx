"use client";

import { AnimatedContainer } from "@/components/ui/effects";
import { motion } from "framer-motion";

const contactMethods = [
  {
    icon: "📧",
    label: "邮箱",
    value: "wywyw12121@gmail.com",
    href: "mailto:wywyw12121@gmail.com",
    description: "随时欢迎技术交流和合作咨询",
  },
  {
    icon: "💬",
    label: "微信",
    value: "w3148468612",
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

export function AboutContact() {
  return (
    <section
      id="contact"
      className="py-20 px-6 bg-gray-50/50 dark:bg-gray-800/50"
    >
      <div className="max-w-6xl mx-auto">
        <AnimatedContainer direction="up" duration={350} fastResponse={true}>
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
              duration={350}
              delay={100 + index * 60} // 减少延迟间隔
              fastResponse={true}
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

        {/* 底部信息 */}
        <AnimatedContainer direction="up" duration={600} delay={800}>
          <div className="text-center mt-12 p-6 bg-gradient-to-r from-blue-50 to-purple-50 dark:from-gray-800 dark:to-gray-900 rounded-xl">
            <p className="text-gray-600 dark:text-gray-300 mb-4">
              &ldquo;技术的最佳之处在于它将人们联系在一起。&rdquo;
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
