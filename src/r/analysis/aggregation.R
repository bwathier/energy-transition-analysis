# =========================================================
# aggregation.R - Category aggregation and colors
# =========================================================

hex_to_rgb <- function(hex) as.numeric(col2rgb(hex))
rgb_to_hex <- function(r, g, b) rgb(r, g, b, maxColorValue = 255)

blend_colors <- function(hex_vec) {
  rgb_vals <- sapply(hex_vec, hex_to_rgb)
  avg <- rowMeans(rgb_vals)
  rgb_to_hex(avg[1], avg[2], avg[3])
}

aggregate_categories <- function(primary_clean,
                                 fuel_plot_data,
                                 fuel_groups,
                                 fuel_colors) {
  
  # ---------------------------------------------------------
  # Extract category definitions from config
  # ---------------------------------------------------------
  fossil_fuels <- fuel_groups$categories$fossil_fuels
  renew_fuels  <- fuel_groups$categories$renewable_energy
  nuclear_fuel <- fuel_groups$categories$nuclear_energy[[1]]
  
  # ---------------------------------------------------------
  # Compute category colors (Fossil & Renewables blended)
  # ---------------------------------------------------------
  fossil_color  <- blend_colors(fuel_colors[fossil_fuels])
  renew_color   <- blend_colors(fuel_colors[renew_fuels])
  nuclear_color <- unname(fuel_colors[nuclear_fuel])
  
  category_colors <- c(
    "Fossil Fuels"     = fossil_color,
    "Renewable Energy" = renew_color,
    "Nuclear Energy"   = nuclear_color
  )
  
  # ---------------------------------------------------------
  # Helper: aggregate fuels into a category
  # ---------------------------------------------------------
  aggregate_category <- function(df, fuels, category_name) {
    df %>%
      filter(Description %in% fuels) %>%
      group_by(Date) %>%
      summarise(Value = sum(Value, na.rm = TRUE), .groups = "drop") %>%
      mutate(Category = category_name)
  }
  
  # ---------------------------------------------------------
  # Aggregate category data
  # ---------------------------------------------------------
  fossil_df  <- aggregate_category(primary_clean, fossil_fuels, "Fossil Fuels")
  renew_df   <- aggregate_category(primary_clean, renew_fuels, "Renewable Energy")
  nuclear_df <- aggregate_category(primary_clean, nuclear_fuel, "Nuclear Energy")
  
  combined_df <- bind_rows(fossil_df, renew_df, nuclear_df) %>%
    mutate(Category = factor(
      Category,
      levels = c("Fossil Fuels", "Renewable Energy", "Nuclear Energy")
    ))
  
  # ---------------------------------------------------------
  # Percentage share
  # ---------------------------------------------------------
  custom_totals <- combined_df %>%
    group_by(Date) %>%
    summarise(Total_Custom = sum(Value, na.rm = TRUE), .groups = "drop")
  
  share_df <- combined_df %>%
    left_join(custom_totals, by = "Date") %>%
    mutate(
      Share = Value / Total_Custom,
      Category = factor(
        Category,
        levels = c("Fossil Fuels", "Renewable Energy", "Nuclear Energy")
      )
    )
  
  # ---------------------------------------------------------
  # YoY and rolling averages
  # ---------------------------------------------------------
  category_yoy_df <- combined_df %>%
    arrange(Category, Date) %>%
    group_by(Category) %>%
    mutate(
      YoY_Change     = (Value - lag(Value, 12)) / lag(Value, 12),
      YoY_Abs_Change = Value - lag(Value, 12)
    ) %>%
    ungroup()
  
  category_roll_df <- combined_df %>%
    arrange(Category, Date) %>%
    group_by(Category) %>%
    mutate(
      roll_12 = rollmean(Value, 12, fill = NA, align = "right"),
      roll_24 = rollmean(Value, 24, fill = NA, align = "right")
    ) %>%
    ungroup()
  
  # ---------------------------------------------------------
  # Build fuel_forecast_df
  # ---------------------------------------------------------
  fuel_forecast_df <- fuel_plot_data %>%
    mutate(
      fuel = Description,
      category = case_when(
        fuel %in% fossil_fuels ~ "Fossil Fuels",
        fuel %in% renew_fuels  ~ "Renewable Energy",
        fuel %in% nuclear_fuel ~ "Nuclear Energy",
        TRUE ~ "Other"
      ),
      consumption = Value
    ) %>%
    select(Date, fuel, category, consumption) %>%
    arrange(fuel, Date)
  
  # ---------------------------------------------------------
  # Return everything cleanly
  # ---------------------------------------------------------
  list(
    combined_df       = combined_df,
    share_df          = share_df,
    category_yoy_df   = category_yoy_df,
    category_roll_df  = category_roll_df,
    category_colors   = category_colors,
    fuel_forecast_df  = fuel_forecast_df
  )
}
