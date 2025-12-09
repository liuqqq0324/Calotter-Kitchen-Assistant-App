# 依赖安装指南

由于系统权限限制，请在终端中手动运行以下命令来安装依赖。

## 方法 1: 使用安装脚本（推荐）

在终端中运行：

```bash
cd /Users/chase/Documents/Internship/Projects/chef_training/A-team-PersonalSousChef
bash install_dependencies.sh
```

## 方法 2: 手动安装步骤

### 步骤 1: 创建虚拟环境

```bash
cd /Users/chase/Documents/Internship/Projects/chef_training/A-team-PersonalSousChef
python3 -m venv venv
```

### 步骤 2: 激活虚拟环境

```bash
source venv/bin/activate
```

### 步骤 3: 升级 pip

```bash
python -m pip install --upgrade pip
```

### 步骤 4: 安装依赖包

```bash
python -m pip install -r ai-engine/requirements.txt
```

### 步骤 5: 验证安装

```bash
python -c "import ultralytics; import torch; print('✅ 安装成功！'); print('ultralytics 版本:', ultralytics.__version__); print('torch 版本:', torch.__version__)"
```

## 方法 3: 如果虚拟环境有问题，使用系统安装（不推荐）

```bash
python3 -m pip install --user --break-system-packages -r ai-engine/requirements.txt
```

⚠️ **注意**: 使用 `--break-system-packages` 可能会影响系统 Python 环境，建议使用方法 1 或 2。

## 安装完成后

安装完成后，每次使用前需要激活虚拟环境：

```bash
source venv/bin/activate
```

然后就可以运行训练了：

```bash
python train.py --data "training datasets/personal chef.v1i.yolov8/data.yaml" --epochs 50 --device cpu
```

