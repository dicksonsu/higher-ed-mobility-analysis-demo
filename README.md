# Higher Education Mobility Analysis Demo

This repository demonstrates a multi-year R-based workflow for analyzing higher education data, focusing on access, affordability, and earnings outcomes across institutions.

## Project overview

In applied research on higher education and economic mobility, I worked with large administrative datasets (e.g., College Scorecard) to construct institutional panels, generate descriptive trends, and estimate regression models linking access measures to institutional characteristics.

This repository provides a simplified, reproducible version of that workflow.

## Analytical workflow

The project follows a three-step workflow:

1. **Data preparation** – construct a multi-year institutional panel from public data  
2. **Descriptive analysis** – generate trends in access (Pell share), cost (tuition), and outcomes (earnings)  
3. **Regression analysis** – estimate relationships between access and institutional characteristics  

## Repository structure

- `scripts/01_data_cleaning.R` builds a multi-year institutional analysis dataset  
- `scripts/02_descriptive_analysis.R` produces summary tables and visualizations of key trends  
- `scripts/03_regression_analysis.R` estimates regression models with institutional and state controls  

## How to run this project

Run scripts in sequence:

1. `01_data_cleaning.R`  
2. `02_descriptive_analysis.R`  
3. `03_regression_analysis.R`  

Intermediate datasets are saved to `data/derived/`, and outputs (figures and tables) are written to `output/`.

## Note on data

This repository is a reconstructed example based on prior research workflows. To keep the project lightweight and reproducible, underlying raw datasets are not included.

## Tools used

R, dplyr, tidyr, ggplot2, fixest
