# 代理拉取优化指南

## 问题诊断结果

根据诊断，您的系统状况如下：

### ✅ 网络连接正常
- GitHub: ✓ 连接正常 (0.07s)
- Google: ✓ 连接正常 (0.16s) 
- Telegram: ✓ 连接正常 (1.15s)
- HTTP测试: ✓ 连接正常 (0.27s)

### ✅ 基础环境就绪
- Python依赖已安装
- 配置文件可以正常加载
- 爬虫功能已启用

## 主要问题分析

### 1. 配置问题
- **Google搜索源被禁用**: 默认配置中Google爬虫被禁用
- **缺少实际的订阅源**: domains配置为空
- **存储配置不完整**: GitHub Gist配置缺失

### 2. 使用方式问题
- 使用了`collect.py`而不是推荐的`process.py`
- 配置文件路径不正确

## 优化方案

### 方案一：快速修复（推荐）

```bash
# 1. 复制优化配置
cp subscribe/config/config.optimized.json subscribe/config/config.json

# 2. 运行优化版本
python3 subscribe/process.py --config subscribe/config/config.optimized.json
```

### 方案二：手动配置

#### 1. 启用更多爬虫源
编辑 `subscribe/config/config.json`:

```json
{
  "crawl": {
    "enable": true,
    "google": {
      "enable": true,
      "qdr": 7,
      "limits": 50
    },
    "github": {
      "enable": true,
      "pages": 5
    },
    "telegram": {
      "enable": true,
      "pages": 10
    }
  }
}
```

#### 2. 添加订阅源
```json
{
  "domains": [
    {
      "name": "示例订阅",
      "sub": ["https://example.com/api/v1/client/subscribe?token=your_token"],
      "enable": true,
      "liveness": true
    }
  ]
}
```

#### 3. 配置存储
```json
{
  "storage": {
    "engine": "gist",
    "items": {
      "proxies-clash": {
        "username": "your_github_username",
        "folderid": "your_gist_id",
        "fileid": "your_file_id"
      }
    }
  }
}
```

### 方案三：环境变量配置

```bash
export GIST_PAT="your_github_personal_access_token"
export GIST_LINK="username/gist_id"
export WORKFLOW_MODE="0"
```

## 运行命令对比

### ❌ 错误方式
```bash
python3 subscribe/collect.py  # 功能有限
```

### ✅ 正确方式
```bash
# 基础运行
python3 subscribe/process.py

# 指定配置文件
python3 subscribe/process.py --config subscribe/config/config.json

# 完整流程（推荐）
python3 subscribe/process.py --config subscribe/config/config.optimized.json
```

## 高级优化

### 1. 网络优化
如果在中国大陆使用，可能需要：

```bash
# 设置代理（如果需要）
export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"

# 或者使用SOCKS5代理
export http_proxy="socks5://127.0.0.1:1080"
export https_proxy="socks5://127.0.0.1:1080"
```

### 2. 超时和重试优化
```json
{
  "crawl": {
    "threshold": 3,
    "config": {
      "timeout": 30,
      "retry": 5
    }
  }
}
```

### 3. 并发优化
```json
{
  "crawl": {
    "threads": 20
  }
}
```

## 验证结果

运行后检查以下文件：
- `workflow.log` - 查看运行日志
- GitHub Gist - 检查推送结果
- 本地生成的配置文件

## 常见问题解决

### 1. FOFA搜索失败
```bash
pip install fofa-hack
```

### 2. GitHub API限制
- 配置GitHub Token
- 降低请求频率

### 3. Telegram访问失败
- 配置代理
- 使用镜像源

### 4. 存储失败
- 检查Gist配置
- 验证Token权限

## 监控和调试

### 查看详细日志
```bash
tail -f workflow.log
```

### 调试模式
```bash
python3 subscribe/process.py --debug
```

### 测试单个源
```bash
python3 optimize_proxy.py --test-connectivity
```

## 总结

您的系统基础环境良好，主要问题是配置不完整。建议：

1. **立即执行**: 使用提供的优化配置
2. **长期优化**: 根据需要调整源和存储配置
3. **监控运行**: 定期检查日志和结果

这样可以显著提高代理拉取的成功率和数量。