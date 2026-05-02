# =============================================================================
# Statistics Coursework
# Three-part analysis using GAMLSS and linear regression in R
#
# Section 1: Distribution fitting on Dutch boys' BMI (DBBMI dataset)
# Section 2: Centile curves for English schoolchildren grip strength (grip dataset)
# Section 3: Linear regression on mtcars (mpg ~ hp + wt + disp)
# =============================================================================


# -----------------------------------------------------------------------------
# Load required libraries
# -----------------------------------------------------------------------------
library(gamlss)
library(gamlss.dist)
library(gamlss.data)
library(tidyverse)
library(MASS)
library(ggplot2)


# =============================================================================
# SECTION 1 — DUTCH BOYS BMI (DBBMI)
# =============================================================================

# ---- [A] Load data and extract the 14–15 age band ---------------------------
data("dbbmi")

old  <- 14
da   <- with(dbbmi, subset(dbbmi, age > old & age < old + 1))
bmi14 <- da$bmi

# Quick histogram of BMI for 14-year-olds
hist(bmi14)

# Summary statistics of the full dbbmi dataset (age and bmi)
summary(dbbmi)

# Truehist with a fitted log-normal curve overlaid (Figure 6 in the report)
# The MASS::truehist function gives a density-scaled histogram
truehist(bmi14)


# ---- [B] Fit candidate parametric distributions and compare via AIC ---------
fit_normal      <- fitdistr(bmi14, "normal")
fit_lognormal   <- fitdistr(bmi14, "lognormal")
fit_exponential <- fitdistr(bmi14, "exponential")
fit_gamma       <- fitdistr(bmi14, "gamma")

# Calculate AIC for each distribution
aic_values <- c(
  AIC(fit_normal),
  AIC(fit_lognormal),
  AIC(fit_gamma),
  AIC(fit_exponential)
)
names(aic_values) <- c("Normal", "Log-Normal", "Gamma", "exponential")

# Print AIC values (lowest = best fit; in this analysis, Log-Normal wins)
print(aic_values)


# ---- [C] Fit GAMLSS versions of the two best candidates ---------------------
# Normal family
fitGAMLSS_norm    <- gamlss(bmi14 ~ 1, family = NO())
# Log-normal family
fitGAMLSS_lognorm <- gamlss(bmi14 ~ 1, family = LOGNO())

# Inspect the fits
summary(fitGAMLSS_norm)
summary(fitGAMLSS_lognorm)

# Re-print the lognormal MLE fit (mean-log and sd-log parameters)
fitnorm    <- fitdistr(bmi14, "normal")
fitlognorm <- fitdistr(bmi14, "lognormal")
print(fitnorm)
print(fitlognorm)

# Overlay the fitted log-normal density on the histogram of bmi14
curve(
  dlnorm(x, meanlog = fitlognorm$estimate["meanlog"],
            sdlog   = fitlognorm$estimate["sdlog"]),
  add = TRUE, col = "red", lwd = 2
)


# =============================================================================
# SECTION 2 — HANDGRIP STRENGTH BY AGE (grip dataset, English schoolchildren)
# =============================================================================

# ---- [A] Take a reproducible random sample of 1000 boys ---------------------
set.seed(320)
index  <- sample(3766, 1000)
mydata <- grip[index, ]
dim(mydata)   # expected: 1000  2


# ---- [B] Visualize age vs grip strength -------------------------------------
plot(mydata, xlab = "age", ylab = "grip")

ggplot(mydata, aes(x = age, y = grip)) +
  geom_line(color = "Blue")


# ---- [C] Fit a Box-Cox Cole and Green (BCCG) model --------------------------
gbccg <- gamlss(
  grip ~ pb(age),
  sigma.fo = ~ pb(age),
  nu.fo    = ~ pb(age),
  data     = mydata,
  family   = BCCG
)

edf(gbccg)
edfAll(gbccg)


# ---- [D] Fit a Box-Cox t (BCT) model, starting from the BCCG fit ------------
gbct <- gamlss(
  grip ~ pb(age),
  sigma.fo = ~ pb(age),
  nu.fo    = ~ pb(age),
  tau.fo   = ~ pb(age),
  data     = mydata,
  family   = BCT,
  start.from = gbccg
)

edf(gbct)
edfAll(gbct)


# ---- [E] Fit a Box-Cox Power Exponential (BCPE) model -----------------------
gbcp <- gamlss(
  grip ~ pb(age),
  sigma.fo  = ~ pb(age),
  nu.fo     = ~ pb(age),
  lambda.fo = ~ pb(age),
  data      = mydata,
  family    = BCPE,
  start.from = gbccg
)

edf(gbcp)


# ---- [F] Compare the three models using GAIC --------------------------------
gaic_bccg <- GAIC(gbccg)
gaic_bct  <- GAIC(gbct)
gaic_bcpe <- GAIC(gbcp)

# Print GAIC values for each model
cat("GAIC for BCCG model:", gaic_bccg, "\n")
cat("GAIC for BCT model:",  gaic_bct,  "\n")
cat("GAIC for BCPE model:", gaic_bcpe, "\n")

# Compare GAIC values and select the model with the lowest GAIC
if (gaic_bccg < gaic_bct & gaic_bccg < gaic_bcpe) {
  cat("BCCG model has the lowest GAIC and is the preferred model.\n")
} else if (gaic_bct < gaic_bccg & gaic_bct < gaic_bcpe) {
  cat("BCT model has the lowest GAIC and is the preferred model.\n")
} else {
  cat("BCPE model has the lowest GAIC and is the preferred model.\n")
}


# ---- [G] Plot fitted parameters (mu, sigma, nu, tau) for all three models ---
fittedPlot(gbccg, gbct, gbcp, x = mydata$age)
fittedPlot(gbccg, gbct,        x = mydata$age)


# ---- [H] Centile curves for each model --------------------------------------
centiles_gbccg <- centiles(gbccg)
centiles_gbct  <- centiles(gbct)
centiles_gbcp  <- centiles(gbcp)


# ---- [I] Residual diagnostics for each model --------------------------------
plot(gbccg, main = "BCCG Model Residuals")
plot(gbct,  main = "BCT Model Residuals")
plot(gbcp,  main = "BCPE Model Residuals")

# Q statistics — test residual normality across age bins
Q.stats(gbccg)
Q.stats(gbct)
Q.stats(gbcp)

# Worm plots — visual goodness-of-fit assessment
wp(gbccg)
wp(gbct)
wp(gbcp)

# Conclusion (from coursework write-up):
# BCT was selected as the preferred model — lowest GAIC, balanced residuals,
# and a worm plot that stays closest to the reference line.


# =============================================================================
# SECTION 3 — mtcars LINEAR REGRESSION (mpg ~ hp + wt + disp)
# =============================================================================

# ---- [A] Load and inspect the dataset ---------------------------------------
data(mtcars)

# Display the structure of the dataset
str(mtcars)

# Display summary statistics
summary(mtcars)


# ---- [B] Exploratory visualization ------------------------------------------
# Scatterplot of mpg vs hp
ggplot(mtcars, aes(x = mpg, y = hp)) +
  geom_point() +
  labs(x = "Miles Per Gallon", y = "Horsepower")

# Histogram of mpg
ggplot(mtcars, aes(x = mpg)) +
  geom_histogram(bins = 30, fill = "grey", color = "green", alpha = 0.8) +
  labs(title = "Histogram of mtcars", x = "Miles Per Gallon", y = "Frequency")


# ---- [C] Define response and explanatory variables --------------------------
# Note: the column names in mtcars are hp (horsepower), wt (weight), disp (displacement)
response_variable    <- mtcars$mpg
explanatory_variables <- mtcars[, c("hp", "wt", "disp")]


# ---- [D] Fit the linear regression model ------------------------------------
model <- lm(response_variable ~ ., data = explanatory_variables)

# Summary of the model
summary(model)


# ---- [E] Check regression assumptions ---------------------------------------
# Residuals vs Fitted values plot
plot(model, which = 1)

# Normal Q-Q plot
plot(model, which = 2)


# ---- [F] Generate predictions and compare with actuals ----------------------
predicted_values <- predict(model, explanatory_variables)
head(predicted_values)

# Build a data frame of actual vs predicted mpg values
prediction_data <- data.frame(
  Actual    = mtcars$mpg,
  Predicted = predicted_values
)

str(prediction_data)


# =============================================================================
# END OF SCRIPT
# =============================================================================
