# System Architecture Documentation  
**U.S. Energy Transition Forecasting System**

This document provides a detailed overview of the system architecture behind the U.S. Energy Transition Forecasting Pipeline. It explains how the pipeline is structured, how components interact, and the design decisions that support reproducibility, modularity, and long‑term maintainability.

---

# 1. Architectural Overview

The forecasting system is built as a **modular, configuration‑driven pipeline**. Each stage of the workflow is isolated into its own subsystem, allowing the project to scale, adapt, and remain transparent.

At a high level, the pipeline flows as follows:

```
Raw Data
   ↓
Data Cleaning & Standardization
   ↓
Feature Preparation (fuels & categories)
   ↓
Rolling-Origin Cross-Validation (ROCV)
   ↓
Model Selection (best model per fuel/category)
   ↓
Long-Horizon Forecasting
   ↓
Interactive Visualization (HTML)
```

This architecture mirrors real‑world production forecasting systems used in energy analytics, finance, and infrastructure planning.

---

# 2. Configuration Strategy

The pipeline is fully configuration‑driven using YAML files stored in `/config`.  
This design ensures:

- **Reproducibility** — all parameters are explicit and version‑controlled  
- **Transparency** — no hidden defaults or hard‑coded values  
- **Flexibility** — users can modify behavior without editing code  
- **Portability** — the pipeline can run in different environments with minimal changes  

### Key configuration files:

- `paths.yaml` — directory paths for data, plots, and outputs  
- `fuel_groups.yaml` — mapping of fuels to categories  
- `fuel_colors.yaml` — consistent color palette for visualizations  
- `forecast.yaml` — model families, forecast horizon, ROCV settings  
- `plot_theme.yaml` — unified styling for all plots  

This approach is common in production ML systems and signals engineering maturity.

---

# 3. Data Architecture

### **Raw Data**
Stored in `/data/raw/` exactly as downloaded from the EIA.

### **Processed Data**
Stored in `/data/processed/` after cleaning and standardization.

### **Data Loading Module**
`src/r/data/load_primary_energy.R` handles:

- reading raw EIA files  
- normalizing units  
- parsing timestamps  
- harmonizing fuel names  
- validating structure  

This ensures downstream modules operate on clean, consistent data.

---

# 4. Feature Preparation

Feature engineering is handled in `/src/r/analysis` and `/src/r/forecasting`.

Key responsibilities:

- Constructing monthly time series for each fuel  
- Aggregating fuels into categories (Renewables, Fossil Fuels, etc.)  
- Applying YAML‑driven grouping rules  
- Preparing data structures required for ROCV and forecasting  

This modular separation keeps the forecasting logic clean and focused.

---

# 5. Modeling Strategy

The system evaluates multiple model families:

- ARIMA  
- ETS  
- TBATS  
- STL‑ARIMA  
- Prophet  

Each model family has its own implementation in `/src/r/modeling`.

### **Why multiple models?**
Energy consumption patterns vary by fuel:

- Some are seasonal  
- Some trend smoothly  
- Some are volatile  
- Some have structural breaks  

A single model family cannot capture all behaviors reliably.

---

# 6. Rolling-Origin Cross-Validation (ROCV)

ROCV is implemented in:

- `evaluate_model_rocv.R`  
- `fit_*_for_rocv.R`  
- `evaluate_models.R`  

### **Why ROCV?**
Traditional train/test splits fail for time‑series forecasting.  
ROCV simulates real‑world forecasting conditions by repeatedly training on past data and testing on future slices.

This provides:

- realistic out‑of‑sample accuracy  
- robust model comparison  
- confidence in long‑horizon forecasts  

---

# 7. Model Selection

The system selects the best model per fuel and per category using:

- accuracy metrics (MAPE, RMSE, MAE)  
- ROCV performance  
- model stability  

Selection logic lives in:

- `select_best_models.R`  
- `fit_best_model.R`  

Metadata is stored for reproducibility.

---

# 8. Forecast Generation

Forecasting is handled in:

- `run_forecasting.R`  
- `combine_forecasts.R`  
- `prepare_forecast_data.R`  

Outputs include:

- point forecasts  
- 95% confidence intervals  
- model metadata  
- combined category‑level forecasts  

Forecasts extend to long horizons (e.g., 2050), supporting energy transition analysis.

---

# 9. Visualization Architecture

All visualization logic lives in `/src/r/plotting`.

Key components:

- `unified_plot_forecast.R` — the core plotting engine  
- `plot_best_forecasts.R` — fuel‑level forecasts  
- `plot_best_forecasts_categories.R` — category‑level forecasts  
- `plot_best_forecasts_fuels.R` — batch generation  

### **Why interactive HTML?**
Stakeholders (policy analysts, engineers, executives) need:

- hoverable values  
- confidence interval exploration  
- zooming and panning  
- trend overlays  

HTML widgets provide this without requiring RStudio.

---

# 10. Utilities & Helpers

The `/src/r/utils` directory contains:

- `load_config.R` — loads and validates YAML files  
- `helpers.R` — shared utility functions  

These modules keep the pipeline DRY and maintainable.

---

# 11. Design Decisions & Tradeoffs

### **Modular R architecture**
Pros: maintainable, testable, scalable  
Tradeoff: more files, more structure to manage

### **YAML‑driven configuration**
Pros: reproducible, transparent, flexible  
Tradeoff: requires careful validation

### **ROCV instead of simple train/test**
Pros: realistic, robust  
Tradeoff: computationally heavier

### **Interactive HTML outputs**
Pros: stakeholder‑friendly  
Tradeoff: larger file sizes

### **Category‑level aggregation**
Pros: supports high‑level policy analysis  
Tradeoff: may smooth out fuel‑specific nuances

---

# 12. Future Enhancements

Potential extensions include:

- Incorporating machine learning baselines (XGBoost, Random Forest)  
- Adding scenario‑based forecasting (policy, price, technology adoption)  
- Deploying as a Shiny dashboard or API  
- Integrating uncertainty quantification beyond confidence intervals  
- Automating data refresh from EIA API  

These enhancements would further align the system with production‑grade forecasting platforms.

---

# 13. Summary

This architecture reflects a real‑world forecasting system:

- modular  
- reproducible  
- configuration‑driven  
- analytically rigorous  
- stakeholder‑oriented  

It demonstrates the engineering discipline expected of a data scientist working in energy analytics, forecasting, or applied ML.

