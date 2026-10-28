# Count very hot days in each bushfire season

For one city, counts the days in each fire season whose maximum
temperature reached a chosen threshold, and records how complete the
temperature record is for that season. Seasons with too many missing
days are flagged rather than dropped, so users can see the gaps.

## Usage

``` r
count_hot_days(
  temps,
  city,
  threshold = 35,
  months = c(9:12, 1:2),
  min_coverage = 0.9
)
```

## Arguments

- temps:

  A data frame of daily maximum temperatures with columns `city`, `date`
  and `max_temp`, such as
  [fire_season_temps](https://etc5523-2026.github.io/etc5523-assignment-4-gauravwarke/reference/fire_season_temps.md).

- city:

  The name of one city in `temps`, for example `"Melbourne"`.

- threshold:

  A day counts as "hot" when its maximum temperature is at or above this
  value, in degrees Celsius. Defaults to 35.

- months:

  The months of the season to include, as numbers. Defaults to the whole
  fire season, September to February (`c(9:12, 1:2)`). Use `9:11` for
  the spring build-up or `c(12, 1, 2)` for the summer peak.

- min_coverage:

  The share of days in a season that must have a temperature reading for
  the season to be marked complete. Defaults to 0.9 (90%).

## Value

A tibble with one row per fire season and columns:

- city:

  City name.

- season_start:

  Year the season starts (see
  [`fire_season()`](https://etc5523-2026.github.io/etc5523-assignment-4-gauravwarke/reference/fire_season.md)).

- season:

  Season label, for example `"2018-19"`.

- days_possible:

  Calendar days in the selected months.

- days_recorded:

  Days with a temperature reading.

- coverage:

  `days_recorded / days_possible`.

- hot_days:

  Days at or above `threshold`.

- hottest:

  Highest maximum temperature in the season (degrees C).

- complete:

  `TRUE` when `coverage` is at least `min_coverage`.

## See also

[`count_exceedances()`](https://etc5523-2026.github.io/etc5523-assignment-4-gauravwarke/reference/count_exceedances.md)
for any variable, threshold direction or season.

## Examples

``` r
# Days of 35 degrees C or more in each Melbourne fire season
melb <- count_hot_days(fire_season_temps, "Melbourne")
tail(melb)
#> # A tibble: 6 × 9
#>   city      season_start season  days_possible days_recorded coverage hot_days
#>   <chr>            <int> <chr>           <int>         <int>    <dbl>    <int>
#> 1 Melbourne         2013 2013-14           181           181        1       12
#> 2 Melbourne         2014 2014-15           181           181        1        9
#> 3 Melbourne         2015 2015-16           182           182        1       11
#> 4 Melbourne         2016 2016-17           181           181        1       11
#> 5 Melbourne         2017 2017-18           181           181        1        8
#> 6 Melbourne         2018 2018-19           181           181        1       11
#> # ℹ 2 more variables: hottest <dbl>, complete <lgl>

# Only the most extreme days, in the summer peak
count_hot_days(fire_season_temps, "Adelaide", threshold = 40,
               months = c(12, 1, 2)) |>
  dplyr::slice_max(hot_days, n = 3)
#> # A tibble: 3 × 9
#>   city     season_start season  days_possible days_recorded coverage hot_days
#>   <chr>           <int> <chr>           <int>         <int>    <dbl>    <int>
#> 1 Adelaide         2013 2013-14            90            90        1       13
#> 2 Adelaide         2018 2018-19            90            90        1       10
#> 3 Adelaide         2008 2008-09            90            90        1        9
#> # ℹ 2 more variables: hottest <dbl>, complete <lgl>
```
