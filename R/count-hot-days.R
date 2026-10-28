#' Label the bushfire season a date belongs to
#'
#' The southern Australian fire season runs from September to February, so
#' it spans two calendar years. A season is labelled by the year it starts:
#' 1 September 2018 to 28 February 2019 is the `2018` season, shown as
#' `"2018-19"`. Dates in March to August are outside the fire season.
#'
#' @param date A vector of class `Date`.
#'
#' @return An integer vector the same length as `date`, giving the year the
#'   season starts. Dates from March to August return `NA`.
#'
#' @examples
#' fire_season(as.Date(c("2018-09-01", "2019-02-28", "2019-06-15")))
#' # 2018 2018 NA: the first two dates are in the same season
#' @export
fire_season <- function(date) {
  if (!inherits(date, "Date")) {
    stop("`date` must be a Date vector, for example as.Date(\"2019-01-15\").",
         call. = FALSE)
  }
  year <- as.integer(format(date, "%Y"))
  month <- as.integer(format(date, "%m"))
  # September to December start a season; January and February finish the
  # season that began the previous September.
  out <- ifelse(month >= 9, year, ifelse(month <= 2, year - 1L, NA_integer_))
  as.integer(out)
}

#' Count very hot days in each bushfire season
#'
#' For one city, counts the days in each fire season whose maximum
#' temperature reached a chosen threshold, and records how complete the
#' temperature record is for that season. Seasons with too many missing
#' days are flagged rather than dropped, so users can see the gaps.
#'
#' @param temps A data frame of daily maximum temperatures with columns
#'   `city`, `date` and `max_temp`, such as [fire_season_temps].
#' @param city The name of one city in `temps`, for example `"Melbourne"`.
#' @param threshold A day counts as "hot" when its maximum temperature is at
#'   or above this value, in degrees Celsius. Defaults to 35.
#' @param months The months of the season to include, as numbers. Defaults
#'   to the whole fire season, September to February (`c(9:12, 1:2)`). Use
#'   `9:11` for the spring build-up or `c(12, 1, 2)` for the summer peak.
#' @param min_coverage The share of days in a season that must have a
#'   temperature reading for the season to be marked complete. Defaults to
#'   0.9 (90%).
#'
#' @return A tibble with one row per fire season and columns:
#'   \describe{
#'     \item{city}{City name.}
#'     \item{season_start}{Year the season starts (see [fire_season()]).}
#'     \item{season}{Season label, for example `"2018-19"`.}
#'     \item{days_possible}{Calendar days in the selected months.}
#'     \item{days_recorded}{Days with a temperature reading.}
#'     \item{coverage}{`days_recorded / days_possible`.}
#'     \item{hot_days}{Days at or above `threshold`.}
#'     \item{hottest}{Highest maximum temperature in the season (degrees C).}
#'     \item{complete}{`TRUE` when `coverage` is at least `min_coverage`.}
#'   }
#'
#' @examples
#' # Days of 35 degrees C or more in each Melbourne fire season
#' melb <- count_hot_days(fire_season_temps, "Melbourne")
#' tail(melb)
#'
#' # Only the most extreme days, in the summer peak
#' count_hot_days(fire_season_temps, "Adelaide", threshold = 40,
#'                months = c(12, 1, 2)) |>
#'   dplyr::slice_max(hot_days, n = 3)
#' @seealso [count_exceedances()] for any variable, threshold direction or
#'   season.
#' @export
count_hot_days <- function(temps, city, threshold = 35,
                           months = c(9:12, 1:2), min_coverage = 0.9) {
  # Check inputs early so the app and users get a plain-language message
  needed <- c("city", "date", "max_temp")
  if (!all(needed %in% names(temps))) {
    stop("`temps` needs the columns city, date and max_temp.", call. = FALSE)
  }
  if (length(city) != 1 || !city %in% temps$city) {
    stop("`city` must be one of: ",
         paste(sort(unique(temps$city)), collapse = ", "), ".", call. = FALSE)
  }
  if (!is.numeric(threshold) || length(threshold) != 1 || is.na(threshold)) {
    stop("`threshold` must be a single temperature in degrees Celsius.",
         call. = FALSE)
  }
  months <- unique(as.integer(months))
  fire_months <- c(9:12, 1:2)
  if (length(months) == 0 || !all(months %in% fire_months)) {
    stop("`months` must be fire-season months: 9, 10, 11, 12, 1 or 2.",
         call. = FALSE)
  }

  # count_hot_days() is the fire-season version of the general
  # count_exceedances(): one city, days at or above the threshold,
  # seasons starting in September.
  chosen <- city
  city_temps <- temps[temps$city == chosen, c("date", "max_temp")]
  out <- count_exceedances(city_temps, "max_temp",
                           threshold = threshold, direction = "above",
                           date = "date",
                           start_month = 9, months = months,
                           min_coverage = min_coverage)
  out$city <- chosen
  names(out)[names(out) == "n_exceed"] <- "hot_days"
  names(out)[names(out) == "extreme"] <- "hottest"
  out[, c("city", "season_start", "season", "days_possible",
          "days_recorded", "coverage", "hot_days", "hottest", "complete")]
}
