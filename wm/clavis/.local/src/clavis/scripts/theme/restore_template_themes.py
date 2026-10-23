#!/usr/bin/env python3
"""Restore only disabled built-in selectors, serialized with theme generation."""
from pathlib import Path
import subprocess
import sys
root=Path(__file__).resolve().parent
code=0
for name in dict.fromkeys(sys.argv[1:]):
    if name not in ("kitty","yazi","icons"):continue
    result=subprocess.run([sys.executable,str(root/(name+"_theme.py")),"restore"],check=False)
    code=code or result.returncode
sys.exit(code)
