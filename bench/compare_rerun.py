"""Run the unchanged historical comparator against newly measured outputs."""
import subprocess
import sys
from pathlib import Path
root=Path(__file__).resolve().parents[1]
raise SystemExit(subprocess.call([sys.executable,str(root/'bench/compare.py'),'app.json','comparison.json'],cwd=root/'rerun'))
