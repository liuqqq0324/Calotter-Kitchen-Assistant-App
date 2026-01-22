from __future__ import annotations

import argparse
from pathlib import Path

import cv2
import numpy as np


def remove_white_background_completely(
    image_path: str | Path,
    output_path: str | Path,
    *,
    threshold: int = 240,  # 白色阈值，高于此值的像素将被设为透明
    blur_ksize: int = 3,
    feather_radius: int = 2,
) -> Path:
    """完全去除白色背景，包括角落的白色像素。"""
    in_path = Path(image_path).expanduser()
    out_path = Path(output_path).expanduser()

    if not in_path.exists():
        raise FileNotFoundError(f"Input not found: {in_path}")

    img = cv2.imread(str(in_path), cv2.IMREAD_UNCHANGED)
    if img is None:
        raise RuntimeError(f"Failed to read image: {in_path}")

    # 确保 BGRA
    if img.ndim == 2:
        img = cv2.cvtColor(img, cv2.COLOR_GRAY2BGRA)
    elif img.shape[2] == 3:
        img = cv2.cvtColor(img, cv2.COLOR_BGR2BGRA)
    elif img.shape[2] != 4:
        raise RuntimeError(f"Unsupported channel count: {img.shape}")

    # 分离通道
    b, g, r, a = cv2.split(img)
    
    # 计算每个像素的亮度
    gray = cv2.cvtColor(img, cv2.COLOR_BGRA2GRAY)
    
    if blur_ksize and blur_ksize >= 3:
        k = blur_ksize if blur_ksize % 2 == 1 else blur_ksize + 1
        gray = cv2.GaussianBlur(gray, (k, k), 0)

    # 创建掩模：白色区域（亮度 > threshold）设为透明
    # 同时检查 RGB 是否都接近白色
    white_mask = (
        (gray > threshold) & 
        (r > threshold) & 
        (g > threshold) & 
        (b > threshold)
    ).astype(np.uint8) * 255

    # 反转掩模：白色区域 = 0（透明），其他区域 = 255（不透明）
    mask = 255 - white_mask

    if feather_radius and feather_radius > 0:
        k = feather_radius * 2 + 1
        mask = cv2.GaussianBlur(mask, (k, k), 0)

    # 应用掩模到 alpha 通道
    img[:, :, 3] = mask

    out_path.parent.mkdir(parents=True, exist_ok=True)
    ok = cv2.imwrite(str(out_path), img)
    if not ok:
        raise RuntimeError(f"Failed to write output: {out_path}")
    return out_path


def main() -> int:
    p = argparse.ArgumentParser(description="Completely remove white background from images.")
    p.add_argument("input", help="Input image path (jpg/png)")
    p.add_argument(
        "-o",
        "--output",
        default=None,
        help="Output PNG path. Default: <input_stem>_no_white.png",
    )
    p.add_argument("--threshold", type=int, default=240, help="White threshold (0-255). Pixels brighter than this will be transparent.")
    p.add_argument("--blur", type=int, default=3, help="Gaussian blur ksize (odd). 0 disables.")
    p.add_argument("--feather", type=int, default=2, help="Mask feather radius. 0 disables.")
    args = p.parse_args()

    in_path = Path(args.input)
    out_path = (
        Path(args.output)
        if args.output
        else in_path.with_name(f"{in_path.stem}_no_white.png")
    )

    out = remove_white_background_completely(
        in_path,
        out_path,
        threshold=args.threshold,
        blur_ksize=args.blur,
        feather_radius=args.feather,
    )
    print(f"✅ Saved: {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

