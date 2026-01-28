# ============================================================
# load_config.R
# Centralized loader for all YAML configuration files
# ============================================================

# ------------------------------------------------------------
# Validate required top-level config sections
# ------------------------------------------------------------
validate_config <- function(cfg, required = character()) {
  missing <- setdiff(required, names(cfg))
  if (length(missing) > 0) {
    stop(
      "Missing required config sections: ",
      paste(missing, collapse = ", ")
    )
  }
  invisible(cfg)
}

# ------------------------------------------------------------
# Main loader
# ------------------------------------------------------------
load_all_configs <- function(
    config_dir = "config",
    required_sections = c("paths", "fuel_groups", "fuel_colors", "forecast", "plot_theme"),
    verbose = TRUE
) {
  
  # --------------------------------------------------------
  # 1. Discover YAML files
  # --------------------------------------------------------
  yaml_files <- list.files(
    config_dir,
    pattern = "\\.yaml$",
    full.names = TRUE
  )
  
  yaml_files <- sort(yaml_files)  # deterministic order
  
  if (length(yaml_files) == 0) {
    stop("No YAML files found in config directory: ", config_dir)
  }
  
  # --------------------------------------------------------
  # 2. Load each YAML file safely
  # --------------------------------------------------------
  configs <- purrr::map(yaml_files, function(f) {
    parsed <- yaml::read_yaml(f)
    
    # If the YAML has a single top-level key matching the filename,
    # unwrap it so cfg$paths, cfg$forecast, etc. work naturally.
    top_key  <- names(parsed)
    file_key <- tools::file_path_sans_ext(basename(f))
    
    if (length(parsed) == 1 && identical(top_key, file_key)) {
      parsed[[1]]
    } else {
      parsed
    }
  })
  
  # --------------------------------------------------------
  # 3. Normalize config names (lowercase)
  # --------------------------------------------------------
  names(configs) <- tolower(tools::file_path_sans_ext(basename(yaml_files)))
  
  # --------------------------------------------------------
  # 4. Validate required sections
  # --------------------------------------------------------
  validate_config(configs, required_sections)
  
  # --------------------------------------------------------
  # 5. Success message
  # --------------------------------------------------------
  if (verbose) {
    message("Loaded config files: ", paste(names(configs), collapse = ", "))
  }
  
  # --------------------------------------------------------
  # 6. Return structured config object
  # --------------------------------------------------------
  structure(configs, class = "energy_config")
}
