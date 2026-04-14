# 02_descriptive_analysis.R
# Purpose: Generate descriptive visualizations for institutional trends

library(dplyr)
library(ggplot2)
library(readr)

data_dir <- "data"
derived_dir <- file.path(data_dir, "derived")
output_dir <- "output"

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

inst_data <- read_csv(file.path(derived_dir, "institution_analysis_file.csv"))

# Example 1: average Pell share over time
pell_df <- inst_data %>%
  group_by(year) %>%
  summarise(pct_pell_mean = mean(pct_pell, na.rm = TRUE), .groups = "drop")

pell_plot <- ggplot(pell_df, aes(x = year, y = pct_pell_mean)) +
  geom_line() +
  geom_point() +
  labs(
    x = "Year",
    y = "Average Pell Share",
    title = "Average Pell Share Over Time"
  ) +
  theme_bw()

ggsave(file.path(output_dir, "pell_share_plot.png"), pell_plot, width = 8, height = 5)

# Example 2: average in-state tuition over time
tuition_df <- inst_data %>%
  filter(tuition_instate > 0) %>%
  group_by(year) %>%
  summarise(tuition_mean = mean(tuition_instate, na.rm = TRUE), .groups = "drop")

tuition_plot <- ggplot(tuition_df, aes(x = year, y = tuition_mean)) +
  geom_line() +
  geom_point() +
  labs(
    x = "Year",
    y = "Average In-state Tuition",
    title = "Average In-state Tuition Over Time"
  ) +
  theme_bw()

ggsave(file.path(output_dir, "tuition_plot.png"), tuition_plot, width = 8, height = 5)
