# =========================================================
# 04_backtesting.R
# Backtest VaR exceedances under Normal and Laplace assumptions
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
params <- read_csv("data/processed/distribution_parameters.csv", show_col_types = FALSE)

x <- returns$log_return
loss <- -x

mu_norm <- params$mu[params$distribution == "Normal"]
sigma_norm <- params$scale[params$distribution == "Normal"]
mu_lap <- params$mu[params$distribution == "Laplace"]
b_lap <- params$scale[params$distribution == "Laplace"]

p <- 0.05

q_laplace <- function(p, mu, b) {
  ifelse(
    p < 0.5,
    mu + b * log(2 * p),
    mu - b * log(2 * (1 - p))
  )
}

var_norm <- -(mu_norm + sigma_norm * qnorm(p))
var_lap <- -q_laplace(p, mu_lap, b_lap)

bt_df <- tibble(
  date = returns$date,
  loss = loss,
  VaR_Normal = var_norm,
  VaR_Laplace = var_lap,
  breach_normal = loss > var_norm,
  breach_laplace = loss > var_lap
)

summary_bt <- tibble(
  model = c("Normal", "Laplace"),
  expected_rate = c(p, p),
  observed_rate = c(mean(bt_df$breach_normal), mean(bt_df$breach_laplace))
) %>%
  mutate(
    expected_percent = 100 * expected_rate,
    observed_percent = 100 * observed_rate,
    gap_percent = observed_percent - expected_percent
  )

write_csv(bt_df, "data/processed/backtesting_daily.csv")
write_csv(summary_bt, "data/processed/backtesting_summary.csv")
bt_plot_df <- summary_bt %>%
  select(model, expected_percent, observed_percent) %>%
  tidyr::pivot_longer(
    cols = c(expected_percent, observed_percent),
    names_to = "type",
    values_to = "percent"
  ) %>%
  mutate(
    type = dplyr::recode(
      type,
      "expected_percent" = "Expected",
      "observed_percent" = "Observed"
    )
  )

p_bt_summary <- ggplot(bt_plot_df, aes(x = model, y = percent, fill = type)) +
  geom_col(position = "dodge", width = 0.65) +
  labs(
    title = "VaR Exceedance Rates",
    subtitle = "Observed versus expected exceedance frequency at the 5% level",
    x = NULL,
    y = "Percent",
    fill = NULL
  ) +
  scale_fill_manual(values = c("Expected" = var_col, "Observed" = es_col)) +
  project_theme()

p_bt <- ggplot(bt_df, aes(x = date)) +
  geom_line(aes(y = loss, color = "Loss"), linewidth = 0.7) +
  geom_line(aes(y = VaR_Normal, color = "Normal VaR"), linewidth = 0.9, linetype = "dashed") +
  geom_line(aes(y = VaR_Laplace, color = "Laplace VaR"), linewidth = 0.9, linetype = "dotted") +
  labs(
    title = "Losses and VaR Backtesting",
    subtitle = "Comparison of realized losses and model-implied VaR",
    x = NULL,
    y = "Loss",
    color = NULL
  ) +
  scale_color_manual(values = c(
    "Loss" = actual_col,
    "Normal VaR" = normal_col,
    "Laplace VaR" = laplace_col
  )) +
  project_theme()

ggsave("figures/main/07_var_backtesting.png", p_bt, width = 11, height = 5.5, dpi = 300)
ggsave("figures/main/07b_exceedance_rates.png", p_bt_summary, width = 9, height = 5.5, dpi = 300)

cat("Script 04 completed successfully.\n")