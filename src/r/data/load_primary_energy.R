# ==============================================================
# load_primary_energy.R - Load and clean energy consumption data
# ==============================================================

load_and_clean_primary_energy <- function(file_path,
                                          na_strings = c("Not Available", "--", "W", ".", "")) {
  # Read raw data
  primary_consump <- readr::read_csv(file_path)
  
  # Clean and transform
  primary_clean <- primary_consump %>%
    dplyr::mutate(
      Year  = floor(YYYYMM / 100),
      Month = YYYYMM %% 100
    ) %>%
    dplyr::filter(Month >= 1 & Month <= 12) %>%
    dplyr::mutate(
      Value = trimws(Value),
      Value = ifelse(Value %in% na_strings, NA, Value),
      Value = as.numeric(Value),
      Date  = lubridate::ymd(sprintf("%04d-%02d-01", Year, Month))
    )
  
  primary_clean
}
