'use client'

import type { BlogPostData } from '@/lib/blog-loader'

interface BlogPostComponentProps {
  post: BlogPostData
}

export function BlogPost({ post }: BlogPostComponentProps) {
  return (
    <div className="prose prose-lg max-w-none dark:prose-invert">
      {/* 渲染 Markdown 转换后的 HTML */}
      <div
        className="blog-markdown-content"
        dangerouslySetInnerHTML={{ __html: post.htmlContent }}
      />

      <style jsx global>{`
        .blog-html-content {
          /* OneNote HTML样式处理 */
        }
        .blog-html-content table {
          @apply border-collapse border border-gray-300;
        }
        .blog-html-content td,
        .blog-html-content th {
          @apply border border-gray-300 px-4 py-2;
        }
        .blog-html-content img {
          @apply max-w-full h-auto rounded-lg shadow-sm;
        }
        .blog-html-content blockquote {
          @apply border-l-4 border-primary pl-4 italic;
        }
        .blog-html-content code {
          @apply bg-muted px-2 py-1 rounded text-sm;
        }
        .blog-html-content pre {
          @apply bg-muted p-4 rounded-lg overflow-x-auto;
        }
        .blog-html-content h1,
        .blog-html-content h2,
        .blog-html-content h3,
        .blog-html-content h4,
        .blog-html-content h5,
        .blog-html-content h6 {
          @apply font-bold mt-8 mb-4;
        }
        .blog-html-content h1 { @apply text-3xl; }
        .blog-html-content h2 { @apply text-2xl; }
        .blog-html-content h3 { @apply text-xl; }
        .blog-html-content h4 { @apply text-lg; }
        .blog-html-content h5 { @apply text-base; }
        .blog-html-content h6 { @apply text-sm; }
        .blog-html-content p {
          @apply mb-4 leading-7;
        }
        .blog-html-content ul,
        .blog-html-content ol {
          @apply mb-4 pl-6;
        }
        .blog-html-content li {
          @apply mb-2;
        }
        .blog-html-content a {
          @apply text-primary hover:underline;
        }

        /* 处理OneNote特有的样式 */
        .blog-html-content .onenote-table {
          @apply w-full border-collapse;
        }
        .blog-html-content .onenote-highlight {
          @apply bg-yellow-200 dark:bg-yellow-800;
        }
        .blog-html-content .onenote-note {
          @apply bg-blue-50 dark:bg-blue-900 border-l-4 border-blue-400 p-4 my-4;
        }
      `}</style>
    </div>
  )
}
