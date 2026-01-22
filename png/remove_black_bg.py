from __future__ import annotations

import argparse
from pathlib import Path

import cv2
import numpy as np


def remove_black_background(
    image_path: str | Path,
    output_path: str | Path,
    *,
    threshold: int = 30,  # 黑色阈值，低于此值的像素视为黑色
    blur_ksize: int = 3,
    feather: int = 2,
) -> Path:
    """
    去除黑色背景，保留其他所有内容。
    将灰度值低于 threshold 的像素设为透明。
    """
    in_path = Path(image_path).expanduser()
    out_path = Path(output_path).expanduser()

    if not in_path.exists():
        raise FileNotFoundError(f"Input not found: {in_path}")

    img = cv2.imread(str(in_path), cv2.IMREAD_UNCHANGED)
    if img is None:
        raise RuntimeError(f"Failed to read image: {in_path}")

    # Ensure BGRA
    if img.ndim == 2:
        img = cv2.cvtColor(img, cv2.COLOR_GRAY2BGRA)
    elif img.shape[2] == 3:
        img = cv2.cvtColor(img, cv2.COLOR_BGR2BGRA)
    elif img.shape[2] != 4:
        raise RuntimeError(f"Unsupported channel count: {img.shape}")

    # Convert to grayscale for thresholding
    gray = cv2.cvtColor(img, cv2.COLOR_BGRA2GRAY)

    if blur_ksize and blur_ksize >= 3:
        k = blur_ksize if blur_ksize % 2 == 1 else blur_ksize + 1
        gray = cv2.GaussianBlur(gray, (k, k), 0)

    # Create mask: 非黑色区域保留（灰度值 > threshold）
    # 黑色区域设为透明（alpha = 0）
    mask = np.where(gray > threshold, 255, 0).astype(np.uint8)

    # Apply feathering to smooth edges
    if feather and feather > 0:
        k = feather * 2 + 1
        mask = cv2.GaussianBlur(mask, (k, k), 0)

    # Apply mask to alpha channel
    img[:, :, 3] = mask

    out_path.parent.mkdir(parents=True, exist_ok=True)
    ok = cv2.imwrite(str(out_path), img)
    if not ok:
        raise RuntimeError(f"Failed to write output: {out_path}")
    return out_path


def main() -> int:
    p = argparse.ArgumentParser(description="Remove black background from image.")
    p.add_argument("input", help="Input image path (jpg/png)")
    p.add_argument(
        "-o",
        "--output",
        default=None,
        help="Output PNG path. Default: <input_stem>_transparent.png",
    )
    p.add_argument(
        "--threshold",
        type=int,
        default=30,
        help="Black threshold (0-255). Pixels below this value are considered black.",
    )
    p.add_argument(
        "--blur", type=int, default=3, help="Gaussian blur ksize (odd). 0 disables."
    )
    p.add_argument(
        "--feather", type=int, default=2, help="Mask feather radius. 0 disables."
    )
    args = p.parse_args()

    in_path = Path(args.input)
    out_path = (
        Path(args.output)
        if args.output
        else in_path.with_name(f"{in_path.stem}_transparent.png")
    )

    out = remove_black_background(
        in_path,
        out_path,
        threshold=args.threshold,
        blur_ksize=args.blur,
        feather=args.feather,
    )
    print(f"✅ Saved: {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

