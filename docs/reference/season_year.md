# Label the season-year a date belongs to

Many climate questions use a "year" that does not start in January: the
southern fire season starts in September, a financial or water year
starts in July. `season_year()` labels every date by the calendar year
in which its season-year starts.

## Usage

``` r
season_year(date, start_month = 1)
```

## Arguments

- date:

  A vector of class `Date`.

- start_month:

  The month (1 to 12) in which each season-year starts. Defaults to 1
  (an ordinary calendar year).

## Value

An integer vector the same length as `date`.

## Examples

``` r
d <- as.Date(c("2018-06-30", "2018-07-01", "2019-02-01"))
season_year(d)                    # calendar years: 2018 2018 2019
#> [1] 2018 2018 2019
season_year(d, start_month = 7)   # July-June years: 2017 2018 2018
#> [1] 2017 2018 2018
```
