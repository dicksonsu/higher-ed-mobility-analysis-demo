# 02_descriptive_analysis.R
# Purpose: Generate descriptive summaries and visualizations for multi-year institutional trends
# Author: Dickson Su
# Project: higher-ed-mobility-analysis-demo

# -----------------------------
# 1. Load packages
# -----------------------------
library(dplyr)
library(readr)
library(ggplot2)
library(scales)

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
analysis_data <- read_csv(file.path(derived_dir, "institution_analysis_file.csv"), show_col_types = FALSE)

# -----------------------------
# 4. Basic checks
# -----------------------------
message("Number of rows loaded:")
print(nrow(analysis_data))

message("Years available:")
print(sort(unique(analysis_data$year)))

message("Ownership categories:")
print(table(analysis_data$ownership, useNA = "ifany"))

# -----------------------------
# 5. Pell share over time
# -----------------------------
pell_df <- analysis_data %>%
  group_by(year) %>%
  summarise(
    pct_pell_mean = mean(pct_pell, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(pell_df, file.path(output_dir, "pell_share_summary.csv"))

pell_plot <- ggplot(pell_df, aes(x = year, y = pct_pell_mean)) +
  geom_line() +
  geom_point() +
  scale_y_continuous(labels = label_percent(accuracy = 1)) +
  labs(
    title = "Average Pell Share Over Time",
    x = "Year",
    y = "Average Pell Share"
  ) +
  theme_bw()

ggsave(
  filename = file.path(output_dir, "pell_share_plot.png"),
  plot = pell_plot,
  width = 8,
  height = 5
)

# -----------------------------
# 6. In-state tuition over time
# -----------------------------
tuition_df <- analysis_data %>%
  filter(!is.na(tuition_instate), tuition_instate > 0) %>%
  group_by(year) %>%
  summarise(
    tuition_mean = mean(tuition_instate, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(tuition_df, file.path(output_dir, "tuition_summary.csv"))

tuition_plot <- ggplot(tuition_df, aes(x = year, y = tuition_mean)) +
  geom_line() +
  geom_point() +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    title = "Average In-state Tuition Over Time",
    x = "Year",
    y = "Average In-state Tuition"
  ) +
  theme_bw()

ggsave(
  filename = file.path(output_dir, "tuition_plot.png"),
  plot = tuition_plot,
  width = 8,
  height = 5
)

# -----------------------------
# 7. Earnings over time
# -----------------------------
earnings_df <- analysis_data %>%
  filter(!is.na(mean_earnings_10y), mean_earnings_10y > 0) %>%
  group_by(year) %>%
  summarise(
    earnings_mean = mean(mean_earnings_10y, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(earnings_df, file.path(output_dir, "earnings_summary.csv"))

earnings_plot <- ggplot(earnings_df, aes(x = year, y = earnings_mean)) +
  geom_line() +
  geom_point() +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    title = "Average 10-Year Earnings Over Time",
    x = "Year",
    y = "Average 10-Year Earnings"
  ) +
  theme_bw()

ggsave(
  filename = file.path(output_dir, "earnings_plot.png"),
  plot = earnings_plot,
  width = 8,
  height = 5
)

# -----------------------------
# 8. Pell share over time by sector
# -----------------------------
pell_by_sector_df <- analysis_data %>%
  filter(!is.na(ownership)) %>%
  group_by(year, ownership) %>%
  summarise(
    pct_pell_mean = mean(pct_pell, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(pell_by_sector_df, file.path(output_dir, "pell_share_by_sector_summary.csv"))

pell_by_sector_plot <- ggplot(
  pell_by_sector_df,
  aes(x = year, y = pct_pell_mean, group = ownership, linetype = ownership)
) +
  geom_line() +
  geom_point() +
  scale_y_continuous(labels = label_percent(accuracy = 1)) +
  labs(
    title = "Average Pell Share Over Time by Sector",
    x = "Year",
    y = "Average Pell Share",
    linetype = "Ownership"
  ) +
  theme_bw()

ggsave(
  filename = file.path(output_dir, "pell_share_by_sector_plot.png"),
  plot = pell_by_sector_plot,
  width = 9,
  height = 5
)

message("Saved descriptive summaries and plots to output/")
