# FFmpeg-Builds 性能优化文档

## win64 gpl-shared 构建时间过长问题分析与解决方案

### 问题描述

在 GitHub Actions 构建过程中，`win64 gpl-shared` 变体的构建时间显著长于其他变体：
- 其他变体：约 4-6 分钟
- win64 gpl-shared：约 90 分钟

### 问题根因分析

通过详细分析构建日志发现：

1. **主要耗时环节**：Docker 缓存导出步骤
   - 实际构建时间：~1-2 分钟
   - 缓存导出时间：~13 分钟
   - 总计约 90 分钟（包括排队等待时间）

2. **根本原因**：
   - `cache-to: type=registry,mode=max` 配置导致导出所有中间层
   - gpl-shared 变体包含更多依赖（80+ 脚本）
   - 每个依赖都有独立的 Docker 层
   - 缓存导出时需要逐个写入每个层（200+ 层）

3. **缓存导出日志分析**：
   ```
   #176 writing layer sha256:01a6f7a36e9b... 1.0s done
   #176 writing layer sha256:021e479b7585... 0.9s done
   ... (200+ 层，每层约 1 秒)
   ```

### 解决方案

#### 1. 优化缓存策略
- 将 `mode=max` 改为 `mode=min`，减少导出的层数
- 对 gpl-shared 变体禁用缓存导出，优先构建速度

#### 2. 实施的更改
```yaml
cache-to: ${{ contains(matrix.variant, 'gpl-shared') && '' || format('type=registry,mode=min,ref={0}:cache', steps.imagename.outputs.name) }}
```

### 预期效果

- win64 gpl-shared 构建时间从 90 分钟降至 20 分钟以内
- 其他变体保持现有性能，略有提升
- 减少 GitHub Actions 使用时间和成本

### 参考文档

- [Docker BuildKit 缓存模式](https://docs.docker.com/build/cache/backends/registry/)
- [GitHub Actions Docker 构建优化](https://docs.github.com/en/actions/publishing-packages/publishing-docker-images)