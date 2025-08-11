"use client";

import { motion } from "framer-motion";
import React, { useEffect, useRef, useState } from "react";
import "./core-effects.css";

const CoreEffectsDemo = () => {
  const matrixCanvasRef = useRef<HTMLCanvasElement>(null);

  // 数字雨背景效果
  useEffect(() => {
    const canvas = matrixCanvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    const resizeCanvas = () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    };

    resizeCanvas();
    window.addEventListener("resize", resizeCanvas);

    // 数字雨字符
    const matrixChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()";
    const fontSize = 14;
    const columns = Math.floor(canvas.width / fontSize);
    const drops: number[] = [];

    // 初始化雨滴位置
    for (let i = 0; i < columns; i++) {
      drops[i] = Math.random() * canvas.height;
    }

    let animationId: number;
    const drawMatrix = () => {
      // 半透明黑色背景，创造拖尾效果
      ctx.fillStyle = "rgba(0, 0, 0, 0.05)";
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      // 绿色文字
      ctx.fillStyle = "#0F4";
      ctx.font = `${fontSize}px monospace`;

      for (let i = 0; i < drops.length; i++) {
        const char =
          matrixChars[Math.floor(Math.random() * matrixChars.length)];
        const x = i * fontSize;
        const y = drops[i] * fontSize;

        ctx.fillText(char, x, y);

        // 随机重置雨滴位置
        if (y > canvas.height && Math.random() > 0.975) {
          drops[i] = 0;
        }
        drops[i]++;
      }

      animationId = requestAnimationFrame(drawMatrix);
    };

    drawMatrix();

    return () => {
      if (animationId) {
        cancelAnimationFrame(animationId);
      }
      window.removeEventListener("resize", resizeCanvas);
    };
  }, []);

  // 液态变形按钮组件
  const MorphingBlobButton = ({
    children,
    className = "",
    onClick,
  }: {
    children: React.ReactNode;
    className?: string;
    onClick?: () => void;
  }) => {
    const [isHovered, setIsHovered] = useState(false);

    return (
      <motion.button
        className={`morphing-blob-button relative px-8 py-4 rounded-full font-semibold text-white overflow-hidden transition-all duration-500 ${className}`}
        onHoverStart={() => setIsHovered(true)}
        onHoverEnd={() => setIsHovered(false)}
        onClick={onClick}
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.95 }}
      >
        {/* 液态变形背景 */}
        <div className="absolute inset-0 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500">
          <div className={`blob-shape ${isHovered ? "blob-hover" : ""}`} />
        </div>

        {/* 按钮内容 */}
        <span className="relative z-10">{children}</span>

        {/* 光泽效果 */}
        <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white to-transparent opacity-0 hover:opacity-20 transition-opacity duration-300 transform -translate-x-full hover:translate-x-full" />
      </motion.button>
    );
  };

  // 全息投影卡片组件
  const HolographicCard = ({
    title,
    description,
    tech,
    progress = 85,
    gradient = "from-blue-500 to-cyan-500",
  }: {
    title: string;
    description: string;
    tech: string;
    progress?: number;
    gradient?: string;
  }) => {
    const [rotateX, setRotateX] = useState(0);
    const [rotateY, setRotateY] = useState(0);
    const cardRef = useRef<HTMLDivElement>(null);

    const handleMouseMove = (e: React.MouseEvent) => {
      if (!cardRef.current) return;

      const rect = cardRef.current.getBoundingClientRect();
      const centerX = rect.left + rect.width / 2;
      const centerY = rect.top + rect.height / 2;

      const rotateXValue = (e.clientY - centerY) / 10;
      const rotateYValue = (centerX - e.clientX) / 10;

      setRotateX(rotateXValue);
      setRotateY(rotateYValue);
    };

    const handleMouseLeave = () => {
      setRotateX(0);
      setRotateY(0);
    };

    return (
      <div
        ref={cardRef}
        className="holographic-card perspective-1000 w-full h-80"
        onMouseMove={handleMouseMove}
        onMouseLeave={handleMouseLeave}
      >
        <motion.div
          className="relative w-full h-full rounded-2xl p-8 bg-gradient-to-br from-gray-900/90 to-gray-800/90 backdrop-blur-sm border border-gray-700 transform-gpu transition-all duration-300 hover:border-transparent"
          style={{
            rotateX,
            rotateY,
            transformStyle: "preserve-3d",
          }}
          whileHover={{ z: 50 }}
        >
          {/* 全息光效背景 */}
          <div
            className={`absolute inset-0 bg-gradient-to-br ${gradient} opacity-20 rounded-2xl`}
          />

          {/* 反光效果 */}
          <div
            className="absolute inset-0 bg-gradient-to-br from-white/10 via-transparent to-transparent rounded-2xl"
            style={{
              transform: `translateX(${rotateY * 2}px) translateY(${
                rotateX * 2
              }px)`,
            }}
          />

          {/* 卡片内容 */}
          <div className="relative z-10 h-full flex flex-col justify-between">
            <div>
              {/* 图标 */}
              <div className="w-16 h-16 bg-gradient-to-br from-white/20 to-white/10 rounded-2xl mb-6 flex items-center justify-center">
                <div
                  className={`w-8 h-8 bg-gradient-to-br ${gradient} rounded-lg animate-pulse`}
                />
              </div>

              {/* 标题和描述 */}
              <h3 className="text-2xl font-bold mb-2 text-white">{title}</h3>
              <p className="text-gray-300 mb-4">{description}</p>
              <p className="text-sm text-gray-400 mb-6">Built with {tech}</p>
            </div>

            {/* 进度条 */}
            <div className="space-y-2">
              <div className="w-full h-2 bg-gray-700 rounded-full overflow-hidden">
                <motion.div
                  className={`h-full bg-gradient-to-r ${gradient} rounded-full`}
                  initial={{ width: 0 }}
                  animate={{ width: `${progress}%` }}
                  transition={{ duration: 2, delay: 0.5 }}
                />
              </div>
              <p className="text-sm text-gray-400">{progress}% Complete</p>
            </div>
          </div>

          {/* 3D 边框效果 */}
          <div
            className="absolute inset-0 rounded-2xl border-2 border-white/20"
            style={{
              transform: "translateZ(10px)",
            }}
          />
        </motion.div>
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-black text-white overflow-hidden relative">
      {/* 数字雨背景 */}
      <canvas
        ref={matrixCanvasRef}
        className="fixed inset-0 w-full h-full opacity-30 pointer-events-none"
        style={{ zIndex: 1 }}
      />

      {/* 主要内容 */}
      <div className="relative z-10">
        {/* 导航栏 */}
        <nav className="fixed top-0 w-full z-50 backdrop-blur-md bg-black/30 border-b border-gray-800">
          <div className="max-w-7xl mx-auto px-6 py-4">
            <div className="flex justify-between items-center">
              <h1 className="text-2xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
                核心视觉特效
              </h1>
              <div className="flex space-x-6 text-sm">
                <a
                  href="#gradient-border"
                  className="hover:text-blue-400 transition-colors"
                >
                  渐变边框
                </a>
                <a
                  href="#holographic"
                  className="hover:text-purple-400 transition-colors"
                >
                  全息卡片
                </a>
                <a
                  href="#morphing"
                  className="hover:text-pink-400 transition-colors"
                >
                  液态按钮
                </a>
                <a
                  href="#matrix"
                  className="hover:text-green-400 transition-colors"
                >
                  数字雨
                </a>
              </div>
            </div>
          </div>
        </nav>

        {/* Hero 区域 */}
        <section className="pt-32 pb-20 text-center">
          <motion.h1
            className="text-7xl font-bold mb-6"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1 }}
          >
            <span className="bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 bg-clip-text text-transparent">
              核心视觉特效
            </span>
          </motion.h1>
          <motion.p
            className="text-xl text-gray-300 mb-12 max-w-3xl mx-auto px-6"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1, delay: 0.3 }}
          >
            四个最震撼的视觉特效组件：渐变边框动画、全息投影卡片、液态变形按钮、数字雨背景
          </motion.p>
        </section>

        {/* 1. 渐变边框动画 */}
        <section id="gradient-border" className="py-20">
          <div className="max-w-7xl mx-auto px-6">
            <motion.h2
              className="text-5xl font-bold mb-16 text-center"
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8 }}
            >
              ### 1. **渐变边框动画 (Gradient Border)**
            </motion.h2>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {/* 旋转边框 */}
              <motion.div
                className="gradient-border-rotating p-8 rounded-2xl bg-gray-900/80 backdrop-blur-sm text-center"
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6 }}
              >
                <div className="w-16 h-16 bg-gradient-to-br from-blue-400 to-cyan-400 rounded-full mx-auto mb-6 flex items-center justify-center">
                  <span className="text-2xl">🌀</span>
                </div>
                <h3 className="text-2xl font-bold mb-4 text-blue-400">
                  旋转边框
                </h3>
                <p className="text-gray-300">
                  360度连续旋转的渐变边框，营造出科技感十足的动态效果
                </p>
              </motion.div>

              {/* 脉冲边框 */}
              <motion.div
                className="gradient-border-pulsing p-8 rounded-2xl bg-gray-900/80 backdrop-blur-sm text-center"
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: 0.1 }}
              >
                <div className="w-16 h-16 bg-gradient-to-br from-purple-400 to-pink-400 rounded-full mx-auto mb-6 flex items-center justify-center">
                  <span className="text-2xl">💓</span>
                </div>
                <h3 className="text-2xl font-bold mb-4 text-purple-400">
                  脉冲边框
                </h3>
                <p className="text-gray-300">
                  如心跳般律动的脉冲效果，边框呼吸般地明暗变化
                </p>
              </motion.div>

              {/* 流动边框 */}
              <motion.div
                className="gradient-border-flowing p-8 rounded-2xl bg-gray-900/80 backdrop-blur-sm text-center"
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: 0.2 }}
              >
                <div className="w-16 h-16 bg-gradient-to-br from-pink-400 to-red-400 rounded-full mx-auto mb-6 flex items-center justify-center">
                  <span className="text-2xl">🌊</span>
                </div>
                <h3 className="text-2xl font-bold mb-4 text-pink-400">
                  流动边框
                </h3>
                <p className="text-gray-300">
                  色彩如液体般沿边框流动，创造出动感的视觉体验
                </p>
              </motion.div>
            </div>
          </div>
        </section>

        {/* 2. 全息投影卡片 */}
        <section
          id="holographic"
          className="py-20 bg-gradient-to-b from-transparent to-gray-900/20"
        >
          <div className="max-w-7xl mx-auto px-6">
            <motion.h2
              className="text-5xl font-bold mb-16 text-center"
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8 }}
            >
              ### 2. **全息投影卡片 (Holographic Cards)**
            </motion.h2>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              <motion.div
                initial={{ opacity: 0, x: -30 }}
                whileInView={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.6 }}
              >
                <HolographicCard
                  title="AI 神经网络"
                  description="基于深度学习的智能数据分析平台，实现复杂模式识别"
                  tech="TensorFlow.js"
                  progress={92}
                  gradient="from-blue-500 to-cyan-500"
                />
              </motion.div>

              <motion.div
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: 0.1 }}
              >
                <HolographicCard
                  title="区块链浏览器"
                  description="去中心化应用界面，支持多链交易查询和智能合约交互"
                  tech="Web3.js"
                  progress={78}
                  gradient="from-purple-500 to-pink-500"
                />
              </motion.div>

              <motion.div
                initial={{ opacity: 0, x: 30 }}
                whileInView={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.6, delay: 0.2 }}
              >
                <HolographicCard
                  title="量子计算模拟"
                  description="量子比特态模拟器，可视化量子算法执行过程"
                  tech="Qiskit.js"
                  progress={65}
                  gradient="from-green-500 to-teal-500"
                />
              </motion.div>
            </div>
          </div>
        </section>

        {/* 3. 液态变形按钮 */}
        <section id="morphing" className="py-20">
          <div className="max-w-7xl mx-auto px-6">
            <motion.h2
              className="text-5xl font-bold mb-16 text-center"
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8 }}
            >
              ### 3. **液态变形按钮 (Morphing Blob Button)**
            </motion.h2>

            <div className="text-center space-y-8">
              <p className="text-xl text-gray-300 mb-12 max-w-2xl mx-auto">
                如液体般流动变形的按钮效果，悬停时产生动态的形状变化
              </p>

              <div className="flex flex-wrap justify-center gap-8">
                <MorphingBlobButton
                  className="bg-gradient-to-r from-blue-500 to-cyan-500"
                  onClick={() => alert("蓝色液态按钮被点击！")}
                >
                  🚀 启动项目
                </MorphingBlobButton>

                <MorphingBlobButton
                  className="bg-gradient-to-r from-purple-500 to-pink-500"
                  onClick={() => alert("紫色液态按钮被点击！")}
                >
                  ⚡ 查看演示
                </MorphingBlobButton>

                <MorphingBlobButton
                  className="bg-gradient-to-r from-green-500 to-emerald-500"
                  onClick={() => alert("绿色液态按钮被点击！")}
                >
                  🌟 下载资源
                </MorphingBlobButton>

                <MorphingBlobButton
                  className="bg-gradient-to-r from-orange-500 to-red-500"
                  onClick={() => alert("橙色液态按钮被点击！")}
                >
                  🔥 联系我们
                </MorphingBlobButton>
              </div>

              <div className="mt-12 text-gray-400 text-sm">
                悬停按钮体验液态变形效果 ⬆️
              </div>
            </div>
          </div>
        </section>

        {/* 4. 数字雨背景说明 */}
        <section
          id="matrix"
          className="py-20 bg-gradient-to-b from-transparent to-black/40"
        >
          <div className="max-w-7xl mx-auto px-6">
            <motion.h2
              className="text-5xl font-bold mb-16 text-center"
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8 }}
            >
              ### 4. **数字雨背景 (Matrix Rain)**
            </motion.h2>

            <div className="text-center">
              <motion.div
                className="max-w-3xl mx-auto"
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.8 }}
              >
                <div className="relative p-8 rounded-2xl bg-black/60 backdrop-blur-sm border border-green-500/20">
                  <div className="absolute inset-0 bg-gradient-to-br from-green-500/10 to-transparent rounded-2xl" />

                  <div className="relative z-10">
                    <div className="w-20 h-20 bg-gradient-to-br from-green-400 to-emerald-500 rounded-full mx-auto mb-6 flex items-center justify-center">
                      <span className="text-3xl">🔢</span>
                    </div>

                    <h3 className="text-3xl font-bold mb-6 text-green-400">
                      黑客帝国风格数字雨
                    </h3>

                    <p className="text-xl text-gray-300 mb-6 leading-relaxed">
                      经典的Matrix风格数字雨背景效果，随机字符从屏幕顶部下落，
                      营造出科幻电影般的视觉氛围。
                    </p>

                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm text-gray-400">
                      <div className="bg-green-500/10 p-3 rounded-lg">
                        <div className="font-semibold text-green-400">
                          字符集
                        </div>
                        <div>A-Z, 0-9, 符号</div>
                      </div>
                      <div className="bg-green-500/10 p-3 rounded-lg">
                        <div className="font-semibold text-green-400">动画</div>
                        <div>60fps 流畅</div>
                      </div>
                      <div className="bg-green-500/10 p-3 rounded-lg">
                        <div className="font-semibold text-green-400">效果</div>
                        <div>拖尾渐隐</div>
                      </div>
                      <div className="bg-green-500/10 p-3 rounded-lg">
                        <div className="font-semibold text-green-400">性能</div>
                        <div>GPU 优化</div>
                      </div>
                    </div>
                  </div>
                </div>
              </motion.div>
            </div>
          </div>
        </section>

        {/* 底部信息 */}
        <footer className="py-16 text-center border-t border-gray-800">
          <div className="max-w-7xl mx-auto px-6">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8 }}
            >
              <h3 className="text-2xl font-bold mb-6 bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
                🎨 PortfolioPulse 核心视觉特效演示
              </h3>
              <p className="text-gray-400 mb-8 max-w-2xl mx-auto">
                精选四个最具视觉冲击力的Web组件，每个都经过精心优化，
                确保在各种设备上都能提供流畅的60fps体验。
              </p>
              <div className="flex flex-wrap justify-center gap-6 text-sm text-gray-500">
                <span className="flex items-center gap-2">
                  ⚡ <span>GPU 加速</span>
                </span>
                <span className="flex items-center gap-2">
                  🎯 <span>性能优化</span>
                </span>
                <span className="flex items-center gap-2">
                  📱 <span>响应式设计</span>
                </span>
                <span className="flex items-center gap-2">
                  🌈 <span>现代渐变</span>
                </span>
                <span className="flex items-center gap-2">
                  🔧 <span>易于集成</span>
                </span>
              </div>
            </motion.div>
          </div>
        </footer>
      </div>
    </div>
  );
};

export default CoreEffectsDemo;
