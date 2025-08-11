import { BlogPost } from "@/components/sections/blog-post";
import { BlogPostMeta } from "@/components/sections/blog-post-meta";
import { RelatedPosts } from "@/components/sections/related-posts";
import { notFound } from "next/navigation";

interface BlogPostPageProps {
  params: Promise<{
    slug: string;
  }>;
}

async function getBlogPost(slug: string) {
  try {
    const res = await fetch(
      `${
        process.env.API_URL || "http://localhost:8000"
      }/api/blog/posts/${slug}`,
      {
        cache: "no-store", // 确保获取最新内容
      }
    );

    if (!res.ok) {
      return null;
    }

    return await res.json();
  } catch (error) {
    console.error("获取博客文章失败:", error);
    return null;
  }
}

export default async function BlogPostPage({ params }: BlogPostPageProps) {
  const { slug } = await params;
  const post = await getBlogPost(slug);

  if (!post) {
    notFound();
  }

  return (
    <div className="container max-w-4xl mx-auto px-4 py-8">
      <article className="mb-12">
        <BlogPostMeta post={post} />
        <BlogPost post={post} />
      </article>

      <div className="border-t pt-8">
        <RelatedPosts currentSlug={slug} category={post.category} />
      </div>
    </div>
  );
}

// 动态生成页面标题
export async function generateMetadata({ params }: BlogPostPageProps) {
  const { slug } = await params;
  const post = await getBlogPost(slug);

  if (!post) {
    return {
      title: "文章未找到",
    };
  }

  return {
    title: `${post.title} | PortfolioPulse 博客`,
    description: post.excerpt || post.title,
    openGraph: {
      title: post.title,
      description: post.excerpt || post.title,
      type: "article",
      publishedTime: post.published_at,
      modifiedTime: post.updated_at,
      authors: ["PortfolioPulse"],
      images: post.cover_image ? [{ url: post.cover_image }] : undefined,
    },
  };
}
