#!/usr/bin/env python3
from pathlib import Path
import struct
import zlib

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "Facezero" / "Assets.xcassets"
APP_ICON = ASSETS / "AppIcon.appiconset" / "FacezeroIcon1024.png"
MASK_TEXTURE = ASSETS / "SampleMaskTexture.imageset" / "SampleMaskTexture.png"


def png_chunk(tag, data):
    return (
        struct.pack(">I", len(data))
        + tag
        + data
        + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
    )


def write_png(path, width, height, pixel_fn):
    path.parent.mkdir(parents=True, exist_ok=True)
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        for x in range(width):
            raw.extend(pixel_fn(x, y, width, height))

    data = b"\x89PNG\r\n\x1a\n"
    data += png_chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
    data += png_chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    data += png_chunk(b"IEND", b"")
    path.write_bytes(data)


def icon_pixel(x, y, w, h):
    cx = (x - w / 2) / (w / 2)
    cy = (y - h / 2) / (h / 2)
    r = 5 + int(16 * y / h)
    g = 7 + int(10 * y / h)
    b = 12 + int(20 * y / h)

    border = max(abs(cx), abs(cy))
    if 0.72 < border < 0.82:
        return (255, 112, 20, 255)

    hood = ((x - 512) / 270) ** 2 + ((y - 430) / 300) ** 2
    if hood < 1:
        r, g, b = 18, 20, 28

    face = ((x - 512) / 185) ** 2 + ((y - 475) / 230) ** 2
    if face < 1:
        r, g, b = 55, 35, 25

    for ex in (430, 594):
        d = ((x - ex) ** 2 + (y - 440) ** 2) ** 0.5
        if d < 60:
            glow = max(0, 1 - d / 60)
            r = int(r * (1 - glow) + 40 * glow)
            g = int(g * (1 - glow) + 220 * glow)
            b = int(b * (1 - glow) + 255 * glow)

    if 700 < y < 815 and 245 < x < 780:
        r, g, b = 26, 28, 36
        if y < 720 or y > 795 or x < 270 or x > 755:
            r, g, b = 255, 112, 20

    return (r, g, b, 255)


def texture_pixel(x, y, w, h):
    r, g, b = 34, 23, 18
    if x % 32 == 0:
        r, g, b = 80, 45, 20
    if y % 32 == 0:
        r, g, b = 20, 70, 80

    face = ((x - 256) / 140) ** 2 + ((y - 260) / 190) ** 2
    if face < 1:
        r, g, b = 68, 44, 30

    for ex in (205, 307):
        eye = ((x - ex) / 26) ** 2 + ((y - 212) / 16) ** 2
        if eye < 1:
            r, g, b = 30, 220, 255

    mouth = ((x - 256) / 55) ** 2 + ((y - 315) / 18) ** 2
    if 0.75 < mouth < 1.05 and y > 300:
        r, g, b = 255, 115, 20

    return (r, g, b, 255)


def main():
    write_png(APP_ICON, 1024, 1024, icon_pixel)
    write_png(MASK_TEXTURE, 512, 512, texture_pixel)
    print(f"Generated {APP_ICON}")
    print(f"Generated {MASK_TEXTURE}")


if __name__ == "__main__":
    main()
