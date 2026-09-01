# Run once after activating the defensin_figures conda env.
# tmod is not distributed via conda/Bioconductor; the original analysis
# installed it straight from GitHub, and every downstream/DE/figure Rmd
# in this repo depends on it for gene set enrichment (tmodCERNOtest,
# ggPanelplot, ggEvidencePlot).
#
# upgrade = "never" is required: devtools::install_github's default
# ("ask") silently becomes "always upgrade" in a non-interactive Rscript
# session, which was clobbering the conda-pinned ggplot2=3.5.1 with a
# newer CRAN release and breaking patchwork's `&`/`+` dispatch. Pinned to
# commit 3bdcabf (DESCRIPTION Version: 0.50.13 - no git tag exists for
# this release) to match the version the manuscript figures were
# rendered with (see envs/README.md provenance note).
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools", repos = "https://cloud.r-project.org")
}
devtools::install_github("january3/tmod@3bdcabf85dba58e56d52e9be9313c334f6a79386", upgrade = "never")

# presto is not on conda/Bioconductor either. Seurat's FindMarkers/
# FindAllMarkers (used twice in preprocessing/02_qc_clustering.Rmd) detect
# it via requireNamespace and use it for a fast presto-based Wilcoxon
# implementation when available, falling back to a much slower base-R loop
# otherwise - this is what was making FindAllMarkers slow without it. 

if (!"BiocManager" %in% installed.packages()) {
          install.packages("BiocManager", repos = "https://cloud.r-project.org")
}

BiocManager::install("immunogenomics/presto")

