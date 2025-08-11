# Rust 版本兼容性修复记录

## 问题描述

在 GitHub Actions 云编译过程中遇到以下错误：

```
error: failed to download replaced source registry `crates-io`

Caused by:
  failed to parse manifest at `/home/runner/.cargo/registry/src/index.crates.io-6f17d22bba15001f/base64ct-1.8.0/Cargo.toml`

Caused by:
  feature `edition2024` is required

  The package requires the Cargo feature called `edition2024`, but that feature is not stabilized in this version of Cargo (1.75.0 (1d8b05cdd 2023-11-20)).
```

## 问题原因

- GitHub Actions 使用的 Rust 版本过老 (1.75.0)
- 某些依赖包（如 `base64ct-1.8.0`）需要更新版本的 Rust 才能支持 `edition2024` 特性
- Cargo 1.75.0 不支持 `edition2024`

## 解决方案

### 1. 更新 GitHub Actions 工作流

#### 文件：`.github/workflows/ubuntu-cross-compile.yml`
```yaml
- name: 🦀 安装 Rust
  uses: dtolnay/rust-toolchain@stable
  with:
    toolchain: '1.82'  # 从默认 stable 改为 1.82
    targets: x86_64-unknown-linux-gnu
    components: rustfmt, clippy
```

#### 文件：`.github/workflows/deploy.yml`
```yaml
env:
  NODE_VERSION: "18"
  RUST_VERSION: "1.82"  # 从 1.75 升级到 1.82
```

### 2. 更新依赖锁文件

运行以下命令更新 Cargo.lock：
```bash
cd backend
cargo update
```

## 版本要求

- **最低 Rust 版本**: 1.80+ (支持 edition2024)
- **推荐版本**: 1.82+ (稳定支持)
- **当前本地版本**: 1.88.0 ✅

## 验证步骤

1. **本地验证**:
   ```bash
   cd backend
   cargo check    # 检查编译
   cargo build    # 完整构建
   ```

2. **CI 验证**:
   - 推送代码到 GitHub
   - 检查 Actions 构建是否成功

## 相关文档

- [Edition 2024 状态](https://doc.rust-lang.org/nightly/cargo/reference/unstable.html#edition-2024)
- [Rust 版本发布时间表](https://forge.rust-lang.org/infra/channel-layout.html)

## 修复时间

- 修复日期: 2025年8月12日
- 修复版本: 将 CI 中的 Rust 从 1.75 升级到 1.82

## 注意事项

- 这个修复确保了项目与最新 Rust 生态系统的兼容性
- 1.82 版本提供了对 edition2024 的稳定支持
- 本地开发环境 (Rust 1.88.0) 完全兼容这些更改
