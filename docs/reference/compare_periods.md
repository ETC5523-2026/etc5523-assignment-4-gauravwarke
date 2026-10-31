# Compare hot days in an early period with a recent period

Averages the output of
[`count_hot_days()`](https://etc5523-2026.github.io/etc5523-assignment-4-gauravwarke/reference/count_hot_days.md)
over two periods that do not overlap, so you can see whether very hot
fire-season days have become more common. Only complete seasons (see the
`complete` column) are used, because a season with many missing days
would undercount hot days.

## Usage

``` r
compare_periods(
  hot_days,
  early = c(1910, 1939),
  recent = c(1989, 2018),
  min_seasons = 10
)
```

## Arguments

- hot_days:

  A tibble returned by
  [`count_hot_days()`](https://etc5523-2026.github.io/etc5523-assignment-4-gauravwarke/reference/count_hot_days.md)
  or
  [`count_exceedances()`](https://etc5523-2026.github.io/etc5523-assignment-4-gauravwarke/reference/count_exceedances.md).

- early:

  Two years giving the first and last season of the early period.
  Defaults to `c(1910, 1939)`.

- recent:

  Two years giving the first and last season of the recent period.
  Defaults to `c(1989, 2018)`, the last 30 complete seasons. 30 years is
  the standard length used to describe a climate "average".

- min_seasons:

  The fewest complete seasons a period needs before its average is
  treated as reliable. Defaults to 10.

## Value

A tibble with two rows (`"Early"` and `"Recent"`) and columns:

- period:

  `"Early"` or `"Recent"`.

- first_season, last_season:

  The years requested.

- seasons_used:

  Complete seasons inside the period.

- mean_hot_days:

  Average counted days per complete season (`NA` if there are none). The
  name is kept for both inputs.

- enough_data:

  `TRUE` when `seasons_used` is at least `min_seasons`.

## Examples

``` r
melb <- count_hot_days(fire_season_temps, "Melbourne")
compare_periods(melb)
#> # A tibble: 2 × 6
#>   period first_season last_season seasons_used mean_hot_days enough_data
#>   <chr>         <int>       <int>        <int>         <dbl> <lgl>      
#> 1 Early          1910        1939           30          7.57 TRUE       
#> 2 Recent         1989        2018           30          8.83 TRUE       
# Average days of 35 degrees C or more per season, early versus recent

# Brisbane's record starts in 1949, so an early period before then
# has no seasons and is flagged with enough_data = FALSE
count_hot_days(fire_season_temps, "Brisbane") |>
  compare_periods(early = c(1910, 1939))
#> # A tibble: 2 × 6
#>   period first_season last_season seasons_used mean_hot_days enough_data
#>   <chr>         <int>       <int>        <int>         <dbl> <lgl>      
#> 1 Early          1910        1939            0        NA     FALSE      
#> 2 Recent         1989        2018           30         0.833 TRUE       
```
