# YOLO 训练工程

用于训练自定义手势识别模型的 YOLOv8 训练工程。

## 📁 目录结构

```
yolo-training/
├── dataset/              # 数据集目录
│   ├── images/           # 图片目录
│   │   ├── train/       # 训练集图片
│   │   ├── valid/       # 验证集图片
│   │   └── test/        # 测试集图片（可选）
│   ├── labels/          # 标签目录（如果标签与图片分开）
│   └── data.yaml        # 数据集配置文件
├── runs/                # 训练结果输出目录（自动创建）
├── train.py             # 训练脚本
└── README.md            # 本文件
```

## 🚀 快速开始

### 第一步：环境准备

安装必要的依赖：

```bash
pip install ultralytics
```

如果你有 NVIDIA GPU，建议安装 GPU 版本的 PyTorch：

```bash
# CUDA 11.8
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# CUDA 12.1
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
```

### 第二步：准备数据集

1. **从 Roboflow 下载数据集**
   - 下载 ZIP 包并解压到 `dataset/` 目录
   - 确保目录结构如下：
     ```
     dataset/
     ├── images/
     │   ├── train/
     │   └── valid/
     └── data.yaml
     ```

2. **修改 data.yaml**
   - 打开 `dataset/data.yaml`
   - 检查并修改 `path`、`train`、`val` 路径
   - 修改 `nc`（类别数量）和 `names`（类别名称）

### 第三步：开始训练

运行训练脚本：

```bash
python train.py
```

或者使用命令行方式：

```bash
yolo detect train data=dataset/data.yaml model=yolov8n.pt epochs=100 imgsz=640 device=0
```

## ⚙️ 训练参数说明

在 `train.py` 中可以调整以下参数：

- **epochs**: 训练轮数（默认: 100）
- **imgsz**: 图片大小（默认: 640，需与 Roboflow 导出时保持一致）
- **batch**: 批次大小（默认: 16）
  - GPU 显存充足: 16-32
  - GPU 显存较小: 8-16
  - 仅 CPU: 4-8
- **device**: 设备选择
  - `0`: 使用第一块 GPU
  - `'cpu'`: 使用 CPU
  - `None`: 自动检测
- **name**: 训练结果文件夹名称（默认: `cooking_gesture_model`）

## 📊 查看训练结果

训练完成后，结果保存在 `runs/detect/cooking_gesture_model/` 目录：

- **最佳权重**: `weights/best.pt` - 验证集上表现最好的模型
- **最终权重**: `weights/last.pt` - 最后一轮的模型
- **训练曲线**: `results.png` - 损失和指标曲线图
- **验证结果**: `val_batch*.jpg` - 验证集上的预测结果可视化

## 🔧 常见问题排查

### 1. File Not Found 错误

**问题**: 找不到数据文件

**解决**: 
- 检查 `dataset/data.yaml` 中的路径是否正确
- 确保使用相对路径或正确的绝对路径
- 检查图片和标签文件是否存在于指定目录

### 2. CUDA out of memory 错误

**问题**: GPU 显存不足

**解决**:
- 减小 `batch` 参数（例如改为 8 或 4）
- 减小 `imgsz` 参数（例如改为 416 或 320）
- 使用更小的模型（例如 `yolov8n.pt` 而不是 `yolov8m.pt`）

### 3. 下载速度慢

**问题**: 预训练模型下载很慢

**解决**:
- 手动从 [Ultralytics GitHub](https://github.com/ultralytics/assets/releases) 下载模型权重
- 将下载的 `.pt` 文件放到项目根目录
- 修改 `train.py` 中的模型路径

### 4. 训练速度慢

**问题**: 训练速度很慢

**解决**:
- 确保使用 GPU（检查 `device=0`）
- 增加 `batch` 大小（如果显存允许）
- 使用更小的模型（`yolov8n.pt` 比 `yolov8x.pt` 快得多）

## 📝 模型选择建议

根据你的需求选择合适的模型：

| 模型 | 大小 | 速度 | 精度 | 适用场景 |
|------|------|------|------|----------|
| yolov8n.pt | 最小 | 最快 | 较低 | 实时检测、移动设备 |
| yolov8s.pt | 小 | 快 | 中等 | 平衡速度和精度 |
| yolov8m.pt | 中 | 中等 | 较高 | 一般应用 |
| yolov8l.pt | 大 | 慢 | 高 | 高精度需求 |
| yolov8x.pt | 最大 | 最慢 | 最高 | 研究、离线处理 |

## 🎯 下一步

训练完成后：

1. 使用 `best.pt` 进行推理测试
2. 如果效果不理想，可以：
   - 增加训练轮数（epochs）
   - 增加数据集大小
   - 调整数据增强参数
   - 尝试更大的模型

## 📚 参考资源

- [Ultralytics YOLOv8 文档](https://docs.ultralytics.com/)
- [Roboflow 数据集准备指南](https://roboflow.com/help)
- [YOLOv8 GitHub](https://github.com/ultralytics/ultralytics)

