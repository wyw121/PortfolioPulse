"use client";

import { motion } from "framer-motion";
import { ReactNode } from "react";

interface GradientBorderCardProps {
  children: ReactNode;
  className?: string;
  hoverEnabled?: boolean;
}

export const GradientBorderCard = ({
  children,
  className = "",
  hoverEnabled = true,
}: GradientBorderCardProps) => {
  return (
    <motion.div
      className={`relative p-6 rounded-xl bg-white dark:bg-gray-900 ${className}`}
      whileHover={hoverEnabled ? { y: -4 } : {}}
      transition={{ duration: 0.3 }}
    >
      {/* 渐变边框效果 */}
      <div className="absolute inset-0 rounded-xl bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300 p-[1px]">
        <div className="w-full h-full rounded-xl bg-white dark:bg-gray-900" />
      </div>

      {/* 内容 */}
      <div className="relative z-10">{children}</div>

      {/* 发光效果 */}
      <div className="absolute inset-0 rounded-xl shadow-lg shadow-blue-500/0 group-hover:shadow-blue-500/25 transition-shadow duration-300" />
    </motion.div>
  );
};
