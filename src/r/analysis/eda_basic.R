# =========================================================
# eda_basic.R - Basic EDA utilities
# =========================================================

# ---------------------------------------------------------
# Computes missingness diagnostics for each fuel Description
# ---------------------------------------------------------
compute_missing_by_desc <- function(primary_clean) {
  primary_clean %>%
    dplyr::group_by(Description) %>%
    dplyr::summarise(
      n_obs       = dplyr::n(),
      n_missing   = sum(is.na(Value)),
      pct_missing = n_missing / n_obs,
      .groups     = "drop"
    ) %>%
    dplyr::arrange(dplyr::desc(pct_missing))
}

# ---------------------------------------------------------
# Summary statistics for each fuel Description
# ---------------------------------------------------------
compute_summary_by_desc <- function(primary_clean) {
  primary_clean %>%
    dplyr::group_by(Description) %>%
    dplyr::summarise(
      n_obs        = sum(!is.na(Value)),
      min_value    = min(Value, na.rm = TRUE),
      max_value    = max(Value, na.rm = TRUE),
      mean_value   = mean(Value, na.rm = TRUE),
      median_value = median(Value, na.rm = TRUE),
      .groups      = "drop"
    ) %>%
    dplyr::arrange(dplyr::desc(max_value))
}

# ---------------------------------------------------------
# Computes the first and last available dates for each fuel
  # Description in the cleaned dataset.
# ---------------------------------------------------------
compute_time_coverage <- function(primary_clean) {
  primary_clean %>%
    dplyr::group_by(Description) %>%
    dplyr::summarise(
      first_date = min(Date, na.rm = TRUE),
      last_date  = max(Date, na.rm = TRUE),
      .groups    = "drop"
    )
}

# ---------------------------------------------------------
# Computes year-over-year (YoY) percent change and absolute
  # change for each fuel Description, then identifies potential
  # outliers using z-scores (|z| > 3).
# ---------------------------------------------------------
compute_yoy_and_outliers <- function(primary_clean) {
  
  # Compute YoY change
  yoy_df <- primary_clean %>%
    dplyr::arrange(Description, Date) %>%
    dplyr::group_by(Description) %>%
    dplyr::mutate(
      YoY_Change     = (Value - dplyr::lag(Value, 12)) / dplyr::lag(Value, 12),
      YoY_Abs_Change = Value - dplyr::lag(Value, 12)
    ) %>%
    dplyr::ungroup()
  
  # Summary statistics
  yoy_summary <- yoy_df %>%
    dplyr::group_by(Description) %>%
    dplyr::summarise(
      n_yoy      = sum(!is.na(YoY_Change)),
      mean_yoy   = mean(YoY_Change, na.rm = TRUE),
      median_yoy = median(YoY_Change, na.rm = TRUE),
      max_yoy    = max(YoY_Change, na.rm = TRUE),
      min_yoy    = min(YoY_Change, na.rm = TRUE),
      .groups    = "drop"
    ) %>%
    dplyr::arrange(dplyr::desc(abs(mean_yoy)))
  
  # Outlier detection
  yoy_outliers <- yoy_df %>%
    dplyr::group_by(Description) %>%
    dplyr::mutate(
      yoy_z = (YoY_Change - mean(YoY_Change, na.rm = TRUE)) /
        sd(YoY_Change, na.rm = TRUE),
      is_outlier = abs(yoy_z) > 3
    ) %>%
    dplyr::ungroup()
  
  list(
    yoy_df      = yoy_df,
    yoy_summary = yoy_summary,
    yoy_outliers = yoy_outliers
  )
}

# ---------------------------------------------------------
# Computes 12-month and 24-month rolling averages for each fuel
  # Description using right-aligned windows.
# ---------------------------------------------------------
compute_rolling_averages <- function(primary_clean) {
  primary_clean %>%
    dplyr::arrange(Description, Date) %>%
    dplyr::group_by(Description) %>%
    dplyr::mutate(
      roll_12 = zoo::rollmean(Value, 12, fill = NA, align = "right"),
      roll_24 = zoo::rollmean(Value, 24, fill = NA, align = "right")
    ) %>%
    dplyr::ungroup()
}

# ---------------------------------------------------------
# Returns a sorted vector of unique Description values present
  # in the cleaned dataset.
# ---------------------------------------------------------
list_unique_descriptions <- function(primary_clean) {
  primary_clean %>%
    dplyr::distinct(Description) %>%
    dplyr::arrange(Description) %>%
    dplyr::pull(Description)
}

# ---------------------------------------------------------
# Computes long-run CAGR for each fuel Description based on
  # the first and last non-missing values in primary_clean.
# ---------------------------------------------------------

compute_cagr_by_fuel <- function(primary_clean) {
  
  compute_cagr <- function(start_value, end_value, n_years) {
    if (is.na(start_value) || is.na(end_value) || start_value <= 0) {
      return(NA_real_)
    }
    (end_value / start_value)^(1 / n_years) - 1
  }
  
  primary_clean %>%
    dplyr::arrange(Description, Date) %>%
    dplyr::group_by(Description) %>%
    dplyr::summarise(
      start_date  = min(Date[!is.na(Value)], na.rm = TRUE),
      end_date    = max(Date[!is.na(Value)], na.rm = TRUE),
      start_value = Value[Date == start_date][1],
      end_value   = Value[Date == end_date][1],
      n_years     = as.numeric(difftime(end_date, start_date, units = "days")) / 365.25,
      CAGR        = compute_cagr(start_value, end_value, n_years),
      .groups     = "drop"
    ) %>%
    dplyr::arrange(dplyr::desc(CAGR))
}
