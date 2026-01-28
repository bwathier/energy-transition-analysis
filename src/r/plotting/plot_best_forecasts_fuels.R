# =====================================================================
# plot_best_forecasts_fuels.R
# Generate best-model forecast plots for individual fuels (interactive)
# =====================================================================


# ---------------------------------------------------------------------
# Extract forecast object for a given fuel + model family
# ---------------------------------------------------------------------
extract_fuel_forecast <- function(fuel_name, model_name, forecast_results) {
  model_name <- tolower(model_name)
  
  if (!model_name %in% c("arima", "ets", "prophet")) return(NULL)
  
  family_obj <- forecast_results[[model_name]]
  if (is.null(family_obj) || !"forecast_fuels" %in% names(family_obj)) return(NULL)
  
  fc_tbl <- family_obj$forecast_fuels
  fc_tbl %>% filter(fuel == fuel_name)
}

# ---------------------------------------------------------------------
# Helper: add synthetic intervals if real ones are missing
# ---------------------------------------------------------------------
add_intervals_if_missing_fuels <- function(df) {
  if (all(c(".lower", ".upper") %in% names(df))) {
    df$.lower_eff <- df$.lower
    df$.upper_eff <- df$.upper
    return(df)
  }
  
  if (!is.numeric(df$.mean)) return(df)
  
  mean_sd <- stats::sd(df$.mean, na.rm = TRUE)
  sd_eff  <- max(mean_sd, 0.001)
  
  if (is.finite(sd_eff) && sd_eff > 0) {
    df$.lower_eff <- df$.mean - 1.96 * sd_eff
    df$.upper_eff <- df$.mean + 1.96 * sd_eff
    return(df)
  }
  
  df
}

# ---------------------------------------------------------------------
# Main fuel plotting function (interactive)
# ---------------------------------------------------------------------
plot_best_forecasts_fuels <- function(best_models,
                                      forecast_results,
                                      fuel_colors,
                                      config) {
  
  out_dir <- config$forecast$paths$output_fuels
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  
  show_linear      <- config$plot_theme$plotting$show_linear
  show_loess       <- config$plot_theme$plotting$show_loess
  horizon_years    <- config$forecast$horizon_years %||% 25
  ci_level         <- config$forecast$ci_level %||% 0.95
  consumption_units <- config$plot_theme$labels$consumption_units %||% "Quadrillion Btu"
  
  fuel_rows <- best_models %>% filter(Type == "Fuel")
  
  for (i in seq_len(nrow(fuel_rows))) {
    
    row        <- fuel_rows[i, ]
    fuel_nm    <- row$Description
    model_name <- row$Best_Model
    
    df <- extract_fuel_forecast(fuel_nm, model_name, forecast_results)
    if (is.null(df)) next
    
    df <- as_tibble(df)
    df$date <- as.Date(df$date)
    df <- add_intervals_if_missing_fuels(df)
    
    df <- df %>% arrange(date)
    df$t <- as.numeric(df$date)
    
    color <- fuel_colors[[fuel_nm]] %||% "#2C3E50"
    
    ci_color <- if (tolower(color) == "#000000") {
      "rgba(0,0,0,0.05)"
    } else {
      rgb_val <- col2rgb(color)
      sprintf("rgba(%d,%d,%d,0.15)", rgb_val[1], rgb_val[2], rgb_val[3])
    }
    
    start_date   <- min(df$date, na.rm = TRUE)
    forecast_end <- max(df$date, na.rm = TRUE)
    today_year   <- as.numeric(format(Sys.Date(), "%Y"))
    horizon_end  <- as.Date(paste0(today_year + horizon_years, "-12-31"))
    end_date     <- min(forecast_end, horizon_end)
    
    df <- df %>% filter(date <= end_date)
    df$t <- as.numeric(df$date)
    
    if (show_linear && is.numeric(df$.mean)) {
      lin_mod    <- lm(.mean ~ t, data = df)
      df$lin_fit <- as.numeric(predict(lin_mod, newdata = df))
    }
    
    if (show_loess && is.numeric(df$.mean)) {
      loess_mod    <- loess(.mean ~ t, data = df, span = 0.5)
      df$loess_fit <- as.numeric(predict(loess_mod, newdata = df))
    }
    
    p <- plot_ly()
    
    if (all(c(".lower_eff", ".upper_eff") %in% names(df))) {
      p <- p %>%
        add_ribbons(
          data        = df,
          x           = ~date,
          ymin        = ~.lower_eff,
          ymax        = ~.upper_eff,
          name        = paste0("Forecast Interval (", ci_level * 100, "%)"),
          legendgroup = "forecast_ci",
          showlegend  = TRUE,
          fillcolor   = ci_color,
          line        = list(color = "transparent")
        )
    }
    
    p <- p %>%
      add_lines(
        data        = df,
        x           = ~date,
        y           = ~.mean,
        name        = paste0("Forecast – ", toupper(model_name)),
        legendgroup = "forecast",
        showlegend  = TRUE,
        line        = list(color = color, width = 2, dash = "dash")
      )
    
    if (show_linear && "lin_fit" %in% names(df)) {
      p <- p %>%
        add_lines(
          data        = df,
          x           = ~date,
          y           = ~lin_fit,
          name        = "Linear Trend",
          legendgroup = "linear",
          showlegend  = TRUE,
          line        = list(color = "black", dash = "dash", width = 2)
        )
    }
    
    if (show_loess && "loess_fit" %in% names(df)) {
      p <- p %>%
        add_lines(
          data        = df,
          x           = ~date,
          y           = ~loess_fit,
          name        = "LOESS Smooth",
          legendgroup = "loess",
          showlegend  = TRUE,
          line        = list(color = "darkred", dash = "dot", width = 1.5)
        )
    }
    
    title_text <- paste0("Fuel Forecast: ", fuel_nm)
    
    p <- p %>%
      layout(
        title = list(text = title_text),
        hovermode = "x unified",
        xaxis = list(
          title      = "Year",
          type       = "date",
          tickformat = "%Y",
          range      = c(start_date, end_date),
          rangeslider = list(
            visible = TRUE,
            range   = c(start_date, end_date)
          )
        ),
        yaxis = list(
          title      = paste0("Consumption (", consumption_units, ")"),
          tickformat = ".3f"
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
    
    safe_name <- stringr::str_replace_all(fuel_nm, "[^A-Za-z0-9]+", "_")
    
    saveWidget(
      p,
      file.path(out_dir, paste0("forecast_fuel_", safe_name, ".html")),
      selfcontained = TRUE
    )
  }
}
