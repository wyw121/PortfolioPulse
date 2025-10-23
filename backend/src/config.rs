/**
 * 配置管理模块
 * 
 * 提供统一的应用配置管理，包括环境变量加载、验证和类型安全的配置访问
 */

use std::env;
use std::fmt;
use std::num::ParseIntError;
use std::str::ParseBoolError;

use serde::{Deserialize, Serialize};
use thiserror::Error;
use tracing::{info, warn};

/// 配置错误类型
#[derive(Error, Debug)]
pub enum ConfigError {
    #[error("缺少必需的环境变量: {var_name}")]
    MissingEnvVar { var_name: String },

    #[error("环境变量 {var_name} 格式错误: {source}")]
    InvalidFormat {
        var_name: String,
        #[source]
        source: Box<dyn std::error::Error + Send + Sync>,
    },

    #[error("环境变量 {var_name} 值无效: {value} (期望: {expected})")]
    InvalidValue {
        var_name: String,
        value: String,
        expected: String,
    },

    #[error("配置验证失败: {message}")]
    ValidationError { message: String },
}

/// 日志级别枚举
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum LogLevel {
    Error,
    Warn,
    Info,
    Debug,
    Trace,
}

impl fmt::Display for LogLevel {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            LogLevel::Error => write!(f, "error"),
            LogLevel::Warn => write!(f, "warn"),
            LogLevel::Info => write!(f, "info"),
            LogLevel::Debug => write!(f, "debug"),
            LogLevel::Trace => write!(f, "trace"),
        }
    }
}

impl std::str::FromStr for LogLevel {
    type Err = ConfigError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.to_lowercase().as_str() {
            "error" => Ok(LogLevel::Error),
            "warn" => Ok(LogLevel::Warn),
            "info" => Ok(LogLevel::Info),
            "debug" => Ok(LogLevel::Debug),
            "trace" => Ok(LogLevel::Trace),
            _ => Err(ConfigError::InvalidValue {
                var_name: "LOG_LEVEL".to_string(),
                value: s.to_string(),
                expected: "error, warn, info, debug, trace".to_string(),
            }),
        }
    }
}

/// 环境类型枚举
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum Environment {
    Development,
    Testing,
    Staging,
    Production,
}

impl fmt::Display for Environment {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Environment::Development => write!(f, "development"),
            Environment::Testing => write!(f, "testing"),
            Environment::Staging => write!(f, "staging"),
            Environment::Production => write!(f, "production"),
        }
    }
}

impl std::str::FromStr for Environment {
    type Err = ConfigError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.to_lowercase().as_str() {
            "development" | "dev" => Ok(Environment::Development),
            "testing" | "test" => Ok(Environment::Testing),
            "staging" => Ok(Environment::Staging),
            "production" | "prod" => Ok(Environment::Production),
            _ => Err(ConfigError::InvalidValue {
                var_name: "ENVIRONMENT".to_string(),
                value: s.to_string(),
                expected: "development, testing, staging, production".to_string(),
            }),
        }
    }
}

/// 服务器配置
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServerConfig {
    /// 服务器监听地址
    pub host: String,
    /// 服务器监听端口
    pub port: u16,
    /// 静态文件目录路径
    pub static_dir: String,
    /// 请求超时时间（秒）
    pub request_timeout: u64,
    /// 最大请求体大小（字节）
    pub max_body_size: usize,
}

/// 数据库配置
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DatabaseConfig {
    /// 数据库连接URL
    pub url: String,
    /// 最大连接数
    pub max_connections: u32,
    /// 连接超时时间（秒）
    pub connect_timeout: u64,
    /// 查询超时时间（秒）
    pub query_timeout: u64,
    /// 是否启用SQL日志
    pub enable_logging: bool,
}

/// 外部API配置
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExternalApiConfig {
    /// GitHub API Token
    pub github_token: Option<String>,
    /// GitHub API 基础URL
    pub github_base_url: String,
    /// API请求超时时间（秒）
    pub request_timeout: u64,
    /// API请求重试次数
    pub max_retries: u32,
}

/// 安全配置
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SecurityConfig {
    /// JWT密钥
    pub jwt_secret: Option<String>,
    /// JWT过期时间（秒）
    pub jwt_expiration: u64,
    /// CORS允许的源
    pub cors_origins: Vec<String>,
    /// 是否启用HTTPS重定向
    pub force_https: bool,
}

/// 日志配置
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LogConfig {
    /// 日志级别
    pub level: LogLevel,
    /// 日志格式 (json, pretty)
    pub format: String,
    /// 是否启用文件日志
    pub file_logging: bool,
    /// 日志文件路径
    pub log_file: Option<String>,
}

/// 应用配置结构
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    /// 环境类型
    pub environment: Environment,
    /// 服务器配置
    pub server: ServerConfig,
    /// 数据库配置
    pub database: Option<DatabaseConfig>,
    /// 外部API配置
    pub external_api: ExternalApiConfig,
    /// 安全配置
    pub security: SecurityConfig,
    /// 日志配置
    pub log: LogConfig,
}

impl Config {
    /// 从环境变量加载配置
    pub fn from_env() -> Result<Self, ConfigError> {
        info!("正在加载应用配置...");

        let config = Config {
            environment: parse_env_var("ENVIRONMENT")
                .unwrap_or_else(|| Environment::Development),
            
            server: ServerConfig {
                host: get_env_var("SERVER_HOST")
                    .unwrap_or_else(|| "0.0.0.0".to_string()),
                port: parse_env_var("SERVER_PORT")
                    .unwrap_or(8000),
                static_dir: get_env_var("STATIC_DIR")
                    .unwrap_or_else(|| "static".to_string()),
                request_timeout: parse_env_var("REQUEST_TIMEOUT")
                    .unwrap_or(30),
                max_body_size: parse_env_var("MAX_BODY_SIZE")
                    .unwrap_or(16_777_216), // 16MB
            },

            database: if get_env_var("DATABASE_URL").is_some() {
                Some(DatabaseConfig {
                    url: require_env_var("DATABASE_URL")?,
                    max_connections: parse_env_var("DB_MAX_CONNECTIONS")
                        .unwrap_or(10),
                    connect_timeout: parse_env_var("DB_CONNECT_TIMEOUT")
                        .unwrap_or(30),
                    query_timeout: parse_env_var("DB_QUERY_TIMEOUT")
                        .unwrap_or(30),
                    enable_logging: parse_env_var("DB_ENABLE_LOGGING")
                        .unwrap_or(false),
                })
            } else {
                None
            },

            external_api: ExternalApiConfig {
                github_token: get_env_var("GITHUB_TOKEN"),
                github_base_url: get_env_var("GITHUB_BASE_URL")
                    .unwrap_or_else(|| "https://api.github.com".to_string()),
                request_timeout: parse_env_var("API_REQUEST_TIMEOUT")
                    .unwrap_or(10),
                max_retries: parse_env_var("API_MAX_RETRIES")
                    .unwrap_or(3),
            },

            security: SecurityConfig {
                jwt_secret: get_env_var("JWT_SECRET"),
                jwt_expiration: parse_env_var("JWT_EXPIRATION")
                    .unwrap_or(86400), // 24小时
                cors_origins: get_env_var("CORS_ORIGINS")
                    .map(|s| s.split(',').map(|s| s.trim().to_string()).collect())
                    .unwrap_or_else(|| vec!["*".to_string()]),
                force_https: parse_env_var("FORCE_HTTPS")
                    .unwrap_or(false),
            },

            log: LogConfig {
                level: parse_env_var("LOG_LEVEL")
                    .unwrap_or(LogLevel::Info),
                format: get_env_var("LOG_FORMAT")
                    .unwrap_or_else(|| "pretty".to_string()),
                file_logging: parse_env_var("LOG_FILE_ENABLED")
                    .unwrap_or(false),
                log_file: get_env_var("LOG_FILE"),
            },
        };

        // 验证配置
        config.validate()?;

        info!("配置加载完成，环境: {}", config.environment);
        Ok(config)
    }

    /// 验证配置的有效性
    fn validate(&self) -> Result<(), ConfigError> {
        // 验证端口范围
        if self.server.port == 0 || self.server.port > 65535 {
            return Err(ConfigError::ValidationError {
                message: format!("服务器端口 {} 超出有效范围 (1-65535)", self.server.port),
            });
        }

        // 验证静态文件目录
        if self.server.static_dir.is_empty() {
            return Err(ConfigError::ValidationError {
                message: "静态文件目录不能为空".to_string(),
            });
        }

        // 验证数据库配置（如果存在）
        if let Some(db_config) = &self.database {
            if db_config.url.is_empty() {
                return Err(ConfigError::ValidationError {
                    message: "数据库URL不能为空".to_string(),
                });
            }

            if db_config.max_connections == 0 {
                return Err(ConfigError::ValidationError {
                    message: "数据库最大连接数必须大于0".to_string(),
                });
            }
        }

        // 验证GitHub Token（生产环境必需）
        if self.environment == Environment::Production 
            && self.external_api.github_token.is_none() {
            warn!("生产环境建议配置GITHUB_TOKEN以避免API限制");
        }

        // 验证JWT Secret（如果启用了认证功能）
        if self.security.jwt_secret.is_some() {
            let secret = self.security.jwt_secret.as_ref().unwrap();
            if secret.len() < 32 {
                return Err(ConfigError::ValidationError {
                    message: "JWT密钥长度必须至少32个字符".to_string(),
                });
            }
        }

        // 验证CORS配置
        if self.security.cors_origins.is_empty() {
            return Err(ConfigError::ValidationError {
                message: "CORS源列表不能为空".to_string(),
            });
        }

        Ok(())
    }

    /// 检查是否为开发环境
    pub fn is_development(&self) -> bool {
        self.environment == Environment::Development
    }

    /// 检查是否为生产环境
    pub fn is_production(&self) -> bool {
        self.environment == Environment::Production
    }

    /// 检查是否为测试环境
    pub fn is_testing(&self) -> bool {
        self.environment == Environment::Testing
    }

    /// 获取服务器监听地址
    pub fn server_address(&self) -> String {
        format!("{}:{}", self.server.host, self.server.port)
    }

    /// 打印配置摘要（隐藏敏感信息）
    pub fn print_summary(&self) {
        info!("=== 应用配置摘要 ===");
        info!("环境: {}", self.environment);
        info!("服务器: {}", self.server_address());
        info!("静态文件目录: {}", self.server.static_dir);
        
        if let Some(db_config) = &self.database {
            info!("数据库: 已配置 (最大连接数: {})", db_config.max_connections);
        } else {
            info!("数据库: 未配置");
        }

        if self.external_api.github_token.is_some() {
            info!("GitHub Token: 已配置");
        } else {
            info!("GitHub Token: 未配置 (将使用匿名访问)");
        }

        info!("日志级别: {}", self.log.level);
        info!("CORS源: {:?}", self.security.cors_origins);
        info!("==================");
    }
}

/// 获取环境变量值
fn get_env_var(key: &str) -> Option<String> {
    env::var(key).ok()
}

/// 获取必需的环境变量
fn require_env_var(key: &str) -> Result<String, ConfigError> {
    env::var(key).map_err(|_| ConfigError::MissingEnvVar {
        var_name: key.to_string(),
    })
}

/// 解析环境变量为指定类型
fn parse_env_var<T>(key: &str) -> Option<T>
where
    T: std::str::FromStr,
    T::Err: std::error::Error + Send + Sync + 'static,
{
    get_env_var(key).and_then(|value| {
        value.parse::<T>().map_err(|e| {
            warn!(
                "无法解析环境变量 {}: {} (错误: {})",
                key, value, e
            );
        }).ok()
    })
}

/// 配置构建器
/// 用于测试环境或特殊场景下的手动配置构建
#[derive(Default)]
pub struct ConfigBuilder {
    environment: Option<Environment>,
    server_host: Option<String>,
    server_port: Option<u16>,
    static_dir: Option<String>,
    database_url: Option<String>,
    github_token: Option<String>,
}

impl ConfigBuilder {
    /// 创建新的配置构建器
    pub fn new() -> Self {
        Self::default()
    }

    /// 设置环境
    pub fn environment(mut self, env: Environment) -> Self {
        self.environment = Some(env);
        self
    }

    /// 设置服务器地址
    pub fn server_address(mut self, host: &str, port: u16) -> Self {
        self.server_host = Some(host.to_string());
        self.server_port = Some(port);
        self
    }

    /// 设置静态文件目录
    pub fn static_dir(mut self, dir: &str) -> Self {
        self.static_dir = Some(dir.to_string());
        self
    }

    /// 设置数据库URL
    pub fn database_url(mut self, url: &str) -> Self {
        self.database_url = Some(url.to_string());
        self
    }

    /// 设置GitHub Token
    pub fn github_token(mut self, token: &str) -> Self {
        self.github_token = Some(token.to_string());
        self
    }

    /// 构建配置
    pub fn build(self) -> Result<Config, ConfigError> {
        let config = Config {
            environment: self.environment.unwrap_or(Environment::Development),
            
            server: ServerConfig {
                host: self.server_host.unwrap_or_else(|| "127.0.0.1".to_string()),
                port: self.server_port.unwrap_or(8000),
                static_dir: self.static_dir.unwrap_or_else(|| "static".to_string()),
                request_timeout: 30,
                max_body_size: 16_777_216,
            },

            database: self.database_url.map(|url| DatabaseConfig {
                url,
                max_connections: 10,
                connect_timeout: 30,
                query_timeout: 30,
                enable_logging: false,
            }),

            external_api: ExternalApiConfig {
                github_token: self.github_token,
                github_base_url: "https://api.github.com".to_string(),
                request_timeout: 10,
                max_retries: 3,
            },

            security: SecurityConfig {
                jwt_secret: None,
                jwt_expiration: 86400,
                cors_origins: vec!["*".to_string()],
                force_https: false,
            },

            log: LogConfig {
                level: LogLevel::Info,
                format: "pretty".to_string(),
                file_logging: false,
                log_file: None,
            },
        };

        config.validate()?;
        Ok(config)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::env;

    #[test]
    fn test_environment_parsing() {
        assert_eq!("development".parse::<Environment>().unwrap(), Environment::Development);
        assert_eq!("dev".parse::<Environment>().unwrap(), Environment::Development);
        assert_eq!("production".parse::<Environment>().unwrap(), Environment::Production);
        assert_eq!("prod".parse::<Environment>().unwrap(), Environment::Production);
        
        assert!("invalid".parse::<Environment>().is_err());
    }

    #[test]
    fn test_log_level_parsing() {
        assert!(matches!("info".parse::<LogLevel>().unwrap(), LogLevel::Info));
        assert!(matches!("debug".parse::<LogLevel>().unwrap(), LogLevel::Debug));
        assert!(matches!("error".parse::<LogLevel>().unwrap(), LogLevel::Error));
        
        assert!("invalid".parse::<LogLevel>().is_err());
    }

    #[test]
    fn test_config_builder() {
        let config = ConfigBuilder::new()
            .environment(Environment::Testing)
            .server_address("localhost", 3000)
            .static_dir("test_static")
            .build()
            .unwrap();

        assert_eq!(config.environment, Environment::Testing);
        assert_eq!(config.server.host, "localhost");
        assert_eq!(config.server.port, 3000);
        assert_eq!(config.server.static_dir, "test_static");
    }

    #[test]
    fn test_config_validation() {
        // 测试无效端口
        let config = ConfigBuilder::new()
            .server_address("localhost", 0)
            .build();
        assert!(config.is_err());

        // 测试有效配置
        let config = ConfigBuilder::new()
            .server_address("localhost", 8080)
            .build();
        assert!(config.is_ok());
    }
}