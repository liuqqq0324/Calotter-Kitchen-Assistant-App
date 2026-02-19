# 数据集目录说明

## 📁 目录结构

将 Roboflow 下载的 ZIP 包解压后，应该得到以下目录结构：

```
dataset/
├── images/
│   ├── train/          # 训练集图片
│   │   ├── image1.jpg
│   │   ├── image2.jpg
│   │   └── ...
│   ├── valid/          # 验证集图片
│   │   ├── image1.jpg
│   │   ├── image2.jpg
│   │   └── ...
│   └── test/           # 测试集图片（可选）
│       └── ...
├── labels/             # 标签文件（如果与图片分开）
│   ├── train/
│   │   ├── image1.txt
│   │   ├── image2.txt
│   │   └── ...
│   └── valid/
│       └── ...
└── data.yaml           # 数据集配置文件
```

## ⚠️ 重要提示

### 1. 路径配置

打开 `data.yaml`，确保路径配置正确：

```yaml
# 方式一：使用绝对路径
path: D:/files/NewFolder_2/code/A-team-PersonalSousChef/yolo-training/dataset
train: images/train
val: images/valid

# 方式二：使用相对路径（相对于 data.yaml 文件）
path: .
train: images/train
val: images/valid
```

### 2. 标签文件格式

YOLO 标签文件是 `.txt` 格式，每行一个目标：

```
class_id center_x center_y width height
```

例如：
```
0 0.5 0.5 0.3 0.4
```

- `class_id`: 类别ID（从0开始）
- `center_x, center_y`: 边界框中心点坐标（归一化到0-1）
- `width, height`: 边界框宽度和高度（归一化到0-1）

### 3. 从 Roboflow 下载

如果从 Roboflow 下载数据集：

1. 选择 **YOLOv8** 格式
2. 选择图片大小（建议 640x640）
3. 下载 ZIP 包
4. 解压到 `dataset/` 目录
5. 检查并修改 `data.yaml` 中的路径

## 📝 检查清单

在开始训练前，请确认：

- [ ] `images/train/` 目录中有训练图片
- [ ] `images/valid/` 目录中有验证图片
- [ ] 每个图片都有对应的 `.txt` 标签文件（同名）
- [ ] `data.yaml` 中的路径配置正确
- [ ] `data.yaml` 中的类别数量（nc）和类别名称（names）正确

