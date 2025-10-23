import { NextRequest, NextResponse } from 'next/server';
import { getRelatedPosts } from '@/lib/blog-loader';

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const slug = searchParams.get('slug');
    const category = searchParams.get('category');
    const limit = Number.parseInt(searchParams.get('limit') || '3', 10);

    if (!slug || !category) {
      return NextResponse.json(
        { error: 'Missing required parameters: slug and category' },
        { status: 400 }
      );
    }

    const posts = await getRelatedPosts(slug, category, limit);
    return NextResponse.json(posts);
  } catch (error) {
    console.error('获取相关文章失败:', error);
    return NextResponse.json(
      { error: '获取相关文章失败' },
      { status: 500 }
    );
  }
}
