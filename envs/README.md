# Environment

Two-step build (conda alone is not enough — see below):

```bash
conda env create -f environment.yaml -n defensin_figures
conda activate defensin_figures
Rscript install_r_packages.R
```

(`mamba` works as a drop-in replacement for `conda` and is considerably faster.)

## Provenance

`environment.yaml` lists exactly the R packages that `preprocessing/`, `differential_expression/`, and `figures/` import in this repo, pinned to the versions the manuscript figures were originally rendered with. Versions were cross-checked against a full `conda env export` of the original analysis environment (`seurat5_voltron`, R 4.3.3, Seurat 5.1.0, DESeq2 1.42.0), which also confirmed that **tmod is not a conda/Bioconductor package** — it was installed with `devtools::install_github("january3/tmod")` in the original environment, hence the separate `install_r_packages.R` step. tmod is used by every DE/enrichment and figure Rmd (`tmodCERNOtest`, `ggPanelplot`, `ggEvidencePlot`).

Two more packages aren't imported via an explicit `library()` call anywhere in this repo, but are picked up internally by Seurat and matter for performance (not just correctness) if missing: **glmGamPoi** (`bioconductor-glmgampoi`, used by `SCTransform(vst.flavor="v2")` in `03_annotation_label_transfer.Rmd`) and **presto** (github-only, installed in `install_r_packages.R`, used by `FindAllMarkers` in `02_qc_clustering.Rmd`). Without them Seurat silently falls back to much slower base-R implementations rather than erroring, which is easy to miss until a step that should take minutes takes hours.

`environment.yaml` also pulls in **`r-data.table`** from conda-forge explicitly, even though nothing here calls it directly: it's a hard `Depends` of `presto`, and `presto` compiling it from source via `install.packages()`/`devtools` needs a full C/OpenMP toolchain that this trimmed env doesn't otherwise install, which fails with `installation of package 'data.table' had non-zero exit status`. Getting it as a conda-forge binary sidesteps that entirely.


The original `seurat5_voltron` environment additionally contained many packages unrelated to this analysis (spatial transcriptomics, trajectory inference, other-omics tooling) that are intentionally left out here to keep the build fast and the dependency surface small.
