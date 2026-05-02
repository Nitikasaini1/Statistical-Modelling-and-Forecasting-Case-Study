Statistical Modelling Coursework — GAMLSS & Linear Regression in R

A three-part statistical analysis project completed as part of my MSc/BSc coursework, demonstrating distribution fitting, centile curve estimation, and linear regression modelling using R.

---

Overview

This project applies different statistical modelling techniques to three real-world datasets:

|   | Dataset | Method | Key Question |
|---|---------|--------|--------------|
| 1 | Dutch boys BMI (`dbbmi`) | GAMLSS distribution fitting | Which parametric distribution best describes BMI for 14-year-olds? |
| 2 | English schoolchildren grip strength (`grip`) | GAMLSS centile curves | How does grip strength change with age, and which model fits best? |
| 3 | Motor Trend cars (`mtcars`) | Multiple linear regression | How well do horsepower, weight, and displacement predict fuel economy? |

---

Tech Stack

- Language: R
- Core packages: gamlss, gamlss.data, MASS, tidyverse, ggplot2
- **Techniques:** Distribution fitting, AIC/GAIC model selection, GAMLSS modelling (BCCG, BCT, BCPE), Q-Q plots, worm plots, residual diagnostics, multiple linear regression, prediction

---

Repository Contents

```
.
├── stats_coursework.R       # Full analysis script (all three sections)
├── README.md                # This file
└── report/                  # Optional: write-up, plots, references
```

---

Section 1 — Dutch Boys BMI (Distribution Fitting)

Goal: Identify the parametric distribution that best fits the BMI of Dutch boys aged 14–15.

Approach:
1. Subset the `dbbmi` dataset to ages 14 ≤ age < 15 (n = 410)
2. Fit four candidate distributions: Normal, Log-Normal, Gamma, Exponential
3. Compare via Akaike Information Criterion (AIC)
4. Validate the best fit using Q-Q plots and density overlay

Result: The Log-Normal distribution had the lowest AIC (1921.7) and was selected. Estimated parameters: meanlog ≈ 2.95, sdlog ≈ 0.13.

| Distribution | AIC |
|--------------|-----|
| Normal | 1962.88 |
| **Log-Normal** | **1921.70** |
| Gamma | 1932.81 |
| Exponential | 3251.09 |

---

 Section 2 — Grip Strength Centile Curves

Goal: Build age-conditional centile curves for grip strength in 1000 randomly sampled English schoolboys.

Approach:
1. Sample 1000 boys (`set.seed(320)`) from the `grip` dataset (n = 3766)
2. Fit three GAMLSS models with smoothing P-splines on age:
   - **BCCG** — Box-Cox Cole and Green
   - **BCT** — Box-Cox t
   - **BCPE** — Box-Cox Power Exponential
3. Compare using GAIC, residual diagnostics, Q-statistics, and worm plots

**Result:** The **BCT model** was selected — it had the lowest GAIC (6363.0), the most balanced residuals, and a worm plot closest to the reference line.

| Model | GAIC |
|-------|------|
| BCCG | 6370.10 |
| **BCT** | **6363.02** |
| BCPE | 6364.41 |

---

## Section 3 — mtcars Linear Regression

Goal: Predict fuel economy (mpg) from horsepower (hp), weight (wt), and displacement (disp).

Approach:
1. Load the `mtcars` dataset (32 cars × 11 variables)
2. Exploratory plots (scatter, histogram)
3. Fit a multiple linear regression: `mpg ~ hp + wt + disp`
4. Check assumptions via residuals-vs-fitted and Q-Q plots
5. Generate predictions and compare to actuals

Result: The model explains **~83% of the variance in mpg** (R² = 0.827, adjusted R² = 0.808, F = 44.57, p < 0.001). Weight and horsepower were statistically significant predictors; displacement was not.

| Predictor | Estimate | p-value |
|-----------|----------|---------|
| Intercept | 37.11 | < 2e-16 *** |
| wt (weight) | −3.80 | 0.0013 ** |
| hp (horsepower) | −0.031 | 0.0110 * |
| disp (displacement) | −0.001 | 0.9285 |

---

How to Run

Requirements
- R (version 4.0 or higher recommended)
- RStudio (optional but recommended)

Install dependencies
```r
install.packages(c("gamlss", "gamlss.data", "MASS", "tidyverse", "ggplot2"))
```

Run the script
```r
source("stats_coursework.R")
```

Or open `stats_coursework.R` in RStudio and run section by section.

---

Key Learnings

- Model selection matters.Choosing between AIC, GAIC, and visual diagnostics (Q-Q, worm plots) gives a fuller picture than any single metric.
- GAMLSS is powerful for non-normal data. Modelling location, scale, and shape simultaneously captures patterns that mean-only regression misses.
- Reproducibility is non-negotiable.Setting `set.seed(320)` ensured consistent random sampling across runs — essential when comparing model fits.
- Diagnostics > p-values. The `disp` predictor in the regression looks redundant once you check correlations between explanatory variables (multicollinearity with `wt` and `hp`).
