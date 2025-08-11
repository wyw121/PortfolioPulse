"use client";

import {
  ANIMATION_DURATIONS,
  ANIMATION_EASINGS,
  ANIMATION_OFFSETS,
  VIEWPORT_MARGINS,
} from "@/lib/animation-config";
import { motion } from "framer-motion";
import { ReactNode } from "react";

interface AnimatedContainerProps {
  children: ReactNode;
  direction?: "up" | "down" | "left" | "right";
  duration?: number;
  delay?: number;
  className?: string;
  fastResponse?: boolean; // 新增快速响应模式
}

export const AnimatedContainer = ({
  children,
  direction = "up",
  duration = ANIMATION_DURATIONS.normal, // 使用配置文件的默认值
  delay = 0,
  className = "",
  fastResponse = false,
}: AnimatedContainerProps) => {
  // 根据快速响应模式和方向选择合适的偏移量
  const getOffset = () => {
    if (fastResponse) {
      return ANIMATION_OFFSETS.fastNormal;
    }
    return ANIMATION_OFFSETS.normal;
  };

  const offset = getOffset();

  // 优化初始偏移量，减少移动距离让动画看起来更快
  const directionVariants = {
    up: { y: offset, opacity: 0 },
    down: { y: -offset, opacity: 0 },
    left: { x: offset, opacity: 0 },
    right: { x: -offset, opacity: 0 },
  };

  return (
    <motion.div
      className={className}
      initial={directionVariants[direction]}
      whileInView={{ x: 0, y: 0, opacity: 1 }}
      viewport={{
        once: true,
        margin: fastResponse ? VIEWPORT_MARGINS.fast : VIEWPORT_MARGINS.default,
      }}
      transition={{
        duration: (fastResponse ? duration * 0.8 : duration) / 1000,
        delay: delay / 1000,
        ease: ANIMATION_EASINGS.fastResponse,
      }}
    >
      {children}
    </motion.div>
  );
};
