# =========================================================
# 01_download_and_prepare_data.R
# Download S&P 500 data and compute daily log returns
# =========================================================

rm(list = ls())

required_packages <- c(
  "quantmod",
  "dplyr",
  "readr",
  "ggplot2",
  "tibble"
)

installed <- rownames(installed.packages())
for (pkg in required_packages) {
  if (!(pkg %in% installed)) install.packages(pkg)
  library(pkg, character.only = TRUE)
}

source("scripts/00_plot_style.R")

dir.create("data", showWarnings = FALSE)
dir.create("data/raw", showWarnings = FALSE)
dir.create("data/processed", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)
dir.create("figures/main", showWarnings = FALSE)
dir.create("figures/diagnostics", showWarnings = FALSE)

# ---------------------------------------------------------
# 1. Download S&P 500 data
# ---------------------------------------------------------
sp500 <- getSymbols("^GSPC", src = "yahoo", auto.assign = FALSE)

prices <- data.frame(
  date = as.Date(index(sp500)),
  adjusted = as.numeric(Ad(sp500))
)

# Estimation window inspired by the assignment
prices <- prices %>%
  filter(date >= as.Date("2013-01-01"),
         date <= as.Date("2018-12-31")) %>%
  arrange(date)

# ---------------------------------------------------------
# 2. Compute daily log returns
# ---------------------------------------------------------
returns <- prices %>%
  mutate(
    log_return = c(NA, diff(log(adjusted))),
    squared_return = log_return^2
  ) %>%
  filter(!is.na(log_return))

write_csv(prices, "data/raw/sp500_prices.csv")
write_csv(returns, "data/processed/sp500_returns.csv")

# ---------------------------------------------------------
# 3. Plots
# ---------------------------------------------------------
p_price <- ggplot(prices, aes(x = date, y = adjusted)) +
  geom_line(color = sp_col, linewidth = 0.8) +
  labs(
    title = "S&P 500 Adjusted Close",
    subtitle = "Estimation window: 2013-01-01 to 2018-12-31",
    x = NULL,
    y = "Adjusted Close"
  ) +
  project_theme()

p_ret <- ggplot(returns, aes(x = date, y = log_return)) +
  geom_line(color = sp_col, linewidth = 0.6) +
  labs(
    title = "Daily Log Returns of the S&P 500",
    subtitle = "2013-01-01 to 2018-12-31",
    x = NULL,
    y = "Log return"
  ) +
  project_theme()

ggsave("figures/main/01_sp500_prices.png", p_price, width = 10, height = 5, dpi = 300)
ggsave("figures/main/02_sp500_returns.png", p_ret, width = 10, height = 5, dpi = 300)

cat("Script 01 completed successfully.\n")