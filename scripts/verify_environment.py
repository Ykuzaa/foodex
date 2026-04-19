import sys
from pathlib import Path


def fail(message: str) -> None:
    print(f"ERROR: {message}")
    raise SystemExit(1)


version = sys.version_info
if not ((3, 10) <= (version.major, version.minor) <= (3, 12)):
    fail(
        f"Python {version.major}.{version.minor} detecte. "
        "Utilise Python 3.10, 3.11 ou 3.12 pour PyTorch/Ultralytics."
    )

try:
    import cv2
except Exception as exc:
    fail(f"OpenCV import failed: {exc}")

try:
    import pandas as pd
    import torch
    import yaml
    from ultralytics import YOLO  # noqa: F401
except Exception as exc:
    fail(f"Import failed: {exc}")

project_root = Path(__file__).resolve().parents[1]
required_paths = [
    project_root / "configs" / "food_dataset.yaml",
    project_root / "dataset" / "images" / "train",
    project_root / "dataset" / "labels" / "train",
    project_root / "notebooks" / "food_detection_training.ipynb",
]
missing = [str(path) for path in required_paths if not path.exists()]
if missing:
    fail("Fichiers/dossiers manquants:\n" + "\n".join(missing))

print("Environment OK")
print(f"Python : {sys.version.split()[0]}")
print(f"cv2    : {cv2.__version__}")
print(f"pandas : {pd.__version__}")
print(f"torch  : {torch.__version__}")
print(f"yaml   : {yaml.__version__}")
print(f"CUDA   : {torch.cuda.is_available()}")
if torch.cuda.is_available():
    print(f"GPU    : {torch.cuda.get_device_name(0)}")
