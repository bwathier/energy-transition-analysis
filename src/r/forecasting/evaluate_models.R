# =========================================================
# evaluate_models.R  
# Uses ROCV engine
# =========================================================

evaluate_models <- function(forecast_results, cfg) {
  
  ts_fuels      <- forecast_results$ts_fuels
  ts_categories <- forecast_results$ts_categories
  
  # ROCV should use a short horizon range (1–3 years)
  horizon <- cfg$forecast$rocv_horizon_years %||% 3
  
  # ---- Evaluate fuels ----
  fuel_list <- unique(ts_fuels$fuel)
  
  fuel_results <- purrr::map_df(fuel_list, function(f) {
    
    df <- ts_fuels %>% dplyr::filter(fuel == f)
    
    arima_acc   <- evaluate_model_rocv(df, fit_arima_for_rocv,   h = horizon)
    ets_acc     <- evaluate_model_rocv(df, fit_ets_for_rocv,     h = horizon)
    prophet_acc <- evaluate_model_rocv(df, fit_prophet_for_rocv, h = horizon)
    tbats_acc   <- evaluate_model_rocv(df, fit_tbats_for_rocv,   h = horizon)
    
    dplyr::bind_rows(
      dplyr::mutate(arima_acc,   model_family = "arima",   fuel = f, level = "fuel"),
      dplyr::mutate(ets_acc,     model_family = "ets",     fuel = f, level = "fuel"),
      dplyr::mutate(prophet_acc, model_family = "prophet", fuel = f, level = "fuel"),
      dplyr::mutate(tbats_acc,   model_family = "tbats",   fuel = f, level = "fuel")
    )
  })
  
  # ---- Evaluate categories ----
  category_results <- ts_categories %>%
    dplyr::group_by(category) %>%
    dplyr::group_split(.keep = TRUE) %>%
    lapply(function(df) {
      
      name <- unique(df$category)
      
      arima_acc   <- evaluate_model_rocv(df, fit_arima_for_rocv,   h = horizon)
      ets_acc     <- evaluate_model_rocv(df, fit_ets_for_rocv,     h = horizon)
      prophet_acc <- evaluate_model_rocv(df, fit_prophet_for_rocv, h = horizon)
      tbats_acc   <- evaluate_model_rocv(df, fit_tbats_for_rocv,   h = horizon)
      
      dplyr::bind_rows(
        dplyr::mutate(arima_acc,   model_family = "arima",   category = name, level = "category"),
        dplyr::mutate(ets_acc,     model_family = "ets",     category = name, level = "category"),
        dplyr::mutate(prophet_acc, model_family = "prophet", category = name, level = "category"),
        dplyr::mutate(tbats_acc,   model_family = "tbats",   category = name, level = "category")
      )
    }) %>%
    dplyr::bind_rows()
  
  dplyr::bind_rows(fuel_results, category_results)
}
