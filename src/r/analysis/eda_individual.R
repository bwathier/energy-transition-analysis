# =========================================================
# eda_individual.R - Individual fuels (Interactive)
# =========================================================

run_eda_individual <- function(
    fuel_plot_data,
    fuel_share_data,
    individual_yoy_df,
    individual_roll_df,
    fuel_colors_plot,
    config
) {
  
  # ---------------------------------------------------------
  # Output directory (config-driven)
  # ---------------------------------------------------------
  out_dir <- config$paths$plots$individual
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  
  # ---------------------------------------------------------
  # Interactive line: absolute consumption
  # ---------------------------------------------------------
  interactive_line <- make_interactive_line(
    df        = fuel_plot_data,
    x         = Date,
    y         = Value,
    color_var = Description,
    colors    = fuel_colors_plot,
    title     = "U.S. Primary Energy Consumption by Fuel Type",
    y_label   = "Quadrillion Btu",
    hover_fmt = ".3f",
    axis_fmt  = ".3f",
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
  
  print(interactive_line)
  saveWidget(interactive_line,
             file.path(out_dir, "eda_line.html"),
             selfcontained = TRUE)
  
  # ---------------------------------------------------------
  # Interactive stacked area: absolute
  # ---------------------------------------------------------
  interactive_area <- make_interactive_area(
    df        = fuel_plot_data,
    x         = Date,
    y         = Value,
    fill_var  = Description,
    colors    = fuel_colors_plot,
    title     = "U.S. Energy Mix Over Time (Interactive Stacked Area Chart)",
    y_label   = "Quadrillion Btu",
    hover_fmt = ".3f",
    axis_fmt  = ".3f",
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
  
  print(interactive_area)
  saveWidget(interactive_area,
             file.path(out_dir, "eda_area.html"),
             selfcontained = TRUE)
  
  # ---------------------------------------------------------
  # Interactive stacked area: percentage share
  # ---------------------------------------------------------
  interactive_share <- make_interactive_area(
    df        = fuel_share_data,
    x         = Date,
    y         = Share,
    fill_var  = Description,
    colors    = fuel_colors_plot,
    title     = "U.S. Energy Mix — Percentage Share Over Time (Interactive)",
    y_label   = "Share of Total Energy",
    hover_fmt = ".2%",
    axis_fmt  = ".0%",
    show_slider = TRUE
  ) %>%
    layout(
      yaxis = list(tickformat = ".0%", range = c(0, 1)),
      legend = list(
        x = 1.02,
        y = 1,
        xanchor = "left",
        bgcolor = "rgba(0,0,0,0)",
        bordercolor = "rgba(0,0,0,0)"),
      autosize = TRUE,
      margin = list(r = 120)
    )
  
  print(interactive_share)
  saveWidget(interactive_share,
             file.path(out_dir, "eda_share.html"),
             selfcontained = TRUE)
  
  # ---------------------------------------------------------
  # Interactive YoY percent change
  # ---------------------------------------------------------
  yoy_interactive <- plot_ly()
  
  for (fuel in levels(individual_yoy_df$Description)) {
    df_fuel <- individual_yoy_df %>%
      filter(Description == fuel, !is.na(YoY_Change))
    
    yoy_interactive <- yoy_interactive %>%
      add_trace(
        data = df_fuel,
        x    = ~Date,
        y    = ~YoY_Change,
        type = "scatter",
        mode = "lines",
        name = fuel,
        line = list(color = fuel_colors_plot[[fuel]]),
        hovertemplate = paste0(
          "<b>", fuel, "</b><br>",
          "Date: %{x}<br>",
          "YoY Change: %{y:.2%}<extra></extra>"
        )
      )
  }
  
  # Add solar spike footnote
  footnote_text <- "* Solar shows an extreme YoY spike in 1989 due to near-zero baseline."
  
  yoy_interactive <- yoy_interactive %>%
    layout(
      title     = list(text = paste0("Year-over-Year Percent Change by Fuel (Interactive)<br><sup>", footnote_text, "</sup>")),
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
        bordercolor = "rgba(0,0,0,0)"),
      autosize = TRUE,
      margin = list(r = 120)
    )
  
  print(yoy_interactive)
  saveWidget(yoy_interactive,
             file.path(out_dir, "eda_yoy.html"),
             selfcontained = TRUE)
  
  # ---------------------------------------------------------
  # Interactive 12-month rolling average
  # ---------------------------------------------------------
  roll12_interactive <- plot_ly()
  
  for (fuel in levels(individual_roll_df$Description)) {
    df_fuel <- individual_roll_df %>%
      filter(Description == fuel, !is.na(roll_12))
    
    roll12_interactive <- roll12_interactive %>%
      add_trace(
        data = df_fuel,
        x    = ~Date,
        y    = ~roll_12,
        type = "scatter",
        mode = "lines",
        name = fuel,
        line = list(color = fuel_colors_plot[[fuel]]),
        hovertemplate = paste0(
          "<b>", fuel, "</b><br>",
          "Date: %{x}<br>",
          "12m Rolling Avg: %{y:.3f}<extra></extra>"
        )
      )
  }
  
  roll12_interactive <- roll12_interactive %>%
    layout(
      title     = "12-Month Rolling Average (Interactive)",
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
        bordercolor = "rgba(0,0,0,0)"),
      autosize = TRUE,
      margin = list(r = 120)
    )
  
  print(roll12_interactive)
  saveWidget(roll12_interactive,
             file.path(out_dir, "eda_roll12.html"),
             selfcontained = TRUE)
  
  cat("\nAll EDA individual fuel plots generated and exported.\n")
}
