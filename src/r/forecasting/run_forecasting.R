# =========================================================
# run_forecasting.R
# Fit only the best model per fuel/category
# =========================================================

run_forecasting <- function(fuel_forecast_df, cfg, best_models) {
  
  # ---- Fuel forecasts ----
  fuel_results <- fuel_forecast_df$ts_fuels %>%
    group_by(fuel) %>%
    group_split(.keep = TRUE) %>%
    lapply(function(df) {
      
      name <- unique(df$fuel)
      
      best <- best_models %>%
        filter(level == "fuel", fuel == name) %>%
        pull(Best_Model)
      
      out <- fit_best_model(df, best, cfg)
      
      list(
        fuel     = name,
        actual   = df,
        model    = out$model,
        forecast = out$forecast
      )
    })
  
  names(fuel_results) <- sapply(fuel_results, `[[`, "fuel")
  
  # ---- Category forecasts ----
  category_results <- fuel_forecast_df$ts_categories %>%
    group_by(category) %>%
    group_split(.keep = TRUE) %>%
    lapply(function(df) {
      
      name <- unique(df$category)
      
      best <- best_models %>%
        filter(level == "category", category == name) %>%
        pull(Best_Model)
      
      out <- fit_best_model(df, best, cfg)
      
      list(
        category = name,
        actual   = df,
        model    = out$model,
        forecast = out$forecast
      )
    })
  
  names(category_results) <- sapply(category_results, `[[`, "category")
  
  list(
    fuel_results     = fuel_results,
    category_results = category_results
  )
}
