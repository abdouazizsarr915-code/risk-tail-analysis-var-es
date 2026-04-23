# =========================================================
# 02_fit_distributions.R
# Fit Normal and Laplace distributions to S&P 500 returns
# =========================================================

rm(list = ls())

required_packages <- c(
  "readr",
  "dplyr",
  "ggplot2",
  "tibble"
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
x <- returns$log_return
n <- length(x)

# ---------------------------------------------------------
# 1. Parameter estimation
# ---------------------------------------------------------
mu_norm <- mean(x)
sigma_norm <- sqrt((n - 1) / n) * sd(x)

mu_lap <- mean(x)
b_lap <- sqrt(0.5 * mean((x - mu_lap)^2))

params <- tibble(
  distribution = c("Normal", "Laplace"),
  mu = c(mu_norm, mu_lap),
  scale = c(sigma_norm, b_lap)
)

write_csv(params, "data/processed/distribution_parameters.csv")

# ---------------------------------------------------------
# 2. Density functions
# ---------------------------------------------------------
d_laplace <- function(z, mu, b) {
  (1 / (2 * b)) * exp(-abs(z - mu) / b)
}

grid <- seq(min(x), max(x), length.out = 1000)

dens_df <- tibble(
  x = grid,
  normal = dnorm(grid, mean = mu_norm, sd = sigma_norm),
  laplace = d_laplace(grid, mu = mu_lap, b = b_lap)
)

# ---------------------------------------------------------
# 3. Histogram + fitted densities
# ---------------------------------------------------------
p_fit <- ggplot(returns, aes(x = log_return)) +
  geom_histogram(aes(y = after_stat(density)),
                 bins = 50, fill = "grey85", color = "grey40") +
  geom_line(data = dens_df, aes(x = x, y = normal, color = "Normal"), linewidth = 1) +
  geom_line(data = dens_df, aes(x = x, y = laplace, color = "Laplace"), linewidth = 1) +
  labs(
    title = "Distribution Fit: S&P 500 Daily Returns",
    subtitle = "Normal versus Laplace",
    x = "Log return",
    y = "Density",
    color = NULL
  ) +
  scale_color_manual(values = c("Normal" = normal_col, "Laplace" = laplace_col)) +
  project_theme()

# Left tail zoom
p_tail <- ggplot(returns %>% filter(log_return < 0), aes(x = log_return)) +
  geom_histogram(aes(y = after_stat(density)),
                 bins = 40, fill = "grey85", color = "grey40") +
  geom_line(data = dens_df %>% filter(x < 0), aes(x = x, y = normal, color = "Normal"), linewidth = 1) +
  geom_line(data = dens_df %>% filter(x < 0), aes(x = x, y = laplace, color = "Laplace"), linewidth = 1) +
  labs(
    title = "Left Tail Comparison",
    subtitle = "Normal versus Laplace fit",
    x = "Log return",
    y = "Density",
    color = NULL
  ) +
  scale_color_manual(values = c("Normal" = normal_col, "Laplace" = laplace_col)) +
  project_theme()

ggsave("figures/main/03_distribution_fit.png", p_fit, width = 10, height = 5.5, dpi = 300)
ggsave("figures/main/04_left_tail_fit.png", p_tail, width = 10, height = 5.5, dpi = 300)

cat("Script 02 completed successfully.\n")