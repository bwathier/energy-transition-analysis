# =========================================================
# models_arima.R
# ARIMA models for fuels and categories
# =========================================================

# ---- Fuel-level ARIMA ----
fit_arima_fuel <- function(ts_fuel, cfg) {
  
  # Fit ARIMA model
  arima_fuel_model <- ts_fuel %>%
    model(arima = ARIMA(consumption))
  
  # Fitted values (normalized for consistency)
  arima_fuel_fitted <- arima_fuel_model %>%
    fitted() %>%
    as_tibble() %>%
    rename(.fitted = .fitted)
  
  # Long-term horizon: years → months
  horizon <- cfg$forecast$horizon_years * 12
  
  # Forecast (already normalized)
  arima_fuel_forecast <- arima_fuel_model %>%
    forecast(h = horizon) %>%
    as_tibble() %>%
    normalize_forecast(key_cols = c("fuel"), index_col = "date")
  
  list(
    model    = arima_fuel_model,
    fitted   = arima_fuel_fitted,
    forecast = arima_fuel_forecast
  )
}

# ---- Category-level ARIMA ----
fit_arima_category <- function(ts_category, cfg) {
  
  # Fit ARIMA model
  arima_category_model <- ts_category %>%
    model(arima = ARIMA(consumption))
  
  # Fitted values (normalized for consistency)
  arima_category_fitted <- arima_category_model %>%
    fitted() %>%
    as_tibble() %>%
    rename(.fitted = .fitted)
  
  # Long-term horizon: years → months
  horizon <- cfg$forecast$horizon_years * 12
  
  # Forecast (already normalized)
  arima_category_forecast <- arima_category_model %>%
    forecast(h = horizon) %>%
    as_tibble() %>%
    normalize_forecast(key_cols = c("category"), index_col = "date")
  
  list(
    model    = arima_category_model,
    fitted   = arima_category_fitted,
    forecast = arima_category_forecast
  )
}
