import { getAllPosts } from "@/lib/blog-loader";
import { NextResponse } from "next/server";

export async function GET() {
  try {
    const posts = await getAllPosts();
    return NextResponse.json(posts);
  } catch (error) {
    console.error("获取博客列表失败:", error);
    return NextResponse.json(
      { error: "获取博客列表失败" },
      { status: 500 }
    );
  }
}
