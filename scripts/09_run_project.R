rm(list = ls())

cat("Running full project pipeline...\n")

source("scripts/01_download_and_prepare_data.R")
source("scripts/02_fit_distributions.R")
source("scripts/03_var_es_analysis.R")
source("scripts/04_backtesting.R")
source("scripts/05_volatility_clustering.R")

cat("Project completed successfully.\n")