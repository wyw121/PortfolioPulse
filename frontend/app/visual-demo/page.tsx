"use client";

import { motion } from "framer-motion";
import React, { useCallback, useEffect, useRef, useState } from "react";
import "./visual-demo.css";

const VisualDemo = () => {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  // 优化的粒子系统
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    const resizeCanvas = () => {
      canvas.width = canvas.offsetWidth;
      canvas.height = 400;
    };

    resizeCanvas();
    window.addEventListener("resize", resizeCanvas);

    const particles: Array<{
      x: number;
      y: number;
      vx: number;
      vy: number;
      size: number;
    }> = [];

    // 减少粒子数量以提升性能
    const particleCount = 20;
    for (let i = 0; i < particleCount; i++) {
      particles.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        vx: (Math.random() - 0.5) * 0.3,
        vy: (Math.random() - 0.5) * 0.3,
        size: Math.random() * 2 + 1,
      });
    }

    let animationId: number;
    const animate = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      // 更新和绘制粒子
      particles.forEach((particle) => {
        particle.x += particle.vx;
        particle.y += particle.vy;

        if (particle.x < 0 || particle.x > canvas.width) particle.vx *= -1;
        if (particle.y < 0 || particle.y > canvas.height) particle.vy *= -1;

        // 绘制粒子
        ctx.beginPath();
        ctx.arc(particle.x, particle.y, particle.size, 0, Math.PI * 2);
        ctx.fillStyle = "rgba(59, 130, 246, 0.6)";
        ctx.fill();
      });

      // 优化连线绘制
      particles.forEach((particle1, i) => {
        particles.slice(i + 1, i + 3).forEach((particle2) => {
          // 限制连线数量
          const dx = particle1.x - particle2.x;
          const dy = particle1.y - particle2.y;
          const distance = Math.sqrt(dx * dx + dy * dy);

          if (distance < 60) {
            // 减少连线距离
            ctx.beginPath();
            ctx.moveTo(particle1.x, particle1.y);
            ctx.lineTo(particle2.x, particle2.y);
            ctx.strokeStyle = `rgba(139, 92, 246, ${
              (1 - distance / 60) * 0.3
            })`;
            ctx.lineWidth = 1;
            ctx.stroke();
          }
        });
      });

      animationId = requestAnimationFrame(animate);
    };

    animate();

    return () => {
      if (animationId) {
        cancelAnimationFrame(animationId);
      }
      window.removeEventListener("resize", resizeCanvas);
    };
  }, []);

  // 优化的文字加密效果
  const EncryptedText = ({
    children,
    delay = 0,
    className = "",
  }: {
    children: string;
    delay?: number;
    className?: string;
  }) => {
    const [displayText, setDisplayText] = useState("");
    const [isAnimating, setIsAnimating] = useState(false);
    const intervalRef = useRef<NodeJS.Timeout | null>(null);

    const chars =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()";

    const startDecryption = useCallback(() => {
      if (isAnimating) return; // 防止重复触发

      setIsAnimating(true);
      let iterations = 0;

      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }

      intervalRef.current = setInterval(() => {
        setDisplayText(
          children
            .split("")
            .map((char, index) => {
              if (index < iterations) {
                return children[index];
              }
              return chars[Math.floor(Math.random() * chars.length)];
            })
            .join("")
        );

        if (iterations >= children.length) {
          if (intervalRef.current) {
            clearInterval(intervalRef.current);
          }
          setIsAnimating(false);
        }
        iterations += 0.5; // 减慢动画速度
      }, 60); // 增加间隔时间
    }, [children, chars, isAnimating]);

    useEffect(() => {
      const timer = setTimeout(startDecryption, delay);
      return () => {
        clearTimeout(timer);
        if (intervalRef.current) {
          clearInterval(intervalRef.current);
        }
      };
    }, [delay, startDecryption]);

    return (
      <span
        className={`font-mono cursor-pointer transition-opacity duration-200 hover:opacity-80 ${className}`}
        onClick={startDecryption}
      >
        {displayText || children}
      </span>
    );
  };

  // 打字机删除输入效果
  const TypewriterText = ({
    texts,
    typingSpeed = 100,
    deletingSpeed = 50,
    pauseDuration = 2000,
    className = "",
  }: {
    texts: string[];
    typingSpeed?: number;
    deletingSpeed?: number;
    pauseDuration?: number;
    className?: string;
  }) => {
    const [displayText, setDisplayText] = useState("");
    const [textIndex, setTextIndex] = useState(0);
    const [isDeleting, setIsDeleting] = useState(false);
    const [showCursor, setShowCursor] = useState(true);
    const timeoutRef = useRef<NodeJS.Timeout | null>(null);
    const cursorIntervalRef = useRef<NodeJS.Timeout | null>(null);

    useEffect(() => {
      const currentText = texts[textIndex];

      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }

      timeoutRef.current = setTimeout(
        () => {
          if (isDeleting) {
            setDisplayText((prev) => prev.slice(0, -1));
            if (displayText === "") {
              setIsDeleting(false);
              setTextIndex((prev) => (prev + 1) % texts.length);
            }
          } else {
            if (displayText !== currentText) {
              setDisplayText(currentText.slice(0, displayText.length + 1));
            } else {
              setTimeout(() => setIsDeleting(true), pauseDuration);
            }
          }
        },
        isDeleting ? deletingSpeed : typingSpeed
      );

      return () => {
        if (timeoutRef.current) {
          clearTimeout(timeoutRef.current);
        }
      };
    }, [
      displayText,
      textIndex,
      isDeleting,
      texts,
      typingSpeed,
      deletingSpeed,
      pauseDuration,
    ]);

    // 光标闪烁效果
    useEffect(() => {
      cursorIntervalRef.current = setInterval(() => {
        setShowCursor((prev) => !prev);
      }, 500);

      return () => {
        if (cursorIntervalRef.current) {
          clearInterval(cursorIntervalRef.current);
        }
      };
    }, []);

    return (
      <span className={`font-mono ${className}`}>
        {displayText}
        <span
          className={`inline-block w-0.5 h-6 bg-current ml-1 transition-opacity duration-100 ${
            showCursor ? "opacity-100" : "opacity-0"
          }`}
        >
          |
        </span>
      </span>
    );
  };

  // 磁吸按钮组件
  const MagneticButton = ({
    children,
    className = "",
    onClick,
  }: {
    children: React.ReactNode;
    className?: string;
    onClick?: () => void;
  }) => {
    const [position, setPosition] = useState({ x: 0, y: 0 });
    const buttonRef = useRef<HTMLButtonElement>(null);

    const handleMouseMove = (e: React.MouseEvent) => {
      if (!buttonRef.current) return;
      const rect = buttonRef.current.getBoundingClientRect();
      const centerX = rect.left + rect.width / 2;
      const centerY = rect.top + rect.height / 2;
      const x = (e.clientX - centerX) * 0.12; // 减少移动幅度
      const y = (e.clientY - centerY) * 0.12;
      setPosition({ x, y });
    };

    const handleMouseLeave = () => {
      setPosition({ x: 0, y: 0 });
    };

    return (
      <button
        ref={buttonRef}
        className={`magnetic-button relative px-8 py-4 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 text-white rounded-xl font-semibold transition-all duration-300 hover:scale-105 hover:shadow-[0_0_30px_rgba(139,92,246,0.3)] ${className}`}
        style={{
          transform: `translate3d(${position.x}px, ${position.y}px, 0)`,
        }}
        onMouseMove={handleMouseMove}
        onMouseLeave={handleMouseLeave}
        onClick={onClick}
      >
        {children}
      </button>
    );
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 text-white overflow-hidden">
      {/* 导航栏 */}
      <nav className="fixed top-0 w-full z-50 backdrop-blur-md bg-gray-900/30 border-b border-gray-800">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex justify-between items-center">
            <h1 className="text-2xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
              视觉冲击力组件演示
            </h1>
            <div className="flex space-x-6">
              <a
                href="#particles"
                className="hover:text-blue-400 transition-colors"
              >
                粒子系统
              </a>
              <a
                href="#text-effects"
                className="hover:text-purple-400 transition-colors"
              >
                文字特效
              </a>
              <a
                href="#buttons"
                className="hover:text-pink-400 transition-colors"
              >
                交互按钮
              </a>
              <a
                href="#borders"
                className="hover:text-cyan-400 transition-colors"
              >
                渐变边框
              </a>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero 区域 */}
      <section className="relative pt-32 pb-20">
        <div className="max-w-7xl mx-auto px-6 text-center">
          <motion.h1
            className="text-6xl font-bold mb-6"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
          >
            <span className="bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 bg-clip-text text-transparent">
              视觉冲击力
            </span>
          </motion.h1>
          <motion.p
            className="text-xl text-gray-300 mb-12 max-w-3xl mx-auto"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
          >
            体验现代 Web
            开发中最震撼的视觉特效组件，优化性能的同时保持极致的用户体验
          </motion.p>

          {/* 粒子系统背景 */}
          <canvas
            ref={canvasRef}
            className="absolute inset-0 w-full h-full opacity-30 pointer-events-none"
            style={{ zIndex: -1 }}
          />
        </div>
      </section>

      {/* 文字特效区域 */}
      <section
        id="text-effects"
        className="py-20 bg-gradient-to-r from-gray-900/50 to-gray-800/50"
      >
        <div className="max-w-7xl mx-auto px-6">
          <motion.h2
            className="text-4xl font-bold mb-16 text-center"
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
          >
            <span className="bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
              文字加密特效
            </span>
          </motion.h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-12">
            {/* 加密文字 */}
            <motion.div
              className="gradient-border-card p-8 rounded-2xl"
              initial={{ opacity: 0, x: -20 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.6 }}
            >
              <h3 className="text-2xl font-semibold mb-4 text-blue-400">
                解密文字效果
              </h3>
              <div className="text-lg leading-relaxed">
                点击下方文字观看解密动画：
              </div>
              <div className="mt-6 text-xl">
                <EncryptedText className="text-purple-400 text-2xl" delay={500}>
                  WELCOME TO THE FUTURE
                </EncryptedText>
              </div>
              <div className="mt-4 text-gray-400 text-sm">
                点击文字重新触发解密动画
              </div>
            </motion.div>

            {/* 打字机效果 */}
            <motion.div
              className="gradient-border-card p-8 rounded-2xl"
              initial={{ opacity: 0, x: 20 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.6 }}
            >
              <h3 className="text-2xl font-semibold mb-4 text-pink-400">
                打字机效果
              </h3>
              <div className="text-lg leading-relaxed mb-6">
                模拟真实打字删除输入过程：
              </div>
              <div className="text-xl h-8">
                <TypewriterText
                  texts={[
                    "Hello World!",
                    "欢迎来到未来科技",
                    "Experience the Future",
                    "代码改变世界",
                  ]}
                  className="text-cyan-400 text-2xl"
                  typingSpeed={120}
                  deletingSpeed={60}
                  pauseDuration={1800}
                />
              </div>
            </motion.div>
          </div>
        </div>
      </section>

      {/* 交互按钮区域 */}
      <section id="buttons" className="py-20">
        <div className="max-w-7xl mx-auto px-6">
          <motion.h2
            className="text-4xl font-bold mb-16 text-center"
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
          >
            <span className="bg-gradient-to-r from-cyan-400 to-blue-400 bg-clip-text text-transparent">
              磁吸交互按钮
            </span>
          </motion.h2>

          <div className="flex flex-wrap justify-center gap-8">
            <MagneticButton onClick={() => alert("磁吸按钮1被点击！")}>
              🚀 磁吸效果
            </MagneticButton>

            <MagneticButton
              className="bg-gradient-to-r from-purple-500 via-pink-500 to-red-500"
              onClick={() => alert("磁吸按钮2被点击！")}
            >
              ⚡ 动态响应
            </MagneticButton>

            <MagneticButton
              className="bg-gradient-to-r from-green-500 via-teal-500 to-cyan-500"
              onClick={() => alert("磁吸按钮3被点击！")}
            >
              🌟 视觉冲击
            </MagneticButton>
          </div>

          <div className="text-center mt-12 text-gray-400">
            将鼠标悬停在按钮上体验磁吸效果
          </div>
        </div>
      </section>

      {/* 渐变边框区域 */}
      <section
        id="borders"
        className="py-20 bg-gradient-to-r from-gray-900/50 to-gray-800/50"
      >
        <div className="max-w-7xl mx-auto px-6">
          <motion.h2
            className="text-4xl font-bold mb-16 text-center"
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
          >
            <span className="bg-gradient-to-r from-pink-400 to-purple-400 bg-clip-text text-transparent">
              渐变边框动画
            </span>
          </motion.h2>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <motion.div
              className="gradient-border-animated p-8 rounded-2xl bg-gray-800/30 backdrop-blur-sm"
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
            >
              <h3 className="text-xl font-semibold mb-4 text-blue-400">
                旋转边框
              </h3>
              <p className="text-gray-300">
                CSS 渐变边框配合旋转动画，创造出科技感十足的视觉效果
              </p>
            </motion.div>

            <motion.div
              className="gradient-border-pulse p-8 rounded-2xl bg-gray-800/30 backdrop-blur-sm"
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.1 }}
            >
              <h3 className="text-xl font-semibold mb-4 text-purple-400">
                脉冲边框
              </h3>
              <p className="text-gray-300">
                呼吸般的脉冲效果，让边框仿佛有生命力一般跳动
              </p>
            </motion.div>

            <motion.div
              className="gradient-border-flow p-8 rounded-2xl bg-gray-800/30 backdrop-blur-sm"
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
            >
              <h3 className="text-xl font-semibold mb-4 text-pink-400">
                流动边框
              </h3>
              <p className="text-gray-300">
                色彩沿着边框流动，如同液体在管道中流淌的动感效果
              </p>
            </motion.div>
          </div>
        </div>
      </section>

      {/* 底部信息 */}
      <footer className="py-12 text-center border-t border-gray-800">
        <div className="max-w-7xl mx-auto px-6">
          <p className="text-gray-400 mb-4">
            🎨 专为 PortfolioPulse 设计的视觉冲击力组件演示
          </p>
          <div className="flex justify-center space-x-8 text-sm text-gray-500">
            <span>⚡ 60fps 流畅动画</span>
            <span>🎯 性能优化</span>
            <span>📱 响应式设计</span>
            <span>🌈 现代渐变风格</span>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default VisualDemo;
