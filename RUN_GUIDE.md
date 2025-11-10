# 项目运行指南

## 项目简介

这是一个免费代理聚合爬取工具，主要功能包括：
- 从Telegram、GitHub、Google等多个源爬取代理订阅
- 自动注册SSPanel风格网站
- 使用Clash测试节点可用性
- 转换为多种客户端格式（Clash、Sing-box、V2Ray、Surge等）
- 将结果推送到Gist或其他存储服务

## 快速开始

### 1. 环境要求

- Python 3.8+
- Linux系统（推荐Ubuntu）
- 网络连接（需要访问GitHub、Telegram等）

### 2. 安装依赖

```bash
# 使用启动脚本（推荐）
./run.sh

# 或手动安装
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 3. 配置文件

项目提供了两个默认配置：
- `subscribe/config/config.default.json` - 基础默认配置
- `subscribe/config/config.optimized.json` - 优化配置（已启用更多爬取源）

**创建自定义配置：**
```bash
cp subscribe/config/config.optimized.json subscribe/config/config.json
# 然后编辑config.json，填写您的配置
```

**主要配置项：**
- `domains`: 要自动注册和续期的机场域名
- `crawl`: 爬取源配置（Telegram、GitHub、Google等）
- `groups`: 代理分组配置
- `storage`: 存储配置（Gist、Pastebin等）

### 4. 运行项目

使用启动脚本：

```bash
# 查看帮助
./run.sh --help

# 使用默认配置运行
./run.sh

# 仅检查已有代理的存活性
./run.sh --check

# 使用100个线程运行
./run.sh --threads 100

# 使用自定义配置
./run.sh --config subscribe/config/config.json

# 不显示进度条（适合后台运行）
./run.sh --invisible

# 设置超时时间（毫秒）
./run.sh --timeout 3000
```

或直接使用Python：

```bash
# 激活虚拟环境
source venv/bin/activate

# 运行主程序
python subscribe/process.py --help

# 使用配置文件运行
python subscribe/process.py --server file:///path/to/config.json

# 仅检查代理
python subscribe/process.py --check --num 50
```

## 使用场景

### 场景1: 爬取公开代理

如果您只想爬取公开的免费代理：

1. 使用`config.optimized.json`配置（已启用GitHub和pages爬取）
2. 运行：`./run.sh --config subscribe/config/config.optimized.json`

### 场景2: 管理机场订阅

如果您有多个机场订阅需要管理：

1. 在`config.json`的`domains`中配置机场信息
2. 配置`storage`部分，设置结果推送到Gist
3. 运行：`./run.sh`

### 场景3: 定期检查代理

设置定时任务定期检查代理可用性：

```bash
# 添加到crontab
0 */6 * * * cd /path/to/project && ./run.sh --check --invisible
```

## 高级配置

### 爬取源配置

**Telegram:**
```json
"telegram": {
  "enable": true,
  "pages": 5,
  "users": {
    "channel_name": {
      "include": "",
      "exclude": "",
      "push_to": []
    }
  }
}
```

**GitHub:**
```json
"github": {
  "enable": true,
  "pages": 2,
  "exclude": "spam_keyword",
  "spams": ["bad_repo"]
}
```

**自定义页面:**
```json
"pages": [
  {
    "enable": true,
    "url": "https://example.com/proxy.txt",
    "include": "vmess|ss|trojan",
    "exclude": "expired"
  }
]
```

### 存储配置

**GitHub Gist:**
```json
"storage": {
  "engine": "gist",
  "items": {
    "xxx-clash": {
      "username": "your_github_username",
      "fileid": "gist_file_id"
    }
  }
}
```

## 故障排查

### 问题1: 依赖安装失败

```bash
# 更新pip
pip install --upgrade pip

# 使用国内镜像
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
```

### 问题2: 网络连接问题

如果在中国大陆使用，某些源可能无法访问：
- 可以禁用Google和Telegram爬取
- 使用代理：设置`http_proxy`和`https_proxy`环境变量

### 问题3: Clash或Subconverter缺失

```bash
# 检查二进制文件
ls -la clash/
ls -la subconverter/

# 下载缺失的二进制文件
# 从GitHub releases下载对应平台的版本
```

## 项目结构

```
.
├── subscribe/          # 主程序包
│   ├── config/         # 配置文件目录
│   ├── process.py      # 主入口（推荐）
│   ├── collect.py      # 简易入口
│   ├── crawl.py        # 爬取模块
│   ├── workflow.py     # 工作流
│   └── ...
├── clash/              # Clash二进制和配置
├── subconverter/       # Subconverter二进制和配置
├── tools/              # 辅助工具
├── cmd/                # Shell脚本
├── run.sh              # 启动脚本（新增）
└── requirements.txt    # Python依赖
```

## 参考资料

- 入口文件：`subscribe/process.py`（推荐）或`subscribe/collect.py`
- 配置示例：`subscribe/config/config.default.json`
- 优化脚本：`optimize_proxy_fetch.sh`

## 注意事项

⚠️ **免责声明**
- 本项目仅用于学习爬虫技术
- 请勿用于违法活动
- 禁止用于任何盈利活动
- 对一切非法使用产生的后果，作者概不负责

## License

详见 [LICENSE](LICENSE) 文件
