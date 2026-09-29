# Upstream processing: FASTQ -> per-sample count matrices

Reproduction of every figure in this repo starts from the final Seurat
object (see [`../data/README.md`](../data/README.md)), so neither step below
is required for that. They're documented for transparency/citability, and
matter only if you want to rebuild the inputs to `preprocessing/` yourself:

- **Step 1, Cell Ranger**: genuinely **not runnable from this repo** — raw
  FASTQ files are human-subjects data and are not distributed, and Cell
  Ranger requires proprietary reference files not practical to vendor here.
- **Step 2, CellBender**: you likely **do need to run this yourself** if
  you're starting from GEO rather than the figshare RDS — the h5 files on GEO
  are Cell Ranger's raw output, *not* CellBender-denoised (see
  [`../data/README.md`](../data/README.md) section 2). CellBender itself
  (GPU-accelerated, no proprietary inputs) is practical to run outside this
  repo; the exact command/parameters used in the original analysis are below.

## 1. Cell Ranger multi (demultiplexing + counting)

10x Genomics Fixed RNA Profiling ("Flex"): a single pooled sequencing run
(2 lanes, paired-end) containing all 16 probe-barcoded samples
(`BC001`-`BC016`), demultiplexed in silico by Cell Ranger's `multi` mode
via probe barcodes (no separate per-sample FASTQs).

- **Tool**: Cell Ranger `multi`, v8.0.0
- **Reference**: `refdata-gex-GRCh38-2024-A`
- **Probe set**: `Chromium_Human_Transcriptome_Probe_Set_v1.0.1_GRCh38-2020-A.csv`
- **`create-bam`**: `false` (no BAM retained)

`libraries.csv` (one GEX library, demultiplexed into 16 samples by probe barcode):

```csv
[gene-expression]
reference,/path/to/refdata-gex-GRCh38-2024-A
probe-set,/path/to/Chromium_Human_Transcriptome_Probe_Set_v1.0.1_GRCh38-2020-A.csv
create-bam,false

[libraries]
fastq_id,fastqs,feature_types
A4869_Foti_RunIII_GEX,/path/to/fastqs/,Gene Expression

[samples]
sample_id,probe_barcode_ids,description
BC001,BC001,Fixed RNA
BC002,BC002,Fixed RNA
...
BC016,BC016,Fixed RNA
```

Run command:

```bash
cellranger multi --id cellranger_multi --csv libraries.csv \
  --jobmode slurm --maxjobs=100 --jobinterval=1000
```

Per-sample outputs used downstream: `sample_raw_feature_bc_matrix.h5` (input
to CellBender, below) and `sample_filtered_feature_bc_matrix.h5`.

## 2. CellBender (ambient RNA removal)

- **Tool**: CellBender `remove-background`, v0.3.0, GPU-accelerated (`--cuda`)
- **Parameters**: all defaults (no `--expected-cells`, `--total-droplets-included`,
  `--epochs`, `--learning-rate`, or `--fpr` overrides) — 150 training epochs,
  target FPR 0.01, cell count estimated automatically per sample.

Run per sample (`BC001`-`BC016`):

```bash
cellbender remove-background \
  --input  cellranger_multi/<sample>/sample_raw_feature_bc_matrix.h5 \
  --output <sample>.h5 \
  --cuda

# repack to a layout Seurat's Read10X_h5() reads directly
ptrepack --complevel 5 <sample>_filtered.h5:/matrix <sample>_filtered_seurat.h5:/matrix
```

`<sample>_filtered_seurat.h5` is the file `preprocessing/02_qc_clustering.Rmd`
expects (see `params$h5_dir` there) — this is the "CellBender-denoised
per-sample count matrices" referenced in [`../data/README.md`](../data/README.md).

## Manuscript Methods, for reference

From "scRNAseq data processing": *"Raw sequencing reads was processed with
Cellranger multi v8.0.0 (10X Genomics) and included alignment to the human
genome (GRCh38), probe barcode demultiplexing and generation of count
matrices with mRNA read counts. Ambient RNA background was removed using
CellBender remove-background (v0.3.0) starting from demultiplexed raw count
matrices."*
