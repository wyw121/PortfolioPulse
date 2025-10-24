import { BlogGrid } from "@/components/blog";
import { Navigation } from "@/components/layout";
import { AnimatedContainer } from "@/components/ui/effects";
import { getAllPosts } from "@/lib/blog-loader";

// 启用 ISR: 每 60 秒重新验证一次
export const revalidate = 60;

// 改为 Server Component，服务端获取数据
export default async function BlogPage() {
  // 服务端直接获取博客文章
  const posts = await getAllPosts();

  return (
    <div className="min-h-screen bg-white dark:bg-gray-900">
      {/* 背景渐变效果 */}
      <div className="fixed inset-0 -z-10 bg-gradient-to-br from-blue-50/30 via-purple-50/20 to-pink-50/30 dark:from-gray-900/90 dark:via-gray-800/80 dark:to-gray-900/90" />

      <Navigation />

      <main className="pt-20">
        <div className="max-w-6xl mx-auto px-6 py-12">
          <AnimatedContainer direction="up" duration={350} fastResponse={true}>
            <div className="text-center mb-12">
              <h1 className="text-4xl md:text-5xl font-bold mb-6 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 bg-clip-text text-transparent">
                技术博客
              </h1>
              <p className="text-lg text-gray-600 dark:text-gray-300 max-w-3xl mx-auto">
                记录技术学习的点点滴滴，分享开发经验与思考，探索前沿技术趋势。
              </p>
            </div>
          </AnimatedContainer>
        </div>

        {/* 将数据通过 props 传递给客户端组件 */}
        <BlogGrid initialPosts={posts} />
      </main>
    </div>
  );
}
