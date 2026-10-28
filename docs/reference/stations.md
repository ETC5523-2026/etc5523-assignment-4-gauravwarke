# Weather stations behind each city in fire_season_temps

One row per city, describing the Bureau of Meteorology station whose
readings are in
[fire_season_temps](https://etc5523-2026.github.io/etc5523-assignment-4-gauravwarke/reference/fire_season_temps.md)
and how complete its fire-season record is. Use it to check whether a
city has enough history for the period you want to compare.

## Usage

``` r
stations
```

## Format

A tibble with 7 rows and 7 columns:

- city:

  City name, matching `fire_season_temps$city`.

- state:

  State or territory abbreviation.

- station:

  BoM station name.

- first_date, last_date:

  First and last fire-season date in the record.

- days_recorded:

  Fire-season days with a temperature reading.

- days_missing:

  Fire-season days listed without a reading.

## Source

Derived from
[fire_season_temps](https://etc5523-2026.github.io/etc5523-assignment-4-gauravwarke/reference/fire_season_temps.md)
in `data-raw/fire_season_temps.R`.

## Examples

``` r
stations
#> # A tibble: 7 × 7
#>   city         state station    first_date last_date  days_recorded days_missing
#>   <chr>        <chr> <chr>      <date>     <date>             <int>        <int>
#> 1 Adelaide     SA    Kent Town  1910-01-02 2019-02-28         19794           20
#> 2 Brisbane     QLD   Brisbane … 1949-09-01 2019-02-28         12667           20
#> 3 Canberra     ACT   Canberra … 1913-09-01 2019-02-28         18637          575
#> 4 Melbourne    VIC   Melbourne… 1910-01-01 2019-02-28         19814            1
#> 5 Perth        WA    Perth Air… 1910-01-01 2019-02-28         19805           10
#> 6 Port Lincoln SA    Port Linc… 1910-01-02 2019-02-28         19644          170
#> 7 Sydney       NSW   Sydney (O… 1910-01-02 2019-02-28         19796           18
```
