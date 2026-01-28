# =========================================================
# models_ets.R
# ETS models for fuels and categories
# =========================================================

# ---- Fuel-level ETS ----
fit_ets_fuel <- function(ts_fuel, cfg) {
  
  # Fit ETS model
  ets_fuel_model <- ts_fuel %>%
    model(ets = ETS(consumption))
  
  # Fitted values (normalized for consistency)
  ets_fuel_fitted <- ets_fuel_model %>%
    fitted() %>%
    as_tibble() %>%
    rename(.fitted = .fitted)
  
  # Long-term horizon: years → months
  horizon <- cfg$forecast$horizon_years * 12
  
  # Forecast (already normalized)
  ets_fuel_forecast <- ets_fuel_model %>%
    forecast(h = horizon) %>%
    as_tibble() %>%
    normalize_forecast(key_cols = c("fuel"), index_col = "date")
  
  list(
    model    = ets_fuel_model,
    fitted   = ets_fuel_fitted,
    forecast = ets_fuel_forecast
  )
}

# ---- Category-level ETS ----
fit_ets_category <- function(ts_category, cfg) {
  
  # Fit ETS model
  ets_category_model <- ts_category %>%
    model(ets = ETS(consumption))
  
  # Fitted values (normalized for consistency)
  ets_category_fitted <- ets_category_model %>%
    fitted() %>%
    as_tibble() %>%
    rename(.fitted = .fitted)
  
  # Long-term horizon: years → months
  horizon <- cfg$forecast$horizon_years * 12
  
  # Forecast (already normalized)
  ets_category_forecast <- ets_category_model %>%
    forecast(h = horizon) %>%
    as_tibble() %>%
    normalize_forecast(key_cols = c("category"), index_col = "date")
  
  list(
    model    = ets_category_model,
    fitted   = ets_category_fitted,
    forecast = ets_category_forecast
  )
}
