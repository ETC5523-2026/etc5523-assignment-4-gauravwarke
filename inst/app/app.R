# Ember Days: a Shiny app in the emberdays package

# User:     people living in bushfire-prone parts of Australia
# Question: In my city, are very hot days in the fire season more common now
#           than in the early 1900s?

# Data come from the installed package (emberdays::fire_season_temps), so
# the app never reads a CSV or other file when it runs.

suppressPackageStartupMessages(suppressWarnings({
  library(shiny); library(bslib); library(dplyr)
  library(ggplot2); library(gt)
  library(emberdays)
}))



temps <- emberdays::fire_season_temps
station_info <- emberdays::stations

# Show the station next to the city so users know exactly what is measured
# e.g. "Melbourne (Olympic Park)" -> "Olympic Park"
station_short <- sub("^.*\\((.*)\\)$", "\\1", station_info$station)
city_choices <- setNames(
  station_info$city,
  paste0(station_info$city, " \u2013 ", station_short, " station")
)

season_parts <- list(
  whole  = list(label = "the whole fire season (Sep\u2013Feb)", months = c(9:12, 1:2)),
  spring = list(label = "the spring build-up (Sep\u2013Nov)", months = 9:11),
  summer = list(label = "the summer peak (Dec\u2013Feb)", months = c(12, 1, 2))
)

first_season <- 1910
last_season <- 2018

# Colours shared by the plot, the value boxes and the CSS
col_early <- "#2F5D8A"   # dusk blue
col_recent <- "#C46A1F"  # ochre
col_other <- "#CFC8B8"   # warm grey for seasons outside both periods
col_gap <- "#ECE6DA"     # very light: incomplete seasons

# ---- User interface ---------------------------------------------------------
ui <- fluidPage(
  theme = bs_theme(
    version = 5,
    bg = "#F6F3EB", fg = "#1E2421",
    primary = "#1F4D3F", secondary = col_recent,
    base_font = font_collection("Source Sans 3", "Helvetica Neue", "Arial", "sans-serif"),
    heading_font = font_collection("Merriweather", "Georgia", "serif"),
    font_scale = 1.05
  ),
  tags$head(
    tags$link(rel = "stylesheet",
              href = "https://fonts.googleapis.com/css2?family=Merriweather:wght@700&family=Source+Sans+3:wght@400;600&display=swap"),
    includeCSS("www/style.css"),
    tags$title("Ember Days: hot fire-season days where you live")
  ),

  # Opening promise: who the app is for and what it answers
  div(
    class = "app-header",
    div(class = "brand", "EMBER DAYS"),
    h1("Are hot fire-season days more common where you live?"),
    p(class = "tagline", "Counting the days hot enough to feed a fire, city by city, since 1910."),
    p(class = "lead-question",
      strong("Question: "),
      "In my city, are very hot days during the bushfire season more common now than in the early 1900s?"),
    p(class = "audience",
      strong("Who this is for: "),
      "people living in bushfire-prone parts of Australia who want to know whether the hot weather that drives dangerous fires is becoming more frequent near them. No climate-science background needed.")
  ),

  sidebarLayout(
    sidebarPanel(
      width = 4,
      h3("Choose what to compare"),

      selectInput("city", "1. Your nearest city", choices = city_choices,
                  selected = "Melbourne"),
      p(class = "help",
        "Each city is measured at one Bureau of Meteorology weather station. Pick the city closest to you."),

      sliderInput("threshold", "2. What counts as a very hot day?",
                  min = 30, max = 45, value = 35, step = 1, post = "\u00b0C"),
      p(class = "help",
        "A day counts when its highest temperature reaches this value. 35\u00b0C is a common benchmark for extreme heat. Raise it to focus on the most dangerous days."),

      radioButtons("season_part", "3. Part of the fire season",
                   choices = c("Whole season (Sep\u2013Feb)" = "whole",
                               "Spring build-up (Sep\u2013Nov)" = "spring",
                               "Summer peak (Dec\u2013Feb)" = "summer"),
                   selected = "whole"),
      p(class = "help",
        "Choose spring to see whether hot days now arrive earlier, before summer."),

      sliderInput("early", "4. Early period", min = first_season, max = last_season,
                  value = c(1910, 1939), step = 1, sep = ""),
      sliderInput("recent", "5. Recent period", min = first_season, max = last_season,
                  value = c(1989, 2018), step = 1, sep = ""),
      p(class = "help",
        "A year here is the year a season starts, so 1989 means September 1989 to February 1990. The defaults compare the first and last 30 seasons, the usual length for a climate average. The two periods can't overlap.")
    ),

    mainPanel(
      width = 8,
      tabsetPanel(
        id = "tabs",

        # Tab 1: the direct answer to the question
        tabPanel(
          "Has it changed?",
          uiOutput("data_warning"),
          uiOutput("summary_boxes"),
          uiOutput("narrative"),
          h4(textOutput("plot_title"), class = "plot-title"),
          plotOutput("hot_plot", height = "380px"),
          div(
            class = "how-to-read",
            strong("How to read this chart: "),
            "each bar is one fire season, and its height is the number of days that reached your threshold. ",
            span(class = "key key-early", "Blue"), " bars are your early period and ",
            span(class = "key key-recent", "ochre"), " bars your recent period; the horizontal line across each period is its average. ",
            "If the ochre line sits above the blue line, very hot days have become more common. ",
            "Pale bars are seasons with more than 10% of days missing; they are left out of the averages."
          ),
          p(class = "source",
            "Source: Australian Bureau of Meteorology daily maximum temperatures, via TidyTuesday (2020, week 2). Records end in February 2019, so Black Summer (2019\u201320) is not included.")
        ),

        # Tab 2: the extreme seasons behind the averages
        tabPanel(
          "Hottest seasons",
          h4(textOutput("table_title"), class = "plot-title"),
          div(
            class = "how-to-read",
            strong("How to read this table: "),
            "the ten seasons with the most days at or above your threshold, ranked. If most of them fall in recent decades, the hottest seasons are clustering in today's climate rather than spread evenly over the century."
          ),
          gt_output("top_table")
        ),

        # Tab 3: field definitions, controls and limitations
        tabPanel(
          "About the data",
          h4("What each term means"),
          tags$dl(
            class = "glossary",
            tags$dt("Maximum temperature"),
            tags$dd("The highest air temperature recorded at the station on a given day, in degrees Celsius."),
            tags$dt("Fire season"),
            tags$dd("September to February, the months when southern Australia's bushfire risk is highest. A season spans two calendar years and is labelled by both, for example 2018\u201319."),
            tags$dt("Very hot day"),
            tags$dd("A day whose maximum temperature reached the threshold you set (35\u00b0C by default)."),
            tags$dt("Average hot days per season"),
            tags$dd("The total of very hot days in a period divided by the number of complete seasons in it."),
            tags$dt("Complete season"),
            tags$dd("A season with readings on at least 90% of its days. Seasons with more gaps would undercount hot days, so they are shown pale and left out of averages."),
            tags$dt("Coverage (table)"),
            tags$dd("The share of days in that season that have a temperature reading.")
          ),
          h4("Why hot days matter for bushfires"),
          p("Hot days dry out grass and forest fuels and push up the Fire Weather Index that fire agencies use. A study of the 2019\u201320 fires found that rising temperature is the main reason dangerous fire weather has become more likely in southeastern Australia (van Oldenborgh et al., 2021, ",
            tags$em("Natural Hazards and Earth System Sciences"), ")."),
          h4("What this app cannot tell you"),
          tags$ul(
            tags$li("Heat is only one ingredient of fire danger: wind, humidity, rainfall and fuel also matter, and they are not in this data."),
            tags$li("One station per city may not match conditions in the hills or bush on its outskirts."),
            tags$li("Over a century, stations can move or become surrounded by buildings, which can add a little warmth unrelated to the wider climate."),
            tags$li("The record ends in February 2019, before the Black Summer fires.")
          ),
          h4("Stations in this app"),
          tableOutput("station_table")
        )
      )
    )
  )
)

# ---- Server -----------------------------------------------------------------
server <- function(input, output, session) {

  # Step 1: hot days per season for the chosen city, threshold and months.
  # count_hot_days() is the package's exported summary function.
  hot_days <- reactive({
    req(input$city, input$threshold, input$season_part)
    count_hot_days(
      temps,
      city = input$city,
      threshold = input$threshold,
      months = season_parts[[input$season_part]]$months
    )
  })

  # Step 2: are the two periods usable? Returns a message, or NULL if fine.
  period_problem <- reactive({
    if (input$early[2] >= input$recent[1]) {
      return(paste0(
        "The two periods overlap: the early period ends in ", input$early[2],
        " but the recent period starts in ", input$recent[1],
        ". Move the recent period later, or end the early period sooner, so each season belongs to only one period."
      ))
    }
    NULL
  })

  # Step 3: average hot days in each period (exported compare_periods()).
  # req() stops quietly here; the message itself is shown once, by
  # output$data_warning, instead of repeating in every output.
  comparison <- reactive({
    req(is.null(period_problem()))
    compare_periods(hot_days(), early = input$early, recent = input$recent)
  })

  # Step 4: detect weak states that still allow a result, but need a caution
  weak_message <- reactive({
    comp <- comparison()
    city_start <- station_info$first_date[station_info$city == input$city]
    msgs <- character(0)
    if (any(comp$seasons_used == 0)) {
      empty <- comp$period[comp$seasons_used == 0]
      msgs <- c(msgs, paste0(
        input$city, "'s record starts in ", format(city_start, "%Y"),
        ", so the ", tolower(empty[1]), " period you chose has no complete seasons to compare. ",
        "Move it to start in ", format(city_start, "%Y"), " or later."
      ))
    } else if (any(!comp$enough_data)) {
      thin <- comp[!comp$enough_data, ]
      msgs <- c(msgs, paste0(
        "The ", tolower(thin$period[1]), " period has only ", thin$seasons_used[1],
        " complete season", ifelse(thin$seasons_used[1] == 1, "", "s"),
        ". One unusually hot or mild year can swing an average this short, so treat the comparison with caution, or widen the period to at least 10 seasons."
      ))
    }
    # Rare events: averages below 1 day a season rest on a handful of days
    if (length(msgs) == 0 && all(comp$seasons_used > 0) &&
        all(comp$mean_hot_days < 1) && any(comp$mean_hot_days > 0)) {
      msgs <- c(msgs, paste0(
        "Days of ", input$threshold, "\u00b0C or more are rare in ", input$city,
        " (fewer than one per season in both periods), so the averages rest on a handful of days. ",
        "Read the individual bars, or lower the threshold for a steadier comparison."
      ))
    }
    msgs
  })

  # A result with no hot days at all in either period cannot show a change
  no_hot_days <- reactive({
    comp <- comparison()
    all(!is.na(comp$mean_hot_days)) && all(comp$mean_hot_days == 0)
  })

  output$data_warning <- renderUI({
    # Invalid state: overlapping periods
    if (!is.null(period_problem())) {
      return(div(class = "state-box state-invalid",
                 strong("These periods can't be compared yet. "), period_problem()))
    }
    # Empty state: the threshold is never reached
    if (no_hot_days()) {
      return(div(class = "state-box state-empty",
                 strong("No very hot days to compare. "),
                 paste0("No day in ", season_parts[[input$season_part]]$label,
                        " reached ", input$threshold, "\u00b0C in ", input$city,
                        " in either period. That threshold is rare there, so try a lower one (for example 35\u00b0C).")))
    }
    # Weak state: a period with no or few complete seasons
    msgs <- weak_message()
    if (length(msgs) == 0) return(NULL)
    div(class = "state-box state-weak", strong("Use with care. "), msgs)
  })

  output$summary_boxes <- renderUI({
    comp <- comparison()
    req(!no_hot_days(), all(comp$seasons_used > 0))
    early <- comp$mean_hot_days[1]
    recent <- comp$mean_hot_days[2]
    diff <- recent - early
    change_text <- paste0(ifelse(diff >= 0, "+", "\u2212"),
                          format(round(abs(diff), 1), nsmall = 1), " days")
    # A ratio is only meaningful when the early period had at least one
    # hot day per season; otherwise 0.1 vs 0.05 would read as "2 times"
    ratio_text <- if (early >= 1) {
      paste0(format(round(recent / early, 1), nsmall = 1), " times the early average")
    } else {
      "per season (too few early hot days for a ratio)"
    }
    div(
      class = "value-row",
      div(class = "value-box vb-early",
          div(class = "vb-label", paste0("Early period (", input$early[1], "\u2013", input$early[2], ")")),
          div(class = "vb-value", format(round(early, 1), nsmall = 1)),
          div(class = "vb-note", paste0("hot days per season, ", comp$seasons_used[1], " seasons"))),
      div(class = "value-box vb-recent",
          div(class = "vb-label", paste0("Recent period (", input$recent[1], "\u2013", input$recent[2], ")")),
          div(class = "vb-value", format(round(recent, 1), nsmall = 1)),
          div(class = "vb-note", paste0("hot days per season, ", comp$seasons_used[2], " seasons"))),
      div(class = "value-box vb-change",
          div(class = "vb-label", "Change"),
          div(class = "vb-value", change_text),
          div(class = "vb-note", ratio_text))
    )
  })


  output$narrative <- renderUI({
    comp <- comparison()
    req(!no_hot_days(), all(comp$seasons_used > 0))
    sentence <- describe_change(
      comp,
      what = paste0("days at or above ", input$threshold, "\u00b0C in ",
                    season_parts[[input$season_part]]$label),
      place = input$city
    )
    p(class = "narrative", strong("Answer: "), sentence)
  })

  output$plot_title <- renderText({
    paste0("Days at or above ", input$threshold, "\u00b0C in ", input$city, ", ",
           season_parts[[input$season_part]]$label, ", each season")
  })

  output$hot_plot <- renderPlot({
    validate(need(is.null(period_problem()),
                  "The chart will return once the two periods no longer overlap."))
    comp <- comparison()
    validate(need(!no_hot_days(),
                  "Nothing to plot: no day reached this threshold in either period. Try a lower threshold."))

    # Label each season by the period it belongs to, so colour = period
    plot_data <- hot_days() |>
      mutate(group = case_when(
        !complete ~ "Incomplete season",
        season_start >= input$early[1] & season_start <= input$early[2] ~ "Early period",
        season_start >= input$recent[1] & season_start <= input$recent[2] ~ "Recent period",
        TRUE ~ "Other seasons"
      ))

    # One horizontal line per period at its average
    means <- comp |>
      filter(!is.na(mean_hot_days)) |>
      mutate(x = first_season - 0.5, xend = last_season + 0.5,
             colour = ifelse(period == "Early", col_early, col_recent),
             label = paste0("Average ", format(round(mean_hot_days, 1), nsmall = 1)))

    ggplot(plot_data, aes(x = season_start, y = hot_days)) +
      geom_col(aes(fill = group), width = 0.85) +
      geom_segment(data = means,
                   aes(x = x, xend = xend, y = mean_hot_days, yend = mean_hot_days),
                   colour = means$colour, linewidth = 1.3, inherit.aes = FALSE) +
      geom_label(data = means,
                 aes(x = (x + xend) / 2, y = mean_hot_days, label = label),
                 colour = means$colour, fill = "#FFFFFF",
                 vjust = -0.4, size = 4.2, fontface = "bold", inherit.aes = FALSE) +
      scale_fill_manual(
        values = c("Early period" = col_early, "Recent period" = col_recent,
                   "Other seasons" = col_other, "Incomplete season" = col_gap),
        breaks = c("Early period", "Recent period", "Other seasons", "Incomplete season"),
        name = NULL, drop = FALSE
      ) +
      scale_x_continuous(breaks = seq(1910, 2020, by = 10), expand = expansion(add = 1)) +
      scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
      labs(x = "Season (year it starts)", y = "Very hot days in the season") +
      theme_minimal(base_size = 14) +
      theme(
        legend.position = "top",
        legend.justification = "left",
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        plot.background = element_rect(fill = "#FFFFFF", colour = NA),
        axis.title = element_text(colour = "#444444")
      )
  })

  output$table_title <- renderText({
    paste0("The 10 seasons with the most days at or above ", input$threshold,
           "\u00b0C in ", input$city)
  })

  output$top_table <- render_gt({
    top <- hot_days() |>
      filter(complete) |>
      arrange(desc(hot_days), desc(season_start)) |>
      slice_head(n = 10)
    validate(need(nrow(top) > 0 && max(top$hot_days) > 0,
                  paste0("No complete season in ", input$city, " had a day at or above ",
                         input$threshold, "\u00b0C. Try a lower threshold.")))
    top |>
      mutate(rank = row_number(),
             era = ifelse(season_start >= input$recent[1] & season_start <= input$recent[2],
                          "Recent period", ifelse(season_start >= input$early[1] & season_start <= input$early[2],
                                                  "Early period", "Neither"))) |>
      select(rank, season, hot_days, hottest, coverage, era) |>
      gt() |>
      cols_label(rank = "Rank", season = "Season", hot_days = "Very hot days",
                 hottest = "Hottest day", coverage = "Coverage", era = "Period") |>
      fmt_number(columns = hottest, decimals = 1, pattern = "{x}\u00b0C") |>
      fmt_percent(columns = coverage, decimals = 0) |>
      tab_style(style = cell_text(weight = "bold", color = col_recent),
                locations = cells_body(columns = era, rows = era == "Recent period")) |>
      tab_style(style = cell_text(weight = "bold", color = col_early),
                locations = cells_body(columns = era, rows = era == "Early period")) |>
      tab_style(style = cell_text(weight = "bold", color = col_early),
                locations = cells_column_labels()) |>
      tab_source_note("Only complete seasons are ranked. Ties are listed most recent first.") |>
      opt_table_font(font = list("Source Sans 3", "Arial", "sans-serif"))
  })

  output$station_table <- renderTable({
    station_info |>
      transmute(City = city, State = state, Station = station,
                `Fire-season record` = paste(format(first_date, "%b %Y"), "to", format(last_date, "%b %Y")),
                `Days missing` = days_missing)
  }, striped = TRUE)
}

shinyApp(ui, server)
