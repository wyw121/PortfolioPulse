'use client'

import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Checkbox } from '@/components/ui/checkbox'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Textarea } from '@/components/ui/textarea'
import { BlogService } from '@/lib/blog-service'
import { CheckIcon, FileIcon, UploadIcon } from 'lucide-react'
import { useRouter } from 'next/navigation'
import { useState } from 'react'

export default function BlogUploadPage() {
  const [file, setFile] = useState<File | null>(null)
  const [title, setTitle] = useState('')
  const [excerpt, setExcerpt] = useState('')
  const [category, setCategory] = useState('')
  const [tags, setTags] = useState('')
  const [status, setStatus] = useState<'draft' | 'published'>('draft')
  const [isFeatured, setIsFeatured] = useState(false)
  const [loading, setLoading] = useState(false)
  const [uploadStatus, setUploadStatus] = useState<'idle' | 'uploading' | 'processing' | 'success' | 'error'>('idle')
  const [error, setError] = useState<string | null>(null)

  const router = useRouter()

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0]
    if (selectedFile) {
      setFile(selectedFile)

      // 从文件名提取标题（去掉扩展名）
      const filename = selectedFile.name.replace(/\.(html?|htm)$/i, '')
      if (!title) {
        setTitle(filename)
      }
    }
  }

  const extractContentFromHTML = (htmlContent: string) => {
    // 创建一个临时的DOM解析器
    const parser = new DOMParser()
    const doc = parser.parseFromString(htmlContent, 'text/html')

    // 提取标题（如果HTML中有title标签）
    const titleElement = doc.querySelector('title')
    const extractedTitle = titleElement?.textContent || ''

    // 提取第一段作为摘要
    const firstParagraph = doc.querySelector('p')
    const extractedExcerpt = firstParagraph?.textContent?.slice(0, 200) || ''

    return {
      title: extractedTitle,
      excerpt: extractedExcerpt,
      content: htmlContent
    }
  }

  const handleUpload = async () => {
    if (!file || !title.trim()) {
      setError('请选择文件并输入标题')
      return
    }

    setLoading(true)
    setUploadStatus('uploading')
    setError(null)

    try {
      // 读取文件内容
      const content = await file.text()

      setUploadStatus('processing')

      // 从HTML提取内容
      const extracted = extractContentFromHTML(content)

      // 准备文章数据
      const postData = {
        title: title.trim(),
        content: extracted.content,
        excerpt: excerpt.trim() || extracted.excerpt,
        category: category || undefined,
        tags: tags.trim() ? tags.split(',').map(t => t.trim()).filter(Boolean) : [],
        status,
        is_featured: isFeatured
      }

      // 创建文章
      await BlogService.createPost(postData)

      setUploadStatus('success')

      // 延迟跳转，让用户看到成功状态
      setTimeout(() => {
        router.push('/admin/blog')
      }, 1500)

    } catch (err) {
      setError(err instanceof Error ? err.message : '上传失败')
      setUploadStatus('error')
    } finally {
      setLoading(false)
    }
  }

  const getStatusIcon = () => {
    switch (uploadStatus) {
      case 'uploading':
        return <UploadIcon className="w-5 h-5 animate-spin" />
      case 'processing':
        return <FileIcon className="w-5 h-5 animate-pulse" />
      case 'success':
        return <CheckIcon className="w-5 h-5 text-green-500" />
      case 'error':
        return <FileIcon className="w-5 h-5 text-red-500" />
      default:
        return <UploadIcon className="w-5 h-5" />
    }
  }

  const getStatusText = () => {
    switch (uploadStatus) {
      case 'uploading':
        return '正在上传文件...'
      case 'processing':
        return '正在处理HTML内容...'
      case 'success':
        return '上传成功！即将跳转...'
      case 'error':
        return '上传失败'
      default:
        return '上传OneNote HTML文件'
    }
  }

  return (
    <div className="container max-w-2xl mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold mb-2">上传HTML文件</h1>
        <p className="text-muted-foreground">
          支持上传OneNote导出的HTML文件，系统会自动解析内容并创建博客文章
        </p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>文件上传</CardTitle>
          <CardDescription>
            请选择HTML文件并填写相关信息。支持OneNote、Word等导出的HTML格式。
          </CardDescription>
        </CardHeader>

        <CardContent className="space-y-6">
          {/* 文件选择 */}
          <div className="space-y-2">
            <Label htmlFor="file">选择HTML文件</Label>
            <Input
              id="file"
              type="file"
              accept=".html,.htm"
              onChange={handleFileSelect}
              disabled={loading}
            />
            {file && (
              <div className="text-sm text-muted-foreground">
                已选择: {file.name} ({(file.size / 1024).toFixed(1)} KB)
              </div>
            )}
          </div>

          {/* 文章标题 */}
          <div className="space-y-2">
            <Label htmlFor="title">文章标题 *</Label>
            <Input
              id="title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="请输入文章标题"
              disabled={loading}
            />
          </div>

          {/* 文章摘要 */}
          <div className="space-y-2">
            <Label htmlFor="excerpt">文章摘要</Label>
            <Textarea
              id="excerpt"
              value={excerpt}
              onChange={(e) => setExcerpt(e.target.value)}
              placeholder="留空则自动从内容中提取"
              rows={3}
              disabled={loading}
            />
          </div>

          {/* 分类 */}
          <div className="space-y-2">
            <Label htmlFor="category">分类</Label>
            <Select value={category} onValueChange={setCategory} disabled={loading}>
              <SelectTrigger>
                <SelectValue placeholder="选择分类" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="finance">金融学习</SelectItem>
                <SelectItem value="technology">技术分享</SelectItem>
                <SelectItem value="life">生活感悟</SelectItem>
                <SelectItem value="notes">学习笔记</SelectItem>
              </SelectContent>
            </Select>
          </div>

          {/* 标签 */}
          <div className="space-y-2">
            <Label htmlFor="tags">标签</Label>
            <Input
              id="tags"
              value={tags}
              onChange={(e) => setTags(e.target.value)}
              placeholder="用逗号分隔多个标签，如：金融,投资,学习笔记"
              disabled={loading}
            />
            <div className="text-sm text-muted-foreground">
              使用逗号分隔多个标签
            </div>
          </div>

          {/* 发布设置 */}
          <div className="space-y-4">
            <div className="space-y-2">
              <Label>发布状态</Label>
              <Select value={status} onValueChange={(value: 'draft' | 'published') => setStatus(value)} disabled={loading}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="draft">保存为草稿</SelectItem>
                  <SelectItem value="published">立即发布</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="flex items-center space-x-2">
              <Checkbox
                id="featured"
                checked={isFeatured}
                onCheckedChange={(checked) => setIsFeatured(checked === true)}
                disabled={loading}
              />
              <Label htmlFor="featured" className="text-sm">
                设为精选文章
              </Label>
            </div>
          </div>

          {/* 错误信息 */}
          {error && (
            <div className="text-sm text-destructive bg-destructive/10 p-3 rounded">
              {error}
            </div>
          )}

          {/* 上传按钮 */}
          <Button
            onClick={handleUpload}
            disabled={!file || !title.trim() || loading}
            className="w-full"
          >
            {getStatusIcon()}
            <span className="ml-2">{getStatusText()}</span>
          </Button>

          {/* 上传提示 */}
          <div className="text-sm text-muted-foreground space-y-2">
            <p><strong>使用说明：</strong></p>
            <ul className="list-disc list-inside space-y-1 ml-2">
              <li>支持OneNote「另存为HTML」导出的文件</li>
              <li>支持Word、WPS等导出的HTML文件</li>
              <li>文件大小限制：10MB</li>
              <li>上传后会自动解析HTML内容并保持原有格式</li>
              <li>图片等资源会被内嵌，确保完整显示</li>
            </ul>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
