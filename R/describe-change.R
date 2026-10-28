#' Describe a change between two periods in plain English
#'
#' Turns the two-row table from [compare_periods()] into one sentence a
#' non-specialist can read, such as "In Perth, days at or above 35 degrees C
#' have become more common: ...". The sentence states the direction, both
#' averages, the size of the change and, when it is meaningful, the ratio.
#' It also says so when a period has no usable seasons, instead of
#' reporting a misleading number.
#'
#' @param comparison A tibble returned by [compare_periods()].
#' @param what A plural noun phrase for what was counted, for example
#'   `"days at or above 35 degrees C"` or `"frosty nights"`.
#' @param place Optional place name to start the sentence with.
#' @param tolerance Differences smaller than this (in days per season) are
#'   described as "about the same". Defaults to 0.5.
#' @param digits Decimal places for the averages. Defaults to 1.
#'
#' @return A single character string.
#'
#' @examples
#' perth <- count_hot_days(fire_season_temps, "Perth")
#' compare_periods(perth) |>
#'   describe_change(what = "days at or above 35 degrees C", place = "Perth")
#'
#' # When a period has no data, the sentence says so
#' count_hot_days(fire_season_temps, "Brisbane") |>
#'   compare_periods() |>
#'   describe_change(what = "very hot days", place = "Brisbane")
#' @export
describe_change <- function(comparison, what = "very hot days", place = NULL,
                            tolerance = 0.5, digits = 1) {
  needed <- c("period", "first_season", "last_season", "seasons_used",
              "mean_hot_days")
  if (!all(needed %in% names(comparison)) || nrow(comparison) != 2) {
    stop("`comparison` must be the output of compare_periods().", call. = FALSE)
  }
  span <- function(i) {
    paste0(comparison$first_season[i], "\u2013", comparison$last_season[i])
  }
  lead <- if (is.null(place)) "" else paste0("In ", place, ", ")
  early <- comparison$mean_hot_days[1]
  recent <- comparison$mean_hot_days[2]

  # Weak state: a period with no complete seasons cannot be compared
  if (is.na(early) || is.na(recent)) {
    empty <- if (is.na(early)) "early" else "recent"
    return(paste0(lead, "the ", empty, " period (", span(ifelse(is.na(early), 1, 2)),
                  ") has no complete seasons, so no change can be stated."))
  }

  fmt <- function(x) format(round(x, digits), nsmall = digits)
  diff <- recent - early
  verdict <- if (abs(diff) < tolerance) {
    "are about as common as they were"
  } else if (diff > 0) {
    "have become more common"
  } else {
    "have become less common"
  }
  change <- if (abs(diff) < tolerance) {
    "a difference too small to matter"
  } else {
    paste0(ifelse(diff > 0, "an increase of ", "a decrease of "),
           fmt(abs(diff)), " per season")
  }
  # A ratio only makes sense when the early average is at least 1 a season
  ratio <- if (early >= 1 && abs(diff) >= tolerance) {
    paste0(" (", fmt(recent / early), " times the early average)")
  } else {
    ""
  }
  sentence <- paste0(lead, what, " ", verdict, ": recent seasons (", span(2),
                     ") averaged ", fmt(recent), " per season, compared with ",
                     fmt(early), " in ", span(1), ", ", change, ratio, ".")
  # Capitalise the first letter when there is no place name
  paste0(toupper(substr(sentence, 1, 1)), substr(sentence, 2, nchar(sentence)))
}
