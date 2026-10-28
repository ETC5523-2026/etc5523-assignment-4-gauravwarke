# Describe a change between two periods in plain English

Turns the two-row table from
[`compare_periods()`](https://etc5523-2026.github.io/etc5523-assignment-4-gauravwarke/reference/compare_periods.md)
into one sentence a non-specialist can read, such as "In Perth, days at
or above 35 degrees C have become more common: ...". The sentence states
the direction, both averages, the size of the change and, when it is
meaningful, the ratio. It also says so when a period has no usable
seasons, instead of reporting a misleading number.

## Usage

``` r
describe_change(
  comparison,
  what = "very hot days",
  place = NULL,
  tolerance = 0.5,
  digits = 1
)
```

## Arguments

- comparison:

  A tibble returned by
  [`compare_periods()`](https://etc5523-2026.github.io/etc5523-assignment-4-gauravwarke/reference/compare_periods.md).

- what:

  A plural noun phrase for what was counted, for example
  `"days at or above 35 degrees C"` or `"frosty nights"`.

- place:

  Optional place name to start the sentence with.

- tolerance:

  Differences smaller than this (in days per season) are described as
  "about the same". Defaults to 0.5.

- digits:

  Decimal places for the averages. Defaults to 1.

## Value

A single character string.

## Examples

``` r
perth <- count_hot_days(fire_season_temps, "Perth")
compare_periods(perth) |>
  describe_change(what = "days at or above 35 degrees C", place = "Perth")
#> [1] "In Perth, days at or above 35 degrees C have become more common: recent seasons (1989–2018) averaged 26.0 per season, compared with 17.0 in 1910–1939, an increase of 9.0 per season (1.5 times the early average)."

# When a period has no data, the sentence says so
count_hot_days(fire_season_temps, "Brisbane") |>
  compare_periods() |>
  describe_change(what = "very hot days", place = "Brisbane")
#> [1] "In Brisbane, the early period (1910–1939) has no complete seasons, so no change can be stated."
```
