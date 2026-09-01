# Shared panel-building functions. These factor out plot patterns that were
# copy-pasted 3-6 times per contrast/cell-type across the original analysis
# scripts (20250919_reorganize.Rmd, 20251016_redo.Rmd) into one reusable
# implementation per pattern. See ../docs/ and each figure Rmd for which
# manuscript panel calls which function with which arguments.
#
# Requires plot_theme.R (contrast_labels, panel_theme_size) to already be
# sourced by the caller.
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(ggrepel)
  library(tmod)
})
`%||%` <- function(a, b) if (is.null(a)) b else a

#' Single-contrast volcano plot for one cell type (Fig5 C-E, SFig13 B).
volcano_panel <- function(res_by_contrast, contrast, cell_type, title = NULL,
                           xlim = c(-4, 4), max_overlaps = 80) {
  d <- res_by_contrast[[contrast]] %>% filter(!is.na(padj), baseMean > 5, cell_type == !!cell_type)
  ggplot(d, aes(x = log2FoldChange, y = -log10(padj), color = padj < .05)) +
    geom_point(size = .5, shape = 1) +
    geom_label_repel(data = filter(d, padj < .05), aes(label = gene_name), colour = "black",
                      segment.size = .25, segment.alpha = .5, size = 2.5, max.overlaps = max_overlaps,
                      label.padding = 0.05, label.size = NA) +
    geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "grey") +
    coord_cartesian(xlim = xlim) +
    scale_color_manual(values = c("black", "red")) +
    theme_classic() +
    theme(strip.background = element_blank(), legend.position = "none",
          plot.title = element_text(size = panel_theme_size),
          axis.title = element_text(size = panel_theme_size),
          axis.text = element_text(size = panel_theme_size)) +
    ggtitle(title %||% paste0(contrast_labels[[contrast]], " (", cell_type, ")"))
}

#' Bar chart of # significant DE genes per cell type, faceted by contrast,
#' coloured by cell type (Fig5 B).
deg_count_bar <- function(long_res, exclude_cell_type = "all") {
  long_res %>%
    filter(!grepl("DEPRECATED", gene_name), !grepl("^ENSG", gene_name), padj < 0.05, cell_type != exclude_cell_type) %>%
    count(cell_type, contrast) %>%
    mutate(contrast = factor(contrast, levels = names(contrast_labels_2lines))) %>%
    ggplot(aes(cell_type, n, fill = cell_type)) +
    geom_bar(stat = "identity", position = "dodge") +
    facet_wrap(~contrast, nrow = 1, labeller = as_labeller(contrast_labels_2lines)) +
    theme_classic() +
    theme(strip.background = element_blank(), strip.text = element_text(size = panel_theme_size),
          axis.text.y = element_text(size = panel_theme_size), axis.text.x = element_blank(),
          axis.title = element_text(size = panel_theme_size), legend.title = element_blank(),
          legend.text = element_text(size = panel_theme_size)) +
    labs(y = "# genes with padj<0.05", x = NULL)
}

#' Two-contrast log2FC-vs-log2FC concordance scatter for one cell type.
#' style = "gradient_top30": colour = -log10(padj_y) for the top 30
#'   concordance-ranked genes, which are also labeled (SFig14 A-C).
#' style = "highlight": grey background dots, a fixed `highlight_genes` list
#'   shown as red dots with labels, no colour gradient (Fig5 G-H).
concordance_scatter <- function(res_by_contrast, contrast_x, contrast_y, cell_type,
                                 style = c("gradient_top30", "highlight"),
                                 highlight_genes = NULL, title = cell_type,
                                 xlab = NULL, ylab = NULL, max_overlaps = 45) {
  style <- match.arg(style)
  dx <- res_by_contrast[[contrast_x]] %>% filter(cell_type == !!cell_type) %>%
    select(gene_name, log2FoldChange_x = log2FoldChange, padj_x = padj)
  dy <- res_by_contrast[[contrast_y]] %>% filter(cell_type == !!cell_type) %>%
    select(gene_name, log2FoldChange_y = log2FoldChange, padj_y = padj)

  df <- inner_join(dx, dy, by = "gene_name") %>%
    filter(!grepl("DEPRECATED", gene_name), !grepl("^ENSG", gene_name)) %>%
    mutate(
      sig_x = !is.na(padj_x) & padj_x < 0.05,
      sig_y = !is.na(padj_y) & padj_y < 0.05,
      disco = log2FoldChange_x * log2FoldChange_y * (abs(log10(padj_x) + log10(padj_y)))
    ) %>%
    filter(sig_x | sig_y)

  if (style == "gradient_top30") {
    top30 <- df %>% slice_max(order_by = disco, n = 30, with_ties = FALSE) %>% pull(gene_name)
    p <- ggplot(df %>% mutate(color = ifelse(gene_name %in% top30, -log10(padj_y), NA)),
                aes(log2FoldChange_x, log2FoldChange_y, color = color)) +
      scale_color_gradient2(low = "blue", mid = "red", high = "yellow", midpoint = 11) +
      geom_point(size = .5) +
      geom_abline(slope = 1, linetype = 2, colour = "grey") +
      geom_label_repel(data = filter(df, gene_name %in% top30), aes(label = gene_name), colour = "black",
                        segment.size = .25, segment.alpha = .5, size = 2.5, max.overlaps = max_overlaps,
                        label.padding = 0.05, label.size = NA) +
      guides(color = guide_colorbar(title = "-log10 Padj")) +
      theme(legend.position = "inside", legend.position.inside = c(.9, .25))
  } else {
    p <- ggplot(df, aes(log2FoldChange_x, log2FoldChange_y)) +
      geom_point(colour = "grey50", size = 0.5) +
      geom_point(data = filter(df, gene_name %in% highlight_genes), colour = "red", size = 2) +
      geom_abline(slope = 1, linetype = 2, colour = "grey") +
      geom_label_repel(data = filter(df, gene_name %in% highlight_genes), aes(label = gene_name), colour = "black",
                        segment.size = .25, segment.alpha = .5, size = 2.5, max.overlaps = 60,
                        label.padding = 0.05, label.size = NA) +
      theme(legend.position = "none")
  }

  p + ggtitle(title) + labs(x = xlab, y = ylab) + theme_classic() +
    theme(legend.title = element_text(size = panel_theme_size), legend.key.size = unit(10, "pt"),
          plot.title = element_text(size = panel_theme_size), axis.title = element_text(size = panel_theme_size),
          axis.text = element_text(size = panel_theme_size), legend.text = element_text(size = panel_theme_size))
}

#' tmod BTM enrichment heatmap for one contrast, split across cell types
#' (SFig12 A-C). `data(tmod)` must already be loaded by the caller.
tmod_panel_by_celltype <- function(res_by_contrast, contrast, q_filter, auc_filter, title = NULL) {
  l <- res_by_contrast[[contrast]] %>% filter(cell_type != "all") %>% split(.$cell_type)
  genes <- lapply(l, function(x) x %>% filter(!is.na(padj)) %>% arrange(pvalue))
  lgenes <- lapply(genes, function(x) x$gene_name)
  res.tmod <- lapply(lgenes, tmodCERNOtest, mset = tmod)
  sgenes <- sapply(l, function(x) tmodDecideTests(x$gene_name, lfc = x$log2FoldChange, pval = x$padj,
                                                    lfc.thr = 0, pval.thr = 0.05, mset = tmod))
  names(sgenes) <- names(l)

  p <- ggPanelplot(res.tmod, sgenes = sgenes, auc_thr = 0, q_thr = 1,
                    filter_row_q = q_filter, filter_row_auc = auc_filter, q_cutoff = 1e-50,
                    label_angle = 90, cluster = TRUE, mset = tmod, add_ids = FALSE) +
    theme(plot.title = element_text(size = panel_theme_size), axis.text = element_text(size = panel_theme_size),
          strip.text = element_text(size = panel_theme_size), legend.text = element_text(size = panel_theme_size),
          legend.title = element_text(size = panel_theme_size), axis.title = element_text(size = panel_theme_size),
          strip.text.x = element_text(hjust = 0), axis.text.x = element_text(angle = 0),
          panel.background = element_blank(), legend.key.size = unit(.1, "in")) +
    guides(alpha = guide_legend(ncol = 1))
  if (!is.null(title)) p <- p + ggtitle(title)
  p
}
