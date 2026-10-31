#' Daily maximum temperatures in the bushfire season, seven Australian cities
#'
#' Daily maximum air temperatures recorded by the Australian Bureau of
#' Meteorology (BoM) at one weather station in each of seven cities, for the
#' fire-season months September to February. Records start in 1910 for most
#' cities (1913 for Canberra, 1949 for Brisbane) and end on 28 February 2019,
#' so the last complete season is 2018-19. The 2019-20 Black Summer season
#' is not included.
#'
#' @format A tibble with 130,971 rows and 4 columns:
#' \describe{
#'   \item{city}{City the station represents: Adelaide, Brisbane, Canberra,
#'     Melbourne, Perth, Port Lincoln or Sydney.}
#'   \item{station}{BoM station name, for example "Melbourne (Olympic Park)".}
#'   \item{date}{Date of the reading (class `Date`).}
#'   \item{max_temp}{Highest air temperature that day, in degrees Celsius.
#'     `NA` where no reading was recorded.}
#' }
#'
#' @details Each city is represented by a single station, which may sit some
#'   distance from bushfire-prone outskirts. Over a century, stations can
#'   move or change equipment and their surroundings can become more built
#'   up, which can shift readings slightly, so treat small differences
#'   between periods with caution. See `data-raw/fire_season_temps.R` for
#'   every preparation step.
#'
#' @source Australian Bureau of Meteorology Climate Data Online,
#'   <http://www.bom.gov.au/climate/data/>, as compiled for TidyTuesday
#'   2020 week 2 ("Australia Fires"),
#'   <https://github.com/rfordatascience/tidytuesday/tree/main/data/2020/2020-01-07>.
#'   BoM data are copyright Commonwealth of Australia.
#'
#' @examples
#' head(fire_season_temps)
#' # Hottest fire-season day on record in each city
#' fire_season_temps |>
#'   dplyr::group_by(city) |>
#'   dplyr::slice_max(max_temp, n = 1, with_ties = FALSE)
"fire_season_temps"

#' Weather stations behind each city in fire_season_temps
#'
#' One row per city, describing the Bureau of Meteorology station whose
#' readings are in [fire_season_temps] and how complete its fire-season
#' record is. Use it to check whether a city has enough history for the
#' period you want to compare.
#'
#' @format A tibble with 7 rows and 7 columns:
#' \describe{
#'   \item{city}{City name, matching `fire_season_temps$city`.}
#'   \item{state}{State or territory abbreviation.}
#'   \item{station}{BoM station name.}
#'   \item{first_date, last_date}{First and last fire-season date in the
#'     record.}
#'   \item{days_recorded}{Fire-season days with a temperature reading.}
#'   \item{days_missing}{Fire-season days listed without a reading.}
#' }
#' @source Derived from [fire_season_temps] in `data-raw/fire_season_temps.R`.
#' @examples
#' stations
"stations"
