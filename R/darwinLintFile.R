#' darwinLintFile
#'
#' Lint a given file.
#'
#' @import lintr
#'
#' @param fileName Path to file to lint
#'
#' @export
lintFile <- function(fileName) {
  lintr::lint(
    filename = fileName,
    linters = lintr::linters_with_defaults(
      lintr::object_name_linter(styles = "camelCase")))
}
