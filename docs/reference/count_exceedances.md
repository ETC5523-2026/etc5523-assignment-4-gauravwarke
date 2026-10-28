# Count days above (or below) a threshold in each season-year

The general engine behind
[`count_hot_days()`](https://etc5523-2026.github.io/etc5523-assignment-4-gauravwarke/reference/count_hot_days.md).
Works on any data frame of daily values, from any source, with any
column names: count very hot days, mild days, heavy-rain days or cold
nights, in a calendar year, a July-June year or a custom season. Missing
days are counted against each season's coverage, so seasons with gaps
are flagged rather than silently undercounted.

## Usage

``` r
count_exceedances(
  data,
  value,
  threshold,
  direction = c("above", "below"),
  date = "date",
  start_month = 1,
  months = 1:12,
  min_coverage = 0.9
)
```

## Arguments

- data:

  A data frame with one row per day for a single place. Filter to one
  place before calling (see the examples).

- value:

  The name of the column holding the daily value, in quotes, for example
  `"max_temp"`.

- threshold:

  The value to compare each day against.

- direction:

  `"above"` counts days at or above `threshold`; `"below"` counts days
  at or below it.

- date:

  The name of the column holding dates (class `Date`), in quotes.
  Defaults to `"date"`.

- start_month:

  The month each season-year starts (1 to 12). Defaults to 1, an
  ordinary calendar year. Use 9 for the southern fire season, 7 for a
  July-June year.

- months:

  The months to include. Defaults to all 12. For example, `c(12, 1, 2)`
  keeps only summer.

- min_coverage:

  The share of days in a season that must have a value for the season to
  be marked complete. Defaults to 0.9.

## Value

A tibble with one row per season-year and columns `season_start`,
`season` (a label such as `"2018-19"`, or `"2018"` for calendar years),
`days_possible`, `days_recorded`, `coverage`, `n_exceed` (days meeting
the threshold), `extreme` (the highest value for `"above"`, the lowest
for `"below"`) and `complete`.

## Examples

``` r
# Your own data can have any column names
sydney <- fire_season_temps |>
  dplyr::filter(city == "Sydney") |>
  dplyr::select(day = date, tmax = max_temp)

# Summer days of 35 degrees C or more, Dec-Feb seasons
count_exceedances(sydney, "tmax", threshold = 35, date = "day",
                  start_month = 12, months = c(12, 1, 2)) |>
  tail()
#> # A tibble: 6 × 8
#>   season_start season  days_possible days_recorded coverage n_exceed extreme
#>          <int> <chr>           <int>         <int>    <dbl>    <int>   <dbl>
#> 1         2013 2013-14            90            90        1        2    36.5
#> 2         2014 2014-15            90            90        1        1    35.7
#> 3         2015 2015-16            91            91        1        3    39.2
#> 4         2016 2016-17            90            90        1       11    39.4
#> 5         2017 2017-18            90            90        1        5    43.4
#> 6         2018 2018-19            90            90        1        4    39.6
#> # ℹ 1 more variable: complete <lgl>

# Mild summer days (maximum of 22 degrees C or less) are the opposite end
count_exceedances(sydney, "tmax", threshold = 22, direction = "below",
                  date = "day", start_month = 12, months = c(12, 1, 2)) |>
  tail()
#> # A tibble: 6 × 8
#>   season_start season  days_possible days_recorded coverage n_exceed extreme
#>          <int> <chr>           <int>         <int>    <dbl>    <int>   <dbl>
#> 1         2013 2013-14            90            90        1        4    21.5
#> 2         2014 2014-15            90            90        1        5    20.4
#> 3         2015 2015-16            91            91        1        5    18.6
#> 4         2016 2016-17            90            90        1        3    19.1
#> 5         2017 2017-18            90            90        1        3    18.6
#> 6         2018 2018-19            90            90        1        2    21.1
#> # ℹ 1 more variable: complete <lgl>
```
