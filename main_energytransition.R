# =================================================================
# main_energytransition.R - Main Energy Transition Operation Script
# =================================================================

# ---------------------------------------------------------
# 1. Call setup_packages.R and load Libraries
# ---------------------------------------------------------
source("setup_packages.R")

# ---------------------------------------------------------
# 2. Source all modules (functions only)
# ---------------------------------------------------------
source("source_setup.R")

# ---------------------------------------------------------
# 3. Load YAML configs
# ---------------------------------------------------------
cfg         <- load_all_configs()
fuel_groups <- cfg$fuel_groups
fuel_colors <- cfg$fuel_colors$individual_fuels

file_path <- file.path(
  cfg$paths$data$raw_monthly,
  "Table_1_3_Primary_Energy_Consumption.csv"
)

# ---------------------------------------------------------
# 4. Load and clean primary energy data
# ---------------------------------------------------------
primary_clean <- load_and_clean_primary_energy(file_path)

# ---------------------------------------------------------
# 5. Fuel matching & preparation
# ---------------------------------------------------------
fuel_data <- prepare_fuel_data(
  primary_clean = primary_clean,
  fuel_groups   = fuel_groups,
  fuel_colors   = fuel_colors
)

fuel_plot_data     <- fuel_data$fuel_plot_data
fuel_share_data    <- fuel_data$fuel_share_data
fuel_colors_plot   <- fuel_data$fuel_colors_plot
fuel_color_map     <- fuel_data$color_map

# ---------------------------------------------------------
# 6. Ensure plot directories exist
# ---------------------------------------------------------
ensure_plot_dirs()

# ---------------------------------------------------------
# 7.1 Missingness diagnostics
# ---------------------------------------------------------
missing_by_desc <- compute_missing_by_desc(primary_clean)
cat("\nMissingness by Description:\n")
print(missing_by_desc)

# ---------------------------------------------------------
# 7.2 Summary statistics
# ---------------------------------------------------------
summary_by_desc <- compute_summary_by_desc(primary_clean)
cat("\nSummary statistics by Description:\n")
print(summary_by_desc)

# ---------------------------------------------------------
# 7.3 Time coverage
# ---------------------------------------------------------
time_coverage <- compute_time_coverage(primary_clean)
cat("\nTime coverage by Description:\n")
print(time_coverage)

# ---------------------------------------------------------
# 7.4 YoY change + outlier detection
# ---------------------------------------------------------
yoy_results <- compute_yoy_and_outliers(primary_clean)

yoy_df       <- yoy_results$yoy_df
yoy_summary  <- yoy_results$yoy_summary
yoy_outliers <- yoy_results$yoy_outliers

cat("\nYoY Change Computed.\n")
cat("\nYoY Summary Statistics:\n")
print(yoy_summary)

cat("\nPotential YoY Outliers (|z| > 3):\n")
print(
  yoy_outliers %>%
    filter(is_outlier) %>%
    select(Date, Description, Value, YoY_Change, yoy_z) %>%
    arrange(Date)
)

# ---------------------------------------------------------
# 7.5 Rolling averages
# ---------------------------------------------------------
rolling_df <- compute_rolling_averages(primary_clean)

# ---------------------------------------------------------
# 7.6 Individual-fuel YoY and rolling (after matching)
# ---------------------------------------------------------
individual_yoy_df <- yoy_df %>%
  filter(Description %in% fuel_plot_data$Description) %>%
  mutate(Description = factor(Description, levels = levels(fuel_plot_data$Description)))

individual_roll_df <- rolling_df %>%
  filter(Description %in% fuel_plot_data$Description) %>%
  mutate(Description = factor(Description, levels = levels(fuel_plot_data$Description)))

cat("\nRolling averages (12m and 24m) computed.\n")

# ---------------------------------------------------------
# 7.7 Unique description diagnostics
# ---------------------------------------------------------
cat("\nUnique Description values in primary_clean:\n")
print(list_unique_descriptions(primary_clean))

# ---------------------------------------------------------
# 7.8 Category aggregation 
# ---------------------------------------------------------
agg <- aggregate_categories(
  primary_clean   = primary_clean,
  fuel_plot_data  = fuel_plot_data,
  fuel_groups     = fuel_groups,
  fuel_colors     = fuel_colors
)

combined_df       <- agg$combined_df
share_df          <- agg$share_df
category_yoy_df   <- agg$category_yoy_df
category_roll_df  <- agg$category_roll_df
category_colors   <- agg$category_colors
forecast_data <- prepare_forecast_data(agg$fuel_forecast_df)

# ---------------------------------------------------------
# 7.9 EDA Plots (config-driven)
# ---------------------------------------------------------
run_eda_individual(
  fuel_plot_data      = fuel_plot_data,
  fuel_share_data     = fuel_share_data,
  individual_yoy_df   = individual_yoy_df,
  individual_roll_df  = individual_roll_df,
  fuel_colors_plot    = fuel_colors_plot,
  config              = cfg
)

run_eda_categories(
  combined_df        = combined_df,
  share_df           = share_df,
  category_yoy_df    = category_yoy_df,
  category_roll_df   = category_roll_df,
  category_colors    = category_colors,
  config             = cfg
)

# ---------------------------------------------------------
# 8. Long-run growth: CAGR per fuel
# ---------------------------------------------------------
cagr_by_fuel <- compute_cagr_by_fuel(primary_clean)
cat("\nLong-run CAGR by fuel (sorted by CAGR):\n")
print(cagr_by_fuel)

# ---------------------------------------------------------
# 9. Model evaluation (ROCV-based)
# ---------------------------------------------------------
model_accuracy <- evaluate_models(forecast_data, cfg)

best_models <- select_best_models(model_accuracy)

# ---------------------------------------------------------
# 9.1 Clean and label best models
# ---------------------------------------------------------
best_models_clean <- best_models %>%
  mutate(
    Type        = ifelse(level == "fuel", "Fuel", "Category"),
    Best_Model  = model_family,
    Description = ifelse(
      level == "fuel",
      as.character(fuel),      # fuel names from config / cleaned data
      as.character(category)   # category names from config / cleaned data
    )
  ) %>%
  select(
    level, fuel, category, Description,
    Type, Best_Model, MAE, RMSE, MAPE, origins
  )

# ---------------------------------------------------------
# 10. Forecasting models (fit only best models)
# ---------------------------------------------------------
forecast_results <- run_forecasting(forecast_data, cfg, best_models_clean)

# ---------------------------------------------------------
# 11. Plot best forecast models (Interactive Only)
# ---------------------------------------------------------
plot_best_forecasts(
  best_models      = best_models_clean,
  forecast_results = forecast_results,
  fuel_colors      = fuel_colors_plot,
  category_colors  = category_colors,
  config           = cfg
)

cat("\nAll interactive forecast plots generated.\n")
