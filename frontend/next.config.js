/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    appDir: true,
  },
  images: {
    domains: [
      'avatars.githubusercontent.com',
      'github.com'
    ],
  },
  env: {
    CUSTOM_KEY: 'my-value',
  },
  compiler: {
    // 移除开发环境中的 console.log
    removeConsole: process.env.NODE_ENV === 'production',
  },
  // 改进水合处理
  reactStrictMode: true,
  swcMinify: true,
}

module.exports = nextConfig
