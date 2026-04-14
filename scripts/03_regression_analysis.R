# 03_regression_analysis.R
# Purpose: Estimate regression models linking Pell share to institutional characteristics
# Author: Dickson Su
# Project: higher-ed-mobility-analysis-demo

# -----------------------------
# 1. Load packages
# -----------------------------
library(dplyr)
library(readr)
library(fixest)

# -----------------------------
# 2. Define paths
# -----------------------------
data_dir <- "data"
derived_dir <- file.path(data_dir, "derived")
output_dir <- "output"

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# -----------------------------
# 3. Load cleaned analysis file
# -----------------------------
analysis_data <- read_csv(
  file.path(derived_dir, "institution_analysis_file.csv"),
  show_col_types = FALSE
)

# -----------------------------
# 4. Prepare regression sample
# -----------------------------
reg_data <- analysis_data %>%
  filter(!is.na(pct_pell)) %>%
  filter(!is.na(log_tuition_instate)) %>%
  filter(!is.na(log_mean_earnings_10y)) %>%
  filter(!is.na(ownership)) %>%
  filter(!is.na(ic_level)) %>%
  filter(!is.na(stabbr))

message("Number of rows in regression sample:")
print(nrow(reg_data))

message("Number of institutions in regression sample:")
print(n_distinct(reg_data$unitid))

# -----------------------------
# 5. Estimate models
# -----------------------------
# Model 1: baseline association
model_1 <- feols(
  pct_pell ~ log_tuition_instate + log_mean_earnings_10y,
  data = reg_data
)

# Model 2: add institutional characteristics
model_2 <- feols(
  pct_pell ~ log_tuition_instate + log_mean_earnings_10y + ownership + ic_level,
  data = reg_data
)

# Model 3: add state fixed effects
model_3 <- feols(
  pct_pell ~ log_tuition_instate + log_mean_earnings_10y + ownership + ic_level | stabbr,
  data = reg_data
)

# -----------------------------
# 6. Print summaries
# -----------------------------
message("Model 1 summary:")
print(summary(model_1))

message("Model 2 summary:")
print(summary(model_2))

message("Model 3 summary:")
print(summary(model_3))

# -----------------------------
# 7. Save regression table
# -----------------------------
etable(
  model_1, model_2, model_3,
  file = file.path(output_dir, "regression_table.txt")
)

# Also save to console-friendly csv if desired
reg_table <- etable(model_1, model_2, model_3)

write.csv(
  as.data.frame(reg_table),
  file.path(output_dir, "regression_table.csv"),
  row.names = TRUE
)

message("Saved regression outputs to output/")
