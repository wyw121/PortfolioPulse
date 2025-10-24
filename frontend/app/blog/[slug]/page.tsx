import { BlogPost } from "@/components/sections/blog-post";
import { BlogPostMeta } from "@/components/sections/blog-post-meta";
import { BlogPostTags } from "@/components/sections/blog-post-tags";
import { RelatedPosts } from "@/components/sections/related-posts";
import { getPostBySlug, getAllPosts } from "@/lib/blog-loader";
import { notFound } from "next/navigation";
import { cookies } from "next/headers";
import Link from "next/link";
import { Home } from "lucide-react";

// 启用 ISR: 每 3600 秒 (1小时) 重新验证一次
export const revalidate = 3600;

interface BlogPostPageProps {
  params: Promise<{
    slug: string;
  }>;
}

export default async function BlogPostPage({ params }: BlogPostPageProps) {
  const { slug } = await params;
  
  // 获取语言偏好
  const cookieStore = await cookies();
  const locale = cookieStore.get("locale")?.value || "zh";
  
  const post = await getPostBySlug(slug, locale as "en" | "zh");

  if (!post) {
    notFound();
  }

  // 在服务端获取相关文章(相同分类,排除当前文章,最多3篇)
  const allPosts = await getAllPosts(locale as "en" | "zh");
  const relatedPosts = allPosts
    .filter(p => p.slug !== slug && p.category === post.category)
    .slice(0, 3);

  return (
    <div className="min-h-screen bg-white dark:bg-gray-950">
      {/* 面包屑导航 - PaperMod风格 */}
      <div className="sticky top-0 z-50 bg-white/80 dark:bg-gray-950/80 backdrop-blur-md border-b border-gray-200 dark:border-gray-800">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <nav className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
            <Link 
              href="/"
              className="hover:text-gray-900 dark:hover:text-gray-100 transition-colors flex items-center gap-1"
            >
              <Home className="w-4 h-4" />
              <span>Home</span>
            </Link>
            <span>/</span>
            <Link 
              href="/blog"
              className="hover:text-gray-900 dark:hover:text-gray-100 transition-colors"
            >
              Blog
            </Link>
            <span>/</span>
            <span className="text-gray-900 dark:text-gray-100 truncate max-w-xs">
              {post.title}
            </span>
          </nav>
        </div>
      </div>
      
      {/* 文章内容 - 居中布局 */}
      <article className="max-w-7xl mx-auto px-6 py-12">
        <div className="max-w-4xl mx-auto">
          <BlogPostMeta post={post} />
          <BlogPost post={post} />
          <BlogPostTags post={post} />
        </div>
      </article>

      {/* 相关文章 - 分离的区块 */}
      {relatedPosts.length > 0 && (
        <div className="border-t border-gray-200 dark:border-gray-800 bg-gray-50/50 dark:bg-gray-900/50">
          <div className="max-w-7xl mx-auto px-6 py-16">
            <RelatedPosts posts={relatedPosts} />
          </div>
        </div>
      )}
    </div>
  );
}

// 生成静态路径
export async function generateStaticParams() {
  const posts = await getAllPosts();
  
  return posts.map((post) => ({
    slug: post.slug,
  }));
}

// 动态生成页面标题
export async function generateMetadata({ params }: BlogPostPageProps) {
  const { slug } = await params;
  const post = await getPostBySlug(slug);

  if (!post) {
    return {
      title: "文章未找到",
    };
  }

  return {
    title: `${post.title} | PortfolioPulse 博客`,
    description: post.description || post.title,
    openGraph: {
      title: post.title,
      description: post.description || post.title,
      type: "article",
      publishedTime: post.date,
      authors: ["PortfolioPulse"],
      images: post.cover ? [{ url: post.cover }] : undefined,
    },
  };
}
