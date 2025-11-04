# Auto EDA Tool 🔍


[![Shiny](https://img.shields.io/badge/Shiny-1.7.0-blue.svg)](https://shiny.rstudio.com/)
[![ggplot2](https://img.shields.io/badge/ggplot2-3.4.0-red.svg)](https://ggplot2.tidyverse.org/)
[![R](https://img.shields.io/badge/R-4.0+-blue.svg)](https://www.r-project.org/)


An interactive web application built with **R Shiny** that automates Exploratory Data Analysis (EDA) tasks. Upload your CSV data and get instant insights through comprehensive visualizations and statistical summaries. This README is embedded here as Markdown so you can preview, copy, or export it.


---


## ✨ Overview


Auto EDA Tool reduces the initial friction of understanding a dataset. It combines automated statistical summaries, intelligent visualizations, and actionable insights so data scientists, students, and analysts can move faster from raw CSV to informed hypotheses.


Key goals:
- Provide immediate, accurate overviews of unknown datasets.
- Surface data quality issues (missing values, inconsistent types, duplicates).
- Suggest next steps: feature engineering hints, candidate models, or data cleaning actions.


---


## 📊 Features (Expanded)


### Data Visualization
- **Histograms**: Auto-binning and adjustable bin width; log-scale option for skewed data.
- **Scatter Plots**: Pairwise scatter with optional smoothing lines (loess) and trend summaries.
- **Box Plots**: Grouped boxplots, violin-plot alternatives, and automatic outlier flagging.
- **Density Plots**: Kernel density with bandwidth selection and multimodality detection.
- **Bar Charts & Counts**: For categorical variables — stacked and normalized views.
- **Pair Plots (Scatterplot matrix)**: For quick multivariate relationships and correlation patterns.


### Statistical & Quality Analysis
- **Summary Statistics**: Count, unique values, missing counts and percentages, min, max, mean, median, mode, standard deviation, variance, skewness, kurtosis.
- **Correlation Matrix**: Pearson, Spearman and Kendall options; correlation heatmap with significance masking.
- **Missing Value Report**: Per-column and per-row missingness, patterns, and suggested imputations (mean/median/mode/KNN).
- **Outlier Detection**: IQR, z-score, and robust MAD-based detection with an explanation for each flagged row.
- **Data Type Inference**: Detects numeric, integer, categorical, boolean, date/time, and text — suggests conversions.
- **Duplicate Detection**: Exact and fuzzy matching to find possibly duplicated records.


### Automation & UX
- **Drag & Drop Upload**: Accepts CSV, TSV, and gzipped CSVs.
- **Auto Schema Preview**: Shows inferred schema and lets you override types before analysis.
- **Interactive Filtering**: Apply filters to the dataset and regenerate plots on the fly.
- **Downloadable Reports**: Export an interactive HTML report or a static PDF report of the EDA.
- **Dark Mode & Responsive Layout**: Mobile-friendly and accessible color palettes.


---


## 🚀 Quick Start (Expanded)


### Prerequisites
- R (version 4.0 or higher)
- RStudio (recommended)
- System: macOS, Windows, or Linux


### Installation


1. **Clone the repository**
```bash
git clone https://github.com/yourusername/auto-eda-tool.git
cd auto-eda-tool
```


2. **Install R package dependencies**
```r
# Run in R or RStudio
install.packages(c("shiny", "ggplot2", "dplyr", "DT", "shinyWidgets", "shinycssloaders", "plotly", "readr", "skimr", "naniar", "corrplot", "GGally"))
```


3. **Run locally**
```r
# in the project directory
library(shiny)
runApp("./app")
```


---


## 🧩 App Structure (Suggested)


- `app/ui.R` — Shiny UI definitions, layout, and inputs.
- `app/server.R` — Server logic: data ingestion, reactive analysis, rendering plots.
- `R/eda_helpers.R` — Reusable helper functions for summaries, plots, and reports.
- `www/` — Static assets (CSS, JS, images).
Project maintainer: Your Name — your.email@example.com
