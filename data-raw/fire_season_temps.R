# Prepare the package data: fire_season_temps and stations
#
# Source: Australian Bureau of Meteorology (BoM) daily maximum temperatures,
# as compiled for TidyTuesday 2020, week 2 ("Australia Fires"):
# https://github.com/rfordatascience/tidytuesday/tree/main/data/2020/2020-01-07
#
# Run this script from the package root to rebuild data/*.rda:
#   source("data-raw/fire_season_temps.R")

library(dplyr)

raw_url <- paste0(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/",
  "main/data/2020/2020-01-07/temperature.csv"
)

# 1. Import ---------------------------------------------------------------
# Keep a local copy so the script can be re-run offline.
# data-raw/*.csv is git-ignored, so the 23 MB file is not committed.
raw_file <- "data-raw/temperature.csv"
if (!file.exists(raw_file)) {
  utils::download.file(raw_url, raw_file, mode = "wb")
}

temperature_raw <- readr::read_csv(
  raw_file,
  col_types = readr::cols(
    city_name   = readr::col_character(),
    date        = readr::col_date(),
    temperature = readr::col_double(),
    temp_type   = readr::col_character(),
    site_name   = readr::col_character()
  )
)

# 2. Clean ----------------------------------------------------------------
# The raw file shortens two city names ("KENT" is Kent Town in Adelaide,
# "PORT" is Port Lincoln), so we replace them with names residents use.
city_lookup <- tibble::tribble(
  ~city_name,  ~city,          ~state,
  "BRISBANE",  "Brisbane",     "QLD",
  "CANBERRA",  "Canberra",     "ACT",
  "KENT",      "Adelaide",     "SA",
  "MELBOURNE", "Melbourne",    "VIC",
  "PERTH",     "Perth",        "WA",
  "PORT",      "Port Lincoln", "SA",
  "SYDNEY",    "Sydney",       "NSW"
)

# Fire season = September to February (the season used by
# van Oldenborgh et al. 2021 for southeastern Australia).
fire_months <- c(9:12, 1:2)

fire_season_temps <- temperature_raw |>
  # Only daily maximums are needed: a "hot day" is defined by the maximum.
  filter(temp_type == "max") |>
  inner_join(city_lookup, by = "city_name") |>
  mutate(
    station = tools::toTitleCase(tolower(site_name)),
    station = sub("Aws$", "AWS", station),
    month = as.integer(format(date, "%m"))
  ) |>
  # Keep fire-season months only; March to August is outside the question.
  filter(month %in% fire_months) |>
  # Readings below 0 or above 55 degrees would be impossible at these
  # stations; none exist, but the rule documents the check.
  filter(is.na(temperature) | between(temperature, 0, 55)) |>
  select(city, station, date, max_temp = temperature) |>
  arrange(city, date) |>
  distinct(city, date, .keep_all = TRUE)

# 3. Station metadata -----------------------------------------------------
stations <- fire_season_temps |>
  group_by(city, station) |>
  summarise(
    first_date = min(date),
    last_date = max(date),
    days_recorded = sum(!is.na(max_temp)),
    days_missing = sum(is.na(max_temp)),
    .groups = "drop"
  ) |>
  left_join(select(city_lookup, city, state), by = "city") |>
  select(city, state, station, first_date, last_date, days_recorded, days_missing)

# 4. Checks ---------------------------------------------------------------
stopifnot(
  n_distinct(fire_season_temps$city) == 7,
  all(format(fire_season_temps$date, "%m") %in% sprintf("%02d", fire_months)),
  !anyDuplicated(fire_season_temps[c("city", "date")])
)

# 5. Save -----------------------------------------------------------------
fire_season_temps <- tibble::as_tibble(fire_season_temps)
stations <- tibble::as_tibble(stations)
usethis::use_data(fire_season_temps, stations, overwrite = TRUE, compress = "xz")
