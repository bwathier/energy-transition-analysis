# =========================================================
# fit_prophet_for_rocv.R
# Prophet wrapper for rolling-origin evaluation
# =========================================================

fit_prophet_for_rocv <- function(train_df, h) {
  
  # Prophet requires ds/y column names
  df <- train_df %>%
    dplyr::select(ds = date, y = consumption)
  
  # Fit model
  m <- prophet::prophet(
    df,
    yearly.seasonality = TRUE,
    weekly.seasonality = FALSE,
    daily.seasonality = FALSE,
    changepoint.prior.scale = 0.05
  )
  
  # Create future dataframe
  future <- prophet::make_future_dataframe(
    m,
    periods = h,
    freq = "month"
  )
  
  # Forecast
  fc <- predict(m, future)
  
  # Return ROCV-compatible tibble
  tibble::tibble(
    date  = fc$ds[(nrow(fc) - h + 1):nrow(fc)],
    .mean = fc$yhat[(nrow(fc) - h + 1):nrow(fc)]
  )
}
