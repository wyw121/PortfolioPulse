"use client";

import { AnimatedContainer } from "@/components/ui/effects";
import { motion } from "framer-motion";

export function HeroActions() {
  return (
    <AnimatedContainer direction="up" duration={600} delay={400}>
      <div className="flex flex-col sm:flex-row gap-4 justify-center items-center mb-16">
        <motion.button
          className="px-8 py-4 bg-gradient-to-r from-blue-500 to-purple-500 text-white rounded-lg font-semibold text-lg shadow-lg hover:shadow-xl"
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          探索项目
        </motion.button>

        <motion.button
          className="px-8 py-4 border-2 border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 rounded-lg font-semibold text-lg hover:border-gray-400 dark:hover:border-gray-500"
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          了解更多
        </motion.button>
      </div>
    </AnimatedContainer>
  );
}
