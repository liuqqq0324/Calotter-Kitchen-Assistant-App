"""
YOLOv8 推理脚本
用于使用训练好的模型进行目标检测

使用方法:
    python inference.py --source <图片/视频路径> --weights <模型权重路径>
"""

import argparse
from pathlib import Path
from ultralytics import YOLO


def main():
    parser = argparse.ArgumentParser(description='YOLOv8 推理脚本')
    parser.add_argument(
        '--source',
        type=str,
        default='dataset/images/valid',
        help='输入源：图片路径、视频路径、摄像头索引（0）或目录路径'
    )
    parser.add_argument(
        '--weights',
        type=str,
        default='runs/detect/ingredient_detection_v1/weights/best.pt',
        help='模型权重文件路径'
    )
    parser.add_argument(
        '--conf',
        type=float,
        default=0.25,
        help='置信度阈值（0-1）'
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
    parser.add_argument(
        '--save',
        action='store_true',
        help='保存检测结果'
    )
    parser.add_argument(
        '--show',
        action='store_true',
        help='显示检测结果'
    )

    args = parser.parse_args()

    print("=" * 60)
    print("YOLOv8 推理脚本")
    print("=" * 60)
    print(f"模型权重: {args.weights}")
    print(f"输入源: {args.source}")
    print(f"置信度阈值: {args.conf}")
    print("-" * 60)

    # 检查权重文件是否存在
    if not Path(args.weights).exists():
        print(f"❌ 错误: 找不到模型权重文件: {args.weights}")
        print("\n请确保:")
        print("1. 已经完成模型训练")
        print("2. 权重文件路径正确")
        print("3. 默认路径: runs/detect/ingredient_detection_v1/weights/best.pt")
        return

    # 加载模型
    print("\n[1/2] 加载模型...")
    model = YOLO(args.weights)
    print("✅ 模型加载成功")

    # 进行推理
    print("\n[2/2] 开始推理...")
    device = int(args.device) if args.device.isdigit() else args.device
    results = model.predict(
        source=args.source,
        conf=args.conf,
        imgsz=args.imgsz,
        device=device,
        save=args.save,
        show=args.show,
    )

    print("\n✅ 推理完成！")
    if args.save:
        print(f"结果保存在: runs/detect/predict/")


if __name__ == '__main__':
    main()

