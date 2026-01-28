# U.S. Energy Transition Forecasting System

A production‑grade forecasting pipeline that models long‑run U.S. primary energy
consumption using monthly data from the U.S. Energy Information Administration
(EIA). The system automates ingestion, cleaning, feature preparation, model 
evaluation, and interactive forecast generation — all driven by configuration 
files for reproducibility and scalability.

This project demonstrates end‑to‑end data science engineering: from raw data to
stakeholder‑ready insights.

---

## Why This Project Matters

Understanding long‑run energy consumption is central to infrastructure planning,
grid reliability, investment strategy, and policy design. This pipeline provides
a transparent, reproducible foundation for exploring U.S. energy transition 
scenarios across fuels and categories.

---

## Project Overview

- **Objective:** Forecast long‑term U.S. primary energy consumption across fuels
                  and categories.  
- **Business Relevance:** Supports utilities, regulators, investors, and policy-
                            makers navigating the U.S. energy transition.  
- **Core Skills Demonstrated:**  
  - Time‑series modeling & ROCV  
  - Modular pipeline engineering  
  - Configuration‑driven architecture  
  - Interactive visualization for stakeholders  
  - Clean, maintainable R code  

---

## Key Insights From the Forecasts

- Renewable consumption shows a persistent upward trend across all model families.  
- Coal continues its long‑term decline with strong cross‑model agreement.  
- Natural gas remains volatile but stable in long‑run projections.  
- Category‑level forecasts reveal structural shifts toward low‑carbon sources.  

These insights are derived from the best‑performing models selected through ROCV.

---

## Technologies Used

- **R**: tidyverse, forecast, fable, prophet, yaml  
- **Visualization**: plotly, htmlwidgets  
- **Configuration**: YAML‑driven pipeline parameters  
- **Engineering Practices**: modular design, reproducible workflows, structured 
                              directory layout  

---

## System Architecture

The pipeline is structured to mirror real‑world production workflows:

### **1. Data Acquisition & Cleaning**
- Imports raw EIA monthly primary energy consumption data  
- Standardizes units, timestamps, and fuel definitions  
- Outputs clean, analysis‑ready datasets  

### **2. Feature Preparation**
- Builds fuel‑level time series  
- Aggregates fuels into categories (Renewables, Fossil Fuels, Nuclear, etc.)  
- Applies YAML‑driven grouping and color standards  

### **3. Model Evaluation (ROCV)**
- Evaluates ARIMA, ETS, TBATS, STL‑ARIMA, Prophet  
- Uses rolling‑origin cross‑validation for realistic out‑of‑sample accuracy  
- Selects the best model per fuel/category  

### **4. Forecast Generation**
- Produces long‑horizon forecasts (e.g., through 2050)  
- Computes confidence intervals  
- Stores model metadata for reproducibility  

### **5. Visualization Layer**
- Unified plotting engine for all fuels and categories  
- Interactive HTML outputs with hover details, trend lines, and uncertainty bands  
- Designed for stakeholder consumption  

---

## Reproducibility

The entire pipeline is configuration‑driven.  
All paths, fuel groupings, model settings, and plot themes are stored in YAML 
files, ensuring:

- consistent results across environments  
- transparent parameterization  
- easy modification without touching code  

---

## Example Forecast Output

Each forecast includes:

- Actual vs forecasted values  
- 95% confidence intervals  
- Linear and LOESS trend overlays  
- Hoverable metadata (model family, values, CI bounds)  

**Example file:**

```
plots/forecasts/fuels/forecast_Coal_Consumption.html
```

---

## Generated Figures

### **Exploratory Analysis**
- Fuel‑level time series  
- Category aggregates  
- Rolling averages  
- Year‑over‑year changes  

### **Forecasting Outputs**
- Interactive HTML forecasts for each fuel  
- Interactive HTML forecasts for each category  
- Trend diagnostics  

These visuals support presentations, dashboards, and policy briefings.

---

## How to Run the Pipeline

From the project root:

```r
source("source_setup.R")
source("main_energytransition.R")
```

Outputs are saved to:

```
plots/individual/
plots/categories/
plots/forecasts/fuels/
plots/forecasts/categories/
```

---

## Repository Structure

```
energy-transition-analysis/
├── config/                             ← YAML configuration files
│   ├── forecast.yaml
│   ├── fuel_colors.yaml
│   ├── fuel_groups.yaml
│   ├── paths.yaml
│   └── plot_theme.yaml
│
├── data/                               ← Raw and processed datasets
│   ├── processed/
│   └── raw/
│
├── plots/                              ← Auto-generated visualizations
│   ├── categories/
│   ├── forecasts/
│   │   ├── fuels/
│   │   └── categories/
│   └── individual/
│
├── src/                                ← Modular R pipeline
│   └── r
│       ├── analysis/                   ← EDA and aggregation logic
│       │   ├── aggregation.R
│       │   ├── eda_basic.R
│       │   ├── eda_categories.R
│       │   ├── eda_individual.R
│       │   ├── fuel_matching/
│       │   └── plotting_functions/
│       │
│       ├── data/                       ← Data loading and preprocessing
│       │   └── load_primary_energy.R
│       │
│       ├── forecasting/                ← Model evaluation & forecasting pipeline
│       │   ├── combine_forecasts.R
│       │   ├── evaluate_model_rocv.R
│       │   ├── evaluate_models.R
│       │   ├── prepare_forecast_data.R
│       │   ├── print_accuracy_summary.R
│       │   ├── run_forecasting.R
│       │   └── select_best_models.R
│       │
│       ├── modeling/                   ← Model definitions and fitting functions
│       │   ├── fit_arima_for_rocv.R
│       │   ├── fit_best_model.R
│       │   ├── fit_ets_for_rocv.R
│       │   ├── fit_prophet_for_rocv.R
│       │   ├── fit_tbats_for_rocv.R
│       │   ├── models_arima.R
│       │   ├── models_ets.R
│       │   ├── models_prophet.R
│       │   └── models_tbats.R
│       │
│       ├── plotting/                    ← Visualization and HTML output
│       │   ├── plot_best_forecasts.R
│       │   ├── plot_best_forecasts_categories.R
│       │   ├── plot_best_forecasts_fuels.R
│       │   └── unified_plot_forecast.R
│       │
│       └── utils/                       ← Helpers and configuration loading
│           ├── helpers.R
│           └── load_config.R
│
├── README.md
├── architecture.md
│
├── main_energytransition.R
├── setup_packages.R
└── source_setup.R
```


---

## License

Creative Commons Attribution‑NonCommercial‑ShareAlike 4.0 International  
https://creativecommons.org/licenses/by-nc-sa/4.0/

---

## Author

**Bill R. Wathier**  
Drilling Fluids Engineer → Data Analyst / Data Scientist  
M.S. Data Analytics, Southern New Hampshire University  
📧 billrwathier@yahoo.com  
🔗 https://www.linkedin.com/in/billwathier
