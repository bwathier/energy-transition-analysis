# =========================================================
# setup_packages.R - Setting up packages and libraries for the 
#  Energy Transition project
# =========================================================

packages <- c(
  "readr",
  "dplyr",
  "lubridate",
  "plotly",
  "htmlwidgets",
  "scales",
  "stringr",
  "purrr",
  "rlang",
  "zoo",
  "tsibble",
  "fable",
  "fabletools",
  "feasts",
  "urca",
  "prophet",
  "forecast",      
  "yardstick",
  "yaml",
  "tools",
  "distributional"
)

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

for (pkg in packages) {
  install_if_missing(pkg)
  library(pkg, character.only = TRUE)
}