#!/usr/bin/env python3
"""Generate GHOSTLINK AppIcon PNGs (black + pink ghost + GL)."""
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("Install: pip install pillow")
    raise

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
    # glow
    for i in range(5, 0, -1):
        d.ellipse([cx - r - i * 3, cy - r - i * 3, cx + r + i * 3, cy + r + i * 3], outline=PINK_LIGHT + (0,))
        d.ellipse([cx - r - i * 2, cy - r - i * 2, cx + r + i * 2, cy + r + i * 2], outline=(PINK[0] // (i + 1), PINK[1] // (i + 1), PINK[2] // (i + 1)))
    # ghost body
    d.ellipse([cx - r, cy - r, cx + r, cy + r // 2], fill=PINK)
    # tail waves
    wave = int(size * 0.08)
    base_y = cy + r // 2
    for i in range(3):
        x0 = cx - r + i * (2 * r // 3)
        d.arc([x0, base_y - wave, x0 + 2 * r // 3, base_y + wave], 0, 180, fill=PINK)
    # eye
    er = max(2, size // 25)
    d.ellipse([cx + r // 4 - er, cy - r // 4 - er, cx + r // 4 + er, cy - r // 4 + er], fill=BLACK)
    # GL text
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
