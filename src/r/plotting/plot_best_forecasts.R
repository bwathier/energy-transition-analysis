# =========================================================
# plot_best_forecasts.R 
# =========================================================

plot_best_forecasts <- function(best_models, forecast_results, fuel_colors, 
                                category_colors, config) {
  
  for (i in seq_len(nrow(best_models))) {
    
    level  <- best_models$level[i]
    name   <- best_models$Description[i]
    family <- best_models$Best_Model[i]
    
    # Output directory
    out_dir <- if (level == "fuel") {
      config$forecast$paths$output_fuels
    } else {
      config$forecast$paths$output_categories
    }
    dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
    
    # Pull actual + forecast directly from new architecture
    if (level == "fuel") {
      series <- forecast_results$fuel_results[[name]]
    } else {
      series <- forecast_results$category_results[[name]]
    }
    
    if (is.null(series)) next
    
    actual_series <- as_tibble(series$actual)
    
    # If forecast is a list (ARIMA/ETS), extract the tibble
    if (is.list(series$forecast) && "forecast" %in% names(series$forecast)) {
      forecast_series <- as_tibble(series$forecast$forecast)
    } else {
      # TBATS/Prophet already return a tibble
      forecast_series <- as_tibble(series$forecast)
    }
    
    if (is.null(actual_series) || is.null(forecast_series)) next
    if (nrow(actual_series) == 0 || nrow(forecast_series) == 0) next
    
    # 🔹 NEW FIX: Skip if forecast has no date column
    if (!("date" %in% names(forecast_series))) next
    
    # Ensure proper date format + ordering
    actual_series$date   <- as.Date(actual_series$date)
    forecast_series$date <- as.Date(forecast_series$date)
    
    actual_series   <- actual_series   %>% arrange(date)
    forecast_series <- forecast_series %>% arrange(date)
    
    # Unified plotting engine
    p <- plot_forecast_interactive(
      actual_df       = actual_series,
      forecast_df     = forecast_series,
      name            = name,
      level           = level,
      family          = family,
      config          = config,
      fuel_colors     = fuel_colors,
      category_colors = category_colors
    )
    
    print(p)
    
    # Export
    html_path <- file.path(out_dir, paste0("forecast_", gsub(" ", "_", name), ".html"))
    saveWidget(p, html_path, selfcontained = TRUE)
  }
  
  cat("\nAll forecast plots generated and exported.\n")
}
