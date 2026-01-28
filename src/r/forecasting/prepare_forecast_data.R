# =========================================================
# prepare_forecast_data.R
# Prepares ts/tsibble objects for forecasting
# =========================================================

prepare_forecast_data <- function(df) {
  
  # ---------------------------------------------------------
  # 1. Normalize date column
  # ---------------------------------------------------------
  df <- df %>%
    mutate(Date = as.Date(Date)) %>%   # ensure pure Date
    rename(date = Date) %>%
    mutate(date = yearmonth(date))     # clean yearmonth index
  
  # ---------------------------------------------------------
  # 2. Fix missing values per fuel
  # ---------------------------------------------------------
  df <- df %>%
    group_by(fuel) %>%
    arrange(date) %>%
    mutate(
      # Fill leading NAs using next known value
      consumption = zoo::na.locf(consumption, na.rm = FALSE, fromLast = TRUE),
      # Fill trailing NAs using previous known value
      consumption = zoo::na.locf(consumption, na.rm = FALSE),
      # Interpolate interior gaps
      consumption = zoo::na.approx(consumption, na.rm = FALSE)
    ) %>%
    ungroup()
  
  # ---------------------------------------------------------
  # 3. Fuel-level tsibble (NO aggregation needed — df already fuel-level)
  # ---------------------------------------------------------
  ts_fuels <- df %>%
    select(fuel, date, consumption) %>%   # drop category
    as_tsibble(index = date, key = fuel)
  
  # ---------------------------------------------------------
  # 4. Category-level tsibble (aggregate fuels)
  # ---------------------------------------------------------
  ts_categories <- df %>%
    group_by(category, date) %>%
    summarise(consumption = sum(consumption), .groups = "drop") %>%
    as_tsibble(index = date, key = category)
  
  # ---------------------------------------------------------
  # 5. Return structured list
  # ---------------------------------------------------------
  return(list(
    ts_fuels      = ts_fuels,
    ts_categories = ts_categories
  ))
}
