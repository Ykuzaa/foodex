#!/usr/bin/env bash
set -euo pipefail

ENV_NAME="${1:-foodex-env}"
PYTHON_BIN="${PYTHON_BIN:-}"
TORCH_CUDA_INDEX="${TORCH_CUDA_INDEX:-https://download.pytorch.org/whl/cu124}"

if [[ -z "${PYTHON_BIN}" ]]; then
  for candidate in python3.11 python3.12 python3.10; do
    if command -v "${candidate}" >/dev/null 2>&1; then
      PYTHON_BIN="${candidate}"
      break
    fi
  done
fi

if [[ -z "${PYTHON_BIN}" ]]; then
  echo "ERROR: Aucun Python 3.10/3.11/3.12 trouve."
  echo "Installe ou selectionne un kernel Python 3.11/3.12. Evite Python 3.13 pour PyTorch/Ultralytics."
  exit 1
fi

PY_VERSION="$("${PYTHON_BIN}" - <<'PY'
import sys
print(f"{sys.version_info.major}.{sys.version_info.minor}")
PY
)"

case "${PY_VERSION}" in
  3.10|3.11|3.12) ;;
  *)
    echo "ERROR: ${PYTHON_BIN} est en Python ${PY_VERSION}. Utilise Python 3.10, 3.11 ou 3.12."
    exit 1
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_DIR="${PROJECT_ROOT}/${ENV_NAME}"

echo "Project root : ${PROJECT_ROOT}"
echo "Python       : ${PYTHON_BIN} (${PY_VERSION})"
echo "Env          : ${ENV_DIR}"
echo "Torch index  : ${TORCH_CUDA_INDEX}"

"${PYTHON_BIN}" -m venv "${ENV_DIR}"
source "${ENV_DIR}/bin/activate"

python -m pip install --upgrade pip setuptools wheel

# Keep only headless OpenCV. opencv-python requires GUI system libraries such as libxcb.
python -m pip uninstall -y opencv-python opencv-contrib-python opencv-python-headless || true

python -m pip install --no-cache-dir \
  pandas==2.3.3 \
  matplotlib==3.10.8 \
  seaborn==0.13.2 \
  PyYAML==6.0.3 \
  ipykernel

python -m pip install --no-cache-dir torch torchvision torchaudio --index-url "${TORCH_CUDA_INDEX}"

# Install Ultralytics with its dependencies, then replace GUI OpenCV with headless OpenCV.
python -m pip install --no-cache-dir ultralytics==8.4.39
python -m pip uninstall -y opencv-python opencv-contrib-python opencv-python-headless || true
python -m pip install --no-cache-dir opencv-python-headless==4.13.0.92 pandas==2.3.3

python -m ipykernel install --user --name "${ENV_NAME}" --display-name "Python - ${ENV_NAME}"

python "${PROJECT_ROOT}/scripts/verify_environment.py"

echo
echo "OK. Dans Jupyter, selectionne le kernel: Python - ${ENV_NAME}"
