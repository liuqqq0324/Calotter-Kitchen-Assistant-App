from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


def _convert_to_transparent(img: Image.Image, white_threshold: int = 200) -> Image.Image:
    """
    Turn (near) white background pixels transparent with a simple feathering.
    Keeps non-white pixels unchanged.
    """
    img = img.convert("RGBA")
    datas = img.getdata()
    new_data = []

    for r, g, b, a in datas:
        if r > white_threshold and g > white_threshold and b > white_threshold:
            avg = (r + g + b) / 3
            # Map avg in [white_threshold, 255] -> alpha in [255, 0]
            denom = max(1, 255 - white_threshold)
            alpha = 255 - int((avg - white_threshold) * (255 / denom))
            new_data.append((r, g, b, max(0, min(255, alpha))))
        else:
            new_data.append((r, g, b, a))

    img.putdata(new_data)

    # Auto-crop away fully-transparent borders
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)
    return img


def _resolve_input_path(user_input: str | None) -> Path:
    if user_input:
        p = Path(user_input).expanduser()
        if p.exists():
            return p
        raise FileNotFoundError(f"Input not found: {p}")

    # Defaults: try local dir first
    candidates = [
        Path("胶带&别针.png"),
        Path("胶带&别针.jpg"),
        Path("胶带&别针.jpeg"),
        # Common location in this repo:
        Path("../frontend-app/homepage_material/胶带&别针.png"),
        Path("../frontend-app/homepage_material/胶带&别针.jpg"),
        Path("../frontend-app/homepage_material/胶带&别针.jpeg"),
    ]
    for c in candidates:
        if c.exists():
            return c

    tried = ", ".join(str(c) for c in candidates)
    raise FileNotFoundError(f"Could not find input image. Tried: {tried}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Split tape/clip image and remove white background.")
    parser.add_argument(
        "--input",
        "-i",
        default=None,
        help="Input image path. If omitted, tries common filenames like '胶带&别针.png'.",
    )
    parser.add_argument(
        "--split",
        type=float,
        default=0.7,
        help="Left-area ratio for tape crop (0-1). Right side is used for clip. Default: 0.7",
    )
    parser.add_argument(
        "--threshold",
        type=int,
        default=200,
        help="White threshold (RGB > threshold treated as background). Default: 200",
    )
    parser.add_argument(
        "--out-dir",
        default=".",
        help="Output directory. Default: current directory",
    )
    parser.add_argument("--tape-name", default="tape.png", help="Output filename for tape. Default: tape.png")
    parser.add_argument("--clip-name", default="clip.png", help="Output filename for clip. Default: clip.png")
    args = parser.parse_args()

    input_path = _resolve_input_path(args.input)
    out_dir = Path(args.out_dir).expanduser()
    out_dir.mkdir(parents=True, exist_ok=True)

    original = Image.open(input_path)
    w, h = original.size

    split = max(0.0, min(1.0, float(args.split)))
    split_x = int(w * split)

    tape_area = original.crop((0, 0, split_x, h))
    clip_area = original.crop((split_x, 0, w, h))

    tape_out = _convert_to_transparent(tape_area, white_threshold=int(args.threshold))
    clip_out = _convert_to_transparent(clip_area, white_threshold=int(args.threshold))

    tape_path = out_dir / args.tape_name
    clip_path = out_dir / args.clip_name

    tape_out.save(tape_path, "PNG")
    clip_out.save(clip_path, "PNG")

    print(f"✅ Input: {input_path}")
    print(f"✅ Generated: {tape_path}")
    print(f"✅ Generated: {clip_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
from PIL import Image

def convert_to_transparent(image_path, output_name):
    img = Image.open(image_path).convert("RGBA")
    datas = img.getdata()
    new_data = []
    
    for item in datas:
        # 简单的白底变透明算法
        # 如果像素点比较白（RGB都大于200），就调整透明度
        if item[0] > 200 and item[1] > 200 and item[2] > 200:
            avg = (item[0] + item[1] + item[2]) / 3
            # 越白越透明，保留边缘羽化
            alpha = 255 - int((avg - 200) * (255 / (255 - 200)))
            new_data.append((item[0], item[1], item[2], max(0, alpha)))
        else:
            new_data.append(item)
            
    img.putdata(new_data)
    # 自动裁剪掉多余的透明边框
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)
    img.save(output_name, "PNG")
    print(f"✅ 已生成: {output_name}")

# 1. 你需要先手动把原图切成两张小图：raw_tape.jpg 和 raw_clip.jpg
#    或者直接用下面的代码尝试自动裁剪（根据你图片的位置估算）
try:
    original = Image.open("胶带&别针.jpg")
    w, h = original.size
    
    # 裁剪左边的胶带 (假设在左侧 70% 区域)
    tape_area = original.crop((0, 0, int(w * 0.7), h))
    tape_area.save("temp_tape.jpg")
    convert_to_transparent("temp_tape.jpg", "tape.png")
    
    # 裁剪右边的别针 (假设在右侧 30% 区域)
    clip_area = original.crop((int(w * 0.7), 0, w, h))
    clip_area.save("temp_clip.jpg")
    convert_to_transparent("temp_clip.jpg", "clip.png")
    
except Exception as e:
    print(f"出错了: {e}，请确保文件名是 '胶带&别针.jpg'")