"""
YOLOv8 Training Script for Personal Sous Chef Project
This script trains YOLOv8 models on ingredient detection datasets.
"""

from ultralytics import YOLO
import argparse
import os
import torch

default_device = 'cuda' if torch.cuda.is_available() else 'cpu'


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


def train_model(data_yaml_path, epochs=50, imgsz=640, model_name='yolov8n.pt', batch=16, device=None, name=None):
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
    """
    # Validate data.yaml path
    if not os.path.exists(data_yaml_path):
        raise FileNotFoundError(f"Dataset configuration file not found: {data_yaml_path}")
    
    # Auto-detect device if not specified
    if device is None:
        device = default_device
    
    # Auto-extract dataset name if not specified
    if name is None:
        name = extract_dataset_name(data_yaml_path)
        name = f"{name}_train"
    
    print(f"Loading pre-trained model: {model_name}")
    print(f"yolov8n.pt is a lightweight pre-trained model that recognizes many basic objects, making training faster.")
    
    # Load the model
    # yolov8n.pt is a pre-trained model that is not only small in size but also recognizes many basic objects, making training faster
    model = YOLO(model_name)
    
    print(f"\nStarting training...")
    print(f"Dataset: {data_yaml_path}")
    print(f"Output name: {name}")
    print(f"Epochs: {epochs}")
    print(f"Image size: {imgsz}")
    print(f"Batch size: {batch}")
    print(f"Device: {device}\n")
    
    # Start training
    # data: path to the dataset configuration YAML file downloaded from Roboflow
    # epochs: number of training epochs (start with 50 for beginners)
    # imgsz: image size

    results = model.train(
        data=data_yaml_path,
        epochs=epochs,
        imgsz=imgsz,
        batch=batch,
        device=device,
        project='runs/detect',
        name=name,
        exist_ok=False  # Changed to False to prevent accidental overwrites
    )
    
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
        default='cpu',
        choices=['cpu', 'cuda', 'mps'],
        help='Device to use for training: cpu, cuda (GPU), or mps (Apple Silicon) (default: cpu)'
    )
    
    parser.add_argument(
        '--name',
        type=str,
        default=None,
        help='Name for the training run output directory (default: auto-extracted from dataset path, e.g., "bagel_train", "pasta_train")'
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
            name=args.name
        )
    except Exception as e:
        print(f"Error during training: {e}")
        return 1
    
    return 0


if __name__ == '__main__':
    exit(main())

