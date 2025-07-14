# python3 - <<'PY'
import re, pathlib
src = pathlib.Path("FontStore.sol").read_text()
parts = re.findall(r'SLICE_\d+\s*=\s*"([^"]+)"', src)
print("slices =", len(parts), " total chars =", sum(len(p) for p in parts))