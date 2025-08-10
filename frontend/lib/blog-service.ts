import { BlogPost, BlogCategory, BlogQuery, CreateBlogPostRequest, UpdateBlogPostRequest } from '@/types/blog'

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

export class BlogService {
  // 获取博客文章列表
  static async getPosts(query: BlogQuery = {}): Promise<BlogPost[]> {
    const params = new URLSearchParams()
    
    if (query.page) params.set('page', query.page.toString())
    if (query.page_size) params.set('page_size', query.page_size.toString())
    if (query.category) params.set('category', query.category)
    if (query.search) params.set('search', query.search)

    const response = await fetch(`${API_BASE_URL}/api/blog/posts?${params}`, {
      cache: 'no-store'
    })

    if (!response.ok) {
      throw new Error('获取博客文章失败')
    }

    return await response.json()
  }

  // 根据slug获取单篇文章
  static async getPostBySlug(slug: string): Promise<BlogPost | null> {
    try {
      const response = await fetch(`${API_BASE_URL}/api/blog/posts/${slug}`, {
        cache: 'no-store'
      })

      if (!response.ok) {
        return null
      }

      return await response.json()
    } catch {
      return null
    }
  }

  // 获取精选文章
  static async getFeaturedPosts(): Promise<BlogPost[]> {
    const response = await fetch(`${API_BASE_URL}/api/blog/featured`, {
      cache: 'no-store'
    })

    if (!response.ok) {
      throw new Error('获取精选文章失败')
    }

    return await response.json()
  }

  // 获取博客分类
  static async getCategories(): Promise<BlogCategory[]> {
    const response = await fetch(`${API_BASE_URL}/api/blog/categories`, {
      cache: 'no-store'
    })

    if (!response.ok) {
      throw new Error('获取博客分类失败')
    }

    return await response.json()
  }

  // 管理员API - 获取所有文章
  static async getAllPostsAdmin(query: BlogQuery = {}): Promise<BlogPost[]> {
    const params = new URLSearchParams()
    
    if (query.page) params.set('page', query.page.toString())
    if (query.page_size) params.set('page_size', query.page_size.toString())

    const response = await fetch(`${API_BASE_URL}/api/admin/blog/posts?${params}`, {
      cache: 'no-store',
      headers: this.getAuthHeaders()
    })

    if (!response.ok) {
      throw new Error('获取所有文章失败')
    }

    return await response.json()
  }

  // 管理员API - 创建文章
  static async createPost(data: CreateBlogPostRequest): Promise<BlogPost> {
    const response = await fetch(`${API_BASE_URL}/api/admin/blog/posts`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...this.getAuthHeaders()
      },
      body: JSON.stringify(data)
    })

    if (!response.ok) {
      throw new Error('创建文章失败')
    }

    return await response.json()
  }

  // 管理员API - 更新文章
  static async updatePost(id: string, data: UpdateBlogPostRequest): Promise<BlogPost> {
    const response = await fetch(`${API_BASE_URL}/api/admin/blog/posts/${id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        ...this.getAuthHeaders()
      },
      body: JSON.stringify(data)
    })

    if (!response.ok) {
      throw new Error('更新文章失败')
    }

    return await response.json()
  }

  // 管理员API - 删除文章
  static async deletePost(id: string): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/api/admin/blog/posts/${id}`, {
      method: 'DELETE',
      headers: this.getAuthHeaders()
    })

    if (!response.ok) {
      throw new Error('删除文章失败')
    }
  }

  // 上传文件（OneNote HTML支持）
  static async uploadFile(file: File): Promise<{ url: string; fileName: string }> {
    const formData = new FormData()
    formData.append('file', file)

    const response = await fetch(`${API_BASE_URL}/api/admin/blog/upload`, {
      method: 'POST',
      headers: this.getAuthHeaders(),
      body: formData
    })

    if (!response.ok) {
      throw new Error('文件上传失败')
    }

    return await response.json()
  }

  // 私有方法 - 获取认证头
  private static getAuthHeaders(): Record<string, string> {
    // 这里需要实现认证逻辑，比如从localStorage获取token
    // 暂时返回空对象，后续需要实现GitHub OAuth认证
    return {}
  }
}
