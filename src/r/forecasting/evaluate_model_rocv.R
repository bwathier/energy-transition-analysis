# =========================================================
# evaluate_model_rocv.R
# Rolling-origin cross-validation engine
# =========================================================

evaluate_model_rocv <- function(
    df, 
    fit_fun, 
    h = 12, 
    min_train = 120, 
    max_origins = 8
    ) {
  
  # Ensure sorted
  df <- df %>% arrange(date)
  
  n <- nrow(df)
  
  # Safety check: if not enough data for ROCV
  if (n < min_train + h) {
    return(tibble(
      MAE = NA_real_,
      RMSE = NA_real_,
      MAPE = NA_real_,
      origins = 0
    ))
  }
  
  # Generate all possible origins
  all_possible <- seq(min_train, n - h)
  
  # Select evenly spaced origins if too many
  if (length(all_possible) > max_origins) {
    origins <- round(seq(
      from = min_train,
      to   = n - h,
      length.out = max_origins
    ))
  } else {
    origins <- all_possible
  }
  
  all_errors <- list()
  
  for (origin in origins) {
    
    train_df <- df[1:origin, ]
    test_df  <- df[(origin + 1):(origin + h), ]
    
    # Fit model using user-supplied function
    fc <- fit_fun(train_df, h)
    
    # Align forecast and actual
    merged <- dplyr::inner_join(
      fc %>% select(date, .mean),
      test_df %>% select(date, consumption),
      by = "date"
    )
    
    if (nrow(merged) == 0) next
    
    # Compute errors
    merged <- merged %>%
      mutate(
        error = .mean - consumption,
        abs_error = abs(error),
        sq_error  = error^2,
        ape       = abs_error / pmax(consumption, 1e-8)
      )
    
    all_errors[[length(all_errors) + 1]] <- merged
  }
  
  if (length(all_errors) == 0) {
    return(tibble(
      MAE = NA_real_,
      RMSE = NA_real_,
      MAPE = NA_real_,
      origins = 0
    ))
  }
  
  errors <- bind_rows(all_errors)
  
  tibble(
    MAE    = mean(errors$abs_error, na.rm = TRUE),
    RMSE   = sqrt(mean(errors$sq_error, na.rm = TRUE)),
    MAPE   = mean(errors$ape, na.rm = TRUE),
    origins = length(all_errors)
  )
}
