#!/usr/bin/env python3
"""Draw the BMI Pocket Calculator icon set and compose store images.

Run after capturing popup screenshots into store-assets/raw/ (see README in this folder).
"""
from pathlib import Path
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parent
EXT = ROOT.parent
BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
REG = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
TEAL_D, TEAL_L, BG, INK = (12, 66, 58), (18, 112, 98), (227, 234, 229), (22, 48, 43)


def icon(size=1024):
    s = size
    base = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    grad = Image.new("RGBA", (s, s))
    gd = ImageDraw.Draw(grad)
    for y in range(s):
        t = y / s
        gd.line([(0, y), (s, y)], fill=tuple(int(TEAL_L[i] * (1 - t) + TEAL_D[i] * t) for i in range(3)) + (255,))
    mask = Image.new("L", (s, s), 0)
    ImageDraw.Draw(mask).rounded_rectangle([s * .04, s * .04, s * .96, s * .96], radius=s * .2, fill=255)
    base.paste(grad, (0, 0), mask)
    d = ImageDraw.Draw(base)
    cx, cy, r = s / 2, s * .53, s * .33
    w = int(s * .06)
    d.arc([cx - r, cy - r, cx + r, cy + r], 200, 340, fill="white", width=w)
    for a in range(205, 340, 22):
        ra = math.radians(a)
        r1, r2 = r - w * 1.4, r - w * 2.2
        d.line([(cx + r1 * math.cos(ra), cy + r1 * math.sin(ra)), (cx + r2 * math.cos(ra), cy + r2 * math.sin(ra))], fill="white", width=int(s * .025))
    na = math.radians(292)
    d.line([(cx, cy - r * .05), (cx + r * .78 * math.cos(na), cy + r * .78 * math.sin(na))], fill=(255, 214, 120), width=int(s * .035))
    d.ellipse([cx - s * .035, cy - r * .05 - s * .035, cx + s * .035, cy - r * .05 + s * .035], fill=(255, 214, 120))
    f = ImageFont.truetype(BOLD, int(s * .27))
    d.text((cx, s * .74), "BMI", font=f, fill="white", anchor="mm")
    return base


def write_icons():
    big = icon(1024)
    for n in (16, 32, 48, 128, 256):
        im = big.resize((n, n), Image.LANCZOS)
        im.save(EXT / "shared" / "icons" / f"icon{n}.png")
    logo = Image.new("RGBA", (300, 300), (0, 0, 0, 0))
    logo.alpha_composite(big.resize((300, 300), Image.LANCZOS))
    logo.save(ROOT / "edge-logo-300x300.png")
    big.resize((128, 128), Image.LANCZOS).save(ROOT / "amo-icon-128x128.png")


def card(shot, h):
    im = Image.open(shot).convert("RGBA")
    im = im.resize((int(im.width * h / im.height), h), Image.LANCZOS)
    m = Image.new("L", im.size, 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, im.width - 1, im.height - 1], radius=18, fill=255)
    im.putalpha(m)
    return im


def compose(shot, title, sub, out, size=(1280, 800)):
    W, H = size
    k = W / 1280
    can = Image.new("RGBA", size, BG + (255,))
    d = ImageDraw.Draw(can)
    c = card(shot, int(H * .88))
    x, y = int(W - c.width - 110 * k), int((H - c.height) / 2)
    sh = Image.new("RGBA", size, (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle([x + 8, y + 14, x + c.width + 8, y + c.height + 14], radius=22, fill=(0, 0, 0, 70))
    can.alpha_composite(sh.filter(ImageFilter.GaussianBlur(14 * k)))
    can.alpha_composite(c, (x, y))
    ic = icon(256).resize((int(84 * k), int(84 * k)), Image.LANCZOS)
    can.alpha_composite(ic, (int(80 * k), int(150 * k)))
    tf = ImageFont.truetype(BOLD, int(50 * k))
    sf = ImageFont.truetype(REG, int(25 * k))
    ty = int(270 * k)
    for line in title.split("\n"):
        d.text((int(80 * k), ty), line, font=tf, fill=TEAL_D)
        ty += int(62 * k)
    ty += int(18 * k)
    for line in sub.split("\n"):
        d.text((int(80 * k), ty), line, font=sf, fill=INK)
        ty += int(36 * k)
    can.convert("RGB").save(out)


def promo(out, size=(440, 280)):
    W, H = size
    can = Image.new("RGB", size, TEAL_D)
    g = ImageDraw.Draw(can)
    for yy in range(H):
        t = yy / H
        g.line([(0, yy), (W, yy)], fill=tuple(int(TEAL_L[i] * (1 - t) + TEAL_D[i] * t) for i in range(3)))
    can = can.convert("RGBA")
    can.alpha_composite(icon(256).resize((120, 120), Image.LANCZOS), (30, 80))
    d = ImageDraw.Draw(can)
    d.text((170, 98), "BMI Pocket", font=ImageFont.truetype(BOLD, 34), fill="white")
    d.text((170, 140), "Calculator", font=ImageFont.truetype(BOLD, 34), fill="white")
    d.text((170, 188), "Offline · private · no account", font=ImageFont.truetype(REG, 15), fill=(220, 240, 234))
    can.convert("RGB").save(out)


if __name__ == "__main__":
    import sys
    write_icons()
    raw = ROOT / "raw"
    if raw.exists():
        items = [
            ("adult", "Adult BMI with\nWHO classes", "Weight and height in, BMI and\nclass out. Shows how many kg\nyou are from the normal range."),
            ("child", "Child BMI-for-age\npercentiles", "Ages 2-19 with CDC LMS growth\ntables, by age and sex, not\nadult cut-offs."),
            ("pregnancy", "Pregnancy weight\ngain bands", "Total gain range from\npre-pregnancy BMI (IOM/ACOG)\nplus a check for your week."),
            ("history", "Private local\nhistory", "Save results in this browser\nonly. Copy one in a tap.\nNo account, nothing uploaded."),
        ]
        for i, (n, t, s) in enumerate(items, 1):
            compose(raw / f"{n}.png", t, s, ROOT / f"screenshot-{i}-{n}-1280x800.png")
            compose(raw / f"{n}.png", t, s, ROOT / f"screenshot-{i}-{n}-640x400.png", (640, 400))
    promo(ROOT / "promo-small-440x280.png")
    print("ok")
