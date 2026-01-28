# =========================================================
# unified_plot_forecast.R
# Unified interactive forecast plotter
# =========================================================

plot_forecast_interactive <- function(
    actual_df,
    forecast_df,
    name,
    level,
    family,
    config,
    fuel_colors,
    category_colors
) {
  
  # ---------------------------------------------------------
  # Horizon trimming and date-range logic
  # ---------------------------------------------------------
  actual_df$date   <- as.Date(actual_df$date)
  forecast_df$date <- as.Date(forecast_df$date)
  
  actual_df   <- actual_df[order(actual_df$date), ]
  forecast_df <- forecast_df[order(forecast_df$date), ]
  
  # ---------------------------------------------------------
  # Normalize forecast column names for all model families
  # ---------------------------------------------------------
  if ("forecast" %in% names(forecast_df) && !(".mean" %in% names(forecast_df))) {
    forecast_df$.mean <- forecast_df$forecast
  }
  
  if (!(".lower" %in% names(forecast_df))) {
    forecast_df$.lower <- forecast_df$.mean
  }
  
  if (!(".upper" %in% names(forecast_df))) {
    forecast_df$.upper <- forecast_df$.mean
  }
  
  last_actual_year <- as.numeric(format(max(actual_df$date, na.rm = TRUE), "%Y"))
  horizon_years    <- config$forecast$horizon_years %||% 25
  horizon_end_date <- as.Date(paste0(last_actual_year + horizon_years, "-12-31"))
  
  forecast_end <- min(max(forecast_df$date, na.rm = TRUE), horizon_end_date)
  forecast_df  <- forecast_df[forecast_df$date <= forecast_end, ]
  
  # ---------------------------------------------------------
  # Ensure valid confidence intervals for plotting
  # ---------------------------------------------------------
  if (!(".lower" %in% names(forecast_df)) || !(".upper" %in% names(forecast_df))) {
    if (is.numeric(forecast_df$.mean)) {
      mean_sd <- stats::sd(forecast_df$.mean, na.rm = TRUE)
      if (is.finite(mean_sd) && mean_sd > 0) {
        forecast_df$.lower <- forecast_df$.mean - 1.96 * mean_sd
        forecast_df$.upper <- forecast_df$.mean + 1.96 * mean_sd
      } else {
        forecast_df$.lower <- forecast_df$.mean
        forecast_df$.upper <- forecast_df$.mean
      }
    }
  }
  
  forecast_df$.lower[is.na(forecast_df$.lower)] <- forecast_df$.mean[is.na(forecast_df$.lower)]
  forecast_df$.upper[is.na(forecast_df$.upper)] <- forecast_df$.mean[is.na(forecast_df$.upper)]
  
  # ---------------------------------------------------------
  # Color selection
  # ---------------------------------------------------------
  if (level == "fuel") {
    color <- fuel_colors[[name]] %||% "#2C3E50"
  } else {
    color <- category_colors[[name]] %||% "#2C3E50"
  }
  
  # ---------------------------------------------------------
  # Plot construction
  # ---------------------------------------------------------
  p <- plot_ly()
  
  # Actual line
  p <- p %>%
    add_lines(
      data = actual_df,
      x = ~date,
      y = ~consumption,
      name = paste0(name, " Actual"),
      line = list(color = color, width = 2)
    )
  
  # Forecast mean
  p <- p %>%
    add_lines(
      data = forecast_df,
      x = ~date,
      y = ~.mean,
      name = paste0(name, " Forecast – ", toupper(family)),
      line = list(color = color, dash = "dash", width = 2)
    )
  
  # Confidence ribbon (with legend entry)
  p <- p %>%
    add_ribbons(
      data = forecast_df,
      x = ~date,
      ymin = ~.lower,
      ymax = ~.upper,
      name = "95% Confidence Interval",
      line = list(color = "transparent"),
      fillcolor = adjustcolor(color, alpha.f = 0.2),
      showlegend = TRUE
    )
  
  # Linear trend (distinct style from forecast + LOESS)
  if (isTRUE(config$plot_theme$plotting$show_linear)) {
    df <- forecast_df
    df$t <- as.numeric(df$date)
    lin_mod <- lm(.mean ~ t, data = df)
    df$lin_fit <- predict(lin_mod, newdata = df)
    
    p <- p %>%
      add_lines(
        data = df,
        x = ~date,
        y = ~lin_fit,
        name = "Linear Trend",
        line = list(color = "black", dash = "dashdot", width = 1.5),
        showlegend = TRUE
      )
  }
  
  # LOESS smoothing (visually distinct)
  if (isTRUE(config$plot_theme$plotting$show_loess)) {
    df <- forecast_df
    df$t <- as.numeric(df$date)
    loess_mod <- loess(.mean ~ t, data = df, span = 0.5)
    df$loess_fit <- predict(loess_mod, newdata = df)
    
    p <- p %>%
      add_lines(
        data = df,
        x = ~date,
        y = ~loess_fit,
        name = "LOESS Smooth",
        line = list(color = "darkred", dash = "dot", width = 1),
        showlegend = TRUE
      )
  }
  
  # ---------------------------------------------------------
  # Layout: title, units, hovermode, rangeslider
  # ---------------------------------------------------------
  consumption_units <- config$plot_theme$labels$consumption_units %||% "Quadrillion Btu"
  
  p <- p %>%
    layout(
      title = list(
        text = paste0("Forecast for ", name),
        x = 0,
        xanchor = "left"
      ),
      hovermode = "x unified",
      xaxis = list(
        title = "Year",
        type = "date",
        tickformat = "%Y",
        rangeslider = list(
          visible = TRUE,
          thickness = 0.05
        )
      ),
      yaxis = list(
        title = paste0("Consumption (", consumption_units, ")"),
        tickformat = ".3f"
      ),
      legend = list(
        x = 1.02,
        y = 1,
        xanchor = "left",
        bgcolor = "rgba(0,0,0,0)",
        bordercolor = "rgba(0,0,0,0)"
      ),
      margin = list(r = 120)
    )
  
  p
}
