from __future__ import annotations

import argparse
import os
from pathlib import Path

import cv2
import numpy as np


def remove_background_keep_all_objects(
    image_path: str | os.PathLike,
    output_path: str | os.PathLike,
    *,
    threshold: int = 200,
    blur_ksize: int = 3,
    close_ksize: int = 3,
    min_area: int = 100,
) -> Path:
    """
    Remove white background while keeping all objects (spoon, fork, knife).
    Instead of using only the largest contour, we keep all significant contours.
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

    gray = cv2.cvtColor(img, cv2.COLOR_BGRA2GRAY)

    if blur_ksize and blur_ksize >= 3:
        k = blur_ksize if blur_ksize % 2 == 1 else blur_ksize + 1
        gray = cv2.GaussianBlur(gray, (k, k), 0)

    # Dark lines -> white in thresh (binary inverse)
    _, thresh = cv2.threshold(gray, int(threshold), 255, cv2.THRESH_BINARY_INV)

    if close_ksize and close_ksize >= 3:
        k = close_ksize if close_ksize % 2 == 1 else close_ksize + 1
        kernel = np.ones((k, k), np.uint8)
        thresh = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel)

    contours, _hier = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if not contours:
        raise RuntimeError(
            "No contours detected. Try increasing threshold (e.g. 220) or adjusting morphology."
        )

    # Create mask with all significant contours (not just the largest)
    mask = np.zeros_like(gray, dtype=np.uint8)
    
    # Filter contours by area and fill them all
    for contour in contours:
        area = cv2.contourArea(contour)
        if area >= min_area:  # Only keep contours above minimum area
            cv2.drawContours(mask, [contour], -1, 255, thickness=cv2.FILLED)

    # Apply slight feathering to smooth edges
    mask = cv2.GaussianBlur(mask, (3, 3), 0)

    img[:, :, 3] = mask

    out_path.parent.mkdir(parents=True, exist_ok=True)
    ok = cv2.imwrite(str(out_path), img)
    if not ok:
        raise RuntimeError(f"Failed to write output: {out_path}")
    return out_path


def main() -> int:
    p = argparse.ArgumentParser(description="Remove white background while keeping all objects.")
    p.add_argument("input", help="Input image path (jpg/png)")
    p.add_argument(
        "-o",
        "--output",
        default=None,
        help="Output PNG path. Default: <input_stem>_transparent.png",
    )
    p.add_argument("--threshold", type=int, default=200, help="Threshold for dark outline detection")
    p.add_argument("--blur", type=int, default=3, help="Gaussian blur ksize (odd). 0 disables.")
    p.add_argument("--close", type=int, default=3, help="Morph close ksize (odd). 0 disables.")
    p.add_argument("--min-area", type=int, default=100, help="Minimum contour area to keep")
    args = p.parse_args()

    in_path = Path(args.input)
    out_path = Path(args.output) if args.output else in_path.with_name(f"{in_path.stem}_transparent.png")

    out = remove_background_keep_all_objects(
        in_path,
        out_path,
        threshold=args.threshold,
        blur_ksize=args.blur,
        close_ksize=args.close,
        min_area=args.min_area,
    )
    print(f"✅ Saved: {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

