# Copyright 2023 DARWIN EU®
#
# This file is part of IncidencePrevalence
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' runShiny
#'
#' Runs a Shiny app for dependency investigation.
#'
#' @return An object that represents the app.
#'
#' @import dplyr
#' @import utils
#' @importFrom desc description
#' @importFrom magrittr %>%
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
