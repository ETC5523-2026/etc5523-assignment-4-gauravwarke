#' Label the season-year a date belongs to
#'
#' Many climate questions use a "year" that does not start in January: the
#' southern fire season starts in September, a financial or water year starts
#' in July. `season_year()` labels every date by the calendar year in which its
#' season-year starts.
#'
#' @param date A vector of class `Date`.
#' @param start_month The month (1 to 12) in which each season-year starts.
#'   Defaults to 1 (an ordinary calendar year).
#'
#' @return An integer vector the same length as `date`.
#'
#' @examples
#' d <- as.Date(c("2018-06-30", "2018-07-01", "2019-02-01"))
#' season_year(d)                    # calendar years: 2018 2018 2019
#' season_year(d, start_month = 7)   # July-June years: 2017 2018 2018
#' @export
season_year <- function(date, start_month = 1) {
  if (!inherits(date, "Date")) {
    stop("`date` must be a Date vector, for example as.Date(\"2019-01-15\").",
         call. = FALSE)
  }
  if (length(start_month) != 1 || !start_month %in% 1:12) {
    stop("`start_month` must be a single month number from 1 to 12.",
         call. = FALSE)
  }
  year <- as.integer(format(date, "%Y"))
  month <- as.integer(format(date, "%m"))
  as.integer(ifelse(month >= start_month, year, year - 1L))
}

#' Count days above (or below) a threshold in each season-year
#'
#' The general-purpose function behind [count_hot_days()]. It works on any
#' data frame of daily values, from any source, with any column names: count very hot days,
#' mild days, heavy-rain days or cold nights, in a calendar year, a July-June
#' year or a custom season. Missing days are counted against each season's
#' coverage, so seasons with gaps are flagged rather than silently
#' undercounted.
#'
#' @param data A data frame with one row per day for a single place. Filter
#'   to one place before calling (see the examples).
#' @param value The name of the column holding the daily value, in quotes,
#'   for example `"max_temp"`.
#' @param threshold The value to compare each day against.
#' @param direction `"above"` counts days at or above `threshold`;
#'   `"below"` counts days at or below it.
#' @param date The name of the column holding dates (class `Date`), in
#'   quotes. Defaults to `"date"`.
#' @param start_month The month each season-year starts (1 to 12). Defaults
#'   to 1, an ordinary calendar year. Use 9 for the southern fire season,
#'   7 for a July-June year.
#' @param months The months to include. Defaults to all 12. For example,
#'   `c(12, 1, 2)` keeps only summer.
#' @param min_coverage The share of days in a season that must have a value
#'   for the season to be marked complete. Defaults to 0.9.
#'
#' @return A tibble with one row per season-year and columns
#'   `season_start`, `season` (a label such as `"2018-19"`, or `"2018"` for
#'   calendar years), `days_possible`, `days_recorded`, `coverage`,
#'   `n_exceed` (days meeting the threshold), `extreme` (the highest value
#'   for `"above"`, the lowest for `"below"`) and `complete`.
#'
#' @examples
#' # Your own data can have any column names
#' sydney <- fire_season_temps |>
#'   dplyr::filter(city == "Sydney") |>
#'   dplyr::select(day = date, tmax = max_temp)
#'
#' # Summer days of 35 degrees C or more, Dec-Feb seasons
#' count_exceedances(sydney, "tmax", threshold = 35, date = "day",
#'                   start_month = 12, months = c(12, 1, 2)) |>
#'   tail()
#'
#' # Mild summer days (maximum of 22 degrees C or less) are the opposite end
#' count_exceedances(sydney, "tmax", threshold = 22, direction = "below",
#'                   date = "day", start_month = 12, months = c(12, 1, 2)) |>
#'   tail()
#' @importFrom dplyr filter mutate group_by summarise left_join arrange n
#' @importFrom dplyr coalesce
#' @export
count_exceedances <- function(data, value, threshold,
                              direction = c("above", "below"),
                              date = "date", start_month = 1, months = 1:12,
                              min_coverage = 0.9) {
  direction <- match.arg(direction)
  value_name <- value
  date_name <- date
  if (!all(c(value_name, date_name) %in% names(data))) {
    stop("`data` must contain the columns `", value_name, "` and `",
         date_name, "`.", call. = FALSE)
  }
  if (!inherits(data[[date_name]], "Date")) {
    stop("The `", date_name, "` column must be of class Date. ",
         "Convert it with as.Date() first.", call. = FALSE)
  }
  if (!is.numeric(data[[value_name]])) {
    stop("The `", value_name, "` column must be numeric.", call. = FALSE)
  }
  if (!is.numeric(threshold) || length(threshold) != 1 || is.na(threshold)) {
    stop("`threshold` must be a single number.", call. = FALSE)
  }
  months <- unique(as.integer(months))
  if (length(months) == 0 || !all(months %in% 1:12)) {
    stop("`months` must be month numbers from 1 to 12.", call. = FALSE)
  }
  if (anyDuplicated(data[[date_name]])) {
    stop("`data` has repeated dates. Filter it to a single place first.",
         call. = FALSE)
  }

  daily <- data.frame(d = data[[date_name]], v = data[[value_name]])
  daily <- daily[as.integer(format(daily$d, "%m")) %in% months, ]
  if (nrow(daily) == 0) {
    stop("No rows fall in the chosen `months`.", call. = FALSE)
  }
  daily$season_start <- season_year(daily$d, start_month)

  # Full calendar of the chosen months, so missing days count against coverage
  first <- min(daily$season_start)
  last <- max(daily$season_start)
  calendar <- seq(as.Date(sprintf("%d-%02d-01", first, start_month)),
                  as.Date(sprintf("%d-%02d-01", last + 1, start_month)) - 1,
                  by = "day")
  calendar <- calendar[as.integer(format(calendar, "%m")) %in% months]
  possible <- data.frame(season_start = season_year(calendar, start_month)) |>
    group_by(season_start) |>
    summarise(days_possible = n(), .groups = "drop")

  meets <- if (direction == "above") {
    function(x) x >= threshold
  } else {
    function(x) x <= threshold
  }
  extreme_fn <- if (direction == "above") max else min

  counts <- daily |>
    group_by(season_start) |>
    summarise(
      days_recorded = sum(!is.na(v)),
      n_exceed = sum(meets(v), na.rm = TRUE),
      extreme = if (all(is.na(v))) NA_real_ else extreme_fn(v, na.rm = TRUE),
      .groups = "drop"
    )

  # Seasons that cross New Year get a two-year label, e.g. "2018-19"
  crosses <- start_month != 1
  possible |>
    left_join(counts, by = "season_start") |>
    mutate(
      season = if (crosses) {
        paste0(season_start, "-", substr(season_start + 1, 3, 4))
      } else {
        as.character(season_start)
      },
      days_recorded = coalesce(days_recorded, 0L),
      n_exceed = coalesce(n_exceed, 0L),
      coverage = days_recorded / days_possible,
      complete = coverage >= min_coverage
    ) |>
    arrange(season_start) |>
    dplyr::select("season_start", "season", "days_possible", "days_recorded",
                  "coverage", "n_exceed", "extreme", "complete") |>
    dplyr::as_tibble()
}
