#' runShiny
#'
#' Runs a Shiny app for dependency investigation.
#'
#' @return An object that represents the app.
#'
#' @export
#'
#' @examples
#' # Run only in interactive session
#' if (interactive()) {
#'   runShiny()
#' }
runShiny <- function() {
  #desc <- description$new()
  # reqs <- desc$get_deps() %>%
  #   dplyr::filter(.data$type == "Suggests") %>%
  #   dplyr::select(.data$package) %>%
  #   unlist %>%
  #   as.character()
  #
  # missing <- unlist(lapply(reqs, function(x) {
  #   if (!requireNamespace(x, quietly = TRUE)) {
  #     x
  #   }
  # }))

  missing <- c()
  if (length(missing > 0)) {
    stop(paste(
      "Additional packages required to run the shiny app. Install them with:",
      paste0("  install.packages('DependencyReviewer', dependencies = c('Suggests'))"),
      sep = "\n"
    ))
  } else {
    # utils::globalVariables(c(".path"))
    .GlobalEnv$.path <- here::here("R")
    appDir <-
      system.file(package = "DependencyReviewer", "shinyApp")
    if (appDir == "") {
      stop("Could not find shiny application")
    } else {
      shiny::shinyAppDir(appDir)
    }
  }
}
