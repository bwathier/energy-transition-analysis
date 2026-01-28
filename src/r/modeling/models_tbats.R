# =========================================================
# models_tbats.R
# Long-term TBATS forecasting for fuels and categories
# =========================================================

# ---- Fuel-level TBATS ----
fit_tbats_fuel <- function(df, cfg) {
  
  # Convert to ts object
  ts_data <- ts(df$consumption, frequency = 12)
  
  # Fit TBATS
  model <- forecast::tbats(ts_data)
  
  # Forecast horizon (years → months)
  h <- cfg$forecast$horizon_years * 12
  
  fc <- forecast::forecast(model, h = h)
  
  # Build future dates as yearmonth
  last_date <- df$date[nrow(df)]
  future_dates <- tsibble::yearmonth(seq(
    from = as.Date(last_date) + 30,
    by   = "1 month",
    length.out = h
  ))
  
  tibble::tibble(
    date     = future_dates,
    forecast = as.numeric(fc$mean)
  )
}

# ---- Category-level TBATS ----
fit_tbats_category <- function(df, cfg) {
  
  ts_data <- ts(df$consumption, frequency = 12)
  
  model <- forecast::tbats(ts_data)
  
  h <- cfg$forecast$horizon_years * 12
  
  fc <- forecast::forecast(model, h = h)
  
  last_date <- df$date[nrow(df)]
  future_dates <- tsibble::yearmonth(seq(
    from = as.Date(last_date) + 30,
    by   = "1 month",
    length.out = h
  ))
  
  tibble::tibble(
    date     = future_dates,
    forecast = as.numeric(fc$mean)
  )
}
