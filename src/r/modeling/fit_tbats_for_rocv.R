# =========================================================
# fit_tbats_for_rocv.R
# TBATS wrapper for rolling-origin evaluation
# =========================================================

fit_tbats_for_rocv <- function(train_df, h) {
  
  # Convert to ts object (monthly frequency)
  ts_data <- ts(train_df$consumption, frequency = 12)
  
  # Fit TBATS model
  model <- forecast::tbats(ts_data)
  
  # Forecast h steps ahead
  fc <- forecast::forecast(model, h = h)
  
  # Construct future dates correctly for yearmonth index
  last_date <- train_df$date[nrow(train_df)]
  future_dates <- tsibble::yearmonth(seq(
    from = as.Date(last_date) + 30, 
    by   = "1 month",
    length.out = h
  ))
  
  tibble::tibble(
    date  = future_dates,
    .mean = as.numeric(fc$mean)
  )
}
