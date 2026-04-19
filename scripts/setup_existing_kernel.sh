#!/usr/bin/env bash
set -euo pipefail

PYTHON_BIN="${PYTHON_BIN:-}"

if [[ -z "${PYTHON_BIN}" ]]; then
  # Prefer the Python executable that already has a working CUDA PyTorch install.
  for candidate in python python3.13 python3.12 python3.11 python3.10; do
    if command -v "${candidate}" >/dev/null 2>&1; then
      if "${candidate}" - <<'PY' >/dev/null 2>&1
import sys
if sys.version_info < (3, 10):
    raise SystemExit(1)
import torch
raise SystemExit(0 if torch.cuda.is_available() else 1)
PY
      then
        PYTHON_BIN="${candidate}"
        break
      fi
    fi
  done
fi

if [[ -z "${PYTHON_BIN}" ]]; then
  echo "ERROR: Aucun Python avec PyTorch CUDA fonctionnel trouve."
  echo "Teste avec: python -c 'import torch; print(torch.cuda.is_available())'"
  exit 1
fi

echo "Using Python: $(${PYTHON_BIN} -c 'import sys; print(sys.executable)')"
echo "Version     : $(${PYTHON_BIN} -c 'import sys; print(sys.version.replace(chr(10), " "))')"
echo

"${PYTHON_BIN}" - <<'PY'
import sys

if sys.version_info < (3, 10):
    raise SystemExit(
        f"ERROR: Python {sys.version_info.major}.{sys.version_info.minor} detecte. "
        "Utilise un kernel Python >= 3.10."
    )

try:
    import torch
except Exception as exc:
    raise SystemExit(
        "ERROR: PyTorch n'est pas utilisable dans ce kernel.\n"
        "Choisis une image/kernel Jupyter GPU avec PyTorch deja installe.\n"
        f"Erreur import torch: {exc}"
    )

print("Torch:", torch.__version__)
print("CUDA :", torch.cuda.is_available())
if torch.cuda.is_available():
    print("GPU  :", torch.cuda.get_device_name(0))
else:
    raise SystemExit(
        "ERROR: PyTorch est present mais CUDA=False. "
        "Choisis le kernel/image GPU PyTorch de la plateforme."
    )
PY

echo
echo "Installing lightweight dependencies only. This does NOT install torch."

"${PYTHON_BIN}" -m pip uninstall -y opencv-python opencv-contrib-python >/dev/null 2>&1 || true

"${PYTHON_BIN}" -m pip install --user --no-cache-dir \
  opencv-python-headless==4.13.0.92 \
  pandas==2.3.3 \
  matplotlib \
  seaborn \
  PyYAML \
  pillow \
  requests \
  scipy \
  tqdm \
  psutil \
  polars \
  ultralytics-thop

# Install Ultralytics without dependencies so pip does not try to replace the existing torch/CUDA stack.
"${PYTHON_BIN}" -m pip install --user --no-cache-dir --no-deps ultralytics==8.4.39

"${PYTHON_BIN}" "$(dirname "$0")/verify_environment.py"

echo
echo "OK. Redemarre le kernel Jupyter courant, puis lance notebooks/00_environment_check.ipynb."
