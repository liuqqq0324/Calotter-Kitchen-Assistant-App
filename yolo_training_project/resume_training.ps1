# PowerShell 脚本 - 从上次停止的地方继续训练 (Windows版本)
# 注意：Mac版本的 resume_training.sh 仍然保留，两个脚本可以共存

# 切换到脚本所在目录
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# 检查并激活虚拟环境
if (Test-Path "venv\Scripts\Activate.ps1") {
    Write-Host "激活虚拟环境..." -ForegroundColor Yellow
    & ".\venv\Scripts\Activate.ps1"
} elseif (Test-Path "venv\bin\activate") {
    Write-Host "⚠️  检测到Mac/Linux虚拟环境，Windows无法直接使用" -ForegroundColor Red
    Write-Host "请先运行 install_dependencies.ps1 创建Windows虚拟环境" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "⚠️  虚拟环境不存在，请先运行 install_dependencies.ps1" -ForegroundColor Red
    exit 1
}

# 先执行过滤，然后续训
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "检查并过滤标签数过多的文件..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 使用Python执行过滤
python -c @"
import sys
import os

# 导入过滤函数（需要导入 train.py 模块）
sys.path.insert(0, os.path.dirname(os.path.abspath('$scriptDir')))
from train import filter_high_label_files

# 从 args.yaml 读取 data.yaml 路径
args_file = os.path.join('$scriptDir', 'runs', 'detect', 'personal_chef.v1i.yolov8_train', 'args.yaml')
data_yaml_path = None

if os.path.exists(args_file):
    with open(args_file, 'r') as f:
        for line in f:
            if line.strip().startswith('data:'):
                data_yaml_path = line.split('data:')[1].strip()
                break

if data_yaml_path and os.path.exists(data_yaml_path):
    print(f'数据集配置文件: {data_yaml_path}')
    moved_count = filter_high_label_files(data_yaml_path, max_labels=100)
    if moved_count > 0:
        print(f'✅ 已将 {moved_count} 个标签数 >= 100 的文件移动到 toomany/ 文件夹')
    else:
        print('✅ 未发现需要过滤的文件（可能已经过滤过了）')
else:
    print(f'⚠️  无法找到 data.yaml 路径: {data_yaml_path}')
    print('   将跳过过滤步骤，直接续训')
"@

# 使用 last.pt 检查点继续训练
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "从检查点继续训练..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 检查checkpoint文件是否存在
$checkpointPath = "runs\detect\personal_chef.v1i.yolov8_train\weights\last.pt"
if (-not (Test-Path $checkpointPath)) {
    Write-Host "❌ 检查点文件不存在: $checkpointPath" -ForegroundColor Red
    Write-Host "请先运行训练以创建检查点" -ForegroundColor Yellow
    exit 1
}

Write-Host "检查点: $checkpointPath" -ForegroundColor Green

# 检测可用设备
python -c @"
from ultralytics import YOLO
import torch

# 加载上次的训练检查点
checkpoint = r'$checkpointPath'
print(f'加载检查点: {checkpoint}')

# 检测最佳设备
if torch.cuda.is_available():
    device = 'cuda'
    print(f'✅ 使用 CUDA 设备: {torch.cuda.get_device_name(0)}')
elif hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
    device = 'mps'
    print('✅ 使用 MPS 设备 (Apple Silicon)')
else:
    device = 'cpu'
    print('⚠️  使用 CPU 设备（训练会较慢）')

# 加载模型（会自动读取训练状态）
model = YOLO(checkpoint)

# 继续训练（resume=True 会从上次停止的 epoch 继续）
print('')
print('开始继续训练...')
print('注意：训练将从上次停止的 epoch 继续')
print('')

model.train(resume=True, device=device)
"@

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "训练完成或已停止" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

