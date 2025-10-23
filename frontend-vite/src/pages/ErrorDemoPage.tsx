/**
 * 错误处理演示页面
 * 
 * 展示不同类型的错误处理机制和用户体验
 * 用于开发和测试错误边界、错误提示等组件
 */

import { useState } from 'react';
import { ErrorToast, InlineError, PageError, ErrorSeverity } from '@/components/ErrorToast';
import { useErrorHandler, useAsyncError } from '@/hooks/useErrorHandler';
import { ApiError, createApiError } from '@/lib/apiError';

export default function ErrorDemoPage() {
  const [showToast, setShowToast] = useState(false);
  const [toastError, setToastError] = useState<ApiError | null>(null);
  const [inlineError, setInlineError] = useState<string>('');
  
  const errorHandler = useErrorHandler();
  const asyncErrorHandler = useAsyncError();

  // 模拟不同类型的错误
  const simulateErrors = {
    networkError: () => {
      const error = createApiError.networkError();
      setToastError(error);
      setShowToast(true);
    },

    validationError: () => {
      setInlineError('用户名必须至少包含3个字符');
    },

    notFoundError: () => {
      const error = createApiError.notFound('项目');
      errorHandler.setError(error);
    },

    serverError: () => {
      const error = createApiError.serverError();
      setToastError(error);
      setShowToast(true);
    },

    asyncError: async () => {
      await asyncErrorHandler.execute(async () => {
        throw createApiError.timeout();
      });
    },

    criticalError: () => {
      const error = createApiError.unauthorized();
      setToastError(error);
      setShowToast(true);
    },

    jsError: () => {
      // 这将被错误边界捕获
      throw new Error('这是一个JavaScript运行时错误示例');
    }
  };

  return (
    <div className="max-w-4xl mx-auto p-6">
      <h1 className="text-3xl font-bold text-gray-900 mb-8">错误处理机制演示</h1>
      
      {/* 错误类型演示按钮 */}
      <section className="mb-12">
        <h2 className="text-xl font-semibold mb-4">错误类型演示</h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <button
            onClick={simulateErrors.networkError}
            className="p-3 bg-blue-500 text-white rounded hover:bg-blue-600 text-sm"
          >
            网络错误
          </button>
          
          <button
            onClick={simulateErrors.validationError}
            className="p-3 bg-yellow-500 text-white rounded hover:bg-yellow-600 text-sm"
          >
            验证错误
          </button>
          
          <button
            onClick={simulateErrors.notFoundError}
            className="p-3 bg-orange-500 text-white rounded hover:bg-orange-600 text-sm"
          >
            404 错误
          </button>
          
          <button
            onClick={simulateErrors.serverError}
            className="p-3 bg-red-500 text-white rounded hover:bg-red-600 text-sm"
          >
            服务器错误
          </button>
          
          <button
            onClick={simulateErrors.asyncError}
            className="p-3 bg-purple-500 text-white rounded hover:bg-purple-600 text-sm"
          >
            异步超时
          </button>
          
          <button
            onClick={simulateErrors.criticalError}
            className="p-3 bg-red-700 text-white rounded hover:bg-red-800 text-sm"
          >
            权限错误
          </button>
          
          <button
            onClick={simulateErrors.jsError}
            className="p-3 bg-gray-800 text-white rounded hover:bg-gray-900 text-sm"
          >
            JS 运行时错误
          </button>
          
          <button
            onClick={() => {
              setShowToast(false);
              setInlineError('');
              errorHandler.clearError();
            }}
            className="p-3 bg-gray-500 text-white rounded hover:bg-gray-600 text-sm"
          >
            清除所有错误
          </button>
        </div>
      </section>

      {/* Toast 错误演示 */}
      <section className="mb-8">
        <h2 className="text-xl font-semibold mb-4">Toast 错误提示</h2>
        <ErrorToast
          error={toastError}
          show={showToast}
          showRetry={true}
          showDetails={true}
          dismissible={true}
          onDismiss={() => setShowToast(false)}
          onRetry={() => {
            console.log('重试操作');
            setShowToast(false);
          }}
          autoClose={0} // 不自动关闭，用于演示
        />
      </section>

      {/* 内联错误演示 */}
      <section className="mb-8">
        <h2 className="text-xl font-semibold mb-4">表单验证错误</h2>
        <div className="max-w-md">
          <label htmlFor="username-input" className="block text-sm font-medium text-gray-700 mb-1">
            用户名
          </label>
          <input
            id="username-input"
            type="text"
            className={`w-full px-3 py-2 border rounded-md ${
              inlineError ? 'border-red-300 focus:border-red-500' : 'border-gray-300 focus:border-blue-500'
            }`}
            placeholder="输入用户名"
          />
          <InlineError error={inlineError} />
        </div>
      </section>

      {/* 错误处理状态演示 */}
      <section className="mb-8">
        <h2 className="text-xl font-semibold mb-4">错误处理状态</h2>
        
        {/* 通用错误处理器状态 */}
        <div className="bg-gray-50 p-4 rounded-lg mb-4">
          <h3 className="font-medium mb-2">通用错误处理器</h3>
          <div className="text-sm space-y-1">
            <div>有错误: {errorHandler.isError ? '是' : '否'}</div>
            <div>可重试: {errorHandler.canRetry ? '是' : '否'}</div>
            <div>错误消息: {errorHandler.getErrorMessage() || '无'}</div>
            {errorHandler.isError && (
              <div className="mt-2 space-x-2">
                <button
                  onClick={errorHandler.retry}
                  disabled={!errorHandler.canRetry}
                  className="px-3 py-1 bg-blue-500 text-white rounded text-sm disabled:bg-gray-300"
                >
                  重试
                </button>
                <button
                  onClick={errorHandler.clearError}
                  className="px-3 py-1 bg-gray-500 text-white rounded text-sm"
                >
                  清除
                </button>
              </div>
            )}
          </div>
        </div>

        {/* 异步错误处理器状态 */}
        <div className="bg-gray-50 p-4 rounded-lg">
          <h3 className="font-medium mb-2">异步错误处理器</h3>
          <div className="text-sm space-y-1">
            <div>加载中: {asyncErrorHandler.isLoading ? '是' : '否'}</div>
            <div>有错误: {asyncErrorHandler.isError ? '是' : '否'}</div>
            <div>可重试: {asyncErrorHandler.canRetry ? '是' : '否'}</div>
            <div>错误消息: {asyncErrorHandler.getErrorMessage() || '无'}</div>
          </div>
        </div>
      </section>

      {/* 页面级错误演示 */}
      <section className="mb-8">
        <h2 className="text-xl font-semibold mb-4">页面级错误展示</h2>
        <div className="border border-gray-200 rounded-lg">
          <PageError
            error={createApiError.serverError('数据库连接失败')}
            title="页面加载失败"
            onRetry={() => console.log('重新加载页面')}
            onGoHome={() => console.log('返回首页')}
          />
        </div>
      </section>

      {/* 不同严重级别的Toast演示 */}
      <section className="mb-8">
        <h2 className="text-xl font-semibold mb-4">不同严重级别的提示</h2>
        <div className="space-y-4">
          <ErrorToast
            error={createApiError.networkError('网络连接超时')}
            severity={ErrorSeverity.INFO}
            title="信息提示"
            dismissible={false}
          />
          
          <ErrorToast
            error={createApiError.validation('输入格式不正确')}
            severity={ErrorSeverity.WARNING}
            title="警告"
            dismissible={false}
          />
          
          <ErrorToast
            error={createApiError.serverError('服务暂时不可用')}
            severity={ErrorSeverity.ERROR}
            title="错误"
            dismissible={false}
          />
          
          <ErrorToast
            error={createApiError.forbidden('权限不足')}
            severity={ErrorSeverity.CRITICAL}
            title="严重错误"
            dismissible={false}
          />
        </div>
      </section>

      {/* 使用说明 */}
      <section className="bg-blue-50 p-6 rounded-lg">
        <h2 className="text-xl font-semibold mb-4">使用说明</h2>
        <div className="text-sm space-y-2">
          <p><strong>错误边界:</strong> 点击 "JS 运行时错误" 按钮将触发错误边界，显示友好的错误页面。</p>
          <p><strong>Toast 提示:</strong> 适用于非阻塞性错误通知，支持自动关闭和手动操作。</p>
          <p><strong>内联错误:</strong> 适用于表单验证等场景，显示在相关输入框附近。</p>
          <p><strong>页面级错误:</strong> 当整个页面无法加载时使用，提供重试和导航选项。</p>
          <p><strong>错误处理 Hook:</strong> 提供统一的错误状态管理和操作方法。</p>
        </div>
      </section>
    </div>
  );
}