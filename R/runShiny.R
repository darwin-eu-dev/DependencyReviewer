#' runShiny
#'
#' @import shiny
#' @import shinyAce
#' @import ggplot2
#' @import here
#' @import DT
#' @import ggplot2
#' @import dplyr
#'
#'
#' @export
#'
#' @examples
#' runShiny
runShiny <- function() {
  appDir <- system.file(package = "DependencyReviewer", "shinyApp")
  if (appDir == "") {
    stop("Could not find shiny application")
  } else {
    shiny::shinyAppDir(appDir)
  }
}
