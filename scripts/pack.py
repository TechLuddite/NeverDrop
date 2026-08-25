#!/usr/bin/env python3
"""Pack NeverDrop into dist/NeverDrop.vmz.

A .vmz is a zip. Metro requires mod.txt at the archive root, with forward-slash
paths. Zip the contents, not the folder that holds them.

Usage:
    python3 scripts/pack.py
    python3 scripts/pack.py --print-version
    python3 scripts/pack.py --out /tmp/NeverDrop.vmz
"""

from __future__ import annotations

import argparse
import re
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MOD_TXT = ROOT / "mod.txt"
VERSION_RE = re.compile(r'(?m)^version\s*=\s*"([^"]+)"')

# Packed as NeverDrop_LICENSE so it does not mount over res://LICENSE.
INCLUDE_ROOT = {
    "mod.txt": "mod.txt",
    "LICENSE": "NeverDrop_LICENSE",
}

SKIP_DIR_NAMES = {".git", ".github", "scripts", "dist", "__pycache__"}
SKIP_SUFFIXES = {".vmz", ".zip", ".pyc"}


def version() -> str:
    text = MOD_TXT.read_text(encoding="utf-8")
    match = VERSION_RE.search(text)
    if not match:
        raise SystemExit(f"version= not found in {MOD_TXT}")
    return match.group(1)


def _should_skip(path: Path) -> bool:
    if path.name.startswith("."):
        return True
    if path.suffix.lower() in SKIP_SUFFIXES:
        return True
    return any(part in SKIP_DIR_NAMES for part in path.relative_to(ROOT).parts)


def pack(out: Path) -> Path:
    if not MOD_TXT.is_file():
        raise SystemExit(f"mod.txt not found at {MOD_TXT}")
    mods = ROOT / "mods"
    if not mods.is_dir():
        raise SystemExit(f"mods/ not found at {mods}")

    out.parent.mkdir(parents=True, exist_ok=True)
    if out.exists():
        out.unlink()

    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zf:
        for src_name, arc_name in INCLUDE_ROOT.items():
            src = ROOT / src_name
            if src.is_file():
                zf.write(src, arcname=arc_name)

        for path in sorted(mods.rglob("*")):
            if not path.is_file() or _should_skip(path):
                continue
            zf.write(path, arcname=path.relative_to(ROOT).as_posix())

    return out


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--print-version", action="store_true")
    parser.add_argument("--out", type=Path, default=ROOT / "dist" / "NeverDrop.vmz")
    args = parser.parse_args()

    if args.print_version:
        print(version())
        return 0

    out = args.out
    pack(out)
    print(f"Built {out} v{version()} ({out.stat().st_size} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
