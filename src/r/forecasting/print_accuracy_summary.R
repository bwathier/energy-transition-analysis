# =========================================================
# print_accuracy_summary.R
# Simple accuracy summary printer
# =========================================================

print_accuracy_summary <- function(acc_df) {
  
  out <- acc_df %>%
    arrange(level, fuel, category, model_family, RMSE)
  
  print(out, n = Inf)
  
  return(invisible(out))
}
