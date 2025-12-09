# GPU 加速使用指南

## 为什么使用 CPU？

### 原因分析

1. **macOS 系统限制**:
   - macOS 不支持 NVIDIA CUDA（NVIDIA GPU 加速）
   - macOS 使用 Apple 的 Metal Performance Shaders (MPS) 进行 GPU 加速

2. **之前的代码问题**:
   - 原代码只检测 CUDA，没有检测 MPS
   - 因此自动回退到 CPU

3. **您的硬件**:
   - **芯片**: Apple M4 Max
   - **支持**: ✅ MPS (Metal Performance Shaders) GPU 加速
   - **性能**: M4 Max 的 GPU 性能非常强大，比 CPU 训练快很多

## ✅ 已修复

我已经更新了 `train.py`，现在会：
- ✅ 自动检测 CUDA (NVIDIA GPU)
- ✅ 自动检测 MPS (Apple Silicon GPU)
- ✅ 如果都不支持，才使用 CPU

## 🚀 如何使用 GPU 加速

### 方法 1: 自动检测（推荐）

不指定 `--device` 参数，脚本会自动选择最佳设备：

```bash
python train.py --data "training datasets/personal chef.v1i.yolov8/data.yaml" --epochs 50
```

对于您的 M4 Max，这会自动使用 **MPS (GPU)**！

### 方法 2: 手动指定 MPS

明确指定使用 Apple Silicon GPU：

```bash
python train.py --data "training datasets/personal chef.v1i.yolov8/data.yaml" --epochs 50 --device mps
```

### 方法 3: 强制使用 CPU（如果需要）

```bash
python train.py --data "training datasets/personal chef.v1i.yolov8/data.yaml" --epochs 50 --device cpu
```

## 📊 性能对比

| 设备 | 训练速度 | 适用场景 |
|------|---------|---------|
| **MPS (M4 Max GPU)** | ⚡⚡⚡ 最快 | 推荐使用 |
| CPU | ⚡ 较慢 | 调试或兼容性测试 |

## 🔍 验证 GPU 是否可用

安装依赖后，运行以下命令验证：

```bash
python -c "import torch; print('CUDA 可用:', torch.cuda.is_available()); print('MPS 可用:', torch.backends.mps.is_available() if hasattr(torch.backends, 'mps') else False)"
```

对于您的 M4 Max，应该显示：
```
CUDA 可用: False
MPS 可用: True
```

## 💡 建议

**对于您的 M4 Max，强烈建议使用 MPS (GPU) 加速！**

训练速度会显著提升，特别是对于：
- 大批量数据
- 多轮训练 (epochs)
- 大图像尺寸

## ⚠️ 注意事项

1. **MPS 限制**: 
   - 某些 PyTorch 操作可能不完全支持 MPS
   - 如果遇到错误，可以回退到 CPU

2. **内存管理**:
   - GPU 内存有限，如果 batch size 太大可能报错
   - 建议从 batch=16 开始，根据情况调整

3. **温度控制**:
   - GPU 训练会产生更多热量
   - 确保 Mac 有良好的散热

---

**总结**: 现在脚本会自动使用您的 M4 Max GPU 加速训练，无需手动指定 `--device mps`！

