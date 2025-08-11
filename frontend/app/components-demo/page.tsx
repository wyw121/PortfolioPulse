"use client";

import { motion } from "framer-motion";
import React, { useEffect, useRef, useState } from "react";
import MatrixRain from "../../components/MatrixRain";
import NeuralNetwork from "../../components/NeuralNetwork";
import "./components-demo.css";

const ComponentsDemo = () => {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [scrollProgress, setScrollProgress] = useState(0);

  // 滚动进度跟踪
  useEffect(() => {
    const handleScroll = () => {
      const scrollTop = window.scrollY;
      const docHeight =
        document.documentElement.scrollHeight - window.innerHeight;
      const progress = (scrollTop / docHeight) * 100;
      setScrollProgress(progress);
    };

    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  // 粒子系统
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    canvas.width = window.innerWidth;
    canvas.height = 600;

    const particles: Array<{
      x: number;
      y: number;
      vx: number;
      vy: number;
      size: number;
    }> = [];

    // 创建粒子
    for (let i = 0; i < 50; i++) {
      particles.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        vx: (Math.random() - 0.5) * 0.5,
        vy: (Math.random() - 0.5) * 0.5,
        size: Math.random() * 3 + 1,
      });
    }

    const animate = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      // 更新粒子
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

      // 绘制连线
      particles.forEach((particle1, i) => {
        particles.slice(i + 1).forEach((particle2) => {
          const dx = particle1.x - particle2.x;
          const dy = particle1.y - particle2.y;
          const distance = Math.sqrt(dx * dx + dy * dy);

          if (distance < 100) {
            ctx.beginPath();
            ctx.moveTo(particle1.x, particle1.y);
            ctx.lineTo(particle2.x, particle2.y);
            ctx.strokeStyle = `rgba(139, 92, 246, ${1 - distance / 100})`;
            ctx.stroke();
          }
        });
      });

      requestAnimationFrame(animate);
    };

    animate();
  }, []);

  // 文字加密效果
  const EncryptedText = ({
    children,
    delay = 0,
  }: {
    children: string;
    delay?: number;
  }) => {
    const [displayText, setDisplayText] = useState("");
    const chars =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()";

    const startDecryption = React.useCallback(() => {
      let iterations = 0;
      const interval = setInterval(() => {
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
          clearInterval(interval);
        }
        iterations += 1 / 3;
      }, 30);
    }, [children, chars]);

    useEffect(() => {
      const timer = setTimeout(startDecryption, delay);
      return () => clearTimeout(timer);
    }, [delay, startDecryption]);

    return (
      <span className="font-mono cursor-pointer" onClick={startDecryption}>
        {displayText || children}
      </span>
    );
  };

  // 磁吸按钮组件
  const MagneticButton = ({ children }: { children: React.ReactNode }) => {
    const [position, setPosition] = useState({ x: 0, y: 0 });
    const buttonRef = useRef<HTMLButtonElement>(null);

    const handleMouseMove = (e: React.MouseEvent) => {
      if (!buttonRef.current) return;
      const rect = buttonRef.current.getBoundingClientRect();
      const centerX = rect.left + rect.width / 2;
      const centerY = rect.top + rect.height / 2;
      const x = (e.clientX - centerX) * 0.3;
      const y = (e.clientY - centerY) * 0.3;
      setPosition({ x, y });
    };

    const handleMouseLeave = () => {
      setPosition({ x: 0, y: 0 });
    };

    return (
      <button
        ref={buttonRef}
        className="relative px-8 py-4 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 text-white rounded-xl font-semibold transition-transform duration-300 hover:scale-105"
        style={{
          transform: `translate3d(${position.x}px, ${position.y}px, 0)`,
        }}
        onMouseMove={handleMouseMove}
        onMouseLeave={handleMouseLeave}
      >
        {children}
      </button>
    );
  };

  return (
    <div className="min-h-screen bg-gray-900 text-white overflow-x-hidden">
      {/* 滚动进度指示器 */}
      <div className="fixed top-0 left-0 w-full h-1 bg-gray-800 z-50">
        <div
          className="h-full bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 transition-all duration-100"
          style={{ width: `${scrollProgress}%` }}
        />
      </div>

      {/* Hero Section with Particles */}
      <section className="relative h-screen flex items-center justify-center">
        <canvas ref={canvasRef} className="absolute inset-0 w-full h-full" />
        <div className="relative z-10 text-center">
          <motion.h1
            className="text-6xl font-bold mb-8"
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1 }}
          >
            <EncryptedText delay={1000}>Creative Components</EncryptedText>
          </motion.h1>
          <motion.p
            className="text-xl text-gray-300 mb-12"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 2, duration: 1 }}
          >
            Experience the future of web interactions
          </motion.p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <MagneticButton>Explore Effects</MagneticButton>
            <a
              href="/visual-demo"
              className="px-8 py-4 border-2 border-purple-500 text-purple-400 rounded-xl font-semibold hover:bg-purple-500 hover:text-white transition-all duration-300 hover:scale-105"
            >
              🎯 视觉冲击力演示
            </a>
            <a
              href="/core-effects"
              className="px-8 py-4 bg-gradient-to-r from-green-500 to-emerald-500 text-white rounded-xl font-semibold hover:from-green-600 hover:to-emerald-600 transition-all duration-300 hover:scale-105 shadow-lg"
            >
              ⚡ 核心特效演示
            </a>
          </div>
        </div>
      </section>

      {/* 渐变边框卡片区域 */}
      <section className="py-20 px-8">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-16">
            <EncryptedText delay={0}>Gradient Border Cards</EncryptedText>
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {[1, 2, 3].map((item) => (
              <div
                key={item}
                className="gradient-border-card group cursor-pointer"
              >
                <div className="relative bg-gray-800 p-8 rounded-xl border border-gray-700 hover:border-transparent transition-all duration-300">
                  <div className="absolute inset-0 rounded-xl bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300 blur-xl" />
                  <div className="relative z-10">
                    <h3 className="text-2xl font-semibold mb-4">
                      Project {item}
                    </h3>
                    <p className="text-gray-300 mb-6">
                      A revolutionary approach to modern web development with
                      cutting-edge technologies.
                    </p>
                    <div className="flex items-center space-x-2">
                      <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse" />
                      <span className="text-sm text-green-400">
                        Active Development
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* 全息投影卡片 */}
      <section className="py-20 px-8 bg-gray-800/30">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-16">
            <EncryptedText delay={0}>Holographic Cards</EncryptedText>
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-12">
            {[
              {
                title: "AI Neural Network",
                tech: "TensorFlow.js",
                color: "from-blue-500 to-cyan-500",
              },
              {
                title: "Blockchain Explorer",
                tech: "Web3.js",
                color: "from-purple-500 to-pink-500",
              },
            ].map((project, index) => (
              <div key={index} className="holographic-card">
                <div className="relative group perspective-1000">
                  <div className="relative w-full h-80 bg-gradient-to-br from-gray-900 to-gray-700 rounded-2xl p-8 transform-gpu transition-all duration-300 group-hover:rotate-x-12 group-hover:rotate-y-12 group-hover:scale-105 shadow-2xl">
                    <div
                      className={`absolute inset-0 bg-gradient-to-br ${project.color} opacity-20 rounded-2xl`}
                    />
                    <div className="relative z-10">
                      <div className="w-16 h-16 bg-gradient-to-br from-white/20 to-white/10 rounded-2xl mb-6 flex items-center justify-center">
                        <div className="w-8 h-8 bg-gradient-to-br from-blue-400 to-purple-400 rounded-lg animate-spin" />
                      </div>
                      <h3 className="text-2xl font-bold mb-2">
                        {project.title}
                      </h3>
                      <p className="text-gray-300 mb-4">
                        Built with {project.tech}
                      </p>
                      <div className="space-y-2">
                        <div className="w-full h-2 bg-gray-600 rounded-full overflow-hidden">
                          <div
                            className="h-full bg-gradient-to-r from-blue-500 to-purple-500 rounded-full animate-pulse"
                            style={{ width: "80%" }}
                          />
                        </div>
                        <p className="text-sm text-gray-400">80% Complete</p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* 液态变形按钮区域 */}
      <section className="py-20 px-8">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-4xl font-bold mb-16">
            <EncryptedText delay={0}>Morphing Interactions</EncryptedText>
          </h2>
          <div className="flex flex-wrap justify-center gap-8">
            {[
              { text: "Download CV", color: "from-green-500 to-emerald-500" },
              { text: "Contact Me", color: "from-blue-500 to-cyan-500" },
              { text: "View Projects", color: "from-purple-500 to-pink-500" },
            ].map((btn, index) => (
              <button
                key={index}
                className={`morphing-button relative px-8 py-4 bg-gradient-to-r ${btn.color} text-white rounded-full font-semibold overflow-hidden transform transition-all duration-300 hover:scale-110 hover:shadow-2xl`}
              >
                <span className="relative z-10">{btn.text}</span>
                <div className="absolute inset-0 bg-white opacity-0 hover:opacity-20 transition-opacity duration-300 rounded-full transform scale-0 hover:scale-150" />
              </button>
            ))}
          </div>
        </div>
      </section>

      {/* 数据可视化区域 */}
      <section className="py-20 px-8 bg-gray-800/50">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-16">
            <EncryptedText delay={0}>Data Visualization</EncryptedText>
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {[
              {
                label: "Projects Completed",
                value: "42",
                color: "text-green-400",
              },
              { label: "Lines of Code", value: "50K+", color: "text-blue-400" },
              {
                label: "Coffee Consumed",
                value: "∞",
                color: "text-yellow-400",
              },
              { label: "Hours Coded", value: "2.5K", color: "text-purple-400" },
            ].map((stat, index) => (
              <motion.div
                key={index}
                className="text-center p-6 bg-gray-800/80 rounded-2xl border border-gray-600 hover:border-gray-500 transition-all duration-300"
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1 }}
                viewport={{ once: true }}
              >
                <div className="relative inline-block mb-4">
                  <svg className="w-24 h-24 transform -rotate-90">
                    <circle
                      cx="48"
                      cy="48"
                      r="40"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="8"
                      className="text-gray-700"
                    />
                    <circle
                      cx="48"
                      cy="48"
                      r="40"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="8"
                      strokeLinecap="round"
                      className={stat.color}
                      strokeDasharray={`${2 * Math.PI * 40}`}
                      strokeDashoffset={`${
                        2 * Math.PI * 40 * (1 - (Math.random() * 0.8 + 0.2))
                      }`}
                      style={{
                        animation: "draw-circle 2s ease-out forwards",
                      }}
                    />
                  </svg>
                  <div className="absolute inset-0 flex items-center justify-center">
                    <span className={`text-2xl font-bold ${stat.color}`}>
                      {stat.value}
                    </span>
                  </div>
                </div>
                <h3 className="text-lg font-semibold text-gray-300">
                  {stat.label}
                </h3>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* AI 神经网络展示 */}
      <section className="py-20 px-8">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-16">
            <EncryptedText delay={0}>AI Neural Network</EncryptedText>
          </h2>
          <div className="flex justify-center">
            <NeuralNetwork />
          </div>
        </div>
      </section>

      {/* 堆叠卡片效果 */}
      <section className="py-20 px-8">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-16">
            <EncryptedText delay={0}>Stacking Cards</EncryptedText>
          </h2>
          <div className="space-y-8">
            {[
              {
                title: "Frontend Development",
                desc: "React, Next.js, TypeScript",
                color: "from-blue-600 to-blue-400",
              },
              {
                title: "Backend Development",
                desc: "Node.js, Python, Rust",
                color: "from-green-600 to-green-400",
              },
              {
                title: "AI/ML Engineering",
                desc: "TensorFlow, PyTorch, OpenAI",
                color: "from-purple-600 to-purple-400",
              },
              {
                title: "DevOps & Cloud",
                desc: "Docker, AWS, Kubernetes",
                color: "from-orange-600 to-orange-400",
              },
            ].map((skill, index) => (
              <motion.div
                key={index}
                className={`sticky top-20 p-8 bg-gradient-to-r ${skill.color} rounded-2xl text-white shadow-2xl transform transition-all duration-300`}
                style={{ zIndex: 100 - index }}
                initial={{ opacity: 0, y: 50 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.2 }}
                viewport={{ once: true }}
              >
                <h3 className="text-2xl font-bold mb-2">{skill.title}</h3>
                <p className="text-lg opacity-90">{skill.desc}</p>
                <div className="mt-4 flex items-center space-x-2">
                  <div className="flex space-x-1">
                    {[...Array(5)].map((_, i) => (
                      <div
                        key={i}
                        className={`w-2 h-2 rounded-full ${
                          i < 4 ? "bg-white" : "bg-white/30"
                        }`}
                      />
                    ))}
                  </div>
                  <span className="text-sm opacity-75">Expert Level</span>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Matrix雨背景区域 */}
      <section className="relative py-20 px-8 bg-black overflow-hidden min-h-screen">
        <div className="absolute inset-0">
          <MatrixRain />
        </div>
        <div className="relative z-10 max-w-4xl mx-auto text-center">
          <h2 className="text-4xl font-bold text-green-400 mb-8">
            <EncryptedText delay={0}>Enter the Matrix</EncryptedText>
          </h2>
          <p className="text-green-300 text-lg mb-8">
            Experience the digital realm where code becomes reality
          </p>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {[
              { title: "Data Processing", value: "∞ TB/s" },
              { title: "Neural Pathways", value: "10^12" },
              { title: "Quantum States", value: "∞" },
            ].map((stat, index) => (
              <motion.div
                key={index}
                className="bg-black/80 border border-green-500/30 rounded-lg p-6 backdrop-blur-sm"
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.2 }}
                viewport={{ once: true }}
              >
                <div className="text-3xl font-bold text-green-400 mb-2">
                  {stat.value}
                </div>
                <div className="text-green-300">{stat.title}</div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* 3D浮动几何体区域 */}
      <section className="py-20 px-8 bg-gradient-to-b from-gray-900 to-black">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-4xl font-bold mb-16">
            <EncryptedText delay={0}>3D Geometries</EncryptedText>
          </h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {[...Array(8)].map((_, index) => (
              <div
                key={index}
                className="floating-geometry h-32 flex items-center justify-center"
              >
                <div
                  className="w-16 h-16 bg-gradient-to-br from-blue-400 to-purple-500 transform-gpu"
                  style={{
                    clipPath:
                      index % 4 === 0
                        ? "polygon(50% 0%, 0% 100%, 100% 100%)"
                        : index % 4 === 1
                        ? "polygon(25% 0%, 100% 0%, 75% 100%, 0% 100%)"
                        : index % 4 === 2
                        ? "circle(50% at 50% 50%)"
                        : "polygon(50% 0%, 100% 38%, 82% 100%, 18% 100%, 0% 38%)",
                    animationDelay: `${index * 0.3}s`,
                  }}
                />
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* 结束区域 */}
      <section className="py-20 px-8 text-center">
        <div className="max-w-4xl mx-auto">
          <motion.h2
            className="text-5xl font-bold mb-8"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
          >
            <EncryptedText delay={0}>
              Ready to Build Something Amazing?
            </EncryptedText>
          </motion.h2>
          <div className="flex justify-center">
            <MagneticButton>Let&apos;s Collaborate</MagneticButton>
          </div>
        </div>
      </section>

      <style jsx>{`
        @keyframes draw-circle {
          to {
            stroke-dashoffset: 0;
          }
        }

        .gradient-border-card:hover
          .gradient-border-card
          > div:first-child::before {
          content: "";
          position: absolute;
          inset: 0;
          padding: 2px;
          background: linear-gradient(
            45deg,
            #3b82f6,
            #8b5cf6,
            #ec4899,
            #3b82f6
          );
          border-radius: inherit;
          mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
          mask-composite: xor;
          animation: border-flow 2s linear infinite;
        }

        @keyframes border-flow {
          0% {
            background-position: 0% 50%;
          }
          100% {
            background-position: 100% 50%;
          }
        }

        .holographic-card {
          perspective: 1000px;
        }

        .morphing-button:hover {
          animation: morph 0.5s ease-in-out;
        }

        @keyframes morph {
          0%,
          100% {
            border-radius: 9999px;
          }
          25% {
            border-radius: 20px;
          }
          50% {
            border-radius: 8px;
          }
          75% {
            border-radius: 30px;
          }
        }
      `}</style>
    </div>
  );
};

export default ComponentsDemo;
