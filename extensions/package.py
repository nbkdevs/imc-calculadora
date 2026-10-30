#!/usr/bin/env python3
"""Copy shared assets into firefox/edge and zip all browser packages."""
from __future__ import annotations

import json
import shutil
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SHARED = ROOT / "shared"
DIST = ROOT / "dist"

SHARED_FILES = [
    "popup.html",
    "css/popup.css",
    "js/calculators.js",
    "js/history.js",
    "js/popup.js",
    "data/cdc_bmi_lms.json",
    "icons/icon16.png",
    "icons/icon32.png",
    "icons/icon48.png",
    "icons/icon128.png",
    "icons/icon256.png",
]


def package_extension(browser: str) -> Path:
    dest = ROOT / browser
    for name in ("popup.html", "css", "js", "data", "icons"):
        p = dest / name
        if p.is_file():
            p.unlink()
        elif p.is_dir():
            shutil.rmtree(p)
    for rel in SHARED_FILES:
        src = SHARED / rel
        dst = dest / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
    DIST.mkdir(parents=True, exist_ok=True)
    zip_path = DIST / f"IMC-Calculadora-{browser}-1.0.0.zip"
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for path in dest.rglob("*"):
            if path.is_file():
                zf.write(path, path.relative_to(dest).as_posix())
    return zip_path


def package_theme() -> Path:
    theme = ROOT / "chrome-theme"
    DIST.mkdir(parents=True, exist_ok=True)
    zip_path = DIST / "IMC-Calculadora-chrome-theme-1.0.0.zip"
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for path in theme.rglob("*"):
            if path.is_file():
                zf.write(path, path.relative_to(theme).as_posix())
    return zip_path


def main() -> None:
    for browser in ("firefox", "edge"):
        path = package_extension(browser)
        print(f"{browser}: {path} ({path.stat().st_size} bytes)")
    theme = package_theme()
    print(f"theme: {theme} ({theme.stat().st_size} bytes)")
    # sanity: manifests parse
    for p in (ROOT / "firefox/manifest.json", ROOT / "edge/manifest.json", ROOT / "chrome-theme/manifest.json"):
        json.loads(p.read_text(encoding="utf-8"))
        print(f"ok {p.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
