"use client";

import { useEffect, useState } from "react";

type LayoutMode = "vercel" | "stripe" | "grid";

export default function LayoutTester() {
  const [currentLayout, setCurrentLayout] = useState<LayoutMode>("vercel");
  const [isDark, setIsDark] = useState(false);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    // 检查系统主题偏好
    const prefersDark = window.matchMedia(
      "(prefers-color-scheme: dark)"
    ).matches;
    setIsDark(prefersDark);
  }, []);

  useEffect(() => {
    if (mounted) {
      document.documentElement.setAttribute(
        "data-theme",
        isDark ? "dark" : "light"
      );
      if (isDark) {
        document.documentElement.classList.add("dark");
      } else {
        document.documentElement.classList.remove("dark");
      }
    }
  }, [isDark, mounted]);

  if (!mounted) {
    return <div className="min-h-screen bg-gray-100 dark:bg-gray-900" />;
  }

  const layoutOptions = [
    {
      id: "vercel",
      name: "Vercel 风格 - 大屏中心式",
      desc: "大量留白，内容居中，专业简洁",
    },
    {
      id: "stripe",
      name: "Stripe 风格 - 分栏信息密集",
      desc: "左右分栏，信息丰富，商业化强",
    },
    {
      id: "grid",
      name: "现代网格布局",
      desc: "不规则网格，创意展示，视觉冲击",
    },
  ];

  const VercelLayout = () => (
    <div className="min-h-screen bg-gradient-to-b from-white to-gray-50 dark:from-[#0f0f0f] dark:to-[#1e1e1e] transition-all duration-500">
      {/* 导航栏 */}
      <nav className="sticky top-0 z-50 backdrop-blur-md bg-white/80 dark:bg-[#0f0f0f]/80 border-b border-gray-200 dark:border-[#333333]">
        <div className="max-w-6xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="text-xl font-bold bg-gradient-to-r from-[#3b82f6] via-[#8b5cf6] to-[#ec4899] bg-clip-text text-transparent">
              PortfolioPulse
            </div>
            <div className="hidden md:flex items-center space-x-8">
              <a
                href="#"
                className="text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white transition-colors"
              >
                项目
              </a>
              <a
                href="#"
                className="text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white transition-colors"
              >
                博客
              </a>
              <a
                href="#"
                className="text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white transition-colors"
              >
                关于
              </a>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="pt-32 pb-20">
        <div className="max-w-4xl mx-auto text-center px-6">
          <h1 className="text-5xl md:text-7xl font-bold mb-8 bg-gradient-to-r from-[#3b82f6] via-[#8b5cf6] to-[#ec4899] bg-clip-text text-transparent">
            开发者作品集
          </h1>
          <p className="text-xl md:text-2xl text-gray-600 dark:text-gray-300 mb-12 max-w-2xl mx-auto">
            展示我的技术项目，分享开发经验，记录学习成长轨迹
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <button className="px-8 py-4 bg-gradient-to-r from-[#3b82f6] to-[#8b5cf6] text-white rounded-lg font-medium hover:shadow-lg hover:shadow-blue-500/25 transition-all duration-300 transform hover:-translate-y-1">
              查看项目
            </button>
            <button className="px-8 py-4 border border-gray-300 dark:border-[#333333] text-gray-700 dark:text-gray-300 rounded-lg font-medium hover:border-gray-400 dark:hover:border-gray-500 transition-all duration-300">
              了解更多
            </button>
          </div>
        </div>
      </section>

      {/* 项目展示区 */}
      <section className="pb-20">
        <div className="max-w-6xl mx-auto px-6">
          <h2 className="text-3xl font-bold text-center mb-16 text-gray-900 dark:text-white">
            精选项目
          </h2>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[1, 2, 3, 4, 5, 6].map((i) => (
              <div key={i} className="group">
                <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl p-6 border border-gray-200 dark:border-[#333333] hover:border-transparent hover:shadow-xl hover:shadow-blue-500/10 transition-all duration-300 transform group-hover:-translate-y-2 relative overflow-hidden">
                  {/* 渐变边框效果 */}
                  <div
                    className="absolute inset-0 bg-gradient-to-r from-[#3b82f6] via-[#8b5cf6] to-[#ec4899] rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300 -z-10"
                    style={{ padding: "1px" }}
                  >
                    <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl h-full w-full"></div>
                  </div>

                  <div className="h-40 bg-gradient-to-br from-blue-100 to-purple-100 dark:from-blue-900/30 dark:to-purple-900/30 rounded-lg mb-6"></div>
                  <h3 className="text-xl font-semibold mb-3 text-gray-900 dark:text-white">
                    项目 {i}
                  </h3>
                  <p className="text-gray-600 dark:text-gray-300 mb-4">
                    这是一个展示用的项目描述，展示项目的主要特点和技术栈。
                  </p>
                  <div className="flex flex-wrap gap-2">
                    <span className="px-3 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-300 rounded-full text-sm">
                      React
                    </span>
                    <span className="px-3 py-1 bg-purple-100 dark:bg-purple-900/30 text-purple-800 dark:text-purple-300 rounded-full text-sm">
                      TypeScript
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );

  const StripeLayout = () => (
    <div className="min-h-screen bg-white dark:bg-[#0f0f0f] transition-all duration-500">
      {/* 顶部导航 */}
      <nav className="sticky top-0 z-50 bg-white/95 dark:bg-[#0f0f0f]/95 backdrop-blur-sm border-b border-gray-200 dark:border-[#333333]">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="text-xl font-bold bg-gradient-to-r from-[#3b82f6] via-[#8b5cf6] to-[#ec4899] bg-clip-text text-transparent">
              PortfolioPulse
            </div>
            <div className="flex items-center space-x-6">
              <nav className="hidden md:flex space-x-8">
                <a
                  href="#"
                  className="text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
                >
                  产品
                </a>
                <a
                  href="#"
                  className="text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
                >
                  解决方案
                </a>
                <a
                  href="#"
                  className="text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
                >
                  开发者
                </a>
                <a
                  href="#"
                  className="text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
                >
                  资源
                </a>
              </nav>
            </div>
          </div>
        </div>
      </nav>

      <div className="flex">
        {/* 侧边栏 */}
        <aside className="hidden lg:block w-64 bg-gray-50 dark:bg-[#1e1e1e] border-r border-gray-200 dark:border-[#333333] min-h-screen">
          <div className="p-6 space-y-6">
            <div>
              <h3 className="font-semibold text-gray-900 dark:text-white mb-3">
                项目类型
              </h3>
              <ul className="space-y-2">
                <li>
                  <a
                    href="#"
                    className="block py-2 text-gray-600 dark:text-gray-300 hover:text-purple-600 dark:hover:text-purple-400"
                  >
                    Web 应用
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    className="block py-2 text-gray-600 dark:text-gray-300 hover:text-purple-600 dark:hover:text-purple-400"
                  >
                    移动应用
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    className="block py-2 text-gray-600 dark:text-gray-300 hover:text-purple-600 dark:hover:text-purple-400"
                  >
                    开源库
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    className="block py-2 text-gray-600 dark:text-gray-300 hover:text-purple-600 dark:hover:text-purple-400"
                  >
                    工具脚本
                  </a>
                </li>
              </ul>
            </div>
            <div>
              <h3 className="font-semibold text-gray-900 dark:text-white mb-3">
                技术栈
              </h3>
              <ul className="space-y-2">
                <li>
                  <a
                    href="#"
                    className="block py-2 text-gray-600 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400"
                  >
                    React
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    className="block py-2 text-gray-600 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400"
                  >
                    Next.js
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    className="block py-2 text-gray-600 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400"
                  >
                    TypeScript
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    className="block py-2 text-gray-600 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400"
                  >
                    Rust
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </aside>

        {/* 主内容区 */}
        <main className="flex-1 max-w-4xl mx-auto p-6 lg:p-12">
          {/* Hero 部分 */}
          <div className="flex flex-col lg:flex-row items-center gap-12 mb-20">
            <div className="flex-1">
              <h1 className="text-4xl lg:text-6xl font-bold mb-6 bg-gradient-to-r from-[#3b82f6] via-[#8b5cf6] to-[#ec4899] bg-clip-text text-transparent">
                构建现代化
                <br />
                技术解决方案
              </h1>
              <p className="text-xl text-gray-600 dark:text-gray-300 mb-8">
                专注于创建高质量的 Web
                应用程序，提供从概念到部署的完整开发服务。
              </p>
              <div className="flex flex-col sm:flex-row gap-4">
                <button className="px-8 py-4 bg-gradient-to-r from-[#3b82f6] to-[#8b5cf6] text-white rounded-lg font-medium hover:shadow-lg hover:shadow-blue-500/25 transition-all duration-300">
                  开始探索
                </button>
                <button className="px-8 py-4 border border-gray-300 dark:border-[#333333] text-gray-700 dark:text-gray-300 rounded-lg font-medium hover:bg-gray-50 dark:hover:bg-[#2a2a2a] transition-all duration-300">
                  查看案例
                </button>
              </div>
            </div>
            <div className="flex-1">
              <div className="bg-gradient-to-br from-blue-400 to-purple-600 rounded-2xl p-8 text-white">
                <div className="space-y-4">
                  <div className="h-4 bg-white/20 rounded"></div>
                  <div className="h-4 bg-white/30 rounded w-3/4"></div>
                  <div className="h-4 bg-white/20 rounded w-1/2"></div>
                  <div className="grid grid-cols-2 gap-4 mt-8">
                    <div className="h-20 bg-white/10 rounded-lg"></div>
                    <div className="h-20 bg-white/15 rounded-lg"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* 项目网格 */}
          <div className="grid md:grid-cols-2 gap-8">
            {[1, 2, 3, 4].map((i) => (
              <div
                key={i}
                className="group border border-gray-200 dark:border-[#333333] rounded-xl p-6 hover:border-transparent hover:shadow-xl hover:shadow-purple-500/10 transition-all duration-300 bg-white dark:bg-[#1e1e1e] relative overflow-hidden"
              >
                <div
                  className="absolute inset-0 bg-gradient-to-r from-[#3b82f6] via-[#8b5cf6] to-[#ec4899] opacity-0 group-hover:opacity-100 transition-opacity duration-300 -z-10 rounded-xl"
                  style={{ padding: "1px" }}
                >
                  <div className="bg-white dark:bg-[#1e1e1e] rounded-xl h-full w-full"></div>
                </div>

                <div className="h-32 bg-gradient-to-br from-gray-100 to-gray-200 dark:from-gray-800 dark:to-gray-700 rounded-lg mb-4"></div>
                <h3 className="text-xl font-semibold mb-2 text-gray-900 dark:text-white">
                  企业级项目 {i}
                </h3>
                <p className="text-gray-600 dark:text-gray-300 mb-4">
                  为企业客户开发的高性能解决方案，包含完整的前后端架构设计。
                </p>
                <div className="flex items-center justify-between">
                  <div className="flex space-x-2">
                    <span className="px-2 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-300 rounded text-sm">
                      React
                    </span>
                    <span className="px-2 py-1 bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300 rounded text-sm">
                      Node.js
                    </span>
                  </div>
                  <button className="text-purple-600 dark:text-purple-400 hover:text-purple-800 dark:hover:text-purple-300 font-medium">
                    查看详情 →
                  </button>
                </div>
              </div>
            ))}
          </div>
        </main>
      </div>
    </div>
  );

  const GridLayout = () => (
    <div className="min-h-screen bg-gray-50 dark:bg-[#0f0f0f] transition-all duration-500">
      {/* 导航栏 */}
      <nav className="sticky top-0 z-50 bg-white/90 dark:bg-[#0f0f0f]/90 backdrop-blur-md border-b border-gray-200 dark:border-[#333333]">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="text-xl font-bold bg-gradient-to-r from-[#3b82f6] via-[#8b5cf6] to-[#ec4899] bg-clip-text text-transparent">
              PortfolioPulse
            </div>
            <div className="flex items-center space-x-8">
              <a
                href="#"
                className="text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
              >
                作品
              </a>
              <a
                href="#"
                className="text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
              >
                服务
              </a>
              <a
                href="#"
                className="text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
              >
                联系
              </a>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="py-20 px-6">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-4xl md:text-6xl font-bold mb-6 bg-gradient-to-r from-[#3b82f6] via-[#8b5cf6] to-[#ec4899] bg-clip-text text-transparent">
            创意与技术的融合
          </h1>
          <p className="text-xl text-gray-600 dark:text-gray-300 mb-8">
            探索无限可能，用代码创造艺术
          </p>
        </div>
      </section>

      {/* 不规则网格布局 */}
      <section className="pb-20 px-6">
        <div className="max-w-7xl mx-auto">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 xl:grid-cols-6 gap-6 auto-rows-min">
            {/* 大卡片 1 */}
            <div className="md:col-span-2 lg:col-span-2 xl:col-span-3 group">
              <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl p-8 h-80 border border-gray-200 dark:border-[#333333] hover:border-transparent hover:shadow-2xl hover:shadow-blue-500/20 transition-all duration-500 transform hover:-translate-y-2 relative overflow-hidden">
                <div className="absolute inset-0 bg-gradient-to-br from-[#3b82f6]/10 via-[#8b5cf6]/10 to-[#ec4899]/10 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                <div className="relative z-10">
                  <div className="h-32 bg-gradient-to-br from-blue-400 to-purple-600 rounded-xl mb-6"></div>
                  <h3 className="text-2xl font-bold mb-3 text-gray-900 dark:text-white">
                    主要项目
                  </h3>
                  <p className="text-gray-600 dark:text-gray-300">
                    这是一个重要的大型项目，具有复杂的功能和创新的设计。
                  </p>
                </div>
              </div>
            </div>

            {/* 小卡片 1 */}
            <div className="lg:col-span-1 xl:col-span-1 group">
              <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl p-6 h-80 border border-gray-200 dark:border-[#333333] hover:border-transparent hover:shadow-2xl hover:shadow-purple-500/20 transition-all duration-500 transform hover:-translate-y-2 relative overflow-hidden">
                <div className="absolute inset-0 bg-gradient-to-br from-purple-500/10 to-pink-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                <div className="relative z-10">
                  <div className="h-20 bg-gradient-to-br from-purple-400 to-pink-500 rounded-lg mb-4"></div>
                  <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-white">
                    工具库
                  </h3>
                  <p className="text-gray-600 dark:text-gray-300 text-sm">
                    开源工具
                  </p>
                </div>
              </div>
            </div>

            {/* 小卡片 2 */}
            <div className="lg:col-span-1 xl:col-span-2 group">
              <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl p-6 h-80 border border-gray-200 dark:border-[#333333] hover:border-transparent hover:shadow-2xl hover:shadow-green-500/20 transition-all duration-500 transform hover:-translate-y-2 relative overflow-hidden">
                <div className="absolute inset-0 bg-gradient-to-br from-green-500/10 to-blue-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                <div className="relative z-10">
                  <div className="h-24 bg-gradient-to-br from-green-400 to-blue-500 rounded-lg mb-4"></div>
                  <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-white">
                    API 服务
                  </h3>
                  <p className="text-gray-600 dark:text-gray-300 text-sm">
                    后端架构设计
                  </p>
                </div>
              </div>
            </div>

            {/* 中等卡片 */}
            <div className="md:col-span-1 lg:col-span-2 xl:col-span-2 group">
              <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl p-6 h-64 border border-gray-200 dark:border-[#333333] hover:border-transparent hover:shadow-2xl hover:shadow-orange-500/20 transition-all duration-500 transform hover:-translate-y-2 relative overflow-hidden">
                <div className="absolute inset-0 bg-gradient-to-br from-orange-500/10 to-red-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                <div className="relative z-10">
                  <div className="h-28 bg-gradient-to-br from-orange-400 to-red-500 rounded-lg mb-4"></div>
                  <h3 className="text-xl font-semibold mb-2 text-gray-900 dark:text-white">
                    移动应用
                  </h3>
                  <p className="text-gray-600 dark:text-gray-300">
                    跨平台解决方案
                  </p>
                </div>
              </div>
            </div>

            {/* 更多小卡片 */}
            <div className="lg:col-span-1 xl:col-span-1 group">
              <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl p-6 h-64 border border-gray-200 dark:border-[#333333] hover:border-transparent hover:shadow-2xl hover:shadow-indigo-500/20 transition-all duration-500 transform hover:-translate-y-2 relative overflow-hidden">
                <div className="absolute inset-0 bg-gradient-to-br from-indigo-500/10 to-purple-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                <div className="relative z-10">
                  <div className="h-20 bg-gradient-to-br from-indigo-400 to-purple-500 rounded-lg mb-4"></div>
                  <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-white">
                    插件
                  </h3>
                  <p className="text-gray-600 dark:text-gray-300 text-sm">
                    效率工具
                  </p>
                </div>
              </div>
            </div>

            <div className="lg:col-span-1 xl:col-span-3 group">
              <div className="bg-white dark:bg-[#1e1e1e] rounded-2xl p-6 h-64 border border-gray-200 dark:border-[#333333] hover:border-transparent hover:shadow-2xl hover:shadow-teal-500/20 transition-all duration-500 transform hover:-translate-y-2 relative overflow-hidden">
                <div className="absolute inset-0 bg-gradient-to-br from-teal-500/10 to-cyan-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                <div className="relative z-10">
                  <div className="h-28 bg-gradient-to-br from-teal-400 to-cyan-500 rounded-lg mb-4"></div>
                  <h3 className="text-xl font-semibold mb-2 text-gray-900 dark:text-white">
                    数据可视化
                  </h3>
                  <p className="text-gray-600 dark:text-gray-300">
                    图表与分析平台
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );

  const renderCurrentLayout = () => {
    switch (currentLayout) {
      case "vercel":
        return <VercelLayout />;
      case "stripe":
        return <StripeLayout />;
      case "grid":
        return <GridLayout />;
      default:
        return <VercelLayout />;
    }
  };

  return (
    <div className="min-h-screen transition-all duration-500">
      {/* 控制面板 */}
      <div className="fixed top-4 right-4 z-50 bg-white/90 dark:bg-[#1e1e1e]/90 backdrop-blur-md rounded-2xl p-6 border border-gray-200 dark:border-[#333333] shadow-xl min-w-[320px]">
        <h3 className="font-bold text-lg mb-4 text-gray-900 dark:text-white">
          布局测试面板
        </h3>

        {/* 主题切换 */}
        <div className="flex items-center justify-between mb-6 p-3 bg-gray-50 dark:bg-[#2a2a2a] rounded-lg">
          <span className="text-sm font-medium text-gray-700 dark:text-gray-300">
            {isDark ? "🌙 暗色主题" : "☀️ 亮色主题"}
          </span>
          <button
            onClick={() => setIsDark(!isDark)}
            className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none ${
              isDark
                ? "bg-gradient-to-r from-[#3b82f6] to-[#8b5cf6]"
                : "bg-gray-300"
            }`}
          >
            <span
              className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                isDark ? "translate-x-6" : "translate-x-1"
              }`}
            />
          </button>
        </div>

        {/* 布局选择 */}
        <div className="space-y-3">
          <h4 className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            选择布局模式
          </h4>
          {layoutOptions.map((option) => (
            <button
              key={option.id}
              onClick={() => setCurrentLayout(option.id as LayoutMode)}
              className={`w-full text-left p-3 rounded-lg border transition-all duration-300 ${
                currentLayout === option.id
                  ? "border-transparent bg-gradient-to-r from-[#3b82f6]/10 via-[#8b5cf6]/10 to-[#ec4899]/10 shadow-lg shadow-blue-500/20"
                  : "border-gray-200 dark:border-[#333333] bg-white dark:bg-[#2a2a2a] hover:border-gray-300 dark:hover:border-gray-500"
              }`}
            >
              <div className="flex items-center space-x-3">
                <div
                  className={`w-3 h-3 rounded-full transition-colors ${
                    currentLayout === option.id
                      ? "bg-gradient-to-r from-[#3b82f6] to-[#8b5cf6]"
                      : "bg-gray-300 dark:bg-gray-600"
                  }`}
                />
                <div>
                  <div
                    className={`font-medium text-sm ${
                      currentLayout === option.id
                        ? "bg-gradient-to-r from-[#3b82f6] via-[#8b5cf6] to-[#ec4899] bg-clip-text text-transparent"
                        : "text-gray-900 dark:text-white"
                    }`}
                  >
                    {option.name}
                  </div>
                  <div className="text-xs text-gray-500 dark:text-gray-400 mt-1">
                    {option.desc}
                  </div>
                </div>
              </div>
            </button>
          ))}
        </div>

        {/* 当前选择指示 */}
        <div className="mt-4 p-3 bg-gradient-to-r from-[#3b82f6]/5 via-[#8b5cf6]/5 to-[#ec4899]/5 rounded-lg border border-blue-200 dark:border-blue-800">
          <div className="text-sm font-medium text-blue-800 dark:text-blue-300">
            当前: {layoutOptions.find((opt) => opt.id === currentLayout)?.name}
          </div>
        </div>
      </div>

      {/* 渲染当前选择的布局 */}
      {renderCurrentLayout()}
    </div>
  );
}
