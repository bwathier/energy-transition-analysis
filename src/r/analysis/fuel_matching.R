# =========================================================
# fuel_matching.R - Match EIA descriptions to fuel keywords
# =========================================================

prepare_fuel_data <- function(primary_clean, fuel_groups, fuel_colors) {
  
  # 1. Extract individual fuel names from config
  fuels <- unname(unlist(fuel_groups$individual_fuels))
  
  # 2. Build color map directly from config
  color_map <- tibble::tibble(
    Description = fuels,
    Color = unname(fuel_colors[fuels])
  )
  
  # 3. Filter primary_clean
  fuel_plot_data <- primary_clean %>%
    filter(Description %in% fuels) %>%
    mutate(Description = factor(Description, levels = fuels))
  
  # 4. Compute share
  total_data <- primary_clean %>%
    filter(Description == "Total Primary Energy Consumption") %>%
    select(Date, Total = Value)
  
  fuel_share_data <- fuel_plot_data %>%
    left_join(total_data, by = "Date") %>%
    mutate(
      Value = ifelse(is.na(Value), 0, Value),
      Share = Value / Total
    )
  
  list(
    fuel_plot_data = fuel_plot_data,
    fuel_share_data = fuel_share_data,
    fuel_colors_plot = setNames(color_map$Color, color_map$Description),
    color_map = color_map
  )
}
