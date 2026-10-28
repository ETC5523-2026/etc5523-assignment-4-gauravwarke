#' Compare hot days in an early period with a recent period
#'
#' Summarises the output of [count_hot_days()] for two non-overlapping
#' periods, so a user can see whether very hot fire-season days have become
#' more common. Only complete seasons (see the `complete` column) are used,
#' because a season with many missing days would undercount hot days.
#'
#' @param hot_days A tibble returned by [count_hot_days()] or
#'   [count_exceedances()].
#' @param early Two years giving the first and last season of the early
#'   period. Defaults to `c(1910, 1939)`.
#' @param recent Two years giving the first and last season of the recent
#'   period. Defaults to `c(1989, 2018)`, the last 30 complete seasons.
#'   30 years is the standard length used to describe a climate "average".
#' @param min_seasons The fewest complete seasons a period needs before its
#'   average is treated as reliable. Defaults to 10.
#'
#' @return A tibble with two rows (`"Early"` and `"Recent"`) and columns:
#'   \describe{
#'     \item{period}{`"Early"` or `"Recent"`.}
#'     \item{first_season, last_season}{The years requested.}
#'     \item{seasons_used}{Complete seasons inside the period.}
#'     \item{mean_hot_days}{Average counted days per complete season
#'       (`NA` if there are none). The name is kept for both inputs.}
#'     \item{enough_data}{`TRUE` when `seasons_used` is at least
#'       `min_seasons`.}
#'   }
#'
#' @examples
#' melb <- count_hot_days(fire_season_temps, "Melbourne")
#' compare_periods(melb)
#' # Average days of 35 degrees C or more per season, early versus recent
#'
#' # Brisbane's record starts in 1949, so an early period before then
#' # has no seasons and is flagged with enough_data = FALSE
#' count_hot_days(fire_season_temps, "Brisbane") |>
#'   compare_periods(early = c(1910, 1939))
#' @importFrom dplyr filter summarise mutate bind_rows
#' @export
compare_periods <- function(hot_days, early = c(1910, 1939),
                            recent = c(1989, 2018), min_seasons = 10) {
  check_period <- function(x, name) {
    if (!is.numeric(x) || length(x) != 2 || anyNA(x) || x[1] > x[2]) {
      stop("`", name, "` must be two years in order, for example c(1910, 1939).",
           call. = FALSE)
    }
  }
  check_period(early, "early")
  check_period(recent, "recent")
  if (early[2] >= recent[1]) {
    stop("The early period must end before the recent period starts.",
         call. = FALSE)
  }
  # Works with either count_hot_days() (hot_days) or count_exceedances()
  # (n_exceed) output
  count_col <- intersect(c("hot_days", "n_exceed"), names(hot_days))[1]
  if (is.na(count_col) || !all(c("season_start", "complete") %in% names(hot_days))) {
    stop("`hot_days` must be the output of count_hot_days() or ",
         "count_exceedances().", call. = FALSE)
  }
  hot_days$.count <- hot_days[[count_col]]

  summarise_period <- function(range, label) {
    hot_days |>
      filter(complete,
             season_start >= range[1],
             season_start <= range[2]) |>
      summarise(
        period = label,
        first_season = as.integer(range[1]),
        last_season = as.integer(range[2]),
        seasons_used = dplyr::n(),
        mean_hot_days = if (dplyr::n() == 0) NA_real_ else
          mean(.count)
      )
  }

  bind_rows(summarise_period(early, "Early"),
            summarise_period(recent, "Recent")) |>
    mutate(enough_data = seasons_used >= min_seasons)
}
