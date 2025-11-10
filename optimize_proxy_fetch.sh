#!/bin/bash

# 代理拉取优化脚本
# 用于诊断和优化代理拉取问题

echo "=== 代理拉取优化脚本 ==="
echo "开始诊断代理拉取问题..."

# 检查网络连接
echo "1. 检查网络连接..."
ping -c 3 8.8.8.8 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ 基础网络连接正常"
else
    echo "✗ 基础网络连接失败，请检查网络设置"
    exit 1
fi

# 检查HTTPS连接
echo "2. 检查HTTPS连接..."
curl -s --connect-timeout 10 https://www.google.com > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ HTTPS连接正常"
else
    echo "✗ HTTPS连接失败，可能存在网络限制"
fi

# 检查Telegram连接
echo "3. 检查Telegram连接..."
curl -s --connect-timeout 10 https://t.me > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Telegram连接正常"
else
    echo "✗ Telegram连接失败"
fi

# 检查GitHub连接
echo "4. 检查GitHub连接..."
curl -s --connect-timeout 10 https://github.com > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ GitHub连接正常"
else
    echo "✗ GitHub连接失败"
fi

# 检查Python依赖
echo "5. 检查Python依赖..."
cd /home/engine/project

echo "检查PyYAML..."
python3 -c "import yaml" 2>/dev/null && echo "✓ PyYAML已安装" || echo "✗ PyYAML未安装"

echo "检查tqdm..."
python3 -c "import tqdm" 2>/dev/null && echo "✓ tqdm已安装" || echo "✗ tqdm未安装"

echo "检查geoip2..."
python3 -c "import geoip2" 2>/dev/null && echo "✓ geoip2已安装" || echo "✗ geoip2未安装"

echo "检查pycryptodomex..."
python3 -c "from Crypto.Cipher import AES" 2>/dev/null && echo "✓ pycryptodomex已安装" || echo "✗ pycryptodomex未安装"

echo "检查fofa-hack..."
python3 -c "import fofa_hack" 2>/dev/null && echo "✓ fofa-hack已安装" || echo "✗ fofa-hack未安装"

# 检查配置文件
echo "6. 检查配置文件..."
if [ -f "subscribe/config/config.json" ]; then
    echo "✓ 发现自定义配置文件"
    python3 -c "import json; json.load(open('subscribe/config/config.json'))" 2>/dev/null && echo "✓ 配置文件格式正确" || echo "✗ 配置文件格式错误"
else
    echo "! 未发现自定义配置文件，将使用默认配置"
fi

# 检查二进制文件
echo "7. 检查二进制文件..."
if [ -f "clash/clash-linux-amd" ]; then
    echo "✓ Clash二进制文件存在"
    chmod +x clash/clash-linux-amd
    echo "✓ Clash文件权限已设置"
else
    echo "✗ Clash二进制文件缺失"
fi

if [ -f "subconverter/subconverter-linux-amd" ]; then
    echo "✓ Subconverter二进制文件存在"
    chmod +x subconverter/subconverter-linux-amd
    echo "✓ Subconverter文件权限已设置"
else
    echo "✗ Subconverter二进制文件缺失"
fi

# 运行测试
echo "8. 运行基础测试..."
echo "测试HTTP请求功能..."
python3 -c "
import sys
sys.path.append('subscribe')
import utils
try:
    result = utils.http_get('https://httpbin.org/ip', timeout=10)
    if result:
        print('✓ HTTP请求功能正常')
    else:
        print('✗ HTTP请求功能异常')
except Exception as e:
    print(f'✗ HTTP请求测试失败: {e}')
"

# 提供优化建议
echo ""
echo "=== 优化建议 ==="
echo "1. 网络优化："
echo "   - 确保可以访问Google、GitHub、Telegram等网站"
echo "   - 如果在中国大陆，可能需要配置代理"
echo ""
echo "2. 配置优化："
echo "   - 复制subscribe/config/config.default.json为config.json"
echo "   - 填写实际的订阅源地址"
echo "   - 配置GitHub Gist用于存储结果"
echo ""
echo "3. 依赖优化："
echo "   - 安装缺失的Python依赖：pip install -r requirements.txt"
echo "   - 确保fofa-hack正确安装用于FOFA搜索"
echo ""
echo "4. 运行优化："
echo "   - 使用process.py而不是collect.py"
echo "   - 设置环境变量WORKFLOW_MODE=0进行完整流程"
echo "   - 增加重试次数和超时时间"
echo ""
echo "=== 快速修复命令 ==="
echo "# 安装依赖"
echo "pip install -r requirements.txt"
echo ""
echo "# 复制配置文件"
echo "cp subscribe/config/config.default.json subscribe/config/config.json"
echo ""
echo "# 运行优化版本"
echo "python3 subscribe/process.py --config subscribe/config/config.optimized.json"

echo ""
echo "诊断完成！"