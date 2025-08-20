"use client";

import { AnimatedContainer } from "@/components/ui/effects";
import { motion } from "framer-motion";

const techStack = ["Next.js", "Rust", "MySQL", "Tailwind"];

export function TechStack() {
  return (
    <AnimatedContainer direction="up" duration={600} delay={600}>
      <div className="flex justify-center items-center space-x-8 opacity-70">
        <div className="text-sm text-gray-500 dark:text-gray-400">技术栈:</div>
        <div className="flex flex-wrap justify-center gap-3">
          {techStack.map((tech, index) => (
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
  );
}
