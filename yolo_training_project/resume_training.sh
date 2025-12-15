#!/bin/bash
# 续训脚本 - 从上次停止的地方继续训练

cd "$(dirname "$0")"

# 检查并激活虚拟环境
if [ -d "venv" ]; then
    echo "激活虚拟环境..."
    source venv/bin/activate
else
    echo "⚠️  虚拟环境不存在，请先运行 install_dependencies.sh"
    exit 1
fi

# 先执行过滤，然后续训
echo ""
echo "=========================================="
echo "检查并过滤标签数过多的文件..."
echo "=========================================="
python3 << 'EOF'
import sys
import os

# 导入过滤函数（需要导入 train.py 模块）
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from train import filter_high_label_files

# 从 args.yaml 读取 data.yaml 路径
args_file = "runs/detect/personal_chef.v1i.yolov8_train/args.yaml"
data_yaml_path = None

if os.path.exists(args_file):
    with open(args_file, 'r') as f:
        for line in f:
            if line.strip().startswith('data:'):
                data_yaml_path = line.split('data:')[1].strip()
                break

if data_yaml_path and os.path.exists(data_yaml_path):
    print(f"数据集配置文件: {data_yaml_path}")
    moved_count = filter_high_label_files(data_yaml_path, max_labels=100)
    if moved_count > 0:
        print(f"✅ 已将 {moved_count} 个标签数 >= 100 的文件移动到 toomany/ 文件夹")
    else:
        print("✅ 未发现需要过滤的文件（可能已经过滤过了）")
else:
    print(f"⚠️  无法找到 data.yaml 路径: {data_yaml_path}")
    print("   将跳过过滤步骤，直接续训")
EOF

# 使用 last.pt 检查点继续训练
echo ""
echo "=========================================="
echo "从检查点继续训练..."
echo "=========================================="
python3 << 'EOF'
from ultralytics import YOLO

# 加载上次的训练检查点
checkpoint = "runs/detect/personal_chef.v1i.yolov8_train/weights/last.pt"
print(f"检查点: {checkpoint}")

# 加载模型（会自动读取训练状态）
model = YOLO(checkpoint)

# 继续训练（resume=True 会从上次停止的 epoch 继续）
model.train(resume=True)
EOF

