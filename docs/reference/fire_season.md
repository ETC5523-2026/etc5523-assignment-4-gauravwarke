# Label the bushfire season a date belongs to

The southern Australian fire season runs from September to February, so
it spans two calendar years. A season is labelled by the year it starts:
1 September 2018 to 28 February 2019 is the `2018` season, shown as
`"2018-19"`. Dates in March to August are outside the fire season.

## Usage

``` r
fire_season(date)
```

## Arguments

- date:

  A vector of class `Date`.

## Value

An integer vector the same length as `date`, giving the year the season
starts. Dates from March to August return `NA`.

## Examples

``` r
fire_season(as.Date(c("2018-09-01", "2019-02-28", "2019-06-15")))
#> [1] 2018 2018   NA
# 2018 2018 NA: the first two dates are in the same season
```
