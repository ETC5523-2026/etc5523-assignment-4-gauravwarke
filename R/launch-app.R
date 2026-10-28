#' Launch the Ember Days app
#'
#' Opens a Shiny app that helps people living in bushfire-prone parts of
#' Australia check whether very hot days in the fire season have become more
#' common in their city. The app uses the [fire_season_temps] data that
#' comes with the package, so it does not need an internet connection or
#' any data files.
#'
#' @param ... Further arguments passed to [shiny::runApp()], for example
#'   `port = 3838` or `launch.browser = FALSE`.
#'
#' @return Called for its side effect of starting the app. Returns the
#'   value of [shiny::runApp()] invisibly when the app is closed.
#'
#' @examples
#' if (interactive()) {
#'   launch_app()
#' }
#' @export
launch_app <- function(...) {
  app_dir <- system.file("app", package = "emberdays")
  if (app_dir == "") {
    stop("Could not find the app. Try reinstalling emberdays.", call. = FALSE)
  }
  shiny::runApp(app_dir, display.mode = "normal", ...)
}
