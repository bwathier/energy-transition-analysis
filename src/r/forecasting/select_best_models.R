# =========================================================
# best_models.R
# Select best model per fuel/category based on ROCV accuracy
# =========================================================

select_best_models <- function(cv_results) {
  
  cv_results %>%
    group_by(level, fuel, category) %>%
    arrange(MAE, .by_group = TRUE) %>%
    slice(1) %>%
    ungroup() %>%
    select(level, fuel, category, model_family, MAE, RMSE, MAPE, origins)
}
