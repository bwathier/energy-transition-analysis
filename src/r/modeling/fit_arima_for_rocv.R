# =========================================================
# fit_arima_for_rocv.R
# ARIMA wrapper for rolling-origin evaluation
# =========================================================

fit_arima_for_rocv <- function(train_df, h) {
  
  model <- train_df %>%
    model(arima = ARIMA(consumption))
  
  fc <- model %>%
    forecast(h = h) %>%
    as_tibble() %>%
    select(date, .mean)
  
  fc
}
