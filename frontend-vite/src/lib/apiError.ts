/**
 * API错误处理工具
 * 
 * 提供统一的API错误处理机制，包括错误类型定义、错误解析和用户友好的错误消息
 */

/**
 * 标准化的API错误响应结构
 * 与后端 ErrorResponse 保持一致
 */
export interface ApiErrorResponse {
  /** 错误码 - 用于程序判断错误类型 */
  code: string;
  /** 用户友好的错误消息 */
  message: string;
  /** 开发者详细信息（可选） */
  details?: string;
  /** 请求ID，用于日志追踪 */
  request_id?: string;
}

/**
 * 客户端错误类型枚举
 */
export enum ApiErrorCode {
  // 网络相关错误
  NETWORK_ERROR = 'NETWORK_ERROR',
  TIMEOUT = 'TIMEOUT',
  
  // HTTP状态错误
  NOT_FOUND = 'NOT_FOUND',
  BAD_REQUEST = 'BAD_REQUEST',
  UNAUTHORIZED = 'UNAUTHORIZED',
  FORBIDDEN = 'FORBIDDEN',
  CONFLICT = 'CONFLICT',
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  RATE_LIMITED = 'RATE_LIMITED',
  INTERNAL_ERROR = 'INTERNAL_ERROR',
  
  // 客户端逻辑错误
  PARSE_ERROR = 'PARSE_ERROR',
  UNKNOWN_ERROR = 'UNKNOWN_ERROR',
}

/**
 * API错误类
 * 继承自Error，添加了错误码和详细信息
 */
export class ApiError extends Error {
  public readonly code: ApiErrorCode;
  public readonly details?: string;
  public readonly requestId?: string;
  public readonly httpStatus?: number;
  public readonly timestamp: Date;

  constructor(
    code: ApiErrorCode,
    message: string,
    details?: string,
    httpStatus?: number,
    requestId?: string
  ) {
    super(message);
    this.name = 'ApiError';
    this.code = code;
    this.details = details;
    this.httpStatus = httpStatus;
    this.requestId = requestId;
    this.timestamp = new Date();

    // 确保正确的原型链
    Object.setPrototypeOf(this, ApiError.prototype);
  }

  /**
   * 判断是否为网络错误
   */
  isNetworkError(): boolean {
    return this.code === ApiErrorCode.NETWORK_ERROR || this.code === ApiErrorCode.TIMEOUT;
  }

  /**
   * 判断是否为客户端错误 (4xx)
   */
  isClientError(): boolean {
    return this.httpStatus ? this.httpStatus >= 400 && this.httpStatus < 500 : false;
  }

  /**
   * 判断是否为服务器错误 (5xx)
   */
  isServerError(): boolean {
    return this.httpStatus ? this.httpStatus >= 500 : false;
  }

  /**
   * 判断是否可重试
   */
  isRetryable(): boolean {
    return this.isNetworkError() || this.isServerError() || this.code === ApiErrorCode.RATE_LIMITED;
  }

  /**
   * 转换为JSON对象，用于日志记录
   */
  toJSON() {
    return {
      name: this.name,
      code: this.code,
      message: this.message,
      details: this.details,
      httpStatus: this.httpStatus,
      requestId: this.requestId,
      timestamp: this.timestamp.toISOString(),
      stack: this.stack
    };
  }
}

/**
 * 错误消息映射表
 * 提供用户友好的错误提示
 */
const ERROR_MESSAGES: Record<ApiErrorCode, string> = {
  [ApiErrorCode.NETWORK_ERROR]: '网络连接失败，请检查您的网络设置',
  [ApiErrorCode.TIMEOUT]: '请求超时，请稍后重试',
  [ApiErrorCode.NOT_FOUND]: '请求的资源不存在',
  [ApiErrorCode.BAD_REQUEST]: '请求参数错误，请检查输入信息',
  [ApiErrorCode.UNAUTHORIZED]: '未授权访问，请先登录',
  [ApiErrorCode.FORBIDDEN]: '权限不足，无法访问此资源',
  [ApiErrorCode.CONFLICT]: '操作冲突，请刷新页面后重试',
  [ApiErrorCode.VALIDATION_ERROR]: '数据验证失败，请检查输入信息',
  [ApiErrorCode.RATE_LIMITED]: '请求过于频繁，请稍后再试',
  [ApiErrorCode.INTERNAL_ERROR]: '服务器内部错误，我们正在处理此问题',
  [ApiErrorCode.PARSE_ERROR]: '数据解析失败，请稍后重试',
  [ApiErrorCode.UNKNOWN_ERROR]: '发生未知错误，请稍后重试'
};

/**
 * HTTP状态码到错误码的映射
 */
const HTTP_STATUS_TO_ERROR_CODE: Record<number, ApiErrorCode> = {
  400: ApiErrorCode.BAD_REQUEST,
  401: ApiErrorCode.UNAUTHORIZED,
  403: ApiErrorCode.FORBIDDEN,
  404: ApiErrorCode.NOT_FOUND,
  409: ApiErrorCode.CONFLICT,
  422: ApiErrorCode.VALIDATION_ERROR,
  429: ApiErrorCode.RATE_LIMITED,
  500: ApiErrorCode.INTERNAL_ERROR,
  502: ApiErrorCode.INTERNAL_ERROR,
  503: ApiErrorCode.INTERNAL_ERROR,
  504: ApiErrorCode.TIMEOUT,
};

/**
 * API错误处理器类
 * 提供错误解析、转换和处理的核心功能
 */
export class ApiErrorHandler {
  /**
   * 解析Response对象，提取错误信息
   */
  static async parseErrorResponse(response: Response): Promise<ApiError> {
    const status = response.status;
    
    try {
      const errorData: ApiErrorResponse = await response.json();
      
      // 使用后端提供的错误码和消息
      const code = this.parseErrorCode(errorData.code);
      const message = errorData.message || ERROR_MESSAGES[code];
      
      return new ApiError(
        code,
        message,
        errorData.details,
        status,
        errorData.request_id
      );
    } catch (parseError) {
      // JSON解析失败，使用HTTP状态码推断错误
      const code = HTTP_STATUS_TO_ERROR_CODE[status] || ApiErrorCode.UNKNOWN_ERROR;
      const message = ERROR_MESSAGES[code];
      
      return new ApiError(
        code,
        `${message} (HTTP ${status})`,
        `Failed to parse error response: ${parseError}`,
        status
      );
    }
  }

  /**
   * 解析网络错误
   */
  static parseNetworkError(error: unknown): ApiError {
    if (error instanceof TypeError) {
      // 网络连接错误通常是TypeError
      return new ApiError(
        ApiErrorCode.NETWORK_ERROR,
        ERROR_MESSAGES[ApiErrorCode.NETWORK_ERROR],
        error.message
      );
    }
    
    if (error instanceof Error) {
      // 检查是否为超时错误
      if (error.name === 'AbortError' || error.message.includes('timeout')) {
        return new ApiError(
          ApiErrorCode.TIMEOUT,
          ERROR_MESSAGES[ApiErrorCode.TIMEOUT],
          error.message
        );
      }
      
      return new ApiError(
        ApiErrorCode.UNKNOWN_ERROR,
        ERROR_MESSAGES[ApiErrorCode.UNKNOWN_ERROR],
        error.message
      );
    }
    
    return new ApiError(
      ApiErrorCode.UNKNOWN_ERROR,
      ERROR_MESSAGES[ApiErrorCode.UNKNOWN_ERROR],
      String(error)
    );
  }

  /**
   * 解析错误码字符串为枚举值
   */
  private static parseErrorCode(codeString: string): ApiErrorCode {
    // 将后端错误码映射到前端枚举
    const normalizedCode = codeString.toUpperCase();
    
    if (Object.values(ApiErrorCode).includes(normalizedCode as ApiErrorCode)) {
      return normalizedCode as ApiErrorCode;
    }
    
    return ApiErrorCode.UNKNOWN_ERROR;
  }

  /**
   * 获取用户友好的错误消息
   */
  static getUserFriendlyMessage(error: ApiError): string {
    return error.message || ERROR_MESSAGES[error.code];
  }

  /**
   * 判断错误是否应该显示详细信息
   */
  static shouldShowDetails(error: ApiError): boolean {
    // 开发环境显示所有详细信息
    if (import.meta.env.DEV) {
      return true;
    }
    
    // 生产环境只显示客户端错误的详细信息
    return error.isClientError() && error.code === ApiErrorCode.VALIDATION_ERROR;
  }

  /**
   * 记录错误到控制台 (开发环境) 或监控服务 (生产环境)
   */
  static logError(error: ApiError, context?: Record<string, any>) {
    const logData = {
      ...error.toJSON(),
      context
    };

    if (import.meta.env.DEV) {
      console.group('🚨 API Error');
      console.error('Error Code:', error.code);
      console.error('Message:', error.message);
      console.error('Details:', error.details);
      console.error('HTTP Status:', error.httpStatus);
      console.error('Request ID:', error.requestId);
      console.error('Context:', context);
      console.groupEnd();
    } else {
      // 生产环境发送到监控服务
      // 这里可以集成 Sentry, LogRocket 等服务
      console.error('API Error:', logData);
    }
  }
}

/**
 * 便捷函数：创建各种类型的API错误
 */
export const createApiError = {
  networkError: (message?: string) => 
    new ApiError(ApiErrorCode.NETWORK_ERROR, message || ERROR_MESSAGES[ApiErrorCode.NETWORK_ERROR]),
  
  timeout: (message?: string) => 
    new ApiError(ApiErrorCode.TIMEOUT, message || ERROR_MESSAGES[ApiErrorCode.TIMEOUT]),
  
  notFound: (resource?: string) => 
    new ApiError(ApiErrorCode.NOT_FOUND, resource ? `${resource}不存在` : ERROR_MESSAGES[ApiErrorCode.NOT_FOUND]),
  
  badRequest: (message?: string) => 
    new ApiError(ApiErrorCode.BAD_REQUEST, message || ERROR_MESSAGES[ApiErrorCode.BAD_REQUEST]),
  
  unauthorized: (message?: string) => 
    new ApiError(ApiErrorCode.UNAUTHORIZED, message || ERROR_MESSAGES[ApiErrorCode.UNAUTHORIZED]),
  
  forbidden: (message?: string) => 
    new ApiError(ApiErrorCode.FORBIDDEN, message || ERROR_MESSAGES[ApiErrorCode.FORBIDDEN]),
  
  validation: (message?: string) => 
    new ApiError(ApiErrorCode.VALIDATION_ERROR, message || ERROR_MESSAGES[ApiErrorCode.VALIDATION_ERROR]),
  
  serverError: (message?: string) => 
    new ApiError(ApiErrorCode.INTERNAL_ERROR, message || ERROR_MESSAGES[ApiErrorCode.INTERNAL_ERROR]),
};