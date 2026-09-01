# Donor 3 exclusion

The scRNA-seq experiment was designed as 4 healthy donors x 4 treatments
(vehicle, HNP1, ClY21-HNP1, IY16-HNP1) = 16 libraries (`BC001`-`BC016`,
see [`../sample_tables/`](../sample_tables/)). One donor — **donor 3**
(`BC009`-`BC012`) — was excluded during quality control, and only 3 donors
(12 libraries) went into every figure in the manuscript, including this repo's.

## Published rationale

From the manuscript Methods ("scRNAseq data processing") and the legend of
Figure S11A:

> During exploratory quality control, donor 3 (vehicle and HNP1 conditions)
> was identified as an outlier. Pseudo-bulk gene expression profiles from
> this donor showed opposite fold-change directionality compared with the
> other donors, and PCA and sample-sample correlation analyses consistently
> separated donor 3 from the remaining samples. Normalization and
> batch-correction approaches (Seurat integration) did not resolve the
> discrepancy, indicating a donor-specific technical anomaly. Taken
> together, these features are consistent with a technical failure of that
> specific library preparation rather than a genuine biological response.
> Therefore, donor 3 was excluded from downstream analyses.

Figure S11 panel A shows the pseudobulk PCA that first flagged donor 3 as an
outlier (all 16 samples); panel E shows the same style of PCA after
exclusion, on the final 12-sample set. `figures/SFig11.Rmd` reproduces both
directly from two vendored, precomputed pseudobulk count tables (see
[`../figures/SFig11_data/README.md`](../figures/SFig11_data/README.md)) — no
preprocessing re-run is needed.

## Internal investigation note (not stated in the manuscript text)

While root-causing the donor-3 anomaly, a possible barcode swap between
donor 3's vehicle (`X`) and HNP1 (`UM`) libraries was investigated: an
alternate sample table (`sample_tables/sample_table_donor3_swap_check.txt`)
swaps donor 3's `BC009`/`BC010` barcode assignment relative to the original
design (`sample_tables/sample_table_full16.txt`) and re-runs the same QC.
Swapping the labels did **not** resolve the outlier behaviour described
above, so a barcode swap was ruled out as the explanation and donor 3 was
excluded outright rather than relabeled. This investigation is not part of
the manuscript's published text; it is documented here only for full
transparency about what was tried before the exclusion decision.

The only 16-sample pseudobulk run that exists in the original analysis used
this swap-check table (there is no equivalent run using the original,
unswapped assignment), which is why `figures/SFig11.Rmd` panel A pairs its
count table with `sample_table_donor3_swap_check.txt` rather than
`sample_table_full16.txt`. This does not change what the panel shows — the
outlier signal is a property of the physical donor-3 samples, not of which
barcode is labeled `X` vs `UM`.

## What this means for reproduction

- `sample_tables/sample_table_final12.txt` (donor 3 excluded, donor 4
  relabeled `batch=3`) is the sample table behind `20250919_pbmc.rds` and
  every figure Rmd in this repo.
- `sample_tables/sample_table_full16.txt` documents the original 16-sample
  design; it is not merged into the final Seurat object and is not needed to
  render any figure (SFig11 uses the swap-check table instead, see above).
  It is only relevant if you want to rebuild the donor-3-outlier count table
  from scratch, from `preprocessing/`, rather than using the vendored one.
