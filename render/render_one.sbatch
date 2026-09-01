#!/bin/bash
#SBATCH --time=4:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=150GB
#SBATCH --partition=medium
#SBATCH -o slurm.%N.%j.out
#SBATCH -e slurm.%N.%j.err

# Renders a single Rmd, passed in via `--export=RMD_PATH=path/to/file.Rmd`.
# Submitted per-figure by render_figures.sh; not usually run directly.
#
# The default --mem=150GB / --time=4:00:00 / --partition=medium matches what
# the original analysis used for its equivalent figure-assembly render step
# (loading the full ~14GB Seurat object is the main cost) - see render/README.md
# for what the original pipeline used for the heavier preprocessing steps.
# `sbatch` CLI flags override the #SBATCH lines above, e.g. for a step that
# needs more:
#   sbatch --mem=400GB --partition=highmem --export=RMD_PATH=../preprocessing/03_annotation_label_transfer.Rmd render_one.sbatch
#
# CONDA_ENV defaults to this repo's own env (defensin_figures) but
# can be overridden, e.g. to smoke-test against an existing env before that
# one has been built:
#   sbatch --export=RMD_PATH=../figures/Fig5.Rmd,CONDA_ENV=seurat5_voltron render_one.sbatch

set -euo pipefail

if [ -z "${RMD_PATH:-}" ]; then
  echo "RMD_PATH not set - submit via render_figures.sh, or: sbatch --export=RMD_PATH=../figures/Fig5.Rmd render_one.sbatch" >&2
  exit 1
fi

# Adjust to how conda/mamba is initialized on your cluster.
source ~/work/miniconda/bin/activate "${CONDA_ENV:-defensin_figures}"

Rscript -e "rmarkdown::render('${RMD_PATH}')"
