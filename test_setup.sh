#!/bin/bash

# 测试项目设置

echo "=================================="
echo "测试项目设置"
echo "=================================="
echo ""

# 测试1: 检查Python
echo "✓ 检查Python版本..."
python3 --version

# 测试2: 检查虚拟环境
echo "✓ 检查虚拟环境..."
if [ -d "venv" ]; then
    echo "  虚拟环境存在"
else
    echo "  虚拟环境不存在，创建中..."
    python3 -m venv venv
fi

# 测试3: 激活虚拟环境并检查依赖
echo "✓ 检查依赖..."
source venv/bin/activate
python -c "import yaml; import tqdm; import geoip2; print('  所有依赖已安装')"

# 测试4: 检查启动脚本
echo "✓ 检查启动脚本..."
if [ -x "run.sh" ]; then
    echo "  run.sh 可执行"
else
    echo "  run.sh 不可执行，修复中..."
    chmod +x run.sh
fi

# 测试5: 检查配置文件
echo "✓ 检查配置文件..."
if [ -f "subscribe/config/config.demo.json" ]; then
    echo "  demo配置存在"
    python -c "import json; json.load(open('subscribe/config/config.demo.json')); print('  配置文件格式正确')"
else
    echo "  配置文件不存在"
fi

# 测试6: 检查二进制文件
echo "✓ 检查二进制文件..."
if [ -f "clash/clash-linux-amd" ]; then
    echo "  Clash二进制存在"
else
    echo "  Clash二进制不存在"
fi

if [ -f "subconverter/subconverter-linux-amd" ]; then
    echo "  Subconverter二进制存在"
else
    echo "  Subconverter二进制不存在"
fi

# 测试7: 检查文档
echo "✓ 检查文档..."
for doc in README.md QUICK_START.md RUN_GUIDE.md PROJECT_SETUP.md; do
    if [ -f "$doc" ]; then
        echo "  $doc ✓"
    else
        echo "  $doc ✗"
    fi
done

echo ""
echo "=================================="
echo "设置测试完成！"
echo "=================================="
echo ""
echo "下一步："
echo "1. 查看快速开始: cat QUICK_START.md"
echo "2. 运行示例: ./example_run.sh"
echo "3. 查看帮助: ./run.sh --help"
echo ""
