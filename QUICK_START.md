# 快速开始指南

## 项目简介

这是一个强大的免费代理聚合爬取工具，主要功能包括：

1. **多源爬取**：从Telegram、GitHub、Google等多个源爬取代理订阅
2. **节点测试**：使用Clash自动测试节点可用性
3. **格式转换**：支持转换为Clash、Sing-box、V2Ray、Surge等多种格式
4. **自动注册**：自动注册SSPanel风格机场并续期
5. **结果推送**：支持推送到GitHub Gist、Pastebin等多种存储平台

## 环境准备

### 系统要求
- Linux系统（推荐Ubuntu 20.04+）
- Python 3.8+
- 至少1GB内存

### 安装依赖

项目已创建便捷的启动脚本，会自动处理依赖安装：

```bash
# 赋予执行权限
chmod +x run.sh

# 查看帮助
./run.sh --help
```

或手动安装：

```bash
# 创建虚拟环境
python3 -m venv venv

# 激活虚拟环境
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt
```

## 快速运行

### 方法1: 使用启动脚本（推荐）

```bash
# 使用demo配置运行（测试用）
./run.sh --config subscribe/config/config.demo.json

# 使用优化配置运行（启用更多爬取源）
./run.sh --config subscribe/config/config.optimized.json

# 仅检查代理存活性
./run.sh --check

# 自定义线程数
./run.sh --threads 100

# 后台运行（不显示进度条）
./run.sh --invisible --threads 50 > output.log 2>&1 &
```

### 方法2: 直接使用Python

```bash
# 激活虚拟环境
source venv/bin/activate

# 设置输出目录（可选）
export LOCAL_BASEDIR=/home/engine/project/output

# 运行程序
python subscribe/process.py \
  --server subscribe/config/config.demo.json \
  --num 50 \
  --timeout 5000

# 查看完整参数
python subscribe/process.py --help
```

## 配置文件说明

项目提供了几个配置文件模板：

### 1. config.demo.json（演示配置）
- 最小化配置
- 仅启用GitHub和一个pages源
- 适合快速测试和理解项目结构
- 结果保存到本地文件

### 2. config.optimized.json（优化配置）
- 启用多个爬取源（GitHub、Google、pages）
- 适合实际使用
- 需要配置存储引擎

### 3. config.default.json（默认配置）
- 完整的配置示例
- 包含所有可用选项
- 需要根据实际情况修改

## 创建自定义配置

### 步骤1: 复制模板

```bash
cp subscribe/config/config.demo.json subscribe/config/config.json
```

### 步骤2: 编辑配置

```json
{
  "domains": [],  // 机场域名配置（可选）
  "crawl": {      // 爬取源配置
    "enable": true,
    "github": {
      "enable": true,
      "pages": 2    // 爬取GitHub的页数
    },
    "pages": [      // 自定义页面源
      {
        "enable": true,
        "url": "https://example.com/proxy.txt",
        "include": "vmess|ss|trojan",
        "exclude": ""
      }
    ]
  },
  "groups": {     // 代理分组
    "mygroup": {
      "emoji": true,
      "targets": {
        "clash": "mygroup-clash"
      }
    }
  },
  "storage": {    // 存储配置
    "engine": "local",
    "items": {
      "mygroup-clash": {
        "fileid": "proxies.yaml"
      }
    }
  }
}
```

### 步骤3: 运行

```bash
./run.sh --config subscribe/config/config.json
```

## 存储引擎配置

### 本地存储（local）

最简单的方式，结果保存到本地文件：

```json
{
  "storage": {
    "engine": "local",
    "items": {
      "myproxies": {
        "fileid": "proxies.yaml",
        "folderid": "output"  // 可选，子目录
      }
    }
  }
}
```

设置输出目录：
```bash
export LOCAL_BASEDIR=/path/to/output
./run.sh --config myconfig.json
```

### GitHub Gist

将结果推送到GitHub Gist：

```json
{
  "storage": {
    "engine": "gist",
    "items": {
      "myproxies": {
        "username": "your_github_username",
        "gistid": "your_gist_id",
        "filename": "proxies.yaml"
      }
    }
  }
}
```

设置GitHub Token：
```bash
export PUSH_TOKEN="your_github_token"
./run.sh --config myconfig.json
```

### 其他支持的引擎

- **imperialb**: Imperial Bin
- **drift**: Paste Drift
- **pastefy**: Pastefy
- **pastegg**: Paste.gg

每种引擎的配置方式可参考 `config.default.json`

## 爬取源配置

### GitHub爬取

从GitHub搜索代理相关仓库：

```json
"github": {
  "enable": true,
  "pages": 3,           // 爬取页数
  "exclude": "spam",    // 排除关键词
  "spams": ["badrepo"], // 黑名单仓库
  "push_to": []
}
```

### 自定义页面

从指定URL爬取：

```json
"pages": [
  {
    "enable": true,
    "url": "https://raw.githubusercontent.com/user/repo/file.txt",
    "include": "vmess|ss|trojan",
    "exclude": "expired",
    "config": {
      "rename": "",
      "liveness": true  // 检查节点存活性
    }
  }
]
```

### Telegram频道（需要配置）

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

## 常见问题

### 1. 提示"cannot found any valid config"

**原因**：配置文件验证失败

**解决方案**：
- 确保`storage.items`中有对应的配置
- 确保每个item都有必需的字段（如local需要`fileid`）
- 确保`groups.targets`中的名称在`storage.items`中存在

### 2. 爬取失败或结果为空

**原因**：网络问题或源不可用

**解决方案**：
- 检查网络连接
- 尝试使用代理
- 减少爬取页数
- 禁用不可用的源

### 3. Clash或Subconverter错误

**原因**：二进制文件缺失或无执行权限

**解决方案**：
```bash
# 检查文件
ls -la clash/clash-linux-amd
ls -la subconverter/subconverter-linux-amd

# 添加执行权限
chmod +x clash/clash-linux-amd
chmod +x subconverter/subconverter-linux-amd
```

### 4. 内存不足

**原因**：同时测试过多节点

**解决方案**：
- 减少线程数：`./run.sh --threads 20`
- 增加超时时间：`./run.sh --timeout 10000`
- 分批处理节点

## 定时任务

使用cron定时运行：

```bash
# 编辑crontab
crontab -e

# 添加定时任务（每6小时运行一次）
0 */6 * * * cd /path/to/project && ./run.sh --config config.json --invisible >> /tmp/proxy-crawler.log 2>&1

# 每天凌晨2点运行
0 2 * * * cd /path/to/project && ./run.sh --check --invisible >> /tmp/proxy-check.log 2>&1
```

## 输出结果

### 本地存储

结果保存在`$LOCAL_BASEDIR`指定的目录中：

```bash
output/
├── demo-clash.yaml          # Clash配置文件
├── crawled-subs.txt         # 爬取的订阅链接
└── crawled-proxies.txt      # 爬取的单个代理节点
```

### 使用结果

1. **Clash**：直接将生成的YAML文件导入Clash客户端
2. **V2Ray/V2RayN**：使用V2Ray格式的订阅链接
3. **Sing-box**：使用生成的Sing-box配置

## 高级用法

### 环境变量

```bash
# 配置文件位置
export SUBSCRIBE_CONF=/path/to/config.json

# 本地输出目录
export LOCAL_BASEDIR=/path/to/output

# Push Token（用于Gist等）
export PUSH_TOKEN=your_token

# 工作流模式
export WORKFLOW_MODE=0
```

### 使用.env文件

创建 `.env` 文件：

```bash
SUBSCRIBE_CONF=/path/to/config.json
LOCAL_BASEDIR=/path/to/output
PUSH_TOKEN=your_github_token
```

运行时指定：

```bash
./run.sh --envrionment .env
```

## 项目结构

```
.
├── subscribe/              # 主程序包
│   ├── config/             # 配置文件目录
│   │   ├── config.default.json
│   │   ├── config.optimized.json
│   │   └── config.demo.json
│   ├── process.py          # 主入口（推荐）
│   ├── collect.py          # 简易入口
│   ├── crawl.py            # 爬取模块
│   ├── workflow.py         # 工作流
│   ├── clash.py            # Clash集成
│   ├── subconverter.py     # 格式转换
│   └── push.py             # 结果推送
├── clash/                  # Clash二进制和配置
├── subconverter/           # Subconverter二进制和配置
├── tools/                  # 辅助工具
├── cmd/                    # Shell脚本
├── run.sh                  # 启动脚本
├── requirements.txt        # Python依赖
├── RUN_GUIDE.md            # 详细运行指南
└── QUICK_START.md          # 本文件
```

## 参与贡献

欢迎提交Issue和Pull Request！

对于质量较高且普适的爬取目标，欢迎在Issues中提出。

## 免责声明

⚠️ **重要**

- 本项目仅用于学习爬虫技术
- 请勿用于违法活动或有损国家利益之事
- 禁止用于任何盈利活动
- 对一切非法使用产生的后果，作者概不负责

## 获取帮助

- 查看详细文档：[RUN_GUIDE.md](RUN_GUIDE.md)
- 查看配置示例：`subscribe/config/`目录
- 运行诊断脚本：`./optimize_proxy_fetch.sh`
- 查看命令帮助：`./run.sh --help`

## License

详见 [LICENSE](LICENSE) 文件
