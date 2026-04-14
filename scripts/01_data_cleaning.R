# 01_data_cleaning.R
# Purpose: Prepare institutional analysis data from public higher education sources

library(dplyr)
library(tidyr)
library(readr)

data_dir <- "data"
raw_dir <- file.path(data_dir, "raw")
derived_dir <- file.path(data_dir, "derived")

if (!dir.exists(derived_dir)) {
  dir.create(derived_dir, recursive = TRUE)
}

# Example: load public institutional data
inst_data <- read_csv(file.path(raw_dir, "institution_sample.csv"))

# Basic cleaning
inst_data_clean <- inst_data %>%
  janitor::clean_names() %>%
  mutate(
    tuition_instate = as.numeric(tuition_instate),
    pct_pell = as.numeric(pct_pell),
    mean_earnings_10y = as.numeric(mean_earnings_10y),
    ownership = case_when(
      control == 1 ~ "Public",
      control == 2 ~ "Private nonprofit",
      control == 3 ~ "Private for-profit",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(unitid))

write_csv(inst_data_clean, file.path(derived_dir, "institution_analysis_file.csv"))
