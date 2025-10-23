import { BlogPost } from "@/components/sections/blog-post";
import { BlogPostMeta } from "@/components/sections/blog-post-meta";
import { RelatedPosts } from "@/components/sections/related-posts";
import { getPostBySlug, getAllPosts } from "@/lib/blog-loader";
import { notFound } from "next/navigation";

interface BlogPostPageProps {
  params: Promise<{
    slug: string;
  }>;
}

export default async function BlogPostPage({ params }: BlogPostPageProps) {
  const { slug } = await params;
  const post = await getPostBySlug(slug);

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
