# Shared labels/palette used across every figure Rmd.

# treatment code -> display name (X = vehicle, UM = HNP1, Cl = ClY21-HNP1, I = IY16-HNP1)
treatment_labels <- c(X = "vehicle", UM = "HNP1", Cl = "ClY21-HNP1", I = "IY16-HNP1")

# consistent per-treatment colours (matches the QC panels in the original analysis)
treatment_colors <- c(X = "grey20", UM = "darkgreen", Cl = "dodgerblue3", I = "orange2")

# a readable label per pairwise contrast (as used in DE/tmod panel titles)
contrast_labels <- c(
  UM_vs_X  = "HNP1 vs vehicle",
  Cl_vs_X  = "ClY21-HNP1 vs vehicle",
  I_vs_X   = "IY16-HNP1 vs vehicle",
  Cl_vs_UM = "ClY21-HNP1 vs HNP1",
  I_vs_UM  = "IY16-HNP1 vs HNP1",
  Cl_vs_I  = "ClY21-HNP1 vs IY16-HNP1"
)

contrast_labels_2lines <- c(
  UM_vs_X  = "HNP1 \nvs vehicle",
  Cl_vs_X  = "ClY21-HNP1 \nvs vehicle",
  I_vs_X   = "IY16-HNP1 \nvs vehicle",
  Cl_vs_UM = "ClY21-HNP1 \nvs HNP1",
  I_vs_UM  = "IY16-HNP1 \nvs HNP1",
  Cl_vs_I  = "ClY21-HNP1 \nvs IY16-HNP1"
)

panel_theme_size <- 8
