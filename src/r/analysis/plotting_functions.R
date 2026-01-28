# =========================================================
# plotting_functions.R - Reusable interactive plot helpers
# =========================================================

# -------------------------------------------------------------------
# Interactive line plot with formatting + slider toggle
# -------------------------------------------------------------------
make_interactive_line <- function(
    df,
    x,
    y,
    color_var,
    colors,
    title,
    y_label = "Value",
    hover_fmt = ".3f",
    axis_fmt  = NULL,
    show_slider = TRUE
) {
  
  color_sym <- rlang::ensym(color_var)
  categories <- levels(df[[rlang::as_name(color_sym)]])
  
  # Base plot
  p <- plotly::plot_ly() %>%
    layout(
      title     = title,
      hovermode = "x unified",
      xaxis = list(
        title = "Year",
        rangeslider = if (show_slider) list(visible = TRUE, thickness = 0.05) else NULL
      ),
      yaxis = list(
        title      = y_label,
        tickformat = axis_fmt,
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
  
  # Add traces
  for (cat in categories) {
    df_cat <- df %>% dplyr::filter({{ color_var }} == cat)
    
    p <- p %>%
      add_trace(
        data = df_cat,
        x    = df_cat[[rlang::as_name(rlang::ensym(x))]],
        y    = df_cat[[rlang::as_name(rlang::ensym(y))]],
        type = "scatter",
        mode = "lines",
        name = cat,
        line = list(color = colors[[cat]]),
        hovertemplate = paste0(
          "<b>", cat, "</b><br>",
          "Date: %{x}<br>",
          y_label, ": %{y:", hover_fmt, "}<extra></extra>"
        )
      )
  }
  
  p
}


# -------------------------------------------------------------------
# Interactive stacked area plot with optional formatting + slider toggle
# -------------------------------------------------------------------
make_interactive_area <- function(
    df,
    x,
    y,
    fill_var,
    colors,
    title,
    y_label = "Value",
    hover_fmt = ".3f",
    axis_fmt  = NULL,
    show_slider = TRUE
) {
  
  categories <- levels(df[[rlang::as_name(rlang::ensym(fill_var))]])
  
  p <- plotly::plot_ly() %>%
    layout(
      title     = title,
      hovermode = "x unified",
      xaxis = list(
        title = "Year",
        rangeslider = if (show_slider) list(visible = TRUE, thickness = 0.05) else NULL
      ),
      yaxis = list(
        title      = y_label,
        tickformat = axis_fmt,
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
  
  for (cat in categories) {
    df_cat <- df %>% dplyr::filter({{ fill_var }} == cat)
    
    p <- p %>%
      add_trace(
        data = df_cat,
        x    = df_cat[[rlang::as_name(rlang::ensym(x))]],
        y    = df_cat[[rlang::as_name(rlang::ensym(y))]],
        type = "scatter",
        mode = "none",
        stackgroup = "one",
        name = cat,
        fillcolor = colors[[cat]],
        line = list(color = colors[[cat]]),
        hovertemplate = paste0(
          "<b>", cat, "</b><br>",
          "Date: %{x}<br>",
          y_label, ": %{y:", hover_fmt, "}<extra></extra>"
        )
      )
  }
  
  p
}
