# SFig12 precomputed pseudobulk count tables

`SFig12.Rmd`'s panels A and E are each a pseudobulk PCA built from a
different sample set. Both underlying count tables are small (<10 MB) and
already existed as output of the original analysis, so they are vendored
here directly — reproducing SFig12 needs no preprocessing re-run at all.

| File | Paired sample table | Samples | Used for |
|---|---|---|---|
| `counts_l1_final12.tsv` | `../../sample_tables/sample_table_final12.txt` | 12 (donor 3 excluded) | Panel E — the "clean" PCA on the final sample set |
| `counts_l1_full16_donor3swap.tsv` | `../../sample_tables/sample_table_donor3_swap_check.txt` | 16 (all donors, donor 3's `X`/`UM` barcodes swapped) | Panel A — the PCA that first flagged donor 3 as an outlier |

**Why the swapped table, not `sample_table_full16.txt`:** the only
already-computed 16-sample pseudobulk run available is
`downstream_analysis/20250922_results/` (see
[`../../docs/donor3_exclusion.md`](../../docs/donor3_exclusion.md) for the
context), which used the barcode-swap-investigation sample table. No
16-sample run exists anywhere using the original, unswapped assignment. The
donor-3 outlier signal is a property of the physical samples, not of which
barcode is labeled `X` vs `UM`, so this does not change what panel A shows —
but it does mean the `sample` / `treatment` columns in this table must be
read alongside `sample_table_donor3_swap_check.txt`, not
`sample_table_full16.txt`, or donor 3's vehicle/HNP1 labels will be wrong.

## Provenance

- `counts_l1_final12.tsv` = `downstream_analysis/20250919_results/counts_l1_190925.tsv` (unchanged copy), produced by the original `DE_create_count_tables_190925.Rmd` from `20250919_sobj_pbmc_annotated.rds`.
- `counts_l1_full16_donor3swap.tsv` = `downstream_analysis/20250922_results/counts_l1_220925.tsv` (unchanged copy), produced by the original `DE_create_count_tables_220925.Rmd` from `20250922_sobj_pbmc_annotated.rds`.

Both are pseudobulk count matrices (genes x sample-per-celltype pseudo-samples,
including an `all_<sample>` column per sample used for the "all cells" PCA);
identical format to `data/intermediate/counts_l1.tsv` produced by
[`../../differential_expression/01_pseudobulk_count_tables.Rmd`](../../differential_expression/01_pseudobulk_count_tables.Rmd)
for the main pipeline.
