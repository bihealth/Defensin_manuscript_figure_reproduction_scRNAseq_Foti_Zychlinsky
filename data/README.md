# Data

This repo does not vendor any of the large source data files (the final RDS,
raw/CellBender h5s, or the PBMC reference) — those need to be downloaded
before rendering, as described below. It does vendor the (small) pseudobulk
DE result tables — see the end of this page.

## 1. The final annotated Seurat object (required for `differential_expression/` and `figures/`)

**`20250919_pbmc.rds`** — the Seurat v5 object (12 samples, donor 3 excluded,
label-transfer-annotated) that every manuscript figure was generated from.

Deposited on **figshare**: <https://doi.org/10.6084/m9.figshare.34022952>.

Download it and place it at `data/20250919_pbmc.rds` (this path is what
every downstream Rmd's `params$pbmc_rds` defaults to):

```bash
curl -L -o data/20250919_pbmc.rds https://ndownloader.figshare.com/files/69460476
```

(~13.2GB; the direct `ndownloader` link above comes from the figshare API
and downloads the file itself, unlike the DOI link which resolves to the
HTML landing page).

## 2. Processed data (count matrices) — GEO accession GSE344857

The processed data underlying the manuscript (per-sample count matrices) are
deposited at GEO: **[GSE344857](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE344857)**.
This is only needed if you want to rebuild `20250919_pbmc.rds` yourself from
`preprocessing/02_qc_clustering.Rmd` onward, or to reproduce the donor-3 QC
diagnostic (SFig12 A/E, see `docs/donor3_exclusion.md`) — not needed if you
only want to reproduce figures from the final RDS above.

**The h5 files deposited at GSE344857 are the raw Cell Ranger `multi`
output, *not* CellBender-denoised.** GEO hosts the per-sample supplementary
files as produced by Cell Ranger; CellBender's ambient-RNA removal was a
downstream processing step on top of those and its output was not itself
deposited. If you're starting from GEO rather than the figshare RDS, you
need to run CellBender yourself on the downloaded Cell Ranger h5 files
before this repo's pipeline can use them — see step 2 ("CellBender") in
[`../preprocessing/01_upstream_processing.md`](../preprocessing/01_upstream_processing.md)
for the exact command/parameters used in the original analysis. Only its
output (`<sample>_filtered_seurat.h5`) is what `preprocessing/02_qc_clustering.Rmd`
actually reads.

Once you have the 16 CellBender-denoised per-sample files, place them at:

```
data/cellbender_h5/BC001_filtered_seurat.h5
data/cellbender_h5/BC002_filtered_seurat.h5
...
data/cellbender_h5/BC016_filtered_seurat.h5
```

(this is what `preprocessing/02_qc_clustering.Rmd`'s `params$h5_dir` defaults to).

## 3. Human PBMC multimodal reference (required only to re-run `preprocessing/03_annotation_label_transfer.Rmd`)

Cell type annotation uses Seurat's classic multimodal reference-mapping
workflow (`SCTransform` -> `FindTransferAnchors` -> `MapQuery` -> `TransferData`
-> `IntegrateEmbeddings` -> `ProjectUMAP`, per the
[Seurat vignette](https://satijalab.org/seurat/articles/multimodal_reference_mapping.html))
against the public human PBMC multimodal atlas (Hao et al. 2021). This is a
third-party public reference, not specific to this study, and not needed if
you start from `20250919_pbmc.rds`.

Download the reference (~2.1GB `.h5seurat`):

```bash
wget https://atlas.fredhutch.org/data/nygc/multimodal/pbmc_multimodal.h5seurat \
  -O data/pbmc_multimodal.h5seurat
```

Converting it to the plain `.rds` that `params$reference_rds` expects needs
`SeuratDisk`, which is unmaintained (last updated ~2021) and assumes the old
`Assay` (Seurat v3/v4) class layout — it conflicts with `SeuratObject` v5,
pinned in `envs/environment.yaml`, and should **not** be installed into
`defensin_figures`. Do the one-time conversion in a separate,
throwaway conda env pinned to `SeuratObject` v4 instead, then upgrade the
result when loading it back into the main env:

```bash
# 1. One-off conversion env (never touches defensin_figures)
# r-matrix must be pinned below 1.6_2: that release reworked Matrix's S4
# class hierarchy (dropped the old "mMatrix" virtual class), which
# SeuratObject 4.1.4's Graph/Neighbor classes depend on - left unpinned,
# conda resolves a newer Matrix and LoadH5Seurat fails with
# "invalid class 'Graph' object: superclass 'mMatrix' not defined".
conda create -n h5seurat_convert -c conda-forge -c bioconda \
  r-base=4.3.3 r-seurat=4.4.0 r-seuratobject=4.1.4 r-matrix=1.6_1.1 \
  r-hdf5r=1.3.11 r-remotes
conda activate h5seurat_convert
Rscript -e 'remotes::install_github("mojaveazure/seurat-disk", upgrade = "never")'

# LoadH5Seurat reads every assay/reduction/graph into memory at once;
# confirmed working with --mem=24G on a SLURM job (an 8G interactive job
# gets OOM-killed).
Rscript -e '
  library(SeuratDisk)
  reference <- LoadH5Seurat("data/pbmc_multimodal.h5seurat")
  saveRDS(reference, "data/pbmc_multimodal_reference_v4.rds")
'
conda deactivate

# 2. Upgrade to Seurat v5 object shape inside the pipeline env
conda activate defensin_figures
Rscript -e '
  library(Seurat)
  reference <- UpdateSeuratObject(readRDS("data/pbmc_multimodal_reference_v4.rds"))
  saveRDS(reference, "data/pbmc_multimodal_reference.rds")
'
rm data/pbmc_multimodal_reference_v4.rds  # intermediate, no longer needed
```

This lands the final reference at `data/pbmc_multimodal_reference.rds`,
which is already `preprocessing/03_annotation_label_transfer.Rmd`'s
`params$reference_rds` default — no path change needed if you use this
location. `h5seurat_convert` can be deleted afterwards
(`conda env remove -n h5seurat_convert`); it's only needed once.

Note: `SeuratData::InstallData("pbmcref")` downloads a *different* artifact
(Azimuth's on-disk annoy-index reference, for `Azimuth::RunAzimuth()`) — it
is not a drop-in for the `FindTransferAnchors`/`MapQuery` pipeline this repo
uses, so use the `.h5seurat` download above instead.

## What's already included in this repo (no download needed)

Unlike the RDS/h5/reference above, the **pseudobulk DE result tables** —
[`../differential_expression/de_results/`](../differential_expression/de_results/)
(6 files, one per pairwise contrast, ~95MB total) — are small enough to
vendor directly, so they're committed to this repo rather than requiring a
download or a re-run of `differential_expression/`. `figures/Fig5.Rmd`,
`SFig13.Rmd`, `SFig14.Rmd`, and `SFig15.Rmd` all default `params$de_dir` to
that path. See its own README for provenance. This mirrors
[`../figures/SFig12_data/`](../figures/SFig12_data/), vendored for the same
reason.

## What is intentionally NOT here

Raw FASTQ files are not distributed (human-subjects data privacy) and are
not required to reproduce any figure — see
[`../preprocessing/01_upstream_processing.md`](../preprocessing/01_upstream_processing.md)
for why, and for how the upstream Cell Ranger/CellBender steps are documented
instead of included.
