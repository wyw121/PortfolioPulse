/** @type {import('next').NextConfig} */
const nextConfig = {
  // 启用 standalone 输出用于二进制部署
  output: "standalone",
  
  // Next.js 15 - 移动到顶级配置
  outputFileTracingRoot: process.cwd(),
  
  images: {
    domains: ["avatars.githubusercontent.com", "github.com"],
  },
  env: {
    CUSTOM_KEY: "my-value",
  },
  compiler: {
    // 移除开发环境中的 console.log
    removeConsole: process.env.NODE_ENV === "production",
  },
  // 改进水合处理
  reactStrictMode: true,
  // 暂时禁用 ESLint 以便构建
  eslint: {
    ignoreDuringBuilds: true,
  },
  // Next.js 15 实验性功能
  experimental: {
    // App Router 已经是稳定功能，不需要放在 experimental 中
    serverComponentsExternalPackages: [],
  },
};

module.exports = nextConfig;
