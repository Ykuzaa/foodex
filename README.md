# Foodex

Notebook and report pipeline for training a YOLO11 food detector on four classes:

- pizza
- sandwich
- pasta
- hotdog

## Structure

```text
configs/food_dataset.yaml
notebooks/food_detection_training.ipynb
report/report.tex
report/references.bib
report/figures/
```

The notebook writes training outputs to `runs_food/` in this repository.

## Dataset

The repository is designed to be self-contained:

```text
dataset/
  images/
  labels/
```

The notebook detects the repository root automatically and reads `dataset/` from there.

## Training

Simplest setup: use the existing GPU kernel provided by Jupyter, without installing a new PyTorch CUDA stack:

```bash
cd foodex
bash scripts/setup_existing_kernel.sh
```

This script checks that the current kernel already has PyTorch with CUDA, then installs only lightweight missing dependencies.

Alternative isolated setup:

```bash
cd foodex
bash scripts/setup_foodex_env.sh
```

If the CUDA PyTorch installation fails with `No space left on device`, create the environment outside the cloned repository, for example in `/tmp`:

```bash
cd foodex
rm -rf foodex-env /tmp/foodex-env
FOODEX_ENV_DIR=/tmp/foodex-env bash scripts/setup_foodex_env.sh
```

Then select this kernel in Jupyter:

```text
Python - foodex-env
```

Optional quick check:

```text
notebooks/00_environment_check.ipynb
```

Then open:

```text
notebooks/food_detection_training.ipynb
```

Run the audit and visualization cells first. To train:

- set `RUN_BASELINE = True` for YOLO11s
- set `RUN_MAIN_TRAINING = True` for YOLO11m

## Report

After the notebook generates figures, build the report from `report/`:

```bash
pdflatex report.tex
bibtex report
pdflatex report.tex
pdflatex report.tex
```
