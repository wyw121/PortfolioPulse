"use client";

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { BlogService } from "@/lib/blog-service";
import type { BlogPost } from "@/types/blog";
import { EditIcon, EyeIcon, PlusIcon, TrashIcon } from "lucide-react";
import Link from "next/link";
// import { useRouter } from "next/navigation"; // 暂时注释掉未使用的useRouter
import { useCallback, useEffect, useState } from "react";

export default function BlogAdminPage() {
  const [posts, setPosts] = useState<BlogPost[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [currentPage] = useState(1);
  // const router = useRouter(); // 暂时注释掉未使用的router

  const loadPosts = useCallback(async () => {
    try {
      setLoading(true);
      const data = await BlogService.getAllPostsAdmin({
        page: currentPage,
        page_size: 20,
      });
      setPosts(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : "加载失败");
    } finally {
      setLoading(false);
    }
  }, [currentPage]);

  useEffect(() => {
    loadPosts();
  }, [loadPosts]);

  const handleDelete = async (id: string, title: string) => {
    if (!confirm(`确定要删除文章《${title}》吗？此操作不可撤销。`)) {
      return;
    }

    try {
      await BlogService.deletePost(id);
      setPosts(posts.filter((post) => post.id !== id));
    } catch (error) {
      alert(
        "删除失败: " + (error instanceof Error ? error.message : "未知错误")
      );
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "published":
        return (
          <Badge className="bg-green-500 hover:bg-green-600">已发布</Badge>
        );
      case "draft":
        return <Badge variant="secondary">草稿</Badge>;
      case "archived":
        return <Badge variant="outline">已归档</Badge>;
      default:
        return <Badge variant="outline">{status}</Badge>;
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("zh-CN", {
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  if (loading) {
    return (
      <div className="container max-w-6xl mx-auto px-4 py-8">
        <div className="text-center">加载中...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="container max-w-6xl mx-auto px-4 py-8">
        <div className="text-center">
          <p className="text-destructive mb-4">加载失败: {error}</p>
          <Button onClick={() => window.location.reload()}>重试</Button>
        </div>
      </div>
    );
  }

  return (
    <div className="container max-w-6xl mx-auto px-4 py-8">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold mb-2">博客管理</h1>
          <p className="text-muted-foreground">
            管理您的博客文章，支持OneNote HTML上传
          </p>
        </div>

        <div className="flex space-x-3">
          <Button asChild>
            <Link href="/admin/blog/new">
              <PlusIcon className="w-4 h-4 mr-2" />
              新建文章
            </Link>
          </Button>

          <Button variant="outline" asChild>
            <Link href="/admin/blog/upload">上传HTML文件</Link>
          </Button>
        </div>
      </div>

      {/* 统计信息 */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">总文章</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{posts.length}</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">已发布</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">
              {posts.filter((p) => p.status === "published").length}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">草稿</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-yellow-600">
              {posts.filter((p) => p.status === "draft").length}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">总浏览量</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {posts.reduce((sum, p) => sum + p.view_count, 0)}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* 文章列表 */}
      <div className="space-y-4">
        {posts.map((post) => (
          <Card key={post.id}>
            <CardHeader>
              <div className="flex items-start justify-between">
                <div className="space-y-2">
                  <CardTitle className="text-lg">{post.title}</CardTitle>
                  <div className="flex items-center space-x-4 text-sm text-muted-foreground">
                    <span>创建于 {formatDate(post.created_at)}</span>
                    <span>更新于 {formatDate(post.updated_at)}</span>
                    {post.published_at && (
                      <span>发布于 {formatDate(post.published_at)}</span>
                    )}
                    <div className="flex items-center space-x-1">
                      <EyeIcon className="w-4 h-4" />
                      <span>{post.view_count}</span>
                    </div>
                  </div>
                </div>

                <div className="flex items-center space-x-2">
                  {getStatusBadge(post.status)}
                  {post.is_featured && (
                    <Badge className="bg-yellow-500 hover:bg-yellow-600">
                      精选
                    </Badge>
                  )}
                </div>
              </div>

              {post.excerpt && (
                <CardDescription className="line-clamp-2">
                  {post.excerpt}
                </CardDescription>
              )}
            </CardHeader>

            <CardContent>
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-2">
                  {post.category && (
                    <Badge variant="outline">{post.category}</Badge>
                  )}
                  {post.tags.slice(0, 3).map((tag) => (
                    <Badge key={tag} variant="outline" className="text-xs">
                      {tag}
                    </Badge>
                  ))}
                  {post.tags.length > 3 && (
                    <Badge variant="outline" className="text-xs">
                      +{post.tags.length - 3}
                    </Badge>
                  )}
                </div>

                <div className="flex items-center space-x-2">
                  <Button size="sm" variant="outline" asChild>
                    <Link href={`/blog/${post.slug}`} target="_blank">
                      <EyeIcon className="w-4 h-4 mr-1" />
                      查看
                    </Link>
                  </Button>

                  <Button size="sm" variant="outline" asChild>
                    <Link href={`/admin/blog/edit/${post.id}`}>
                      <EditIcon className="w-4 h-4 mr-1" />
                      编辑
                    </Link>
                  </Button>

                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => handleDelete(post.id, post.title)}
                    className="text-destructive hover:text-destructive"
                  >
                    <TrashIcon className="w-4 h-4 mr-1" />
                    删除
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {posts.length === 0 && (
        <div className="text-center py-12">
          <p className="text-muted-foreground mb-4">还没有任何文章</p>
          <Button asChild>
            <Link href="/admin/blog/new">
              <PlusIcon className="w-4 h-4 mr-2" />
              创建第一篇文章
            </Link>
          </Button>
        </div>
      )}
    </div>
  );
}
