"""
YOLOv8 模型验证脚本
用于评估训练好的模型在验证集上的表现

使用方法:
    python validate.py --weights <模型权重路径>
"""

import argparse
from pathlib import Path
from ultralytics import YOLO


def main():
    parser = argparse.ArgumentParser(description='YOLOv8 模型验证脚本')
    parser.add_argument(
        '--weights',
        type=str,
        default='runs/detect/ingredient_detection_v1/weights/best.pt',
        help='模型权重文件路径'
    )
    parser.add_argument(
        '--data',
        type=str,
        default='dataset/data.yaml',
        help='数据集配置文件路径'
    )
    parser.add_argument(
        '--imgsz',
        type=int,
        default=512,
        help='图片大小（需与 Roboflow/训练时 imgsz 一致）'
    )
    parser.add_argument(
        '--device',
        type=str,
        default='0',
        help='设备：0 (GPU), cpu, 或 None (自动检测)'
    )

    args = parser.parse_args()

    print("=" * 60)
    print("YOLOv8 模型验证")
    print("=" * 60)
    print(f"模型权重: {args.weights}")
    print(f"数据集配置: {args.data}")
    print("-" * 60)

    # 检查文件是否存在
    if not Path(args.weights).exists():
        print(f"❌ 错误: 找不到模型权重文件: {args.weights}")
        return

    if not Path(args.data).exists():
        print(f"❌ 错误: 找不到数据集配置文件: {args.data}")
        return

    # 加载模型
    print("\n[1/2] 加载模型...")
    model = YOLO(args.weights)
    print("✅ 模型加载成功")

    # 进行验证
    print("\n[2/2] 开始验证...")
    device = int(args.device) if args.device.isdigit() else args.device
    metrics = model.val(
        data=args.data,
        imgsz=args.imgsz,
        device=device,
    )

    print("\n✅ 验证完成！")
    print("=" * 60)
    print("验证指标:")
    print(f"  mAP50: {metrics.box.map50:.4f}")
    print(f"  mAP50-95: {metrics.box.map:.4f}")
    print(f"  精确度 (Precision): {metrics.box.mp:.4f}")
    print(f"  召回率 (Recall): {metrics.box.mr:.4f}")
    print("=" * 60)


if __name__ == '__main__':
    main()

