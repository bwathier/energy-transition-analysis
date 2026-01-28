# =========================================================
# combine_forecasts.R
# Combines ARIMA, ETS, Prophet forecasts
# =========================================================

# =========================================================
# normalize_forecast.R-like helper inline
# Ensures all forecast outputs share the same structure
# =========================================================

normalize_forecast <- function(df, key_cols, index_col = "date") {
  df <- as_tibble(df)
  
  # Ensure index is Date
  df[[index_col]] <- as.Date(df[[index_col]])
  
  # If we already have .lower/.upper, just keep them
  has_lower <- ".lower" %in% names(df)
  has_upper <- ".upper" %in% names(df)
  
  if (!has_lower || !has_upper) {
    # Fallback: synthesize intervals from .mean
    if (!(".mean" %in% names(df))) {
      stop("normalize_forecast: '.mean' column is missing.")
    }
    
    mean_sd <- stats::sd(df$.mean, na.rm = TRUE)
    if (!is.finite(mean_sd) || mean_sd <= 0) {
      mean_sd <- 0.01
    }
    
    df$.lower <- df$.mean - 1.96 * mean_sd
    df$.upper <- df$.mean + 1.96 * mean_sd
  }
  
  df %>%
    select(all_of(key_cols), all_of(index_col), .mean, .lower, .upper)
}


combine_forecasts <- function(arima, ets, prophet) {
  
  # Convert each model family to plain base data frames
  arima_fuels       <- as.data.frame(arima$arima_fuels)
  ets_fuels         <- as.data.frame(ets$ets_fuels)
  prophet_fuels     <- as.data.frame(prophet$prophet_fuels)
  
  arima_categories   <- as.data.frame(arima$arima_categories)
  ets_categories     <- as.data.frame(ets$ets_categories)
  prophet_categories <- as.data.frame(prophet$prophet_categories)
  
  # Remove the distribution column (consumption)
  arima_fuels$consumption <- NULL
  ets_fuels$consumption <- NULL
  prophet_fuels$consumption <- NULL
  
  arima_categories$consumption <- NULL
  ets_categories$consumption <- NULL
  prophet_categories$consumption <- NULL
  
  # Now bind_rows safely
  fuels <- dplyr::bind_rows(
    arima_fuels,
    ets_fuels,
    prophet_fuels
  )
  
  categories <- dplyr::bind_rows(
    arima_categories,
    ets_categories,
    prophet_categories
  )
  
  list(
    fuels = fuels,
    categories = categories
  )
}
