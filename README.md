# Risk Modeling of S&P 500 Returns: VaR, Expected Shortfall and Tail Behavior

A quantitative risk analysis project focused on tail risk, distributional assumptions, and model validation using Value-at-Risk (VaR) and Expected Shortfall (ES).

---

## Overview

Financial returns exhibit non-normal behavior, particularly in the tails, where extreme losses occur more frequently than predicted by Gaussian models.

This project develops a structured framework to:

* model return distributions,
* estimate risk measures (VaR and Expected Shortfall),
* compare parametric and empirical approaches,
* and evaluate model performance through backtesting.

The analysis focuses on daily S&P 500 returns and highlights the importance of correctly modeling tail behavior in risk management.

---

## Data

* Source: Yahoo Finance (S&P 500 index)
* Frequency: Daily
* Period: 2013–2018
* Variable of interest: log returns

---

## Methodology

### Distribution Modeling

Two parametric models are considered:

* Normal distribution (baseline assumption)
* Laplace distribution (heavy-tailed alternative)

The Laplace distribution allows for excess kurtosis and better captures extreme observations in the data.

---

### Risk Measures

The following risk metrics are computed:

* Value-at-Risk (VaR)
* Expected Shortfall (ES)

Each metric is evaluated under three approaches:

* Normal model
* Laplace model
* Empirical (non-parametric benchmark)

---

### Backtesting

Model performance is evaluated by comparing:

* expected exceedance rates (theoretical)
* observed exceedance rates (empirical)

This allows us to assess whether the models underestimate or overestimate risk.

---

### Volatility Analysis

Squared returns are used as a proxy for volatility.

The presence of volatility clustering indicates that returns are not independent over time, which challenges the i.i.d. assumption and motivates more advanced models.

---

## Results

### Distribution Fit

![Distribution Fit](figures/main/03_distribution_fit.png)

The Laplace distribution provides a better fit in the tails compared to the Normal model, highlighting the importance of accounting for extreme events.

---

### Tail Behavior

![Left Tail Comparison](figures/main/04_left_tail_fit.png)

The left tail of the distribution is particularly relevant for risk management, as it captures large negative returns.

---

### VaR Analysis

![VaR Curves](figures/main/05_var_curves.png)

The Laplace-based VaR is consistently more conservative than the Normal-based VaR, while the empirical VaR provides a reference benchmark.

---

### Expected Shortfall

![Expected Shortfall](figures/main/06_es_curves.png)

Expected Shortfall further emphasizes tail risk by measuring average losses beyond the VaR threshold.

---

### Backtesting

![VaR Backtesting](figures/main/07_var_backtesting.png)

![Exceedance Rates](figures/main/07b_exceedance_rates.png)

Observed exceedance rates deviate from theoretical expectations, indicating model risk.

The Normal model tends to underestimate extreme losses, while the Laplace model provides a more conservative estimate.

---

### Volatility Clustering

![Squared Returns](figures/main/08_squared_returns.png)

The clustering of large squared returns suggests time-varying volatility and dependence in the data.

---

## Key Insights

* Financial returns exhibit heavy tails and are not well described by a Normal distribution
* Tail risk is underestimated under Gaussian assumptions
* Laplace distribution provides a better fit for extreme events
* Empirical VaR highlights discrepancies between model-based estimates and observed data
* Backtesting reveals deviations between expected and observed exceedances
* Volatility clustering indicates that returns are not independent

---

## Technical Implementation

* Language: R
* Libraries: quantmod, ggplot2, dplyr, tseries
* Methods:

  * Maximum likelihood estimation
  * Method of moments
  * Non-parametric estimation
  * Backtesting procedures

---

## Reproducibility

To reproduce the full analysis:

```r
source("scripts/09_run_project.R")
```

All figures and processed data will be generated automatically.

---

## Project Structure

```
.
├── README.md
├── data/
├── figures/
│   ├── main/
│   └── diagnostics/
└── scripts/
```

---

## Conclusion

This project demonstrates the importance of modeling tail risk accurately in financial applications.

While simple parametric models are useful, they can lead to significant underestimation of extreme losses if distributional assumptions are not carefully validated.

Combining parametric, empirical, and backtesting approaches provides a more robust framework for risk assessment.

---

## Extensions

Potential extensions include:

* GARCH-based volatility modeling
* Extreme Value Theory (EVT)
* Multivariate risk modeling
* Portfolio-level risk aggregation

---
