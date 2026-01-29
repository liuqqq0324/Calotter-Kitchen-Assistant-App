"""
YOLOv8 食材检测训练脚本
支持 Roboflow 自动下载数据集，或使用本地 dataset/data.yaml

使用方法:
    python train.py

前置操作（若使用 Roboflow 自动下载）:
    pip install roboflow ultralytics
    在下方填入 Roboflow API Key 与项目信息
"""

from ultralytics import YOLO
import os


def main():
    print("=" * 60)
    print("YOLOv8 食材检测训练 (极速版)")
    print("=" * 60)

    # ---------------------------------------------------------
    # 1. 数据配置：二选一
    # ---------------------------------------------------------
    # 方式 A：使用 Roboflow 自动下载（推荐，防路径错误）
    # 去 Roboflow 点击 Export -> Format: YOLOv8 -> Show Download Code，填入下方
    use_roboflow_download = True  # 改为 False 可改用本地 dataset/data.yaml

    if use_roboflow_download:
        try:
            from roboflow import Roboflow
            rf = Roboflow(api_key="jVSjn3RcOuVF2VubxgBt")
            project = rf.workspace("ingredientdetection-w9e8h").project("ingredients-detection-yhua")
            version = project.version(2)
            dataset = version.download("yolov8")
            data_yaml_path = f"{dataset.location}/data.yaml"
        except Exception as e:
            print(f"❌ Roboflow 下载失败: {e}")
            print("请检查 API Key 与项目名，或改为 use_roboflow_download=False 使用本地数据")
            raise
    else:
        # 方式 B：使用本地 dataset/data.yaml
        data_yaml_path = os.path.join(os.path.dirname(__file__), "dataset", "data.yaml")
        if not os.path.isfile(data_yaml_path):
            raise FileNotFoundError(f"未找到数据配置: {data_yaml_path}，请先准备 dataset 或启用 Roboflow 下载")

    print(f"\n✅ 数据集配置: {data_yaml_path}")

    # ---------------------------------------------------------
    # 2. 加载模型
    # ---------------------------------------------------------
    # yolov8n.pt 是速度最快的，适合赶时间
    model = YOLO('yolov8n.pt')

    # ---------------------------------------------------------
    # 3. 开始训练
    # ---------------------------------------------------------
    results = model.train(
        data=data_yaml_path,
        epochs=50,                      # 赶时间可用 50 轮，通常足够演示
        imgsz=512,                      # 与 Roboflow 512x512 设置一致
        batch=16,                       # 显存不足可改为 8 或 4
        device=0,
        name='ingredient_detection_v1', # 食材检测项目命名
        patience=15,                    # 早停：15 轮无提升则停止，省时间
        save=True,
        plots=True,
        val=True,
        workers=4,                      # 加快数据读取
    )

    print("\n[训练完成]")
    print("=" * 60)
    print("训练结果保存在: runs/detect/ingredient_detection_v1/")
    print("最佳权重: runs/detect/ingredient_detection_v1/weights/best.pt")
    print("最终权重: runs/detect/ingredient_detection_v1/weights/last.pt")
    print("=" * 60)


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️ 训练被用户中断")
    except Exception as e:
        print(f"\n\n❌ 训练出错: {e}")
        print("\n常见问题排查:")
        print("1. 检查 dataset/data.yaml 中的路径是否正确（或启用 Roboflow 自动下载）")
        print("2. 如果显存不足，请将 batch 改为 8 或 4")
        print("3. 如果没有 GPU，请将 device 改为 'cpu'")
        raise
