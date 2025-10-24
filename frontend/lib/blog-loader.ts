import fs from "node:fs";
import path from "node:path";
import matter from "gray-matter";
import { remark } from "remark";
import html from "remark-html";
import remarkGfm from "remark-gfm";

// 博客文章元数据接口
export interface BlogPostMeta {
  slug: string;
  title: string;
  description: string;
  date: string;
  category: string;
  tags?: string[];
  featured?: boolean;
  readTime?: string;
  cover?: string;
}

// 博客文章完整数据接口
export interface BlogPostData extends BlogPostMeta {
  content: string;
  htmlContent: string;
}

// 博客目录路径
const BLOG_DIRECTORY = path.join(process.cwd(), "content", "blog");

/**
 * 计算文章阅读时长
 * @param content Markdown 内容
 * @param locale 语言代码
 * @returns 阅读时长字符串
 */
function calculateReadTime(content: string, locale: string = "zh"): string {
  const wordsPerMinute = locale === "zh" ? 200 : 250; // 中文 200 字/分钟,英文 250 词/分钟
  const wordCount = content.length;
  const minutes = Math.ceil(wordCount / wordsPerMinute);
  return locale === "zh" ? `${minutes} 分钟` : `${minutes} min`;
}

/**
 * 从文件名提取 slug
 * @param fileName 文件名（如：2025-01-15-nextjs-15-features.md 或 2025-01-15-nextjs-15-features.en.md）
 * @returns slug（如：nextjs-15-features）
 */
function extractSlug(fileName: string): string {
  // 移除语言后缀和 .md 扩展名 (如 .en.md, .zh.md)
  let withoutExt = fileName.replace(/\.(en|zh|ja|ko)\.md$/, "");
  // 如果没有语言后缀,只移除 .md
  if (withoutExt === fileName) {
    withoutExt = fileName.replace(/\.md$/, "");
  }
  
  // 如果文件名以日期开头（YYYY-MM-DD-），则移除日期部分
  const datePattern = /^\d{4}-\d{2}-\d{2}-/;
  if (datePattern.test(withoutExt)) {
    return withoutExt.replace(datePattern, "");
  }
  
  return withoutExt;
}

/**
 * 获取所有博客文章文件名
 * @param locale 语言代码
 * @returns 文件名数组
 */
function getBlogFileNames(locale: string = "zh"): string[] {
  try {
    const files = fs.readdirSync(BLOG_DIRECTORY);
    const allFiles = files.filter((file) => file.endsWith(".md") && file !== "README.md");
    
    if (locale === "zh") {
      // 中文:排除 .en.md 等其他语言文件
      return allFiles.filter(file => !file.match(/\.(en|ja|ko)\.md$/));
    }
    
    // 其他语言:只返回对应语言的文件
    return allFiles.filter(file => file.includes(`.${locale}.md`));
  } catch (error) {
    console.warn("博客目录不存在或读取失败:", error);
    return [];
  }
}

/**
 * 获取所有博客文章元数据（按日期排序）
 * @param locale 语言代码（默认为中文）
 * @returns 博客文章元数据数组
 */
export async function getAllPosts(locale: string = "zh"): Promise<BlogPostMeta[]> {
  const fileNames = getBlogFileNames(locale);

  const posts = await Promise.all(
    fileNames.map(async (fileName) => {
      const filePath = path.join(BLOG_DIRECTORY, fileName);
      const fileContents = fs.readFileSync(filePath, "utf8");
      const { data, content } = matter(fileContents);

      // 从文件名提取 slug (extractSlug 会自动处理语言后缀)
      const slug = extractSlug(fileName);

      // 确保 date 是字符串格式
      let dateString: string;
      if (data.date instanceof Date) {
        dateString = data.date.toISOString().split("T")[0];
      } else if (typeof data.date === "string") {
        dateString = data.date;
      } else {
        dateString = new Date().toISOString().split("T")[0];
      }

      return {
        slug,
        title: data.title || "无标题",
        description: data.description || "",
        date: dateString,
        category: data.category || "未分类",
        tags: data.tags || [],
        featured: data.featured || false,
        readTime: data.readTime || calculateReadTime(content, locale),
        cover: data.cover,
      } as BlogPostMeta;
    })
  );

  // 按日期降序排序（最新文章在前）
  return posts.sort((a, b) => {
    return new Date(b.date).getTime() - new Date(a.date).getTime();
  });
}

/**
 * 获取特色博客文章
 * @param locale 语言代码
 * @returns 特色文章数组
 */
export async function getFeaturedPosts(locale: string = "zh"): Promise<BlogPostMeta[]> {
  const allPosts = await getAllPosts(locale);
  return allPosts.filter((post) => post.featured);
}

/**
 * 根据分类获取博客文章
 * @param category 分类名称
 * @param locale 语言代码
 * @returns 该分类下的文章数组
 */
export async function getPostsByCategory(
  category: string,
  locale: string = "zh"
): Promise<BlogPostMeta[]> {
  const allPosts = await getAllPosts(locale);
  return allPosts.filter((post) => post.category === category);
}

/**
 * 根据标签获取博客文章
 * @param tag 标签名称
 * @param locale 语言代码
 * @returns 包含该标签的文章数组
 */
export async function getPostsByTag(
  tag: string,
  locale: string = "zh"
): Promise<BlogPostMeta[]> {
  const allPosts = await getAllPosts(locale);
  return allPosts.filter((post) => post.tags?.includes(tag));
}

/**
 * 获取所有分类及其文章数量
 * @param locale 语言代码
 * @returns 分类统计对象
 */
export async function getAllCategories(
  locale: string = "zh"
): Promise<Record<string, number>> {
  const allPosts = await getAllPosts(locale);
  const categories: Record<string, number> = {};

  for (const post of allPosts) {
    categories[post.category] = (categories[post.category] || 0) + 1;
  }

  return categories;
}

/**
 * 获取所有标签及其文章数量
 * @param locale 语言代码
 * @returns 标签统计对象
 */
export async function getAllTags(
  locale: string = "zh"
): Promise<Record<string, number>> {
  const allPosts = await getAllPosts(locale);
  const tags: Record<string, number> = {};

  for (const post of allPosts) {
    if (post.tags) {
      for (const tag of post.tags) {
        tags[tag] = (tags[tag] || 0) + 1;
      }
    }
  }

  return tags;
}

/**
 * 根据 slug 获取博客文章完整数据
 * @param slug 文章 slug
 * @param locale 语言代码
 * @returns 博客文章数据或 null
 */
export async function getPostBySlug(
  slug: string,
  locale: string = "zh"
): Promise<BlogPostData | null> {
  const fileNames = getBlogFileNames(locale);

  // 查找匹配的文件（支持带日期和不带日期的文件名）
  const fileName = fileNames.find((file) => {
    const fileSlug = extractSlug(file);
    return fileSlug === slug;
  });

  if (!fileName) {
    return null;
  }

  const filePath = path.join(BLOG_DIRECTORY, fileName);
  const fileContents = fs.readFileSync(filePath, "utf8");
  const { data, content } = matter(fileContents);

  // 将 Markdown 转换为 HTML
  const processedContent = await remark()
    .use(remarkGfm) // 支持 GitHub Flavored Markdown
    .use(html, { sanitize: false }) // 允许 HTML 标签
    .process(content);

  const htmlContent = processedContent.toString();

  // 确保 date 是字符串格式
  let dateString: string;
  if (data.date instanceof Date) {
    dateString = data.date.toISOString().split("T")[0];
  } else if (typeof data.date === "string") {
    dateString = data.date;
  } else {
    dateString = new Date().toISOString().split("T")[0];
  }

  return {
    slug,
    title: data.title || "无标题",
    description: data.description || "",
    date: dateString,
    category: data.category || "未分类",
    tags: data.tags || [],
    featured: data.featured || false,
    readTime: data.readTime || calculateReadTime(content, locale),
    cover: data.cover,
    content,
    htmlContent,
  };
}

/**
 * 获取相关文章（同分类的其他文章）
 * @param currentSlug 当前文章 slug
 * @param category 分类名称
 * @param locale 语言代码
 * @param limit 返回数量限制
 * @returns 相关文章数组
 */
export async function getRelatedPosts(
  currentSlug: string,
  category: string,
  locale: string = "zh",
  limit = 3
): Promise<BlogPostMeta[]> {
  const categoryPosts = await getPostsByCategory(category, locale);
  
  // 过滤掉当前文章
  const relatedPosts = categoryPosts.filter((post) => post.slug !== currentSlug);
  
  // 返回指定数量的文章
  return relatedPosts.slice(0, limit);
}

/**
 * 搜索博客文章（标题、描述、内容）
 * @param query 搜索关键词
 * @param locale 语言代码
 * @returns 匹配的文章数组
 */
export async function searchPosts(
  query: string,
  locale: string = "zh"
): Promise<BlogPostMeta[]> {
  const allPosts = await getAllPosts(locale);
  const lowerQuery = query.toLowerCase();

  return allPosts.filter((post) => {
    return (
      post.title.toLowerCase().includes(lowerQuery) ||
      post.description.toLowerCase().includes(lowerQuery) ||
      post.tags?.some((tag) => tag.toLowerCase().includes(lowerQuery))
    );
  });
}
