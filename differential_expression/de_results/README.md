# Pseudobulk DE result tables

The 6 pairwise DESeq2 result tables produced by
[`../02_deseq2_tmod.Rmd`](../02_deseq2_tmod.Rmd) from `data/20250919_pbmc.rds`
(via [`../01_pseudobulk_count_tables.Rmd`](../01_pseudobulk_count_tables.Rmd)).
Vendored here directly (~95MB total, well within what's reasonable to commit)
so that `figures/Fig5.Rmd`, `SFig12.Rmd`, `SFig13.Rmd`, and `SFig14.Rmd` can
render without first re-running the DE pipeline — all four default
`params$de_dir` to this directory.

| File | Contrast |
|---|---|
| `results_UM_vs_X.tsv` | HNP1 vs vehicle |
| `results_Cl_vs_X.tsv` | ClY21-HNP1 vs vehicle |
| `results_I_vs_X.tsv` | IY16-HNP1 vs vehicle |
| `results_Cl_vs_UM.tsv` | ClY21-HNP1 vs HNP1 |
| `results_I_vs_UM.tsv` | IY16-HNP1 vs HNP1 |
| `results_Cl_vs_I.tsv` | ClY21-HNP1 vs IY16-HNP1 |

Each is a per-gene, per-cell-type DESeq2 results table (`baseMean`,
`log2FoldChange`, `pvalue`, `padj`, etc., plus `cell_type` and `contrast`
columns), read by [`../../R/io_helpers.R`](../../R/io_helpers.R)'s
`load_de_results()`.

To regenerate these yourself instead of using the vendored copy, run
`01_pseudobulk_count_tables.Rmd` then `02_deseq2_tmod.Rmd` and point the
figure Rmds' `params$de_dir` at `data/intermediate/de_results` (their
default output location) instead.
