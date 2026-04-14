# Higher Education Mobility Analysis Demo

This repository provides a public-facing demonstration of a multi-year higher-education data workflow using institutional data to examine trends in access, affordability, and mobility-related outcomes.

## Project overview

In applied research on higher education and economic mobility, I worked with large administrative and public datasets to construct institutional panels, generate descriptive trends, and estimate regression models linking access measures to institutional characteristics.

This repository presents a simplified, reproducible version of that workflow using public or representative data sources.

## What this repo demonstrates

- cleaning and restructuring large institutional datasets
- constructing analysis-ready variables from public higher education data
- generating descriptive visualizations for policy and stakeholder audiences
- estimating regression models with institutional and state controls
- organizing an end-to-end analytical workflow in R

## Repository structure

- `scripts/01_data_cleaning.R` prepares an institutional analysis file from public data sources  
- `scripts/02_descriptive_analysis.R` generates descriptive summaries and visualizations  
- `scripts/03_regression_analysis.R` estimates regression models examining institutional access patterns  

## How to run this project

Scripts are designed to be run in sequence:

1. `01_data_cleaning.R`
2. `02_descriptive_analysis.R`
3. `03_regression_analysis.R`

Intermediate outputs are saved to `data/derived/`.

## Note on data

This repository is a reconstructed and simplified example based on prior professional research workflow. Some original project-specific data files are not included here, so public or representative data sources are used in their place.

## Tools used

R, dplyr, tidyr, ggplot2, fixest
