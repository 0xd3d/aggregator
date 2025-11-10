#!/bin/bash

# 代理聚合爬取项目启动脚本
# 作者: wzdnzd
# 项目主要功能: 爬取免费代理订阅，自动测试并转换格式

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 项目目录
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查Python
if ! command -v python3 &> /dev/null; then
    log_error "Python 3 未安装，请先安装Python 3"
    exit 1
fi

log_info "Python版本: $(python3 --version)"

# 激活或创建虚拟环境
if [ ! -d "venv" ]; then
    log_info "创建虚拟环境..."
    python3 -m venv venv
fi

log_info "激活虚拟环境..."
source venv/bin/activate

# 安装依赖
log_info "检查并安装依赖..."
if ! pip show PyYAML &> /dev/null; then
    log_info "安装依赖包..."
    pip install -r requirements.txt
else
    log_info "依赖包已安装"
fi

# 检查配置文件
if [ ! -f "subscribe/config/config.json" ]; then
    log_warn "未找到config.json，使用优化配置文件..."
    CONFIG_FILE="subscribe/config/config.optimized.json"
else
    CONFIG_FILE="subscribe/config/config.json"
    log_info "使用自定义配置文件"
fi

# 设置二进制文件权限
if [ -f "clash/clash-linux-amd" ]; then
    chmod +x clash/clash-linux-amd
    log_info "设置Clash执行权限"
fi

if [ -f "subconverter/subconverter-linux-amd" ]; then
    chmod +x subconverter/subconverter-linux-amd
    log_info "设置Subconverter执行权限"
fi

# 解析命令行参数
MODE="default"
CHECK_ONLY=false
NUM_THREADS=50
INVISIBLE=false
TIMEOUT=5000

while [[ $# -gt 0 ]]; do
    case $1 in
        --check)
            CHECK_ONLY=true
            shift
            ;;
        --threads)
            NUM_THREADS="$2"
            shift 2
            ;;
        --invisible)
            INVISIBLE=true
            shift
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        --help)
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --check           仅检查代理是否存活"
            echo "  --threads NUM     线程数量 (默认: 50)"
            echo "  --invisible       不显示进度条"
            echo "  --timeout MS      超时时间（毫秒）(默认: 5000)"
            echo "  --config FILE     配置文件路径"
            echo "  --help            显示帮助信息"
            echo ""
            echo "示例:"
            echo "  $0                                    # 使用默认配置运行"
            echo "  $0 --check                            # 仅检查代理"
            echo "  $0 --threads 100                      # 使用100个线程"
            echo "  $0 --config myconfig.json             # 使用自定义配置"
            exit 0
            ;;
        *)
            log_error "未知选项: $1"
            log_info "使用 --help 查看帮助"
            exit 1
            ;;
    esac
done

# 构建运行命令
CMD="python subscribe/process.py"

if [ "$CHECK_ONLY" = true ]; then
    CMD="$CMD --check"
fi

if [ "$INVISIBLE" = true ]; then
    CMD="$CMD --invisible"
fi

CMD="$CMD --num $NUM_THREADS"
CMD="$CMD --timeout $TIMEOUT"

if [ -n "$CONFIG_FILE" ] && [ -f "$CONFIG_FILE" ]; then
    log_info "使用配置文件: $CONFIG_FILE"
    CMD="$CMD --server file://$PROJECT_DIR/$CONFIG_FILE"
fi

# 打印信息
echo ""
echo "======================================"
echo "  代理聚合爬取项目"
echo "======================================"
echo ""
log_info "配置文件: $CONFIG_FILE"
log_info "线程数: $NUM_THREADS"
log_info "超时时间: ${TIMEOUT}ms"
log_info "仅检查模式: $CHECK_ONLY"
echo ""
log_info "开始运行..."
echo ""

# 运行程序
eval "$CMD"

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    log_info "运行完成！"
else
    log_error "运行失败，退出码: $EXIT_CODE"
fi

exit $EXIT_CODE
