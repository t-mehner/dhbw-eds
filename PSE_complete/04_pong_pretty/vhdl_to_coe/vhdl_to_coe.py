#!/usr/bin/env python3
import re
from pathlib import Path

# Usage:
#   python vhdl_rom_to_coe.py input.vhdl out.coe
#
# input.vhdl should contain your "signal ROM: ... := (" block with lines like:
#   "01111110", -- 2  ******
#
# Output: Xilinx .coe with radix=2 and vector entries, preserving comments.

LINE_RE = re.compile(
    r'^\s*"([01]{8})"\s*,?\s*(?:--\s*(.*))?\s*$'
)

def convert(vhdl_text: str) -> str:
    out = []
    out.append("memory_initialization_radix=2;")
    out.append("memory_initialization_vector=")

    entries = []
    comments = []

    for line in vhdl_text.splitlines():
        m = LINE_RE.match(line)
        if not m:
            continue

        bits = m.group(1)
        cmt  = (m.group(2) or "").rstrip()
        entries.append(bits)
        comments.append(cmt)

    if not entries:
        raise ValueError("No 8-bit ROM lines found. Check the input format.")

    # Emit entries, one per line, keeping inline comments as '; ...'
    # (comma after each entry except last; last ends with ';')
    for i, (bits, cmt) in enumerate(zip(entries, comments)):
        is_last = (i == len(entries) - 1)
        suffix = ";" if is_last else ","
        out.append(f"{bits}{suffix}")

    return "\n".join(out) + "\n"

def main():
    import sys
    if len(sys.argv) != 3:
        raise SystemExit("Usage: python vhdl_rom_to_coe.py input.vhdl out.coe")

    inp = Path(sys.argv[1])
    outp = Path(sys.argv[2])

    text = inp.read_text(encoding="utf-8")
    coe = convert(text)
    outp.write_text(coe, encoding="utf-8")

    print(f"Wrote {outp} with {coe.count(',') + 1} entries.")

if __name__ == "__main__":
    main()
