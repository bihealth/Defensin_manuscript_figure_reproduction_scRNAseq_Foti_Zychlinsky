#!/bin/bash
# Render all figures, or a user-specified subset, on a SLURM cluster.
#
#   ./render_figures.sh                                  # all 5 figures
#   ./render_figures.sh Fig5 SFig12                       # only these
#   CONDA_ENV=seurat5_voltron ./render_figures.sh Fig5    # smoke-test against an existing env
#   MEM=300GB ./render_figures.sh Fig5                    # more memory than the 150GB default
set -euo pipefail
cd "$(dirname "$0")"

ALL_FIGURES=(Fig5 SFig11 SFig12 SFig13 SFig14)

if [ $# -eq 0 ]; then
  targets=("${ALL_FIGURES[@]}")
else
  targets=("$@")
fi

export_vars="RMD_PATH"
if [ -n "${CONDA_ENV:-}" ]; then
  export_vars="RMD_PATH,CONDA_ENV"
fi

# sbatch CLI flags override the #SBATCH defaults baked into render_one.sbatch.
sbatch_resource_args=()
[ -n "${MEM:-}" ] && sbatch_resource_args+=(--mem="$MEM")
[ -n "${TIME:-}" ] && sbatch_resource_args+=(--time="$TIME")
[ -n "${PARTITION:-}" ] && sbatch_resource_args+=(--partition="$PARTITION")

for fig in "${targets[@]}"; do
  rmd="../figures/${fig}.Rmd"
  if [ ! -f "$rmd" ]; then
    echo "Unknown figure '$fig' (expected one of: ${ALL_FIGURES[*]})" >&2
    exit 1
  fi
  echo "Submitting $fig..."
  RMD_PATH="$rmd" sbatch "${sbatch_resource_args[@]}" --export="$export_vars" render_one.sbatch
done
