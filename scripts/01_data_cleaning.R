# 01_data_cleaning.R
# Purpose: Prepare an institutional analysis file from public higher education data
# Author: Dickson Su
# Project: higher-ed-mobility-analysis-demo

# -----------------------------
# 1. Load packages
# -----------------------------
library(dplyr)
library(tidyr)
library(readr)

# -----------------------------
# 2. Define paths
# -----------------------------
data_dir <- "data"
raw_dir <- file.path(data_dir, "raw")
derived_dir <- file.path(data_dir, "derived")

if (!dir.exists(derived_dir)) {
  dir.create(derived_dir, recursive = TRUE)
}

# -----------------------------
# 3. Load sample institutional data
# -----------------------------
# Expected example input:
# data/raw/MERGED2024_25_PP.csv
#
# This public-facing script assumes a simplified institutional file
# with representative variables drawn from public higher education data.

inst_data <- read_csv(file.path(raw_dir, "MERGED2024_25_PP.csv"))

if (!file.exists(input_file)) {
  stop("Sample institutional data file not found in data/raw/MERGED2024_25_PP.csv")
}

inst_data <- read_csv(input_file)

inst_data <- inst_data %>%
  mutate(across(everything(), ~na_if(., "NULL"))) %>%
  mutate(across(everything(), ~na_if(., "PrivacySuppressed")))

# -----------------------------
# 4. Inspect columns
# -----------------------------
message("Available columns:")
print(names(inst_data))

# -----------------------------
# 5. Clean variable types
# -----------------------------
inst_data <- inst_data %>%
  rename(
    unitid = UNITID,
    instnm = INSTNM,
    stabbr = STABBR,
    control = CONTROL,
    iclevel = ICLEVEL,
    tuition_instate = TUITIONFEE_IN,
    pct_pell = PCTPELL,
    mean_earnings_10y = MD_EARN_WNE_P10
  )

inst_data_clean <- inst_data %>%
  mutate(
    unitid = as.character(unitid),
    year = as.integer(year),
    instnm = as.character(instnm),
    stabbr = as.character(stabbr),
    control = as.integer(control),
    iclevel = as.integer(iclevel),
    tuition_instate = as.numeric(tuition_instate),
    pct_pell = as.numeric(pct_pell),
    net_price_lowinc = as.numeric(net_price_lowinc),
    mean_earnings_10y = as.numeric(mean_earnings_10y),
    median_debt = as.numeric(median_debt),
    pell_completion_pct = as.numeric(pell_completion_pct)
  )

# -----------------------------
# 6. Recode institutional characteristics
# -----------------------------
inst_data_clean <- inst_data_clean %>%
  mutate(
    ownership = case_when(
      control == 1 ~ "Public",
      control == 2 ~ "Private nonprofit",
      control == 3 ~ "Private for-profit",
      TRUE ~ NA_character_
    ),
    ic_level = case_when(
      iclevel == 1 ~ "4 year",
      iclevel == 2 ~ "2 year",
      iclevel == 3 ~ "Less than 2 year",
      TRUE ~ NA_character_
    )
  )

# -----------------------------
# 7. Filter to analysis-ready sample
# -----------------------------
analysis_data <- inst_data_clean %>%
  filter(!is.na(unitid)) %>%
  filter(!is.na(year)) %>%
  filter(!is.na(stabbr)) %>%
  filter(!is.na(pct_pell))

# -----------------------------
# 8. Create selected derived variables
# -----------------------------
analysis_data <- analysis_data %>%
  mutate(
    net_price_lowinc = tuition_instate,
    pell_completion_pct = pct_pell
  )

analysis_data <- analysis_data %>%
  mutate(
    log_tuition_instate = ifelse(tuition_instate > 0, log(tuition_instate), NA_real_),
    log_net_price_lowinc = ifelse(net_price_lowinc > 0, log(net_price_lowinc), NA_real_),
    log_mean_earnings_10y = ifelse(mean_earnings_10y > 0, log(mean_earnings_10y), NA_real_)
  )

# -----------------------------
# 9. Basic validation checks
# -----------------------------
message("Number of rows in analysis file:")
print(nrow(analysis_data))

message("Number of unique institutions:")
print(n_distinct(analysis_data$unitid))

message("Years covered:")
print(range(analysis_data$year, na.rm = TRUE))

message("Ownership categories:")
print(table(analysis_data$ownership, useNA = "ifany"))

message("Institution level categories:")
print(table(analysis_data$ic_level, useNA = "ifany"))

# -----------------------------
# 10. Missingness check for key variables
# -----------------------------
missing_summary <- analysis_data %>%
  summarise(
    pct_pell_missing = sum(is.na(pct_pell)),
    tuition_missing = sum(is.na(tuition_instate)),
    net_price_lowinc_missing = sum(is.na(net_price_lowinc)),
    earnings_missing = sum(is.na(mean_earnings_10y)),
    debt_missing = sum(is.na(median_debt)),
    pell_completion_missing = sum(is.na(pell_completion_pct))
  )

message("Missingness summary:")
print(missing_summary)

# -----------------------------
# 11. Save cleaned analysis file
# -----------------------------
write_csv(
  analysis_data,
  file.path(derived_dir, "institution_analysis_file.csv")
)

message("Saved cleaned institutional analysis file to data/derived/institution_analysis_file.csv")
