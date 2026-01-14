"""
YOLOv8 训练脚本
用于训练自定义目标检测模型

使用方法:
    python train.py

配置说明:
    - 修改 data.yaml 中的路径和类别信息
    - 调整训练参数（epochs, batch, imgsz 等）
    - 根据硬件配置调整 device 参数
"""

from ultralytics import YOLO


def main():
    """
    主训练函数
    """
    print("=" * 60)
    print("YOLOv8 训练脚本")
    print("=" * 60)

    # 1. 加载模型
    # yolov8n.pt 是预训练权重，会自动下载
    # 可选模型: yolov8n.pt (nano), yolov8s.pt (small), yolov8m.pt (medium), 
    #          yolov8l.pt (large), yolov8x.pt (xlarge)
    print("\n[1/3] 加载预训练模型...")
    model = YOLO('yolov8n.pt')  # 使用 nano 版本（最小最快）
    print("✅ 模型加载成功")

    # 2. 开始训练
    print("\n[2/3] 开始训练...")
    print("训练参数:")
    print("  - 数据文件: dataset/data.yaml")
    print("  - 训练轮数: 100")
    print("  - 图片大小: 640")
    print("  - 批次大小: 16")
    print("  - 设备: 自动检测 (优先使用 GPU)")
    print("-" * 60)

    results = model.train(
        data='dataset/data.yaml',  # 指向 data.yaml 文件的路径
        epochs=100,  # 训练轮数，通常 50-100 起步
        imgsz=640,  # 图片大小，Roboflow下载时通常是 640，保持一致即可
        batch=16,  # 批次大小，根据显存调整（GPU: 16-32, CPU: 4-8）
        device=0,  # 0 表示使用第一块 GPU，'cpu' 表示使用 CPU，None 表示自动检测
        name='cooking_gesture_model',  # 训练结果保存的文件夹名称
        patience=50,  # 早停耐心值（如果50轮没有改善就停止）
        save=True,  # 保存检查点
        plots=True,  # 生成训练曲线图
        val=True,  # 在训练过程中进行验证
    )

    print("\n[3/3] 训练完成！")
    print("=" * 60)
    print("训练结果保存在: runs/detect/cooking_gesture_model/")
    print("最佳权重: runs/detect/cooking_gesture_model/weights/best.pt")
    print("最终权重: runs/detect/cooking_gesture_model/weights/last.pt")
    print("=" * 60)


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️ 训练被用户中断")
    except Exception as e:
        print(f"\n\n❌ 训练出错: {e}")
        print("\n常见问题排查:")
        print("1. 检查 dataset/data.yaml 中的路径是否正确")
        print("2. 如果显存不足，请减小 batch 参数（例如改为 8 或 4）")
        print("3. 如果没有 GPU，请将 device 参数改为 'cpu'")
        raise

