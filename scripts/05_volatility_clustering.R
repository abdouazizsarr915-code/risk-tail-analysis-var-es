# =========================================================
# 05_volatility_clustering.R
# Analyze squared returns as a proxy for volatility clustering
# =========================================================

rm(list = ls())

required_packages <- c(
  "readr",
  "dplyr",
  "ggplot2"
)

installed <- rownames(installed.packages())
for (pkg in required_packages) {
  if (!(pkg %in% installed)) install.packages(pkg)
  library(pkg, character.only = TRUE)
}

source("scripts/00_plot_style.R")

dir.create("figures/main", showWarnings = FALSE)

returns <- read_csv("data/processed/sp500_returns.csv", show_col_types = FALSE)

p_sq <- ggplot(returns, aes(x = as.Date(date), y = squared_return)) +
  geom_line(color = sp_col, linewidth = 0.6) +
  labs(
    title = "Squared Returns of the S&P 500",
    subtitle = "Volatility clustering proxy",
    x = NULL,
    y = "Squared return"
  ) +
  project_theme()

ggsave("figures/main/08_squared_returns.png", p_sq, width = 10, height = 5.5, dpi = 300)

cat("Script 05 completed successfully.\n")