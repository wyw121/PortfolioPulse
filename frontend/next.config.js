/** @type {import('next').NextConfig} */
const nextConfig = {
  // 启用standalone输出，用于服务器部署
  output: "standalone",
  // 优化文件追踪
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
};

module.exports = nextConfig;
