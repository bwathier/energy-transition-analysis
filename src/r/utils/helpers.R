# =========================================================
# helpers.R - Utility helper functions
# =========================================================

# Create directories safely
safe_dir_create <- function(path, verbose = FALSE) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
    if (verbose) message("Created directory: ", path)
  } else if (verbose) {
    message("Directory already exists: ", path)
  }
}

# Main directory initializer
ensure_plot_dirs <- function(config = NULL,
                             base_dir = "plots",
                             verbose = FALSE) {
  
  # --------------------------------------------------------
  # 1. If config is provided, use config-driven paths
  # --------------------------------------------------------
  if (!is.null(config)) {
    # Collect all plot-related paths from config
    plot_paths <- c(
      config$paths$plots$individual,
      config$paths$plots$categories,
      config$paths$plots$forecasts,
      config$forecast$paths$output_fuels,
      config$forecast$paths$output_categories
    )
    
    # Remove NULLs and duplicates
    plot_paths <- unique(Filter(Negate(is.null), plot_paths))
    
    # Create each directory
    for (p in plot_paths) {
      safe_dir_create(p, verbose = verbose)
    }
    
    return(invisible(TRUE))
  }
  
  # --------------------------------------------------------
  # 2. Fallback: original hard-coded behavior
  # --------------------------------------------------------
  dirs <- c(
    base_dir,
    file.path(base_dir, "individual"),
    file.path(base_dir, "categories"),
    file.path(base_dir, "forecasts")
  )
  
  for (d in dirs) {
    safe_dir_create(d, verbose = verbose)
  }
  
  invisible(TRUE)
}
