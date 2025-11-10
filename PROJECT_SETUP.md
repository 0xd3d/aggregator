# 项目设置完成总结

## 已完成的工作

为了让这个代理爬取项目更容易运行，我们完成了以下工作：

### 1. 环境配置
- ✅ 创建并配置Python虚拟环境（venv）
- ✅ 安装所有必需的依赖包（PyYAML、tqdm、geoip2、pycryptodomex、fofa-hack）
- ✅ 设置可执行文件权限（clash和subconverter二进制文件）

### 2. 启动脚本
创建了 `run.sh` 脚本，提供便捷的运行方式：

**特性：**
- 自动创建和激活虚拟环境
- 自动安装依赖
- 彩色日志输出
- 灵活的命令行参数
- 完整的帮助信息

**用法：**
```bash
./run.sh --help                              # 查看帮助
./run.sh --config config.json               # 使用配置运行
./run.sh --check --threads 100              # 检查代理
./run.sh --invisible                        # 后台运行
```

### 3. 配置文件
创建了 `config.demo.json` 演示配置：

**特点：**
- 最小化配置，便于理解
- 启用GitHub和pages爬取源
- 使用本地存储（不需要额外配置）
- 包含完整的配置结构示例

**位置：** `subscribe/config/config.demo.json`

### 4. 文档
创建了三个详细的文档：

#### QUICK_START.md
- 完整的快速开始指南
- 环境准备说明
- 配置文件详解
- 常见问题解答
- 高级用法示例

#### RUN_GUIDE.md
- 详细的运行指南
- 项目结构说明
- 使用场景示例
- 故障排查指南

#### example_run.sh
- 交互式示例脚本
- 展示三种常见使用场景
- 新手友好

### 5. 代码修复
修复了一个Python 3兼容性问题：
- **文件：** `subscribe/process.py`
- **问题：** `dict.values()[0]` 在Python 3中不可用
- **修复：** 改为 `list(dict.values())[0]`

### 6. README更新
更新了主README文件，添加了：
- 快速开始部分
- 文档链接
- 启动脚本说明

## 项目结构

```
project/
├── run.sh                    # 主启动脚本（新增）⭐
├── example_run.sh           # 示例运行脚本（新增）⭐
├── QUICK_START.md           # 快速开始指南（新增）⭐
├── RUN_GUIDE.md             # 详细运行指南（新增）⭐
├── PROJECT_SETUP.md         # 本文件（新增）⭐
├── README.md                # 项目说明（已更新）
├── requirements.txt         # Python依赖
├── venv/                    # 虚拟环境（已创建）
├── output/                  # 输出目录（已创建）
├── subscribe/
│   ├── config/
│   │   ├── config.default.json    # 默认配置
│   │   ├── config.optimized.json  # 优化配置
│   │   └── config.demo.json       # 演示配置（新增）⭐
│   ├── process.py           # 主入口（已修复bug）⭐
│   └── ...
├── clash/                   # Clash二进制文件
├── subconverter/           # Subconverter二进制文件
└── ...
```

## 如何使用

### 第一次运行

1. **查看帮助**
   ```bash
   ./run.sh --help
   ```

2. **使用demo配置测试**
   ```bash
   export LOCAL_BASEDIR=/home/engine/project/output
   ./run.sh --config subscribe/config/config.demo.json --threads 10
   ```

3. **查看结果**
   ```bash
   ls -lh output/
   ```

### 日常使用

1. **创建自己的配置**
   ```bash
   cp subscribe/config/config.demo.json subscribe/config/config.json
   # 编辑 config.json
   ```

2. **运行程序**
   ```bash
   ./run.sh --config subscribe/config/config.json
   ```

3. **定时任务**
   ```bash
   # 添加到crontab
   0 */6 * * * cd /path/to/project && ./run.sh --invisible >> /tmp/proxy.log 2>&1
   ```

### 进阶使用

1. **使用GitHub Gist存储**
   - 修改配置文件中的`storage.engine`为`gist`
   - 配置GitHub token：`export PUSH_TOKEN=your_token`
   - 运行程序

2. **自定义爬取源**
   - 在`crawl.pages`中添加自己的URL
   - 设置过滤规则（include/exclude）
   - 运行程序

3. **管理多个机场订阅**
   - 在`domains`中配置机场信息
   - 配置自动注册和续期参数
   - 运行程序

## 常用命令

```bash
# 安装依赖（首次）
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 查看帮助
./run.sh --help
python subscribe/process.py --help

# 测试运行
./run.sh --config subscribe/config/config.demo.json --threads 10

# 后台运行
nohup ./run.sh --invisible > crawler.log 2>&1 &

# 查看日志
tail -f crawler.log

# 停止后台进程
pkill -f "python subscribe/process.py"

# 查看输出结果
ls -lh output/
cat output/demo-clash.yaml
```

## 环境变量

```bash
# 配置文件路径
export SUBSCRIBE_CONF=/path/to/config.json

# 本地输出目录（使用local存储引擎时需要）
export LOCAL_BASEDIR=/path/to/output

# Push token（使用gist等远程存储时需要）
export PUSH_TOKEN=your_github_token

# 网络代理（如果需要）
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
```

## 注意事项

### ⚠️ 网络要求
- 项目需要访问GitHub、Telegram等网站
- 在中国大陆可能需要配置代理
- 可以禁用不可用的爬取源

### ⚠️ 系统要求
- Python 3.8+
- 至少1GB内存
- 建议使用Linux系统

### ⚠️ 配置要求
- 使用本地存储时必须设置`LOCAL_BASEDIR`环境变量
- 使用远程存储时必须设置`PUSH_TOKEN`环境变量
- 配置文件必须通过JSON验证

### ⚠️ 法律声明
- 仅用于学习目的
- 请勿用于违法活动
- 禁止用于盈利活动

## 故障排查

### 问题1: 提示"cannot found any valid config"
**原因：** 配置文件验证失败

**检查：**
1. `storage.items`中的每个item必须有`fileid`（本地存储）
2. `groups.targets`中的名称必须在`storage.items`中存在
3. 配置文件JSON格式正确

### 问题2: 爬取失败
**原因：** 网络问题

**解决：**
1. 检查网络连接
2. 尝试使用代理
3. 禁用不可用的爬取源

### 问题3: 内存不足
**原因：** 同时处理太多节点

**解决：**
1. 减少线程数：`--threads 20`
2. 增加超时：`--timeout 10000`

## 获取更多帮助

- 📖 [快速开始指南](QUICK_START.md)
- 📖 [详细运行指南](RUN_GUIDE.md)
- 💡 运行示例脚本：`./example_run.sh`
- 🔧 运行诊断脚本：`./optimize_proxy_fetch.sh`
- 💬 查看代码中的注释和文档

## 下一步

1. ✅ 项目已经可以运行
2. 📝 根据需求自定义配置文件
3. 🚀 运行程序并测试
4. 📊 查看和使用生成的代理
5. ⏰ 可选：设置定时任务

祝使用愉快！🎉
