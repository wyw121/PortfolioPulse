/**
 * 错误处理相关的自定义 Hooks
 * 
 * 提供统一的错误处理逻辑，包括错误状态管理、用户提示和错误恢复
 */

import { useState, useCallback, useRef } from 'react';
import { ApiError, ApiErrorHandler, ApiErrorCode } from '@/lib/apiError';

/**
 * 错误状态接口
 */
interface ErrorState {
  error: ApiError | null;
  isError: boolean;
  errorId: string | null;
}

/**
 * 错误处理操作接口
 */
interface ErrorActions {
  /** 设置错误 */
  setError: (error: ApiError | Error | string) => void;
  /** 清除错误 */
  clearError: () => void;
  /** 重试操作 */
  retry: () => void;
  /** 设置重试回调 */
  setRetryCallback: (callback: () => void) => void;
  /** 是否可重试 */
  canRetry: boolean;
  /** 获取用户友好的错误消息 */
  getErrorMessage: () => string;
  /** 是否应该显示错误详情 */
  shouldShowDetails: () => boolean;
}

/**
 * Hook: 错误状态管理
 * 
 * 提供完整的错误处理功能，包括错误状态、重试机制和用户提示
 */
export function useErrorHandler(): ErrorState & ErrorActions {
  const [errorState, setErrorState] = useState<ErrorState>({
    error: null,
    isError: false,
    errorId: null,
  });

  const retryCallbackRef = useRef<(() => void) | null>(null);

  /**
   * 设置错误
   */
  const setError = useCallback((error: ApiError | Error | string) => {
    let apiError: ApiError;

    if (error instanceof ApiError) {
      apiError = error;
    } else if (error instanceof Error) {
      apiError = ApiErrorHandler.parseNetworkError(error);
    } else {
      apiError = new ApiError(
        ApiErrorCode.UNKNOWN_ERROR,
        typeof error === 'string' ? error : '未知错误'
      );
    }

    // 记录错误
    ApiErrorHandler.logError(apiError);

    setErrorState({
      error: apiError,
      isError: true,
      errorId: `${Date.now()}_${Math.random().toString(36).substring(2, 11)}`,
    });
  }, []);

  /**
   * 清除错误
   */
  const clearError = useCallback(() => {
    setErrorState({
      error: null,
      isError: false,
      errorId: null,
    });
  }, []);

  /**
   * 重试操作
   */
  const retry = useCallback(() => {
    if (retryCallbackRef.current) {
      clearError();
      retryCallbackRef.current();
    }
  }, [clearError]);

  /**
   * 设置重试回调
   */
  const setRetryCallback = useCallback((callback: () => void) => {
    retryCallbackRef.current = callback;
  }, []);

  /**
   * 检查是否可重试
   */
  const canRetry = errorState.error?.isRetryable() || false;

  /**
   * 获取用户友好的错误消息
   */
  const getErrorMessage = useCallback(() => {
    if (!errorState.error) return '';
    return ApiErrorHandler.getUserFriendlyMessage(errorState.error);
  }, [errorState.error]);

  /**
   * 是否应该显示错误详情
   */
  const shouldShowDetails = useCallback(() => {
    if (!errorState.error) return false;
    return ApiErrorHandler.shouldShowDetails(errorState.error);
  }, [errorState.error]);

  return {
    ...errorState,
    setError,
    clearError,
    retry,
    canRetry,
    getErrorMessage,
    shouldShowDetails,
    setRetryCallback,
  };
}

/**
 * Hook: 异步操作错误处理
 * 
 * 专门用于处理异步操作 (如API调用) 的错误处理
 */
export function useAsyncError() {
  const [isLoading, setIsLoading] = useState(false);
  const errorHandler = useErrorHandler();

  /**
   * 执行异步操作，自动处理加载状态和错误
   */
  const execute = useCallback(async <T>(
    asyncFn: () => Promise<T>,
    options?: {
      onSuccess?: (data: T) => void;
      onError?: (error: ApiError) => void;
      enableRetry?: boolean;
    }
  ): Promise<T | null> => {
    const { onSuccess, onError, enableRetry = true } = options || {};

    setIsLoading(true);
    errorHandler.clearError();

    try {
      const result = await asyncFn();
      onSuccess?.(result);
      return result;
    } catch (error) {
      const apiError = error instanceof ApiError 
        ? error 
        : ApiErrorHandler.parseNetworkError(error);

      errorHandler.setError(apiError);
      onError?.(apiError);

      // 设置重试回调
      if (enableRetry && apiError.isRetryable()) {
        errorHandler.setRetryCallback(() => execute(asyncFn, options));
      }

      return null;
    } finally {
      setIsLoading(false);
    }
  }, [errorHandler]);

  return {
    execute,
    isLoading,
    ...errorHandler,
  };
}

/**
 * Hook: 表单验证错误处理
 * 
 * 专门用于处理表单提交和验证错误
 */
export function useFormError() {
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});
  const errorHandler = useErrorHandler();

  /**
   * 设置字段级别的错误
   */
  const setFieldError = useCallback((field: string, message: string) => {
    setFieldErrors(prev => ({
      ...prev,
      [field]: message,
    }));
  }, []);

  /**
   * 清除字段错误
   */
  const clearFieldError = useCallback((field: string) => {
    setFieldErrors(prev => {
      const { [field]: _, ...rest } = prev;
      return rest;
    });
  }, []);

  /**
   * 清除所有字段错误
   */
  const clearAllFieldErrors = useCallback(() => {
    setFieldErrors({});
  }, []);

  /**
   * 处理验证错误响应
   * 解析服务端返回的验证错误，设置到对应字段
   */
  const handleValidationError = useCallback((error: ApiError) => {
    if (error.code === ApiErrorCode.VALIDATION_ERROR && error.details) {
      try {
        // 假设details包含字段错误信息的JSON
        const fieldErrors = JSON.parse(error.details);
        setFieldErrors(fieldErrors);
      } catch {
        // 如果解析失败，使用通用错误
        errorHandler.setError(error);
      }
    } else {
      errorHandler.setError(error);
    }
  }, [errorHandler]);

  /**
   * 获取字段错误消息
   */
  const getFieldError = useCallback((field: string) => {
    return fieldErrors[field];
  }, [fieldErrors]);

  /**
   * 检查字段是否有错误
   */
  const hasFieldError = useCallback((field: string) => {
    return Boolean(fieldErrors[field]);
  }, [fieldErrors]);

  /**
   * 检查是否有任何字段错误
   */
  const hasAnyFieldError = Object.keys(fieldErrors).length > 0;

  return {
    fieldErrors,
    setFieldError,
    clearFieldError,
    clearAllFieldErrors,
    handleValidationError,
    getFieldError,
    hasFieldError,
    hasAnyFieldError,
    ...errorHandler,
  };
}

/**
 * Hook: 全局错误处理
 * 
 * 用于处理全局级别的错误，如未捕获的Promise rejection
 */
export function useGlobalErrorHandler() {
  const errorHandler = useErrorHandler();

  const handleGlobalError = useCallback((error: unknown) => {
    console.error('Global error caught:', error);
    
    if (error instanceof ApiError) {
      errorHandler.setError(error);
    } else if (error instanceof Error) {
      errorHandler.setError(ApiErrorHandler.parseNetworkError(error));
    } else {
      errorHandler.setError(String(error));
    }
  }, [errorHandler]);

  return {
    handleGlobalError,
    ...errorHandler,
  };
}