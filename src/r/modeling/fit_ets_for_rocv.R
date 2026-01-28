# =========================================================
# fit_ets_for_rocv.R
# ETS wrapper for rolling-origin evaluation
# =========================================================

fit_ets_for_rocv <- function(train_df, h) {
  
  model <- train_df %>%
    model(ets = ETS(consumption))
  
  fc <- model %>%
    forecast(h = h) %>%
    as_tibble() %>%
    select(date, .mean)
  
  fc
}
