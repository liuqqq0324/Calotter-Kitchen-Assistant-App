"""
YOLOv8 Training Script for Personal Sous Chef Project
This script trains YOLOv8 models on ingredient detection datasets.
"""

from ultralytics import YOLO
import argparse
import os
import torch
import shutil

def get_default_device():
    """自动检测最佳可用设备"""
    if torch.cuda.is_available():
        return 'cuda'
    elif hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
        return 'mps'
    else:
        return 'cpu'

default_device = get_default_device()


def extract_dataset_name(data_yaml_path):
    """
    Extract dataset name from the data.yaml file path.
    For example: 'training datasets/ Grains/Wheat products/Bagel/data.yaml' -> 'Bagel'
    """
    # Get the directory containing data.yaml
    dataset_dir = os.path.dirname(os.path.abspath(data_yaml_path))
    # Get the last directory name as dataset name
    dataset_name = os.path.basename(dataset_dir)
    # Clean up the name (remove spaces, convert to lowercase with underscores)
    dataset_name = dataset_name.lower().replace(' ', '_').replace('-', '_')
    return dataset_name


def filter_high_label_files(data_yaml_path, max_labels=100):
    """
    将标签数过多的文件移动到 toomany 文件夹，避免训练时出现张量尺寸不匹配错误。
    
    Args:
        data_yaml_path (str): data.yaml 文件路径
        max_labels (int): 最大标签数阈值，超过此数量的文件将被移动（默认: 100）
    
    Returns:
        int: 移动的文件数量（图片-标签对的数量）
    """
    # 获取 data.yaml 所在目录
    dataset_dir = os.path.dirname(os.path.abspath(data_yaml_path))
    
    # 解析 data.yaml 中的 train 路径
    # 通常格式为: train: ../train/images 或 train: train/images
    train_path_relative = None
    try:
        with open(data_yaml_path, 'r') as f:
            for line in f:
                if line.strip().startswith('train:'):
                    train_path_relative = line.split('train:')[1].strip()
                    break
    except Exception as e:
        print(f"⚠️  无法读取 data.yaml: {e}")
        return 0
    
    if not train_path_relative:
        print("⚠️  未在 data.yaml 中找到 train 路径")
        return 0
    
    # 解析相对路径，获取 train 目录
    # 注意：data.yaml 中的路径可能是相对路径，但实际数据集可能在 data.yaml 所在目录下
    train_dir = None
    
    if train_path_relative.startswith('../'):
        # 相对路径，先尝试 data.yaml 所在目录下的 train（常见情况）
        possible_dir1 = os.path.join(dataset_dir, 'train')
        # 再尝试相对于 data.yaml 所在目录的上一级
        possible_dir2 = os.path.join(os.path.dirname(dataset_dir), train_path_relative.replace('../train/images', 'train'))
        
        # 选择存在的路径
        if os.path.exists(possible_dir1):
            train_dir = possible_dir1
        elif os.path.exists(possible_dir2):
            train_dir = possible_dir2
        else:
            # 如果都不存在，使用可能的路径2（按照 data.yaml 的指示）
            train_dir = possible_dir2
    elif train_path_relative.startswith('train/'):
        # 相对于 data.yaml 所在目录
        train_dir = os.path.join(dataset_dir, train_path_relative.replace('train/images', 'train'))
    else:
        # 绝对路径或需要进一步处理
        train_dir = os.path.join(dataset_dir, train_path_relative.replace('/images', '').replace('images', 'train'))
    
    train_dir = os.path.abspath(train_dir)
    labels_dir = os.path.join(train_dir, 'labels')
    images_dir = os.path.join(train_dir, 'images')
    
    # 检查目录是否存在
    if not os.path.exists(labels_dir):
        print(f"⚠️  标签目录不存在: {labels_dir}")
        return 0
    if not os.path.exists(images_dir):
        print(f"⚠️  图片目录不存在: {images_dir}")
        return 0
    
    # 创建 toomany 目录
    toomany_dir = os.path.join(train_dir, 'toomany')
    toomany_labels_dir = os.path.join(toomany_dir, 'labels')
    toomany_images_dir = os.path.join(toomany_dir, 'images')
    
    os.makedirs(toomany_labels_dir, exist_ok=True)
    os.makedirs(toomany_images_dir, exist_ok=True)
    
    # 扫描标签文件，找出标签数 >= max_labels 的文件
    moved_count = 0
    problematic_files = []
    
    for label_file in os.listdir(labels_dir):
        # 跳过 macOS 隐藏文件（以 ._ 开头）
        if label_file.startswith('._'):
            continue
        
        if not label_file.endswith('.txt'):
            continue
        
        label_path = os.path.join(labels_dir, label_file)
        
        # 统计标签数量
        try:
            # 使用 UTF-8 编码读取，如果失败则尝试其他编码
            try:
                with open(label_path, 'r', encoding='utf-8') as f:
                    label_count = len([line for line in f if line.strip()])
            except UnicodeDecodeError:
                # 如果 UTF-8 失败，尝试 latin-1（几乎可以读取任何字节）
                with open(label_path, 'r', encoding='latin-1') as f:
                    label_count = len([line for line in f if line.strip()])
            
            if label_count >= max_labels:
                # 获取对应的图片文件名
                image_file = label_file.replace('.txt', '.jpg')
                image_path = os.path.join(images_dir, image_file)
                
                # 检查图片文件是否存在
                if os.path.exists(image_path):
                    problematic_files.append({
                        'label_file': label_file,
                        'label_path': label_path,
                        'image_file': image_file,
                        'image_path': image_path,
                        'label_count': label_count
                    })
        except Exception as e:
            # 跳过无法读取的文件（通常是 macOS 隐藏文件或损坏的文件）
            # 不打印错误，因为这些文件通常不应该被处理
            continue
    
    # 移动文件
    for item in problematic_files:
        try:
            # 移动标签文件
            dest_label_path = os.path.join(toomany_labels_dir, item['label_file'])
            shutil.move(item['label_path'], dest_label_path)
            
            # 移动图片文件
            dest_image_path = os.path.join(toomany_images_dir, item['image_file'])
            shutil.move(item['image_path'], dest_image_path)
            
            moved_count += 1
        except Exception as e:
            print(f"⚠️  移动文件失败 {item['label_file']}: {e}")
            continue
    
    if moved_count > 0:
        print(f"📦 已将 {moved_count} 个文件移动到: {toomany_dir}")
        print(f"   (标签数范围: {min(p['label_count'] for p in problematic_files)} - {max(p['label_count'] for p in problematic_files)})")
    
    return moved_count


def train_model(data_yaml_path, epochs=50, imgsz=640, model_name='yolov8n.pt', batch=16, device=None, name=None, filter_labels=True, max_labels=100):
    """
    Train a YOLOv8 model on the specified dataset.
    
    Args:
        data_yaml_path (str): Path to the dataset configuration YAML file
        epochs (int): Number of training epochs (default: 50)
        imgsz (int): Image size for training (default: 640)
        model_name (str): Pre-trained model to use (default: 'yolov8n.pt')
        batch (int): Batch size for training (default: 16)
        device (str): Device to use for training - 'cpu', 'cuda', or 'mps' (default: auto-detect)
        name (str): Name for the training run output directory (default: auto-extracted from dataset path)
        filter_labels (bool): Whether to filter out files with too many labels (default: True)
        max_labels (int): Maximum number of labels per image before filtering (default: 100)
    """
    # Validate data.yaml path
    if not os.path.exists(data_yaml_path):
        raise FileNotFoundError(f"Dataset configuration file not found: {data_yaml_path}")
    
    # Filter high label files before training
    if filter_labels:
        print("\n" + "="*60)
        print("检查并过滤标签数过多的文件...")
        print("="*60)
        moved_count = filter_high_label_files(data_yaml_path, max_labels=max_labels)
        if moved_count > 0:
            print(f"✅ 已将 {moved_count} 个标签数 >= {max_labels} 的文件移动到 toomany/ 文件夹")
        else:
            print(f"✅ 未发现标签数 >= {max_labels} 的文件")
        print("="*60 + "\n")
    
    # Auto-detect device if not specified
    if device is None:
        device = default_device
    
    # Auto-extract dataset name if not specified
    if name is None:
        name = extract_dataset_name(data_yaml_path)
        name = f"{name}_train"
    
    # 检查是否存在 checkpoint，如果存在则从 checkpoint 恢复训练
    checkpoint_path = os.path.join('runs', 'detect', name, 'weights', 'last.pt')
    best_checkpoint_path = os.path.join('runs', 'detect', name, 'weights', 'best.pt')
    resume_training = False
    
    if os.path.exists(checkpoint_path):
        print(f"\n{'='*60}")
        print(f"发现检查点文件: {checkpoint_path}")
        print(f"尝试从上次停止的地方继续训练...")
        print(f"{'='*60}\n")
        model_name = checkpoint_path
        resume_training = True
    elif os.path.exists(best_checkpoint_path):
        print(f"\n{'='*60}")
        print(f"发现最佳模型文件: {best_checkpoint_path}")
        print(f"将从最佳模型继续训练（使用最佳权重）")
        print(f"{'='*60}\n")
        model_name = best_checkpoint_path
        resume_training = True
    else:
        print(f"未找到检查点，从预训练模型开始训练: {model_name}")
        print(f"yolov8n.pt is a lightweight pre-trained model that recognizes many basic objects, making training faster.")
        resume_training = False
    
    # Load the model
    model = YOLO(model_name)
    
    print(f"\nStarting training...")
    print(f"Dataset: {data_yaml_path}")
    print(f"Output name: {name}")
    print(f"Epochs: {epochs}")
    print(f"Image size: {imgsz}")
    print(f"Batch size: {batch}")
    print(f"Device: {device}")
    if resume_training:
        print(f"Resume: True (从上次停止的epoch继续)")
    print()
    
    # Start training
    # data: path to the dataset configuration YAML file downloaded from Roboflow
    # epochs: number of training epochs (start with 50 for beginners)
    # imgsz: image size
    
    try:
        results = model.train(
            data=data_yaml_path,
            epochs=epochs,
            imgsz=imgsz,
            batch=batch,
            device=device,
            project='runs/detect',
            name=name,
            exist_ok=True,  # 允许继续使用已存在的目录
            resume=resume_training  # 如果从checkpoint恢复，设置为True
        )
    except Exception as e:
        if resume_training and "GradScaler" in str(e):
            print(f"\n{'='*60}")
            print(f"警告: 检测到AMP GradScaler兼容性问题（可能是跨平台checkpoint）")
            print(f"将使用最佳模型权重继续训练，但会重新开始epoch计数")
            print(f"{'='*60}\n")
            # 如果resume失败，尝试从best.pt加载并继续训练（不使用resume）
            if os.path.exists(best_checkpoint_path) and checkpoint_path != best_checkpoint_path:
                model = YOLO(best_checkpoint_path)
                print(f"从最佳模型继续训练: {best_checkpoint_path}")
            else:
                # 如果best.pt也不存在，从原始checkpoint加载但不使用resume
                model = YOLO(checkpoint_path)
                print(f"从checkpoint加载权重，但重新开始训练")
            
            results = model.train(
                data=data_yaml_path,
                epochs=epochs,
                imgsz=imgsz,
                batch=batch,
                device=device,
                project='runs/detect',
                name=name,
                exist_ok=True,
                resume=False  # 不使用resume，从权重继续但重新开始epoch
            )
        else:
            # 其他错误，直接抛出
            raise
    
    print("\nTraining completed!")
    print(f"Results saved in: runs/detect/{name}/")
    
    return results


def main():
    """Main function to handle command line arguments and start training."""
    parser = argparse.ArgumentParser(
        description='Train YOLOv8 model for ingredient detection',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Train on noodles dataset with default parameters (auto-named as "noodles_train")
  python train.py --data "training datasets/ Grains/Wheat products/NOODLES/data.yaml"
  
  # Train with custom epochs and image size (auto-named as "bagel_train")
  python train.py --data "training datasets/ Grains/Wheat products/Bagel/data.yaml" --epochs 100 --imgsz 416
  
  # Train with custom output name
  python train.py --data "training datasets/ Grains/Wheat products/Pasta/data.yaml" --name pasta_train_v2
  
  # Train on GPU (if available)
  python train.py --data "training datasets/ Grains/Wheat products/Bread./data.yaml" --device cuda
        """
    )
    
    parser.add_argument(
        '--data',
        type=str,
        required=True,
        help='Path to the dataset configuration YAML file (e.g., "training datasets/ Grains/Wheat products/NOODLES/data.yaml")'
    )
    
    parser.add_argument(
        '--epochs',
        type=int,
        default=50,
        help='Number of training epochs (default: 50)'
    )
    
    parser.add_argument(
        '--imgsz',
        type=int,
        default=640,
        help='Image size for training (default: 640)'
    )
    
    parser.add_argument(
        '--model',
        type=str,
        default='yolov8n.pt',
        choices=['yolov8n.pt', 'yolov8s.pt', 'yolov8m.pt', 'yolov8l.pt', 'yolov8x.pt'],
        help='Pre-trained model to use (default: yolov8n.pt)'
    )
    
    parser.add_argument(
        '--batch',
        type=int,
        default=16,
        help='Batch size for training (default: 16)'
    )
    
    parser.add_argument(
        '--device',
        type=str,
        default=None,
        choices=['cpu', 'cuda', 'mps'],
        help=f'Device to use for training: cpu, cuda (NVIDIA GPU), or mps (Apple Silicon GPU) (default: auto-detect, currently: {default_device})'
    )
    
    parser.add_argument(
        '--name',
        type=str,
        default=None,
        help='Name for the training run output directory (default: auto-extracted from dataset path, e.g., "bagel_train", "pasta_train")'
    )
    
    parser.add_argument(
        '--max-labels',
        type=int,
        default=100,
        help='Maximum number of labels per image. Files with more labels will be moved to toomany/ folder (default: 100)'
    )
    
    parser.add_argument(
        '--no-filter',
        action='store_true',
        help='Disable automatic filtering of high-label files'
    )
    
    args = parser.parse_args()
    
    try:
        train_model(
            data_yaml_path=args.data,
            epochs=args.epochs,
            imgsz=args.imgsz,
            model_name=args.model,
            batch=args.batch,
            device=args.device,
            name=args.name,
            filter_labels=not args.no_filter,
            max_labels=args.max_labels
        )
    except Exception as e:
        print(f"Error during training: {e}")
        return 1
    
    return 0


if __name__ == '__main__':
    exit(main())

