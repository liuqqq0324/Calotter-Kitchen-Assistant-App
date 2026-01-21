from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


def crop_transparent_edges(
    image_path: str | Path,
    output_path: str | Path,
) -> Path:
    """Remove transparent edges from an image by cropping to the bounding box."""
    in_path = Path(image_path).expanduser()
    out_path = Path(output_path).expanduser()

    if not in_path.exists():
        raise FileNotFoundError(f"Input not found: {in_path}")

    img = Image.open(in_path)
    if img.mode != "RGBA":
        img = img.convert("RGBA")

    # Get bounding box of non-transparent pixels
    bbox = img.getbbox()
    if bbox is None:
        raise RuntimeError("Image is completely transparent")

    # Crop to bounding box
    cropped = img.crop(bbox)

    out_path.parent.mkdir(parents=True, exist_ok=True)
    cropped.save(out_path, "PNG")
    return out_path


def main() -> int:
    p = argparse.ArgumentParser(description="Crop transparent edges from PNG image.")
    p.add_argument("input", help="Input PNG path")
    p.add_argument(
        "-o",
        "--output",
        default=None,
        help="Output PNG path. Default: <input_stem>_cropped.png",
    )
    args = p.parse_args()

    in_path = Path(args.input)
    out_path = (
        Path(args.output)
        if args.output
        else in_path.with_name(f"{in_path.stem}_cropped.png")
    )

    out = crop_transparent_edges(in_path, out_path)
    print(f"✅ Saved: {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

