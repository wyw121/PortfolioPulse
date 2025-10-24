import { BlogGrid } from "@/components/blog";
import { BlogPageHeader } from "@/components/blog/blog-page-header";
import { getAllPosts } from "@/lib/blog-loader";
import { cookies } from "next/headers";

// 启用 ISR: 每 60 秒重新验证一次
export const revalidate = 60;

// 改为 Server Component,服务端获取数据
export default async function BlogPage() {
  // 从 cookie 获取用户语言偏好(现在已同步)
  const cookieStore = await cookies();
  const locale = cookieStore.get("locale")?.value || "zh";
  
  // 服务端直接获取博客文章(根据语言)
  const posts = await getAllPosts(locale as "en" | "zh");

  return (
    <div className="min-h-screen bg-white dark:bg-gray-900">
      {/* 背景渐变效果 */}
      <div className="fixed inset-0 -z-10 bg-gradient-to-br from-blue-50/30 via-purple-50/20 to-pink-50/30 dark:from-gray-900/90 dark:via-gray-800/80 dark:to-gray-900/90" />

      <main className="pt-24">
        <BlogPageHeader />

        {/* 将数据通过 props 传递给客户端组件 */}
        <BlogGrid initialPosts={posts} />
      </main>
    </div>
  );
}
