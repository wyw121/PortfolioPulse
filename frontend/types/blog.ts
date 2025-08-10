export interface BlogPost {
  id: string
  title: string
  slug: string
  content: string
  excerpt?: string
  cover_image?: string
  category?: string
  tags: string[]
  status: 'draft' | 'published' | 'archived'
  view_count: number
  is_featured: boolean
  created_at: string
  updated_at: string
  published_at?: string
}

export interface BlogCategory {
  id: string
  name: string
  slug: string
  description?: string
  color: string
  post_count: number
  created_at: string
  updated_at: string
}

export interface CreateBlogPostRequest {
  title: string
  content: string
  excerpt?: string
  category?: string
  tags?: string[]
  status?: 'draft' | 'published' | 'archived'
  is_featured?: boolean
  cover_image?: string
}

export interface UpdateBlogPostRequest {
  title?: string
  content?: string
  excerpt?: string
  category?: string
  tags?: string[]
  status?: 'draft' | 'published' | 'archived'
  is_featured?: boolean
  cover_image?: string
}

export interface BlogQuery {
  page?: number
  page_size?: number
  category?: string
  search?: string
}
