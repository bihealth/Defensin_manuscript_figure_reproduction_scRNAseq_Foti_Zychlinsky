# Rendering

Requires the `defensin_figures` conda env (see
[`../envs/`](../envs/)) and `20250919_pbmc.rds` + the sample tables in place
(see [`../data/README.md`](../data/README.md)).

```bash
./render_figures.sh                # render all 5 figures (submits 5 SLURM jobs)
./render_figures.sh Fig5 SFig12    # render only these
```

Each figure is submitted as its own SLURM job (`render_one.sbatch`,
`sbatch --export=RMD_PATH=...`), following the same pattern as the original
analysis's `render_*.sh` scripts. Edit the `conda activate` line in
`render_one.sbatch` if your cluster's setup differs.

## Resources

`render_one.sbatch` defaults to `--mem=150GB --time=4:00:00 --partition=medium`
— an interactive session's default allocation is usually not enough, since
loading `20250919_pbmc.rds` alone (~14GB on disk) needs a large working-memory
headroom. This matches what the original analysis used for its own
figure-assembly render step. `sbatch` CLI flags override the script's
`#SBATCH` defaults, and `render_figures.sh` forwards `MEM`/`TIME`/`PARTITION`
if set:

```bash
MEM=300GB ./render_figures.sh Fig5
# equivalent, for a one-off Rmd not covered by render_figures.sh:
sbatch --mem=300GB --export=RMD_PATH=../figures/Fig5.Rmd render_one.sbatch
```

For reference, resource requests the original analysis used per pipeline
stage (a reasonable starting point if you're submitting `preprocessing/` or
`differential_expression/` Rmds directly with `render_one.sbatch`, which
tend to need more than the figures do):

| Stage | mem | partition | time |
|---|---|---|---|
| `preprocessing/02_qc_clustering.Rmd` | 150GB | medium | 24h |
| `preprocessing/03_annotation_label_transfer.Rmd` | 400GB | highmem | 24h |
| `differential_expression/01_pseudobulk_count_tables.Rmd` | 40GB | medium | 4h |
| `differential_expression/02_deseq2_tmod.Rmd` | 40GB | medium | 4h |
| `figures/*.Rmd` | 150GB | medium | 4h |

e.g.:

```bash
sbatch --mem=400GB --partition=highmem --time=24:00:00 \
  --export=RMD_PATH=../preprocessing/03_annotation_label_transfer.Rmd render_one.sbatch
```

Without SLURM, render a figure directly:

```r
rmarkdown::render("figures/Fig5.Rmd")
```

Output lands in `output/<Figure>/<Figure>.pdf` and
`output/<Figure>/<Figure>_data.xlsx` (one sheet per panel).
