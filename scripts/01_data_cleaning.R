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
library(purrr)
library(stringr)

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
# 3. Define input files
# -----------------------------
scorecard_files <- c(
  "MERGED2020_21_PP.csv",
  "MERGED2021_22_PP.csv",
  "MERGED2022_23_PP.csv",
  "MERGED2023_24_PP.csv",
  "MERGED2024_25_PP.csv"
)

# Optional check: stop if any file is missing
missing_files <- scorecard_files[!file.exists(file.path(raw_dir, scorecard_files))]

if (length(missing_files) > 0) {
  stop(
    paste(
      "The following input files are missing from data/raw/:",
      paste(missing_files, collapse = ", ")
    )
  )
}

# -----------------------------
# 4. Read and combine annual files
# -----------------------------
read_scorecard_file <- function(filename) {
  # Extract first year from filename, e.g. 2019 from MERGED2019_20_PP.csv
  file_year <- str_extract(filename, "\\d{4}") |> as.integer()
  
  read_csv(
    file.path(raw_dir, filename),
    show_col_types = FALSE
  ) %>%
    mutate(year = file_year)
}

inst_data <- map_dfr(scorecard_files, read_scorecard_file)

# -----------------------------
# 5. Handle common missing-value strings
# -----------------------------
inst_data <- inst_data %>%
  mutate(across(everything(), ~na_if(., "NULL"))) %>%
  mutate(across(everything(), ~na_if(., "PrivacySuppressed")))

# -----------------------------
# 6. Inspect columns
# -----------------------------
message("Available columns:")
print(names(inst_data))

# -----------------------------
# 7. Rename selected variables
# -----------------------------
# Adjust this list if your specific files use slightly different names.
inst_data <- inst_data %>%
  rename(
    unitid = UNITID,
    instnm = INSTNM,
    stabbr = STABBR,
    control = CONTROL,
    iclevel = ICLEVEL,
    tuition_instate = TUITIONFEE_IN,
    pct_pell = PCTPELL,
    mean_earnings_10y = MD_EARN_WNE_P10,
    median_debt = DEBT_MDN
  )

# Optional: if you have a low-income net price field available, rename it here.
# Uncomment and adjust if present in your files:
# inst_data <- inst_data %>%
#   rename(
#     net_price_lowinc = NPT41_PUB
#   )

# -----------------------------
# 8. Clean variable types
# -----------------------------
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
    mean_earnings_10y = as.numeric(mean_earnings_10y),
    median_debt = as.numeric(median_debt)
  )

# -----------------------------
# 9. Recode institutional characteristics
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
# 10. Filter to analysis-ready sample
# -----------------------------
analysis_data <- inst_data_clean %>%
  filter(!is.na(unitid)) %>%
  filter(!is.na(year)) %>%
  filter(!is.na(stabbr)) %>%
  filter(!is.na(pct_pell))

# -----------------------------
# 11. Create selected derived variables
# -----------------------------
analysis_data <- analysis_data %>%
  mutate(
    log_tuition_instate = ifelse(tuition_instate > 0, log(tuition_instate), NA_real_),
    log_mean_earnings_10y = ifelse(mean_earnings_10y > 0, log(mean_earnings_10y), NA_real_)
  )

# -----------------------------
# 12. Basic validation checks
# -----------------------------
message("Number of rows in analysis file:")
print(nrow(analysis_data))

message("Number of unique institutions:")
print(n_distinct(analysis_data$unitid))

message("Years covered:")
print(sort(unique(analysis_data$year)))

message("Ownership categories:")
print(table(analysis_data$ownership, useNA = "ifany"))

message("Institution level categories:")
print(table(analysis_data$ic_level, useNA = "ifany"))

# -----------------------------
# 13. Missingness check for key variables
# -----------------------------
missing_summary <- analysis_data %>%
  summarise(
    pct_pell_missing = sum(is.na(pct_pell)),
    tuition_missing = sum(is.na(tuition_instate)),
    earnings_missing = sum(is.na(mean_earnings_10y)),
    debt_missing = sum(is.na(median_debt))
  )

message("Missingness summary:")
print(missing_summary)

# -----------------------------
# 14. Save cleaned analysis file
# -----------------------------
write_csv(
  analysis_data,
  file.path(derived_dir, "institution_analysis_file.csv")
)

message("Saved cleaned institutional analysis file to data/derived/institution_analysis_file.csv")
