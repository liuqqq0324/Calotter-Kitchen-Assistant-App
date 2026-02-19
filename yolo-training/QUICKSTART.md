# 🚀 快速开始指南

## 第一步：安装依赖

```bash
pip install -r requirements.txt
```

或者只安装核心库：

```bash
pip install ultralytics
```

## 第二步：准备数据集

1. **从 Roboflow 下载数据集**
   - 访问 [Roboflow](https://roboflow.com/)
   - 选择你的数据集
   - 导出格式选择 **YOLOv8**
   - 下载 ZIP 包

2. **解压数据集**
   ```bash
   # 将下载的 ZIP 包解压到 dataset/ 目录
   # 确保目录结构如下：
   dataset/
   ├── images/
   │   ├── train/
   │   └── valid/
   └── data.yaml
   ```

3. **修改 data.yaml**
   - 打开 `dataset/data.yaml`
   - 检查 `path`、`train`、`val` 路径是否正确
   - 修改 `nc`（类别数量）和 `names`（类别名称）

## 第三步：开始训练

```bash
python train.py
```

训练参数可以在 `train.py` 中调整：
- `epochs`: 训练轮数（默认 100）
- `batch`: 批次大小（默认 16，根据显存调整）
- `imgsz`: 图片大小（默认 640）
- `device`: 设备（0=GPU, 'cpu'=CPU）

## 第四步：查看结果

训练完成后，结果保存在：
- **最佳模型**: `runs/detect/cooking_gesture_model/weights/best.pt`
- **最终模型**: `runs/detect/cooking_gesture_model/weights/last.pt`
- **训练曲线**: `runs/detect/cooking_gesture_model/results.png`

## 第五步：使用模型进行推理

```bash
# 检测图片
python inference.py --source path/to/image.jpg --weights runs/detect/cooking_gesture_model/weights/best.pt

# 检测视频
python inference.py --source path/to/video.mp4 --weights runs/detect/cooking_gesture_model/weights/best.pt

# 使用摄像头
python inference.py --source 0 --weights runs/detect/cooking_gesture_model/weights/best.pt
```

## 第六步：验证模型

```bash
python validate.py --weights runs/detect/cooking_gesture_model/weights/best.pt
```

## ⚠️ 常见问题

### 显存不足
减小 `batch` 参数：
```python
batch=8  # 或更小
```

### 路径错误
检查 `dataset/data.yaml` 中的路径是否正确。

### 训练速度慢
- 确保使用 GPU（检查 `device=0`）
- 使用更小的模型（`yolov8n.pt`）

## 📚 更多信息

查看 `README.md` 获取详细文档。

