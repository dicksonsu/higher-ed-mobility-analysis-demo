# 03_regression_analysis.R
# Purpose: Estimate regression models linking access measures to institutional characteristics

library(dplyr)
library(readr)
library(fixest)

data_dir <- "data"
derived_dir <- file.path(data_dir, "derived")
output_dir <- "output"

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

analysis_data <- read_csv(file.path(derived_dir, "institution_analysis_file.csv"))

# Example models
model_1 <- feols(
  pct_pell ~ pell_completion_pct,
  data = analysis_data
)

model_2 <- feols(
  pct_pell ~ pell_completion_pct | state_abbr,
  data = analysis_data
)

model_3 <- feols(
  pct_pell ~ pell_completion_pct + log(net_price_lowinc) + log(tuition_instate) + ownership | state_abbr + institution_category,
  data = analysis_data
)

etable(model_1, model_2, model_3,
       file = file.path(output_dir, "regression_table.txt"))
