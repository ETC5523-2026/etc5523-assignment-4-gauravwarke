# Daily maximum temperatures in the bushfire season, seven Australian cities

Daily maximum air temperatures recorded by the Australian Bureau of
Meteorology (BoM) at one weather station in each of seven cities, for
the fire-season months September to February. Records start in 1910 for
most cities (1913 for Canberra, 1949 for Brisbane) and end on 28
February 2019, so the last complete season is 2018-19. The 2019-20 Black
Summer season is not included.

## Usage

``` r
fire_season_temps
```

## Format

A tibble with 130,971 rows and 4 columns:

- city:

  City the station represents: Adelaide, Brisbane, Canberra, Melbourne,
  Perth, Port Lincoln or Sydney.

- station:

  BoM station name, for example "Melbourne (Olympic Park)".

- date:

  Date of the reading (class `Date`).

- max_temp:

  Highest air temperature that day, in degrees Celsius. `NA` where no
  reading was recorded.

## Source

Australian Bureau of Meteorology Climate Data Online,
<http://www.bom.gov.au/climate/data/>, as compiled for TidyTuesday 2020
week 2 ("Australia Fires"),
<https://github.com/rfordatascience/tidytuesday/tree/main/data/2020/2020-01-07>.
BoM data are copyright Commonwealth of Australia.

## Details

Each city is represented by a single station, which may sit some
distance from bushfire-prone outskirts. Over a century, stations can
move or change equipment and their surroundings can become more built
up, which can shift readings slightly, so treat small differences
between periods with caution. See `data-raw/fire_season_temps.R` for
every preparation step.

## See also

[`count_hot_days()`](https://etc5523-2026.github.io/etc5523-assignment-4-gauravwarke/reference/count_hot_days.md)
to turn these readings into hot-day counts,
[stations](https://etc5523-2026.github.io/etc5523-assignment-4-gauravwarke/reference/stations.md)
for the station behind each city.

## Examples

``` r
head(fire_season_temps)
#> # A tibble: 6 × 4
#>   city     station   date       max_temp
#>   <chr>    <chr>     <date>        <dbl>
#> 1 Adelaide Kent Town 1910-01-02     37.9
#> 2 Adelaide Kent Town 1910-01-03     37.4
#> 3 Adelaide Kent Town 1910-01-04     37.9
#> 4 Adelaide Kent Town 1910-01-05     39.3
#> 5 Adelaide Kent Town 1910-01-06     38.2
#> 6 Adelaide Kent Town 1910-01-07     37.4
# Hottest fire-season day on record in each city
fire_season_temps |>
  dplyr::group_by(city) |>
  dplyr::slice_max(max_temp, n = 1, with_ties = FALSE)
#> # A tibble: 7 × 4
#> # Groups:   city [7]
#>   city         station                   date       max_temp
#>   <chr>        <chr>                     <date>        <dbl>
#> 1 Adelaide     Kent Town                 2019-01-24     47.7
#> 2 Brisbane     Brisbane Aero             2004-02-22     40.2
#> 3 Canberra     Canberra Airport          1968-02-01     42.3
#> 4 Melbourne    Melbourne (Olympic Park)  2009-02-07     45.9
#> 5 Perth        Perth Airport             1991-02-23     46.3
#> 6 Port Lincoln Port Lincoln AWS          2019-01-24     48.3
#> 7 Sydney       Sydney (Observatory Hill) 1939-01-14     47.9
```
