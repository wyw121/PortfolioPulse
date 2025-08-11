"use client";

import { cn } from "@/lib/utils";
import { ReactNode, useEffect, useRef, useState } from "react";

interface AnimatedContainerProps {
  readonly children: ReactNode;
  readonly className?: string;
  readonly delay?: number;
  readonly direction?: "up" | "down" | "left" | "right" | "fade";
  readonly duration?: number;
  readonly threshold?: number;
}

/**
 * 通用动画容器组件
 * 支持多种进入动画方向和自定义配置
 */
export function AnimatedContainer({
  children,
  className,
  delay = 0,
  direction = "up",
  duration = 800,
  threshold = 0.1,
}: AnimatedContainerProps) {
  const [isIntersecting, setIsIntersecting] = useState(false);
  const elementRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const element = elementRef.current;
    if (!element || !("IntersectionObserver" in window)) {
      // 如果不支持 IntersectionObserver，直接显示元素
      setIsIntersecting(true);
      return;
    }

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsIntersecting(true);
          observer.unobserve(element); // 只触发一次
        }
      },
      {
        threshold,
        rootMargin: "0px 0px -50px 0px",
      }
    );

    observer.observe(element);

    return () => {
      observer.unobserve(element);
    };
  }, [threshold]);

  // 根据方向设置初始变换
  const getTransform = () => {
    switch (direction) {
      case "up":
        return "translateY(30px)";
      case "down":
        return "translateY(-30px)";
      case "left":
        return "translateX(30px)";
      case "right":
        return "translateX(-30px)";
      case "fade":
      default:
        return "translateY(0px)";
    }
  };

  return (
    <div
      ref={elementRef}
      className={cn("transition-all ease-out", className)}
      style={{
        transitionDuration: `${duration}ms`,
        transitionDelay: `${delay}ms`,
        opacity: isIntersecting ? 1 : 0,
        transform: isIntersecting
          ? "translateY(0px) translateX(0px)"
          : getTransform(),
      }}
    >
      {children}
    </div>
  );
}
