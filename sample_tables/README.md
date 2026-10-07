# Sample tables

Each table maps a 10x FLEX probe barcode (`BC001`-`BC016`) to a donor/replicate
(`batch`), treatment (`treatment`: `X` = vehicle, `UM` = HNP1, `Cl` = ClY21-HNP1,
`I` = IY16-HNP1) and a `sample` id (`s<donor>_<treatment index>`). See
[`../docs/donor3_exclusion.md`](../docs/donor3_exclusion.md) for why three of
these tables exist.

| File | Samples | Used by | Purpose |
|---|---|---|---|
| `sample_table_full16.txt` | 16 (donors 1-4 x 4 treatments) | not read by any figure Rmd; only relevant if rebuilding the donor-3 diagnostic from scratch via `preprocessing/` | Original experimental design, before any exclusion. |
| `sample_table_donor3_swap_check.txt` | 16 | `figures/SFig12.Rmd` (panel A, paired with the vendored `figures/SFig12_data/counts_l1_full16_donor3swap.tsv`) | Identical to `sample_table_full16.txt` except donor 3's `X`/`UM` barcodes are swapped (`BC009`<->`BC010`). This was tested as a possible barcode-swap explanation for donor 3's outlier behaviour; it did not resolve the anomaly (see `docs/donor3_exclusion.md`). It is also the only 16-sample table an existing pseudobulk run used, which is why SFig12 pairs with this one, not `sample_table_full16.txt`. |
| `sample_table_final12.txt` | 12 (donor 3 excluded; donor 4 relabeled `batch=3`) | `preprocessing/02_qc_clustering.Rmd` onward (default), and `figures/SFig12.Rmd` panel E | The sample set actually used to build `20250919_pbmc.rds` and every manuscript figure. |
