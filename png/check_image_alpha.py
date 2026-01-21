from __future__ import annotations

from pathlib import Path
from PIL import Image
import numpy as np


def check_image_alpha(image_path: str | Path):
    """Check if image has transparent corners."""
    img = Image.open(image_path)
    arr = np.array(img)
    
    print(f"Image mode: {img.mode}")
    print(f"Image size: {img.size}")
    
    if img.mode == "RGBA":
        alpha = arr[:, :, 3]
        print(f"Alpha channel - min: {alpha.min()}, max: {alpha.max()}")
        
        # Check corners
        corners = [
            arr[0, 0],      # top-left
            arr[0, -1],      # top-right
            arr[-1, 0],      # bottom-left
            arr[-1, -1],     # bottom-right
        ]
        print(f"\nCorner pixels (RGBA):")
        for i, corner in enumerate(corners):
            print(f"  Corner {i}: {corner}")
            if len(corner) == 4:
                print(f"    Alpha: {corner[3]}")
    else:
        print("Image does not have alpha channel!")


if __name__ == "__main__":
    check_image_alpha("frontend-app/assets/images/Shell_transparent_cropped.png")

