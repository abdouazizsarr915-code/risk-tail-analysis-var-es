library(ggplot2)

sp_col <- "#1F77B4"
normal_col <- "#D62728"
laplace_col <- "#2CA02C"
var_col <- "#9467BD"
es_col <- "#8C564B"
actual_col <- "#4C4C4C"
band_col <- "grey75"

project_theme <- function() {
  theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", size = 18),
      plot.subtitle = element_text(size = 12, colour = "grey30"),
      axis.title = element_text(face = "bold"),
      legend.title = element_text(face = "bold"),
      panel.grid.minor = element_blank()
    )
}