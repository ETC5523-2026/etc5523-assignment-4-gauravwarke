# Column names used inside dplyr verbs. Declaring them stops R CMD check
# reporting "no visible binding for global variable".
utils::globalVariables(c(
  "season_start", "days_possible", "days_recorded", "coverage", "v",
  "n_exceed", "extreme", "complete", "period", "seasons_used",
  ".count", "mean_hot_days"
))
