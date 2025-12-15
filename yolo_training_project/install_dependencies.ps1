# PowerShell 脚本 - 安装训练所需的 Python 依赖包 (Windows版本)
# 注意：Mac版本的 install_dependencies.sh 仍然保留，两个脚本可以共存

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "安装 YOLOv8 训练依赖包 (Windows)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Python 版本
Write-Host "检查 Python 版本..." -ForegroundColor Yellow
$pythonCmd = $null
# 尝试不同的Python命令
foreach ($cmd in @("python", "python3", "py")) {
    try {
        $result = & $cmd --version 2>&1
        if ($LASTEXITCODE -eq 0 -and $result -match "Python") {
            $pythonCmd = $cmd
            Write-Host "$result" -ForegroundColor Green
            break
        }
    } catch {
        continue
    }
}

if (-not $pythonCmd) {
    Write-Host "[错误] 未找到 Python，请先安装 Python 3.8 或更高版本" -ForegroundColor Red
    Write-Host "请从 https://www.python.org/downloads/ 下载并安装 Python" -ForegroundColor Yellow
    Write-Host "安装时请勾选 'Add Python to PATH' 选项" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# 检查是否有 pip
Write-Host "检查 pip..." -ForegroundColor Yellow
try {
    $pipVersion = & $pythonCmd -m pip --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] $pipVersion" -ForegroundColor Green
    } else {
        Write-Host "[错误] 未找到 pip，请先安装 pip" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[错误] 未找到 pip，请先安装 pip" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 创建虚拟环境（如果不存在）
if (-not (Test-Path "venv")) {
    Write-Host "创建虚拟环境..." -ForegroundColor Yellow
    & $pythonCmd -m venv venv
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] 虚拟环境创建成功" -ForegroundColor Green
    } else {
        Write-Host "[错误] 虚拟环境创建失败" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[OK] 虚拟环境已存在" -ForegroundColor Green
}
Write-Host ""

# 激活虚拟环境并安装依赖
Write-Host "激活虚拟环境并安装依赖包..." -ForegroundColor Yellow
$activateScript = ".\venv\Scripts\Activate.ps1"

# 检查激活脚本是否存在
if (-not (Test-Path $activateScript)) {
    Write-Host "[错误] 虚拟环境激活脚本不存在，可能是Mac创建的虚拟环境" -ForegroundColor Red
    Write-Host "建议删除 venv 文件夹后重新运行此脚本" -ForegroundColor Yellow
    exit 1
}

# 执行激活脚本
& $activateScript

Write-Host "升级 pip..." -ForegroundColor Yellow
& $pythonCmd -m pip install --upgrade pip --quiet

Write-Host ""
Write-Host "安装依赖包（这可能需要几分钟）..." -ForegroundColor Yellow
Write-Host "注意：将安装支持 CUDA 的 PyTorch 版本" -ForegroundColor Cyan

# 检查CUDA版本并安装对应的PyTorch
Write-Host "检测 CUDA 版本..." -ForegroundColor Yellow
$cudaVersion = $null
try {
    $nvidiaSmi = nvidia-smi 2>&1
    if ($nvidiaSmi -match "CUDA Version: (\d+\.\d+)") {
        $cudaVersion = $matches[1]
        Write-Host "[OK] 检测到 CUDA 版本: $cudaVersion" -ForegroundColor Green
    }
} catch {
    Write-Host "[警告] 无法检测 CUDA 版本，将安装 CPU 版本的 PyTorch" -ForegroundColor Yellow
}

# 安装基础依赖（不包括torch，因为需要特殊处理）
Write-Host "安装基础依赖包..." -ForegroundColor Yellow
& $pythonCmd -m pip install numpy>=1.24.0 opencv-python>=4.8.0 pillow>=9.5.0 pandas>=2.0.0 pyyaml>=6.0 --quiet

# 安装PyTorch（优先安装CUDA版本）
Write-Host ""
Write-Host "安装 PyTorch..." -ForegroundColor Yellow
if ($cudaVersion) {
    # 根据CUDA版本安装对应的PyTorch
    if ($cudaVersion -match "^12\.") {
        Write-Host "安装 PyTorch (CUDA 12.x)..." -ForegroundColor Cyan
        & $pythonCmd -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121 --quiet
    } elseif ($cudaVersion -match "^11\.") {
        Write-Host "安装 PyTorch (CUDA 11.x)..." -ForegroundColor Cyan
        & $pythonCmd -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118 --quiet
    } else {
        Write-Host "安装 PyTorch (CPU版本，CUDA版本不匹配)..." -ForegroundColor Yellow
        & $pythonCmd -m pip install torch torchvision --quiet
    }
} else {
    Write-Host "安装 PyTorch (CPU版本)..." -ForegroundColor Yellow
    & $pythonCmd -m pip install torch torchvision --quiet
}

# 安装ultralytics
Write-Host "安装 ultralytics..." -ForegroundColor Yellow
& $pythonCmd -m pip install ultralytics>=8.0.0 --quiet

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "[OK] 依赖安装完成！" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "验证安装..." -ForegroundColor Yellow
& $pythonCmd -c "import ultralytics; import torch; print('[OK] ultralytics 版本:', ultralytics.__version__); print('[OK] torch 版本:', torch.__version__); print('[OK] CUDA 可用:', torch.cuda.is_available()); print('[OK] GPU 名称:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'N/A'); print('[OK] CUDA 版本:', torch.version.cuda if torch.cuda.is_available() else 'N/A')"
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "使用方法：" -ForegroundColor Yellow
Write-Host "1. 激活虚拟环境: .\venv\Scripts\Activate.ps1" -ForegroundColor White
Write-Host "2. 运行训练: python train.py --data `"training datasets/personal chef.v1i.yolov8/data.yaml`" --epochs 50 --device cuda" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Cyan

