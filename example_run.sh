#!/bin/bash

# 这是一个示例脚本，展示如何运行代理爬取项目
# 你可以根据自己的需求修改参数

set -e

echo "=================================="
echo "  代理爬取项目运行示例"
echo "=================================="
echo ""

# 项目目录
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# 创建输出目录
mkdir -p output

# 设置环境变量
export LOCAL_BASEDIR="$PROJECT_DIR/output"

echo "示例1: 使用demo配置运行（推荐新手）"
echo "命令: ./run.sh --config subscribe/config/config.demo.json --threads 10"
echo ""
read -p "是否运行? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./run.sh --config subscribe/config/config.demo.json --threads 10
    echo ""
    echo "结果已保存到: $LOCAL_BASEDIR/"
    ls -lh "$LOCAL_BASEDIR/"
fi

echo ""
echo "=================================="
echo ""

echo "示例2: 仅检查代理可用性"
echo "命令: ./run.sh --check --threads 20"
echo ""
echo "注意: 这个命令需要已有配置文件和爬取的代理"
echo ""
read -p "是否运行? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./run.sh --check --threads 20
fi

echo ""
echo "=================================="
echo ""

echo "示例3: 后台运行并记录日志"
echo "命令: nohup ./run.sh --config config.json --invisible --threads 50 > crawler.log 2>&1 &"
echo ""
echo "这个命令会在后台运行，日志保存到 crawler.log"
echo ""
read -p "是否运行? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    nohup ./run.sh --config subscribe/config/config.demo.json --invisible --threads 50 > crawler.log 2>&1 &
    echo "程序已在后台运行，PID: $!"
    echo "查看日志: tail -f crawler.log"
    echo "停止程序: kill $!"
fi

echo ""
echo "=================================="
echo "更多用法请查看:"
echo "  ./run.sh --help"
echo "  cat QUICK_START.md"
echo "=================================="
