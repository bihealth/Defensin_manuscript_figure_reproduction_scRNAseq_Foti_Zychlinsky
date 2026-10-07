# Defensin_manuscript_figure_reproduction_scRNAseq_Foti_Zychlinsky

[![DOI](https://zenodo.org/badge/1347135498.svg)](https://doi.org/10.5281/zenodo.23210106)

Code and supplementary files to reproduce the scRNA-seq figures of:

> **Tyrosine halogenation converts α-defensins into potent immunomodulators**
> Foti et al., *Science* (in press). <!-- TODO: full citation + DOI once published -->

This repo reproduces every scRNA-seq panel in the manuscript: **Figure 5**
(panels A-H), **Supplementary Figures 12-15** (all panels). 

## Quickstart

```bash
git clone <this-repo>
cd Defensin_manuscript_figure_reproduction_scRNAseq_Foti_Zychlinsky

conda env create -f envs/environment.yaml -n defensin_figures
conda activate defensin_figures
Rscript envs/install_r_packages.R

# download 20250919_pbmc.rds from figshare - see data/README.md
curl -L -o data/20250919_pbmc.rds https://ndownloader.figshare.com/files/69460476

rmarkdown::render("figures/Fig5.Rmd")   # to run locally
cd render
./render_figures.sh Fig5 # to run on SLURM cluster with a batch script
```

Every figure Rmd is self-contained and only needs `data/20250919_pbmc.rds`
plus the pseudobulk DE result tables — already vendored in
`differential_expression/de_results/` (see below), no regeneration needed —
to run.

## Repo map

| Path | What |
|---|---|
| [`envs/`](envs/) | Conda environment + a small post-install script (see below for why two steps) |
| [`data/`](data/) | Where to get the RDS/reference data this repo needs (not vendored here) |
| [`sample_tables/`](sample_tables/) | Donor/treatment/barcode metadata; see `docs/donor3_exclusion.md` |
| [`docs/donor3_exclusion.md`](docs/donor3_exclusion.md) | Why donor 3 was excluded, transparently documented |
| [`preprocessing/`](preprocessing/) | h5 -> QC/clustering -> label transfer -> `20250919_pbmc.rds` (documents Cell Ranger/CellBender too, non-runnable) |
| [`differential_expression/`](differential_expression/) | Pseudobulk aggregation + DESeq2 + tmod gene set enrichment. Its output, the 6 DE result tables, is vendored in `differential_expression/de_results/` (see its README) so figures don't need this stage re-run |
| [`R/`](R/) | Shared plotting/IO helpers used by every figure Rmd |
| [`figures/`](figures/) | One Rmd per figure: `Fig5.Rmd`, `SFig12.Rmd`, `SFig13.Rmd`, `SFig14.Rmd`, `SFig15.Rmd`. `SFig12.Rmd` additionally ships small precomputed inputs in `figures/SFig12_data/` (see its README) so it needs no preprocessing re-run |
| [`render/`](render/) | Render all figures, or a chosen subset, on a SLURM cluster |
| [`output/`](output/) | Rendered PDFs + one multi-sheet xlsx per figure (one sheet per panel), gitignored |
| `legacy/` | Superseded/exploratory scripts from the original analysis, kept only for historical reference - not part of the reproduction pipeline |

## Pipeline order

```
preprocessing/01_upstream_processing.md      (documentation only - Cell Ranger + CellBender)
  -> preprocessing/02_qc_clustering.Rmd
  -> preprocessing/03_annotation_label_transfer.Rmd     -> data/20250919_pbmc.rds
  -> differential_expression/01_pseudobulk_count_tables.Rmd
  -> differential_expression/02_deseq2_tmod.Rmd         -> differential_expression/de_results/ (available in this repo - this stage is optional)
  -> figures/{Fig5,SFig12,SFig13,SFig14,SFig15}.Rmd     -> output/
```

If you start from `data/20250919_pbmc.rds` (recommended), you only need the
last stage — the DE result tables that the DE stage would produce are already
available in `differential_expression/de_results/`.

## Data availability & donor exclusion

`20250919_pbmc.rds` is deposited on figshare:
<https://doi.org/10.6084/m9.figshare.34022952>. The processed data
(per-sample count matrices) are deposited at GEO, accession
[GSE344857](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE344857).
See [`data/README.md`](data/README.md) for download commands for both. One
donor (donor 3) was excluded from the analysis before this object was built;
this is documented transparently, including an internal investigation that
isn't part of the published text, in
[`docs/donor3_exclusion.md`](docs/donor3_exclusion.md).

Raw FASTQ files are not included (human-subjects data privacy) — see
[`preprocessing/01_upstream_processing.md`](preprocessing/01_upstream_processing.md).
Note that the per-sample h5 files at GSE344857 are Cell Ranger's raw output,
not CellBender-denoised — if you want to start from those instead of the
figshare RDS, you'll need to run CellBender yourself first (see
[`data/README.md`](data/README.md) section 2).

## License

[GPLv3](LICENSE).
