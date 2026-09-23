#!/usr/bin/env python3
"""Set the Large Address Aware bit on a 32-bit PRM.exe, keeping a backup."""

from pathlib import Path
import shutil
import struct
import sys


def main() -> int:
    exe = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).with_name("PRM.exe")
    with exe.open("r+b") as f:
        if f.read(2) != b"MZ":
            raise SystemExit(f"Not a PE executable: {exe}")
        f.seek(0x3C)
        pe_offset = struct.unpack("<I", f.read(4))[0]
        f.seek(pe_offset)
        if f.read(4) != b"PE\0\0":
            raise SystemExit(f"Invalid PE header: {exe}")
        machine = struct.unpack("<H", f.read(2))[0]
        f.seek(pe_offset + 4 + 18)
        chars = struct.unpack("<H", f.read(2))[0]
        if machine != 0x014C:
            raise SystemExit(f"Expected 32-bit x86 PRM.exe, got machine 0x{machine:04x}")
        if chars & 0x0020:
            return 0

        backup = exe.with_name(exe.name + ".pre-laa")
        shutil.copy2(exe, backup)
        f.seek(pe_offset + 4 + 18)
        f.write(struct.pack("<H", chars | 0x0020))
        f.flush()
    print(f"Enabled LAA (Characteristics=0x{chars | 0x0020:04x}); backup: {backup.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
