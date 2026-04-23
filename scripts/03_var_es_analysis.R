# =========================================================
# 03_var_es_analysis.R
# Compute and compare VaR / ES under Normal and Laplace models
# =========================================================

rm(list = ls())

required_packages <- c(
  "readr",
  "dplyr",
  "ggplot2",
  "tibble",
  "purrr"
)

installed <- rownames(installed.packages())
for (pkg in required_packages) {
  if (!(pkg %in% installed)) install.packages(pkg)
  library(pkg, character.only = TRUE)
}

source("scripts/00_plot_style.R")

dir.create("figures/main", showWarnings = FALSE)
dir.create("data/processed", showWarnings = FALSE)

returns <- read_csv("data/processed/sp500_returns.csv", show_col_types = FALSE)
params <- read_csv("data/processed/distribution_parameters.csv", show_col_types = FALSE)

x <- returns$log_return
mu_norm <- params$mu[params$distribution == "Normal"]
sigma_norm <- params$scale[params$distribution == "Normal"]
mu_lap <- params$mu[params$distribution == "Laplace"]
b_lap <- params$scale[params$distribution == "Laplace"]

# ---------------------------------------------------------
# 1. Risk functions
# ---------------------------------------------------------
VaR_normal <- function(p, mu, sigma) {
  -(mu + sigma * qnorm(p))
}

ES_normal <- function(p, mu, sigma) {
  -mu + sigma * dnorm(qnorm(p)) / p
}

q_laplace <- function(p, mu, b) {
  ifelse(
    p < 0.5,
    mu + b * log(2 * p),
    mu - b * log(2 * (1 - p))
  )
}

VaR_laplace <- function(p, mu, b) {
  -q_laplace(p, mu, b)
}

ES_laplace_mc <- function(p, mu, b, n_sim = 200000) {
  u <- runif(n_sim)
  r <- q_laplace(u, mu, b)
  loss <- -r
  q <- quantile(loss, probs = 1 - p, names = FALSE)
  mean(loss[loss >= q])
}
VaR_empirical <- function(x, p) {
  quantile(-x, probs = 1 - p, names = FALSE)
}

ES_empirical <- function(x, p) {
  losses <- -x
  q <- quantile(losses, probs = 1 - p, names = FALSE)
  mean(losses[losses >= q])
}
p_grid <- seq(0.01, 0.10, by = 0.01)

var_df <- tibble(
  p = p_grid,
  Normal = sapply(p_grid, VaR_normal, mu = mu_norm, sigma = sigma_norm),
  Laplace = sapply(p_grid, VaR_laplace, mu = mu_lap, b = b_lap),
  Empirical = sapply(p_grid, VaR_empirical, x = x)
) %>%
  tidyr::pivot_longer(-p, names_to = "distribution", values_to = "VaR")

es_df <- tibble(
  p = p_grid,
  Normal = sapply(p_grid, ES_normal, mu = mu_norm, sigma = sigma_norm),
  Laplace = sapply(p_grid, ES_laplace_mc, mu = mu_lap, b = b_lap),
  Empirical = sapply(p_grid, ES_empirical, x = x)
) %>%
  tidyr::pivot_longer(-p, names_to = "distribution", values_to = "ES")
write_csv(var_df, "data/processed/var_results.csv")
write_csv(es_df, "data/processed/es_results.csv")

# ---------------------------------------------------------
# 2. Plots
# ---------------------------------------------------------
p_var <- ggplot(var_df, aes(x = p, y = VaR, color = distribution)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2) +
  labs(
    title = "Value-at-Risk by Confidence Level",
    subtitle = "Normal versus Laplace assumptions",
    x = "Tail probability p",
    y = "VaR",
    color = NULL
  ) +
  scale_color_manual(values = c(
    "Normal" = normal_col,
    "Laplace" = laplace_col,
    "Empirical" = sp_col
  )) +
  project_theme()

p_es <- ggplot(es_df, aes(x = p, y = ES, color = distribution)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2) +
  labs(
    title = "Expected Shortfall by Confidence Level",
    subtitle = "Normal versus Laplace assumptions",
    x = "Tail probability p",
    y = "Expected Shortfall",
    color = NULL
  ) +
  scale_color_manual(values = c(
    "Normal" = normal_col,
    "Laplace" = laplace_col,
    "Empirical" = sp_col
  )) +
  project_theme()

ggsave("figures/main/05_var_curves.png", p_var, width = 10, height = 5.5, dpi = 300)
ggsave("figures/main/06_es_curves.png", p_es, width = 10, height = 5.5, dpi = 300)

cat("Script 03 completed successfully.\n")