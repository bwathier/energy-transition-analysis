# =========================================================
# models_prophet.R
# Long-term Prophet forecasting for fuels and categories
# =========================================================

# ---- Fuel-level Prophet ----
fit_prophet_fuel <- function(df, cfg) {
  
  # Prophet requires ds/y format
  df_prophet <- df %>%
    dplyr::select(date, consumption) %>%
    dplyr::rename(ds = date, y = consumption) %>%
    dplyr::mutate(ds = as.Date(ds))
  
  # Fit Prophet model
  model <- prophet::prophet(df_prophet)
  
  # Forecast horizon (years → months)
  h <- cfg$forecast$horizon_years * 12
  
  future <- prophet::make_future_dataframe(
    model,
    periods = h,
    freq = "month"
  )
  
  fc <- predict(model, future)
  
  # Convert back to yearmonth
  out <- tibble::tibble(
    date     = tsibble::yearmonth(fc$ds),
    forecast = fc$yhat
  )
  
  # Keep only the forecast horizon (not the historical fitted values)
  out %>% dplyr::slice((n() - h + 1):n())
}

# ---- Category-level Prophet ----
fit_prophet_category <- function(df, cfg) {
  
  df_prophet <- df %>%
    dplyr::select(date, consumption) %>%
    dplyr::rename(ds = date, y = consumption) %>%
    dplyr::mutate(ds = as.Date(ds))
  
  model <- prophet::prophet(df_prophet)
  
  h <- cfg$forecast$horizon_years * 12
  
  future <- prophet::make_future_dataframe(
    model,
    periods = h,
    freq = "month"
  )
  
  fc <- predict(model, future)
  
  out <- tibble::tibble(
    date     = tsibble::yearmonth(fc$ds),
    forecast = fc$yhat
  )
  
  out %>% dplyr::slice((n() - h + 1):n())
}
