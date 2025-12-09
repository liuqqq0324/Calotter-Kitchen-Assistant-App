#!/bin/bash
# 安装训练所需的 Python 依赖包

set -e

echo "=========================================="
echo "安装 YOLOv8 训练依赖包"
echo "=========================================="
echo ""

# 检查 Python 版本
echo "检查 Python 版本..."
python3 --version
echo ""

# 创建虚拟环境（如果不存在）
if [ ! -d "venv" ]; then
    echo "创建虚拟环境..."
    python3 -m venv venv
    echo "✅ 虚拟环境创建成功"
else
    echo "✅ 虚拟环境已存在"
fi
echo ""

# 激活虚拟环境并安装依赖
echo "激活虚拟环境并安装依赖包..."
source venv/bin/activate

echo "升级 pip..."
python -m pip install --upgrade pip

echo ""
echo "安装依赖包（这可能需要几分钟）..."
python -m pip install -r ai-engine/requirements.txt

echo ""
echo "=========================================="
echo "✅ 依赖安装完成！"
echo "=========================================="
echo ""
echo "验证安装..."
python -c "import ultralytics; import torch; print('✅ ultralytics 版本:', ultralytics.__version__); print('✅ torch 版本:', torch.__version__); print('✅ CUDA 可用:', torch.cuda.is_available()); print('✅ MPS 可用:', torch.backends.mps.is_available() if hasattr(torch.backends, 'mps') else False)"
echo ""
echo "=========================================="
echo "使用方法："
echo "1. 激活虚拟环境: source venv/bin/activate"
echo "2. 运行训练: python train.py --data \"training datasets/personal chef.v1i.yolov8/data.yaml\" --epochs 50"
echo "=========================================="

