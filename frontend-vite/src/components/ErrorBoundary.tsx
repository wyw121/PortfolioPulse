/**
 * React 错误边界组件
 * 
 * 捕获组件渲染过程中的JavaScript错误，避免整个应用崩溃
 * 提供用户友好的错误展示和错误恢复选项
 */

import React, { Component, ReactNode } from 'react';
import { RefreshCw, AlertTriangle, Home, Bug } from 'lucide-react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
  onError?: (error: Error, errorInfo: React.ErrorInfo) => void;
}

interface State {
  hasError: boolean;
  error: Error | null;
  errorInfo: React.ErrorInfo | null;
  errorId: string;
}

/**
 * 错误边界类组件
 * 
 * 功能特性:
 * - 捕获子组件中的所有JavaScript错误
 * - 显示用户友好的错误界面
 * - 提供错误恢复选项 (刷新、返回首页)
 * - 错误信息记录和上报
 * - 支持自定义fallback UI
 */
export class ErrorBoundary extends Component<Props, State> {
  private retryCount = 0;
  private readonly maxRetries = 3;

  constructor(props: Props) {
    super(props);
    
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null,
      errorId: this.generateErrorId()
    };
  }

  static getDerivedStateFromError(error: Error): Partial<State> {
    // 更新state，下次渲染将显示错误界面
    return {
      hasError: true,
      error,
      errorId: Date.now().toString(36)
    };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    // 记录错误信息
    this.setState({
      error,
      errorInfo
    });

    // 调用外部错误处理回调
    this.props.onError?.(error, errorInfo);

    // 发送错误报告 (生产环境)
    if (import.meta.env.PROD) {
      this.reportError(error, errorInfo);
    }

    // 开发环境下在控制台输出详细错误
    if (import.meta.env.DEV) {
      console.group('🚨 ErrorBoundary Caught an Error');
      console.error('Error:', error);
      console.error('Error Info:', errorInfo);
      console.error('Component Stack:', errorInfo.componentStack);
      console.groupEnd();
    }
  }

  /**
   * 生成唯一的错误ID，用于追踪和日志
   */
  private generateErrorId(): string {
    return `err_${Date.now()}_${Math.random().toString(36).substring(2, 11)}`;
  }

  /**
   * 上报错误到监控服务 (生产环境)
   */
  private async reportError(error: Error, errorInfo: React.ErrorInfo) {
    try {
      // 这里可以集成第三方错误监控服务
      // 如 Sentry, LogRocket, Bugsnag 等
      const errorReport = {
        id: this.state.errorId,
        message: error.message,
        stack: error.stack,
        componentStack: errorInfo.componentStack,
        userAgent: navigator.userAgent,
        url: globalThis.location.href,
        timestamp: new Date().toISOString(),
        userId: null, // 暂时为null，后续集成用户系统时获取
        buildVersion: import.meta.env.VITE_APP_VERSION || 'unknown'
      };

      // 发送到错误收集端点
      await fetch('/api/errors', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(errorReport)
      });
    } catch (reportingError) {
      console.error('Failed to report error:', reportingError);
    }
  }

  /**
   * 尝试恢复错误状态
   */
  private readonly handleRetry = () => {
    if (this.retryCount < this.maxRetries) {
      this.retryCount++;
      this.setState({
        hasError: false,
        error: null,
        errorInfo: null,
        errorId: this.generateErrorId()
      });
    }
  };

  /**
   * 重置错误状态并导航到首页
   */
  private readonly handleGoHome = () => {
    this.setState({
      hasError: false,
      error: null,
      errorInfo: null,
      errorId: this.generateErrorId()
    });
    globalThis.location.href = '/';
  };

  /**
   * 刷新整个页面
   */
  private readonly handleRefresh = () => {
    globalThis.location.reload();
  };

  /**
   * 复制错误信息到剪贴板
   */
  private readonly handleCopyError = async () => {
    const errorText = `
错误ID: ${this.state.errorId}
错误消息: ${this.state.error?.message}
错误堆栈:
${this.state.error?.stack}

组件堆栈:
${this.state.errorInfo?.componentStack}

页面URL: ${globalThis.location.href}
时间: ${new Date().toISOString()}
    `.trim();

    try {
      await navigator.clipboard.writeText(errorText);
      alert('错误信息已复制到剪贴板');
    } catch (err) {
      console.error('Failed to copy error info:', err);
    }
  };

  render() {
    // 如果有错误，渲染错误界面
    if (this.state.hasError) {
      // 使用自定义fallback UI
      if (this.props.fallback) {
        return this.props.fallback;
      }

      // 默认错误界面
      return (
        <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-900 to-black">
          <div className="max-w-md w-full mx-4">
            <div className="bg-gray-800 border border-gray-700 rounded-lg p-6 shadow-xl">
              {/* 错误图标和标题 */}
              <div className="flex items-center space-x-3 mb-4">
                <div className="flex-shrink-0">
                  <AlertTriangle className="h-8 w-8 text-red-400" />
                </div>
                <div>
                  <h1 className="text-lg font-semibold text-white">
                    页面出现了问题
                  </h1>
                  <p className="text-sm text-gray-400">
                    错误ID: {this.state.errorId}
                  </p>
                </div>
              </div>

              {/* 错误描述 */}
              <div className="mb-6">
                <p className="text-gray-300 text-sm mb-3">
                  很抱歉，页面遇到了一个意外错误。您可以尝试以下操作来解决问题：
                </p>
                
                {/* 开发环境显示错误详情 */}
                {import.meta.env.DEV && this.state.error && (
                  <details className="bg-gray-900 border border-gray-600 rounded p-3 mt-3">
                    <summary className="text-red-400 cursor-pointer text-sm font-medium">
                      错误详情 (开发模式)
                    </summary>
                    <div className="mt-2 text-xs text-gray-300 font-mono">
                      <p className="text-red-400 mb-2">{this.state.error.message}</p>
                      <pre className="whitespace-pre-wrap text-gray-400 text-xs">
                        {this.state.error.stack}
                      </pre>
                    </div>
                  </details>
                )}
              </div>

              {/* 操作按钮 */}
              <div className="space-y-3">
                {/* 重试按钮 (有限次数) */}
                {this.retryCount < this.maxRetries && (
                  <button
                    onClick={this.handleRetry}
                    className="w-full flex items-center justify-center space-x-2 bg-blue-600 hover:bg-blue-700 text-white py-2 px-4 rounded-md transition-colors duration-200"
                  >
                    <RefreshCw className="h-4 w-4" />
                    <span>重试 ({this.maxRetries - this.retryCount} 次机会)</span>
                  </button>
                )}

                {/* 返回首页 */}
                <button
                  onClick={this.handleGoHome}
                  className="w-full flex items-center justify-center space-x-2 bg-gray-600 hover:bg-gray-700 text-white py-2 px-4 rounded-md transition-colors duration-200"
                >
                  <Home className="h-4 w-4" />
                  <span>返回首页</span>
                </button>

                {/* 刷新页面 */}
                <button
                  onClick={this.handleRefresh}
                  className="w-full flex items-center justify-center space-x-2 bg-gray-600 hover:bg-gray-700 text-white py-2 px-4 rounded-md transition-colors duration-200"
                >
                  <RefreshCw className="h-4 w-4" />
                  <span>刷新页面</span>
                </button>

                {/* 复制错误信息 (开发/调试用) */}
                <button
                  onClick={this.handleCopyError}
                  className="w-full flex items-center justify-center space-x-2 bg-gray-700 hover:bg-gray-600 text-gray-300 py-2 px-4 rounded-md transition-colors duration-200 text-sm"
                >
                  <Bug className="h-4 w-4" />
                  <span>复制错误信息</span>
                </button>
              </div>

              {/* 帮助信息 */}
              <div className="mt-4 pt-4 border-t border-gray-700">
                <p className="text-xs text-gray-500 text-center">
                  如果问题持续出现，请联系技术支持或刷新页面重试
                </p>
              </div>
            </div>
          </div>
        </div>
      );
    }

    // 正常渲染子组件
    return this.props.children;
  }
}

/**
 * 高阶组件: 为任何组件包装错误边界
 */
export function withErrorBoundary<P extends object>(
  Component: React.ComponentType<P>,
  fallback?: ReactNode,
  onError?: (error: Error, errorInfo: React.ErrorInfo) => void
) {
  const WrappedComponent = (props: P) => (
    <ErrorBoundary fallback={fallback} onError={onError}>
      <Component {...props} />
    </ErrorBoundary>
  );

  WrappedComponent.displayName = `withErrorBoundary(${Component.displayName || Component.name})`;
  return WrappedComponent;
}

/**
 * Hook: 在函数组件中手动触发错误边界
 * 用于异步操作中的错误处理
 */
export function useErrorHandler() {
  return (error: Error, errorInfo?: any) => {
    // 抛出错误，让最近的错误边界捕获
    if (import.meta.env.DEV) {
      console.error('useErrorHandler triggered:', error, errorInfo);
    }
    throw error;
  };
}