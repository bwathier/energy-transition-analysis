# =========================================================
# source_setup.R - Sources all Energy Transition project modules
# =========================================================

# -------------------------
# Utilities
# -------------------------
source("src/r/utils/helpers.R")
source("src/r/utils/load_config.R")

# -------------------------
# Data loading
# -------------------------
source("src/r/data/load_primary_energy.R")

# -------------------------
# Plotting helpers (interactive only)
# -------------------------
source("src/r/analysis/plotting_functions.R")

# -------------------------
# Fuel matching & preparation
# -------------------------
source("src/r/analysis/fuel_matching.R")

# -------------------------
# Aggregation
# -------------------------
source("src/r/analysis/aggregation.R")

# -------------------------
# EDA modules 
# -------------------------
source("src/r/analysis/eda_basic.R")
source("src/r/analysis/eda_individual.R")
source("src/r/analysis/eda_categories.R")

# -------------------------
# Forecasting modules
# -------------------------
source("src/r/forecasting/prepare_forecast_data.R")
source("src/r/forecasting/run_forecasting.R")
source("src/r/forecasting/combine_forecasts.R")
source("src/r/forecasting/evaluate_models.R")
source("src/r/forecasting/print_accuracy_summary.R") #Display Model Accuracy 
source("src/r/forecasting/select_best_models.R")

# -------------------------
#  ROCV modules for modeling
# -------------------------
source("src/r/forecasting/evaluate_model_rocv.R")
source("src/r/modeling/fit_arima_for_rocv.R")
source("src/r/modeling/fit_ets_for_rocv.R")
source("src/r/modeling/fit_prophet_for_rocv.R")
source("src/r/modeling/fit_best_model.R")
source("src/r/modeling/fit_tbats_for_rocv.R")

# -------------------------
# Final forecast model families
# -------------------------
source("src/r/modeling/models_arima.R")
source("src/r/modeling/models_ets.R")
source("src/r/modeling/models_prophet.R")
source("src/r/modeling/models_tbats.R")

# -------------------------
# Final forecast plotting 
# -------------------------
source("src/r/plotting/plot_best_forecasts.R")
source("src/r/plotting/unified_plot_forecast.R")

