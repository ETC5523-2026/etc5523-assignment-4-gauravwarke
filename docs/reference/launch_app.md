# Launch the Ember Days app

Opens a Shiny app that helps people living in bushfire-prone parts of
Australia check whether very hot days in the fire season have become
more common in their city. The app uses the
[fire_season_temps](https://etc5523-2026.github.io/etc5523-assignment-4-gauravwarke/reference/fire_season_temps.md)
data that comes with the package, so it does not need an internet
connection or any data files.

## Usage

``` r
launch_app(...)
```

## Arguments

- ...:

  Further arguments passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html), for
  example `port = 3838` or `launch.browser = FALSE`.

## Value

Called for its side effect of starting the app. Returns the value of
[`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html) invisibly
when the app is closed.

## Examples

``` r
if (interactive()) {
  launch_app()
}
```
