#' emberdays: very hot days in the bushfire season
#'
#' Data, functions and a Shiny app to check whether very hot fire-season days
#' have become more common in seven Australian cities.
"_PACKAGE"

# bslib, ggplot2 and gt are used by the Shiny app in inst/app/app.R rather
# than by functions in R/. Importing one name from each records that use,
# so installing emberdays always installs everything the app needs.
#' @importFrom bslib bs_theme
#' @importFrom ggplot2 ggplot
#' @importFrom gt gt
NULL
