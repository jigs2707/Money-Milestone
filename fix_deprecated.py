#!/usr/bin/env python3
"""
Replace deprecated Flutter APIs:
  1. Color.withOpacity(x)  →  Color.withValues(alpha: x)
  2. BouncingScrollPhysics() → AlwaysScrollableScrollPhysics()
  3. ClampingScrollPhysics() → ClampingScrollPhysics()  [still fine, but remove const if needed]

Run from the project root:
  python3 fix_deprecated.py
"""

import re
import os
import glob

ROOT = "lib"

# Files to process
dart_files = glob.glob(os.path.join(ROOT, "**", "*.dart"), recursive=True)

# ─── Replacement 1: .withOpacity(expr) → .withValues(alpha: expr) ───────────
# Handles single-level expressions (no nested parens in the argument)
OPACITY_RE = re.compile(r"\.withOpacity\(([^()]+)\)")


def replace_with_opacity(m):
    return f".withValues(alpha: {m.group(1)})"


# ─── Replacement 2: BouncingScrollPhysics → AlwaysScrollableScrollPhysics ───
BOUNCING_RE = re.compile(r"\bBouncingScrollPhysics\b")

# ─── Summary ─────────────────────────────────────────────────────────────────
total_files_changed = 0
total_replacements = 0

for path in sorted(dart_files):
    with open(path, "r", encoding="utf-8") as f:
        original = f.read()

    text = original

    # 1. withOpacity → withValues(alpha:)
    text, n1 = OPACITY_RE.subn(replace_with_opacity, text)

    # 2. BouncingScrollPhysics → AlwaysScrollableScrollPhysics
    text, n2 = BOUNCING_RE.subn("AlwaysScrollableScrollPhysics", text)

    count = n1 + n2
    if count > 0:
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        print(f"  [{count:3d} replacements]  {path}")
        total_files_changed += 1
        total_replacements += count

print()
print(f"Done — {total_replacements} replacements across {total_files_changed} files.")
