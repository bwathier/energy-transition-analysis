# =========================================================
# fit_best_model.R
# Dispatches to the correct long-term model family
# =========================================================

fit_best_model <- function(df, model_family, cfg) {
  
  is_fuel <- "fuel" %in% names(df)
  
  out <- switch(
    model_family,
    
    "arima" = {
      preds <- if (is_fuel) fit_arima_fuel(df, cfg) else fit_arima_category(df, cfg)
      list(model = "arima", forecast = preds)
    },
    
    "ets" = {
      preds <- if (is_fuel) fit_ets_fuel(df, cfg) else fit_ets_category(df, cfg)
      list(model = "ets", forecast = preds)
    },
    
    "prophet" = {
      preds <- if (is_fuel) fit_prophet_fuel(df, cfg) else fit_prophet_category(df, cfg)
      list(model = "prophet", forecast = preds)
    },
    
    "tbats" = {
      preds <- if (is_fuel) fit_tbats_fuel(df, cfg) else fit_tbats_category(df, cfg)
      list(model = "tbats", forecast = preds)
    },
    
    stop(paste("Unknown model family:", model_family))
  )
  
  out
}
