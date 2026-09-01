# Shared I/O helpers used by every figure Rmd, and (require_files only) by
# preprocessing/ and differential_expression/ too.
suppressPackageStartupMessages(library(openxlsx))

#' Stop with a clear, actionable message if any of the given paths don't
#' exist, instead of letting readRDS()/read.delim() fail deep inside with an
#' opaque low-level error (e.g. "Error in gzfile(): cannot open the
#' connection"). Pass a named vector/list so the message says which params
#' entry is missing, e.g. require_files(c(annotated_rds = params$annotated_rds)).
require_files <- function(paths) {
  missing <- paths[!file.exists(paths)]
  if (length(missing) > 0) {
    label <- function(i) if (!is.null(names(missing)) && nzchar(names(missing)[i])) paste0(names(missing)[i], " = ") else ""
    lines <- vapply(seq_along(missing), function(i) paste0("  - ", label(i), missing[[i]]), character(1))
    stop("Missing input file(s), check these params paths (see data/README.md and each Rmd's intro):\n",
         paste(lines, collapse = "\n"), call. = FALSE)
  }
}

#' Read the 6 pairwise DESeq2 result tables written by
#' differential_expression/02_deseq2_tmod.Rmd into one long data frame and,
#' separately, as a named list keyed by contrast (mirrors the `res`/`df_l`
#' objects the original analysis scripts built ad hoc in every figure Rmd).
load_de_results <- function(de_dir, contrasts = c("UM_vs_X", "Cl_vs_X", "I_vs_X", "Cl_vs_UM", "I_vs_UM", "Cl_vs_I")) {
  files <- setNames(file.path(de_dir, paste0("results_", contrasts, ".tsv")), contrasts)
  require_files(files)
  by_contrast <- lapply(files, read.delim, header = TRUE)
  list(by_contrast = by_contrast, long = do.call(rbind, by_contrast))
}

#' Write one multi-sheet xlsx per figure: `sheets` is a named list of
#' data frames, one per panel. Sheet names are truncated to Excel's 31-char
#' limit (kept short/unambiguous at the call site instead, per repo convention).
write_panel_xlsx <- function(sheets, out_path) {
  dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
  wb <- createWorkbook()
  for (sheet_name in names(sheets)) {
    addWorksheet(wb, sheet_name)
    writeData(wb, sheet_name, sheets[[sheet_name]])
  }
  saveWorkbook(wb, out_path, overwrite = TRUE)
}

#' Save a patchwork/ggplot figure as both PDF and (implicitly, via the
#' caller writing the xlsx separately) its panel data, into the figure's own
#' output/<Fig>/ directory.
save_figure_pdf <- function(plot, out_path, width, height) {
  dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
  ggplot2::ggsave(out_path, plot = plot, device = grDevices::cairo_pdf, width = width, height = height)
}
