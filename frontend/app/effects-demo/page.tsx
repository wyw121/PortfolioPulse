"use client";

import { motion } from "framer-motion";
import React, { useCallback, useEffect, useRef, useState } from "react";
import "./effects.css";

const FiveEffectsDemo = () => {
  // 代码流动效果状态
  const [codeLines, setCodeLines] = useState([
    "const portfolio = new Portfolio();",
    "portfolio.addProject('AI Assistant');",
    "await portfolio.deploy();",
    "console.log('Success!');",
  ]);

  // 数据可视化节点状态
  const [nodes, setNodes] = useState([
    { id: 1, x: 100, y: 100, size: 20, connections: [2, 3] },
    { id: 2, x: 300, y: 150, size: 25, connections: [1, 4] },
    { id: 3, x: 200, y: 250, size: 18, connections: [1, 4, 5] },
    { id: 4, x: 400, y: 200, size: 22, connections: [2, 3] },
    { id: 5, x: 250, y: 350, size: 19, connections: [3] },
  ]);

  // AI对话泡泡状态
  const [messages, setMessages] = useState([
    {
      id: 1,
      text: "Hello! How can I help you today?",
      isAI: true,
      timestamp: Date.now() - 5000,
    },
    {
      id: 2,
      text: "I need help with my portfolio website",
      isAI: false,
      timestamp: Date.now() - 3000,
    },
    {
      id: 3,
      text: "I'd be happy to help! Let me analyze your requirements...",
      isAI: true,
      timestamp: Date.now() - 1000,
    },
  ]);

  // 渐变边框动画组件（修复版本）
  const GradientBorderCard = ({
    children,
    className = "",
    variant = "rotating",
  }: {
    children: React.ReactNode;
    className?: string;
    variant?: "rotating" | "pulsing" | "flowing";
  }) => {
    return (
      <div className={`gradient-border-wrapper ${variant} ${className}`}>
        <div className="gradient-border-content">{children}</div>
      </div>
    );
  };

  // 液态变形按钮组件（优化版本）
  const MorphingBlobButton = ({
    children,
    className = "",
    onClick,
    variant = "blue",
  }: {
    children: React.ReactNode;
    className?: string;
    onClick?: () => void;
    variant?: "blue" | "purple" | "green" | "orange";
  }) => {
    const [isHovered, setIsHovered] = useState(false);

    return (
      <motion.button
        className={`morphing-blob-btn ${variant} ${className}`}
        onHoverStart={() => setIsHovered(true)}
        onHoverEnd={() => setIsHovered(false)}
        onClick={onClick}
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.95 }}
      >
        <div className={`blob-bg ${isHovered ? "hovered" : ""}`} />
        <span className="blob-text">{children}</span>
      </motion.button>
    );
  };

  // 代码流动效果组件
  const CodeFlowEffect = () => {
    const [activeLineIndex, setActiveLineIndex] = useState(0);

    useEffect(() => {
      const interval = setInterval(() => {
        setActiveLineIndex((prev) => (prev + 1) % codeLines.length);
      }, 2000);

      return () => clearInterval(interval);
    }, [codeLines.length]);

    return (
      <div className="code-flow-container">
        <div className="code-flow-header">
          <div className="code-flow-dots">
            <span className="dot red"></span>
            <span className="dot yellow"></span>
            <span className="dot green"></span>
          </div>
          <span className="code-flow-title">portfolio.ts</span>
        </div>
        <div className="code-flow-content">
          {codeLines.map((line, index) => (
            <motion.div
              key={index}
              className={`code-line ${
                index === activeLineIndex ? "active" : ""
              }`}
              initial={{ opacity: 0.3, x: -20 }}
              animate={{
                opacity: index === activeLineIndex ? 1 : 0.5,
                x: index === activeLineIndex ? 0 : -10,
                scale: index === activeLineIndex ? 1.02 : 1,
              }}
              transition={{ duration: 0.5, ease: "easeOut" }}
            >
              <span className="line-number">{index + 1}</span>
              <span className="line-content">{line}</span>
              {index === activeLineIndex && (
                <motion.div
                  className="code-cursor"
                  animate={{ opacity: [1, 0, 1] }}
                  transition={{ duration: 1, repeat: Infinity }}
                />
              )}
            </motion.div>
          ))}
        </div>
      </div>
    );
  };

  // AI对话泡泡组件
  const AIChatBubbles = () => {
    const [newMessage, setNewMessage] = useState("");

    const addMessage = useCallback(() => {
      if (!newMessage.trim()) return;

      const userMessage = {
        id: Date.now(),
        text: newMessage,
        isAI: false,
        timestamp: Date.now(),
      };

      setMessages((prev) => [...prev, userMessage]);
      setNewMessage("");

      // 模拟AI回复
      setTimeout(() => {
        const aiResponses = [
          "That's an interesting question! Let me think about it...",
          "I can help you with that. Here's what I suggest...",
          "Based on your input, I recommend the following approach...",
          "Great idea! Here's how we can implement that...",
        ];

        const aiMessage = {
          id: Date.now() + 1,
          text: aiResponses[Math.floor(Math.random() * aiResponses.length)],
          isAI: true,
          timestamp: Date.now(),
        };

        setMessages((prev) => [...prev, aiMessage]);
      }, 1000 + Math.random() * 2000);
    }, [newMessage]);

    return (
      <div className="ai-chat-container">
        <div className="chat-header">
          <div className="ai-avatar">🤖</div>
          <div className="ai-status">
            <span className="ai-name">AI Assistant</span>
            <span className="ai-online">● Online</span>
          </div>
        </div>

        <div className="chat-messages">
          {messages.map((message) => (
            <motion.div
              key={message.id}
              className={`message-bubble ${
                message.isAI ? "ai-message" : "user-message"
              }`}
              initial={{ opacity: 0, y: 20, scale: 0.8 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              transition={{
                duration: 0.3,
                ease: "easeOut",
                type: "spring",
                stiffness: 200,
              }}
            >
              <div className="message-text">{message.text}</div>
              {message.isAI && (
                <motion.div
                  className="typing-indicator"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: [0, 1, 0] }}
                  transition={{ duration: 1.5, repeat: Infinity }}
                >
                  <span>●</span>
                  <span>●</span>
                  <span>●</span>
                </motion.div>
              )}
            </motion.div>
          ))}
        </div>

        <div className="chat-input">
          <input
            type="text"
            value={newMessage}
            onChange={(e) => setNewMessage(e.target.value)}
            onKeyPress={(e) => e.key === "Enter" && addMessage()}
            placeholder="Type your message..."
            className="message-input"
          />
          <button onClick={addMessage} className="send-button">
            ➤
          </button>
        </div>
      </div>
    );
  };

  // 数据可视化节点组件
  const DataVisualizationNodes = () => {
    const svgRef = useRef<SVGSVGElement>(null);
    const [hoveredNode, setHoveredNode] = useState<number | null>(null);

    useEffect(() => {
      const interval = setInterval(() => {
        setNodes((prevNodes) =>
          prevNodes.map((node) => ({
            ...node,
            size: node.size + (Math.random() - 0.5) * 2,
          }))
        );
      }, 2000);

      return () => clearInterval(interval);
    }, []);

    const getConnectionPath = (
      node1: (typeof nodes)[0],
      node2: (typeof nodes)[0]
    ) => {
      const dx = node2.x - node1.x;
      const dy = node2.y - node1.y;
      const dr = Math.sqrt(dx * dx + dy * dy);
      return `M${node1.x},${node1.y}A${dr},${dr} 0 0,1 ${node2.x},${node2.y}`;
    };

    return (
      <div className="data-viz-container">
        <div className="viz-header">
          <h3>Neural Network Visualization</h3>
          <div className="viz-controls">
            <span className="viz-status active">● Active Learning</span>
          </div>
        </div>

        <svg
          ref={svgRef}
          className="data-viz-svg"
          viewBox="0 0 500 400"
          width="100%"
          height="400"
        >
          <defs>
            <linearGradient
              id="connectionGradient"
              x1="0%"
              y1="0%"
              x2="100%"
              y2="0%"
            >
              <stop offset="0%" stopColor="#3b82f6" stopOpacity="0.8" />
              <stop offset="50%" stopColor="#8b5cf6" stopOpacity="0.6" />
              <stop offset="100%" stopColor="#ec4899" stopOpacity="0.4" />
            </linearGradient>

            <filter id="nodeGlow">
              <feGaussianBlur stdDeviation="3" result="coloredBlur" />
              <feMerge>
                <feMergeNode in="coloredBlur" />
                <feMergeNode in="SourceGraphic" />
              </feMerge>
            </filter>
          </defs>

          {/* 渲染连接线 */}
          {nodes.map((node) =>
            node.connections.map((connectionId) => {
              const connectedNode = nodes.find((n) => n.id === connectionId);
              if (!connectedNode) return null;

              return (
                <motion.path
                  key={`${node.id}-${connectionId}`}
                  d={getConnectionPath(node, connectedNode)}
                  fill="none"
                  stroke="url(#connectionGradient)"
                  strokeWidth={
                    hoveredNode === node.id || hoveredNode === connectionId
                      ? 3
                      : 2
                  }
                  initial={{ pathLength: 0 }}
                  animate={{ pathLength: 1 }}
                  transition={{ duration: 2, ease: "easeInOut" }}
                />
              );
            })
          )}

          {/* 渲染节点 */}
          {nodes.map((node) => (
            <motion.g key={node.id}>
              <motion.circle
                cx={node.x}
                cy={node.y}
                r={node.size}
                fill={hoveredNode === node.id ? "#8b5cf6" : "#3b82f6"}
                filter="url(#nodeGlow)"
                className="data-node"
                onHoverStart={() => setHoveredNode(node.id)}
                onHoverEnd={() => setHoveredNode(null)}
                whileHover={{ scale: 1.2, r: node.size + 5 }}
                animate={{
                  r: node.size,
                  fill: hoveredNode === node.id ? "#ec4899" : "#3b82f6",
                }}
                transition={{ duration: 0.3 }}
              />

              <text
                x={node.x}
                y={node.y + 5}
                textAnchor="middle"
                className="node-label"
                fill="white"
                fontSize="12"
                fontWeight="bold"
              >
                {node.id}
              </text>
            </motion.g>
          ))}
        </svg>
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-black text-white overflow-hidden">
      {/* 导航栏 */}
      <nav className="fixed top-0 w-full z-50 backdrop-blur-md bg-black/50 border-b border-gray-800">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex justify-between items-center">
            <h1 className="text-2xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
              五大特效演示
            </h1>
            <div className="flex space-x-4 text-sm">
              <a
                href="#borders"
                className="hover:text-blue-400 transition-colors"
              >
                渐变边框
              </a>
              <a
                href="#buttons"
                className="hover:text-purple-400 transition-colors"
              >
                液态按钮
              </a>
              <a
                href="#code"
                className="hover:text-green-400 transition-colors"
              >
                代码流动
              </a>
              <a href="#chat" className="hover:text-pink-400 transition-colors">
                AI对话
              </a>
              <a href="#data" className="hover:text-cyan-400 transition-colors">
                数据节点
              </a>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero区域 */}
      <section className="pt-32 pb-20 text-center">
        <motion.h1
          className="text-7xl font-bold mb-6"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1 }}
        >
          <span className="bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 bg-clip-text text-transparent">
            五大核心特效
          </span>
        </motion.h1>
      </section>

      {/* 1. 渐变边框动画 */}
      <section id="borders" className="py-20 px-6">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl font-bold mb-12 text-center text-blue-400">
            1. 渐变边框动画
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <GradientBorderCard variant="rotating" className="p-8">
              <h3 className="text-xl font-bold mb-4">旋转边框</h3>
              <p className="text-gray-300">360度连续旋转的渐变边框效果</p>
            </GradientBorderCard>

            <GradientBorderCard variant="pulsing" className="p-8">
              <h3 className="text-xl font-bold mb-4">脉冲边框</h3>
              <p className="text-gray-300">呼吸般的脉冲渐变边框</p>
            </GradientBorderCard>

            <GradientBorderCard variant="flowing" className="p-8">
              <h3 className="text-xl font-bold mb-4">流动边框</h3>
              <p className="text-gray-300">色彩流动的渐变边框</p>
            </GradientBorderCard>
          </div>
        </div>
      </section>

      {/* 2. 液态变形按钮 */}
      <section id="buttons" className="py-20 px-6 bg-gray-900/20">
        <div className="max-w-6xl mx-auto text-center">
          <h2 className="text-4xl font-bold mb-12 text-purple-400">
            2. 液态变形按钮
          </h2>

          <div className="flex flex-wrap justify-center gap-6">
            <MorphingBlobButton
              variant="blue"
              onClick={() => alert("蓝色按钮!")}
            >
              🚀 启动项目
            </MorphingBlobButton>

            <MorphingBlobButton
              variant="purple"
              onClick={() => alert("紫色按钮!")}
            >
              ⚡ 查看演示
            </MorphingBlobButton>

            <MorphingBlobButton
              variant="green"
              onClick={() => alert("绿色按钮!")}
            >
              🌟 下载资源
            </MorphingBlobButton>

            <MorphingBlobButton
              variant="orange"
              onClick={() => alert("橙色按钮!")}
            >
              🔥 联系我们
            </MorphingBlobButton>
          </div>
        </div>
      </section>

      {/* 3. 代码流动效果 */}
      <section id="code" className="py-20 px-6">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-4xl font-bold mb-12 text-center text-green-400">
            3. 代码流动效果
          </h2>

          <CodeFlowEffect />
        </div>
      </section>

      {/* 4. AI对话泡泡 */}
      <section id="chat" className="py-20 px-6 bg-gray-900/20">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-4xl font-bold mb-12 text-center text-pink-400">
            4. AI 对话泡泡
          </h2>

          <AIChatBubbles />
        </div>
      </section>

      {/* 5. 数据可视化节点 */}
      <section id="data" className="py-20 px-6">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl font-bold mb-12 text-center text-cyan-400">
            5. 数据可视化节点
          </h2>

          <DataVisualizationNodes />
        </div>
      </section>

      {/* 底部 */}
      <footer className="py-12 text-center border-t border-gray-800">
        <p className="text-gray-400">
          🎨 PortfolioPulse - 五大核心视觉特效演示
        </p>
      </footer>
    </div>
  );
};

export default FiveEffectsDemo;
