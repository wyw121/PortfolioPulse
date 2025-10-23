/**
 * 错误提示组件
 * 
 * 提供用户友好的错误展示，支持不同类型的错误样式和交互
 */

import React from 'react';
import { AlertTriangle, RefreshCw, X, Info, AlertCircle, XCircle } from 'lucide-react';
import { ApiError, ApiErrorCode } from '@/lib/apiError';

/**
 * 错误类型联合
 */
type ErrorType = ApiError | Error | string;

/**
 * 错误严重级别
 */
export enum ErrorSeverity {
  INFO = 'info',
  WARNING = 'warning', 
  ERROR = 'error',
  CRITICAL = 'critical'
}

/**
 * 错误提示组件属性
 */
interface ErrorToastProps {
  /** 错误对象 */
  error: ErrorType | null;
  /** 是否显示 */
  show?: boolean;
  /** 严重级别 */
  severity?: ErrorSeverity;
  /** 是否可关闭 */
  dismissible?: boolean;
  /** 是否显示重试按钮 */
  showRetry?: boolean;
  /** 是否显示详情 */
  showDetails?: boolean;
  /** 自定义标题 */
  title?: string;
  /** 自定义类名 */
  className?: string;
  /** 关闭回调 */
  onDismiss?: () => void;
  /** 重试回调 */
  onRetry?: () => void;
  /** 自动关闭时间(毫秒)，0表示不自动关闭 */
  autoClose?: number;
}

/**
 * 根据错误类型获取严重级别
 */
function getErrorSeverity(error: ErrorType): ErrorSeverity {
  if (error instanceof ApiError) {
    switch (error.code) {
      case ApiErrorCode.UNAUTHORIZED:
      case ApiErrorCode.FORBIDDEN:
        return ErrorSeverity.CRITICAL;
      
      case ApiErrorCode.INTERNAL_ERROR:
        return ErrorSeverity.ERROR;
      
      case ApiErrorCode.VALIDATION_ERROR:
      case ApiErrorCode.BAD_REQUEST:
        return ErrorSeverity.WARNING;
      
      case ApiErrorCode.NOT_FOUND:
      case ApiErrorCode.NETWORK_ERROR:
      case ApiErrorCode.TIMEOUT:
        return ErrorSeverity.INFO;
      
      default:
        return ErrorSeverity.ERROR;
    }
  }
  
  return ErrorSeverity.ERROR;
}

/**
 * 获取错误显示信息
 */
function getErrorDisplayInfo(error: ErrorType) {
  if (error instanceof ApiError) {
    return {
      message: error.message,
      details: error.details,
      canRetry: error.isRetryable(),
      code: error.code,
    };
  }
  
  if (error instanceof Error) {
    return {
      message: error.message,
      details: error.stack,
      canRetry: false,
      code: 'UNKNOWN_ERROR',
    };
  }
  
  return {
    message: typeof error === 'string' ? error : '未知错误',
    details: undefined,
    canRetry: false,
    code: 'UNKNOWN_ERROR',
  };
}

/**
 * 获取严重级别对应的样式
 */
function getSeverityStyles(severity: ErrorSeverity) {
  const baseClasses = "border rounded-lg p-4 shadow-md";
  
  switch (severity) {
    case ErrorSeverity.INFO:
      return `${baseClasses} bg-blue-50 border-blue-200 text-blue-800`;
    
    case ErrorSeverity.WARNING:
      return `${baseClasses} bg-yellow-50 border-yellow-200 text-yellow-800`;
    
    case ErrorSeverity.ERROR:
      return `${baseClasses} bg-red-50 border-red-200 text-red-800`;
    
    case ErrorSeverity.CRITICAL:
      return `${baseClasses} bg-red-100 border-red-300 text-red-900 shadow-lg`;
    
    default:
      return `${baseClasses} bg-gray-50 border-gray-200 text-gray-800`;
  }
}

/**
 * 获取严重级别对应的图标
 */
function getSeverityIcon(severity: ErrorSeverity) {
  const iconClasses = "h-5 w-5 flex-shrink-0";
  
  switch (severity) {
    case ErrorSeverity.INFO:
      return <Info className={`${iconClasses} text-blue-500`} />;
    
    case ErrorSeverity.WARNING:
      return <AlertTriangle className={`${iconClasses} text-yellow-500`} />;
    
    case ErrorSeverity.ERROR:
      return <AlertCircle className={`${iconClasses} text-red-500`} />;
    
    case ErrorSeverity.CRITICAL:
      return <XCircle className={`${iconClasses} text-red-600`} />;
    
    default:
      return <AlertTriangle className={`${iconClasses} text-gray-500`} />;
  }
}

/**
 * 错误提示组件
 */
export function ErrorToast({
  error,
  show = true,
  severity,
  dismissible = true,
  showRetry,
  showDetails = false,
  title,
  className = '',
  onDismiss,
  onRetry,
  autoClose = 0,
}: Readonly<ErrorToastProps>) {
  // 自动关闭逻辑 - 移到前面避免条件调用
  React.useEffect(() => {
    if (autoClose > 0 && onDismiss) {
      const timer = setTimeout(onDismiss, autoClose);
      return () => clearTimeout(timer);
    }
  }, [autoClose, onDismiss]);

  // 如果没有错误或不显示，返回null
  if (!error || !show) {
    return null;
  }

  const errorInfo = getErrorDisplayInfo(error);
  const finalSeverity = severity || getErrorSeverity(error);
  const severityStyles = getSeverityStyles(finalSeverity);
  const severityIcon = getSeverityIcon(finalSeverity);
  
  // 确定是否显示重试按钮
  const shouldShowRetry = showRetry ?? errorInfo.canRetry;

  return (
    <div className={`${severityStyles} ${className}`} role="alert">
      <div className="flex">
        {/* 图标 */}
        <div className="flex-shrink-0">
          {severityIcon}
        </div>

        {/* 内容区域 */}
        <div className="ml-3 flex-1">
          {/* 标题 */}
          {title && (
            <h3 className="text-sm font-medium mb-1">
              {title}
            </h3>
          )}

          {/* 错误消息 */}
          <div className="text-sm">
            {errorInfo.message}
          </div>

          {/* 错误详情 (开发环境或特定情况) */}
          {showDetails && errorInfo.details && (
            <details className="mt-2">
              <summary className="text-xs font-medium cursor-pointer hover:underline">
                错误详情
              </summary>
              <div className="mt-1 text-xs font-mono bg-white bg-opacity-50 p-2 rounded border overflow-auto max-h-32">
                {errorInfo.details}
              </div>
            </details>
          )}

          {/* 错误代码 (开发环境) */}
          {import.meta.env.DEV && (
            <div className="mt-1 text-xs opacity-75">
              错误代码: {errorInfo.code}
            </div>
          )}

          {/* 操作按钮区域 */}
          {(shouldShowRetry || dismissible) && (
            <div className="mt-3 flex space-x-2">
              {/* 重试按钮 */}
              {shouldShowRetry && onRetry && (
                <button
                  onClick={onRetry}
                  className="inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded text-white bg-opacity-80 bg-gray-800 hover:bg-gray-900 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 transition-colors"
                >
                  <RefreshCw className="h-3 w-3 mr-1" />
                  重试
                </button>
              )}

              {/* 关闭按钮 */}
              {dismissible && onDismiss && (
                <button
                  onClick={onDismiss}
                  className="inline-flex items-center px-3 py-1.5 border border-current text-xs font-medium rounded hover:bg-white hover:bg-opacity-20 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-current transition-colors"
                >
                  <X className="h-3 w-3 mr-1" />
                  关闭
                </button>
              )}
            </div>
          )}
        </div>

        {/* 右上角关闭图标 */}
        {dismissible && onDismiss && (
          <div className="ml-auto pl-3">
            <div className="-mx-1.5 -my-1.5">
              <button
                onClick={onDismiss}
                className="inline-flex rounded-md p-1.5 hover:bg-white hover:bg-opacity-20 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-current transition-colors"
              >
                <span className="sr-only">关闭</span>
                <X className="h-4 w-4" />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

/**
 * 内联错误组件
 * 用于表单字段或小范围的错误展示
 */
interface InlineErrorProps {
  error: string | null;
  show?: boolean;
  className?: string;
}

export function InlineError({ error, show = true, className = '' }: Readonly<InlineErrorProps>) {
  if (!error || !show) {
    return null;
  }

  return (
    <div className={`flex items-center text-sm text-red-600 mt-1 ${className}`}>
      <AlertCircle className="h-4 w-4 mr-1 flex-shrink-0" />
      <span>{error}</span>
    </div>
  );
}

/**
 * 页面级错误组件
 * 用于替代整个页面内容的错误展示
 */
interface PageErrorProps {
  error: ErrorType;
  title?: string;
  onRetry?: () => void;
  onGoHome?: () => void;
  className?: string;
}

export function PageError({ 
  error, 
  title = "页面加载失败", 
  onRetry, 
  onGoHome,
  className = ''
}: Readonly<PageErrorProps>) {
  const errorInfo = getErrorDisplayInfo(error);
  
  return (
    <div className={`min-h-64 flex items-center justify-center ${className}`}>
      <div className="text-center max-w-md mx-auto px-4">
        {/* 错误图标 */}
        <div className="mx-auto flex items-center justify-center h-16 w-16 rounded-full bg-red-100 mb-4">
          <AlertTriangle className="h-8 w-8 text-red-600" />
        </div>

        {/* 标题 */}
        <h2 className="text-xl font-semibold text-gray-900 mb-2">
          {title}
        </h2>

        {/* 错误消息 */}
        <p className="text-gray-600 mb-6">
          {errorInfo.message}
        </p>

        {/* 操作按钮 */}
        <div className="space-y-3">
          {/* 重试按钮 */}
          {errorInfo.canRetry && onRetry && (
            <button
              onClick={onRetry}
              className="w-full inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"
            >
              <RefreshCw className="h-4 w-4 mr-2" />
              重新加载
            </button>
          )}

          {/* 返回首页 */}
          {onGoHome && (
            <button
              onClick={onGoHome}
              className="w-full inline-flex items-center justify-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"
            >
              返回首页
            </button>
          )}
        </div>

        {/* 开发环境显示错误详情 */}
        {import.meta.env.DEV && errorInfo.details && (
          <details className="mt-6 text-left">
            <summary className="text-sm text-gray-500 cursor-pointer hover:text-gray-700">
              开发者信息
            </summary>
            <div className="mt-2 p-3 bg-gray-100 rounded text-xs font-mono text-gray-700 overflow-auto max-h-32">
              {errorInfo.details}
            </div>
          </details>
        )}
      </div>
    </div>
  );
}