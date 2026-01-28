# ================================================================
# eda_categories.R - Fossil vs Renewables vs Nuclear (Interactive)
# ================================================================

run_eda_categories <- function(
    combined_df,
    share_df,
    category_yoy_df,
    category_roll_df,
    category_colors,
    config
) {
  
  # ---------------------------------------------------------
  # Output directory (config-driven)
  # ---------------------------------------------------------
  out_dir <- config$paths$plots$categories
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  
  # ---------------------------------------------------------
  # INTERACTIVE LINE CHART (absolute consumption)
  # ---------------------------------------------------------
  p_line_int <- make_interactive_line(
    df         = combined_df,
    x          = Date,
    y          = Value,
    color_var  = Category,
    colors     = category_colors,
    title      = "U.S. Energy Consumption: Fossil vs Renewables vs Nuclear",
    y_label    = "Quadrillion Btu",
    hover_fmt  = ".3f",
    axis_fmt   = ".3f",
    show_slider = TRUE
  ) %>%
    layout(
      legend = list(
        x = 1.02,
        y = 1,
        xanchor = "left",
        bgcolor = "rgba(0,0,0,0)",
        bordercolor = "rgba(0,0,0,0)"),
      autosize = TRUE,
      margin = list(r = 120)
    )
  
  print(p_line_int)
  saveWidget(p_line_int, file.path(out_dir, "eda_categories_line.html"), selfcontained = TRUE)
  
  # ---------------------------------------------------------
  # INTERACTIVE STACKED AREA (absolute consumption)
  # ---------------------------------------------------------
  p_area_int <- make_interactive_area(
    df         = combined_df,
    x          = Date,
    y          = Value,
    fill_var   = Category,
    colors     = category_colors,
    title      = "U.S. Energy Mix Over Time (Fossil vs Renewables vs Nuclear)",
    y_label    = "Quadrillion Btu",
    hover_fmt  = ".3f",
    axis_fmt   = ".3f",
    show_slider = TRUE
  ) %>%
    layout(
      legend = list(
        x = 1.02,
        y = 1,
        xanchor = "left",
        bgcolor = "rgba(0,0,0,0)",
        bordercolor = "rgba(0,0,0,0)")
    )
  
  print(p_area_int)
  saveWidget(p_area_int, file.path(out_dir, "eda_categories_area.html"), selfcontained = TRUE)
  
  # ---------------------------------------------------------
  # INTERACTIVE PERCENTAGE SHARE
  # ---------------------------------------------------------
  p_share_int <- make_interactive_area(
    df         = share_df,
    x          = Date,
    y          = Share,
    fill_var   = Category,
    colors     = category_colors,
    title      = "Energy Mix Percentage Share: Fossil vs Renewables vs Nuclear",
    y_label    = "Share of Total Energy",
    hover_fmt  = ".2%",
    axis_fmt   = ".0%",
    show_slider = TRUE
  ) %>%
    layout(
      yaxis = list(tickformat = ".0%", range = c(0, 1)),
      legend = list(
        x = 1.02,
        y = 1,
        xanchor = "left",
        bgcolor = "rgba(0,0,0,0)",
        bordercolor = "rgba(0,0,0,0)")
    )
  
  print(p_share_int)
  saveWidget(p_share_int, file.path(out_dir, "eda_categories_share.html"), selfcontained = TRUE)
  
  # ---------------------------------------------------------
  # INTERACTIVE YoY percent change
  # ---------------------------------------------------------
  p_cat_yoy_interactive <- plot_ly()
  
  for (cat in levels(category_yoy_df$Category)) {
    df <- category_yoy_df %>% filter(Category == cat, !is.na(YoY_Change))
    
    p_cat_yoy_interactive <- p_cat_yoy_interactive %>%
      add_trace(
        data = df,
        x    = ~Date,
        y    = ~YoY_Change,
        type = "scatter",
        mode = "lines",
        name = cat,
        line = list(color = category_colors[[cat]]),
        hovertemplate = paste0(
          "<b>", cat, "</b><br>",
          "Date: %{x}<br>",
          "YoY Change: %{y:.2%}<extra></extra>"
        )
      )
  }
  
  p_cat_yoy_interactive <- p_cat_yoy_interactive %>%
    layout(
      title     = "Year-over-Year Percent Change (Fossil vs Renewables vs Nuclear)",
      hovermode = "x unified",
      xaxis     = list(
        title = "Year",
        rangeslider = list(visible = TRUE, thickness = 0.05)
      ),
      yaxis     = list(
        title = "YoY Change (%)",
        tickformat = ".2%",
        fixedrange = FALSE   # Allow vertical zoom
      ),
      legend = list(
        x = 1.02,
        y = 1,
        xanchor = "left",
        bgcolor = "rgba(0,0,0,0)",
        bordercolor = "rgba(0,0,0,0)")
    )
  
  print(p_cat_yoy_interactive)
  saveWidget(p_cat_yoy_interactive, file.path(out_dir, "eda_categories_yoy.html"), selfcontained = TRUE)
  
  # ---------------------------------------------------------
  # INTERACTIVE 12-month rolling average
  # ---------------------------------------------------------
  p_cat_roll12_interactive <- plot_ly()
  
  for (cat in levels(category_roll_df$Category)) {
    df <- category_roll_df %>% filter(Category == cat, !is.na(roll_12))
    
    p_cat_roll12_interactive <- p_cat_roll12_interactive %>%
      add_trace(
        data = df,
        x    = ~Date,
        y    = ~roll_12,
        type = "scatter",
        mode = "lines",
        name = cat,
        line = list(color = category_colors[[cat]]),
        hovertemplate = paste0(
          "<b>", cat, "</b><br>",
          "Date: %{x}<br>",
          "12m Rolling Avg: %{y:.3f}<extra></extra>"
        )
      )
  }
  
  p_cat_roll12_interactive <- p_cat_roll12_interactive %>%
    layout(
      title     = "12-Month Rolling Average (Fossil vs Renewables vs Nuclear)",
      hovermode = "x unified",
      xaxis     = list(
        title = "Year",
        rangeslider = list(visible = TRUE, thickness = 0.05)
      ),
      yaxis     = list(title = "12-Month Rolling Avg (Quadrillion Btu)"),
      legend = list(
        x = 1.02,
        y = 1,
        xanchor = "left",
        bgcolor = "rgba(0,0,0,0)",
        bordercolor = "rgba(0,0,0,0)")
    )
  
  print(p_cat_roll12_interactive)
  saveWidget(p_cat_roll12_interactive, file.path(out_dir, "eda_categories_roll12.html"), selfcontained = TRUE)
  
  cat("\nAll EDA category plots generated and exported.\n")
}
