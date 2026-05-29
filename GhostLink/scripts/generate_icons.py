#!/usr/bin/env python3
"""Generate GHOSTLINK AppIcon PNGs (black + pink ghost + GL)."""
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    import subprocess
    import sys
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pillow", "-q"])
    from PIL import Image, ImageDraw, ImageFont

OUT = Path(__file__).resolve().parents[1] / "GhostLink" / "Assets.xcassets" / "AppIcon.appiconset"
SIZES = {
    "Icon-40.png": 40,
    "Icon-60.png": 60,
    "Icon-58.png": 58,
    "Icon-87.png": 87,
    "Icon-80.png": 80,
    "Icon-120.png": 120,
    "Icon-180.png": 180,
    "Icon-1024.png": 1024,
}

PINK = (255, 42, 109)
BLACK = (0, 0, 0)
PINK_LIGHT = (255, 102, 196)


def draw_icon(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size), BLACK)
    d = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2
    r = int(size * 0.28)
    for i in range(5, 0, -1):
        shade = max(1, PINK[0] // (i + 1))
        d.ellipse(
            [cx - r - i * 2, cy - r - i * 2, cx + r + i * 2, cy + r + i * 2],
            outline=(shade, PINK[1] // (i + 1), PINK[2] // (i + 1)),
        )
    d.ellipse([cx - r, cy - r, cx + r, cy + r // 2], fill=PINK)
    er = max(2, size // 25)
    d.ellipse([cx + r // 4 - er, cy - r // 4 - er, cx + r // 4 + er, cy - r // 4 + er], fill=BLACK)
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", max(10, size // 6))
    except OSError:
        try:
            font = ImageFont.truetype("arial.ttf", max(10, size // 6))
        except OSError:
            font = ImageFont.load_default()
    d.text((cx - r, cy + r // 3), "GL", fill=PINK_LIGHT, font=font)
    return img


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for name, size in SIZES.items():
        draw_icon(size).save(OUT / name)
        print("Wrote", OUT / name)


if __name__ == "__main__":
    main()
