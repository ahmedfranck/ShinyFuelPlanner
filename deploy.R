if (!requireNamespace("rsconnect", quietly = TRUE)) {
  stop("Install rsconnect first: install.packages('rsconnect')")
}

accounts <- rsconnect::accounts()
if (nrow(accounts) == 0) {
  stop(
    "No Posit shinyapps.io account is configured. ",
    "Run rsconnect::setAccountInfo(...) locally, then rerun this script."
  )
}

rsconnect::deployApp(
  appDir = ".",
  appName = "road-trip-fuel-planner",
  appTitle = "Road Trip Fuel Planner",
  account = accounts$name[[1]],
  server = accounts$server[[1]],
  forceUpdate = TRUE
)

