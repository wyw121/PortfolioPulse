"use client";

import { AnimatedContainer } from "@/components/ui/effects";
import { useTranslation } from "@/hooks/use-translation";
import { motion } from "framer-motion";

const contactMethodsData = [
  {
    icon: "📧",
    value: "wywyw12121@gmail.com",
    href: "mailto:wywyw12121@gmail.com",
    key: "email" as const,
  },
  {
    icon: "💬",
    value: "w3148468612",
    href: "#",
    key: "wechat" as const,
  },
  {
    icon: "🐙",
    value: "github.com/wyw121",
    href: "https://github.com/wyw121",
    key: "github" as const,
  },
  {
    icon: "🐦",
    value: "@wywyw12121",
    href: "https://twitter.com/wywyw12121",
    key: "twitter" as const,
  },
];

const interestsData = [
  { icon: "💻", key: "programming" as const },
  { icon: "📚", key: "reading" as const },
  { icon: "🎮", key: "gaming" as const },
  { icon: "🎵", key: "music" as const },
  { icon: "🏃", key: "fitness" as const },
  { icon: "🌍", key: "travel" as const },
];

export function AboutContact() {
  const { dict } = useTranslation();

  return (
    <section
      id="contact"
      className="py-20 px-6 bg-gray-50/50 dark:bg-gray-800/50"
    >
      <div className="max-w-6xl mx-auto">
        <AnimatedContainer direction="up" duration={350} fastResponse={true}>
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold mb-4 text-gray-900 dark:text-white">
              {dict.about.contact}
            </h2>
            <p className="text-lg text-gray-600 dark:text-gray-300">
              {dict.about.contactSubtitle}
            </p>
          </div>
        </AnimatedContainer>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mb-16">
          {contactMethodsData.map((contact, index) => (
            <AnimatedContainer
              key={contact.key}
              direction="up"
              duration={350}
              delay={100 + index * 60}
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
                    {dict.about.contactMethods[contact.key].label}
                  </h3>
                  <p className="text-blue-600 dark:text-blue-400 text-sm font-medium mb-2">
                    {contact.value}
                  </p>
                  <p className="text-xs text-gray-500 dark:text-gray-400">
                    {dict.about.contactMethods[contact.key].description}
                  </p>
                </div>
              </motion.a>
            </AnimatedContainer>
          ))}
        </div>

        <AnimatedContainer direction="up" duration={600} delay={600}>
          <div className="bg-white dark:bg-gray-800 rounded-2xl p-8 shadow-sm border border-gray-200 dark:border-gray-700">
            <h3 className="text-2xl font-bold mb-6 text-gray-900 dark:text-white text-center">
              {dict.about.interests}
            </h3>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
              {interestsData.map((interest, index) => (
                <motion.div
                  key={interest.key}
                  className="flex items-center space-x-3 p-3 rounded-lg bg-gray-50 dark:bg-gray-700/50"
                  initial={{ opacity: 0, scale: 0.8 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ delay: 0.8 + index * 0.1 }}
                  whileHover={{ scale: 1.05 }}
                >
                  <span className="text-xl">{interest.icon}</span>
                  <span className="text-gray-700 dark:text-gray-300 font-medium">
                    {dict.about.interestsList[interest.key]}
                  </span>
                </motion.div>
              ))}
            </div>
          </div>
        </AnimatedContainer>

        <AnimatedContainer direction="up" duration={600} delay={800}>
          <div className="text-center mt-12 p-6 bg-gradient-to-r from-blue-50 to-purple-50 dark:from-gray-800 dark:to-gray-900 rounded-xl">
            <p className="text-gray-600 dark:text-gray-300 mb-4">
              &ldquo;{dict.about.quote}&rdquo;
            </p>
            <p className="text-sm text-gray-500 dark:text-gray-400">
              {dict.about.closing}
            </p>
          </div>
        </AnimatedContainer>
      </div>
    </section>
  );
}
