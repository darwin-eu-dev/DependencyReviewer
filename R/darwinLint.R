#' darwinLint
#'
#' Darwin lintr object, using default lintr object with camelCase
#'
#' @import lintr
#' @export
#'
#' @examples
#' darwinLint()
darwinLintPackage <- function() {
  tryCatch({
    lintr::lint_package(
      path = ".",
      linters = lintr::linters_with_defaults(
        lintr::object_name_linter(styles = "camelCase")))
  }, error = function(e) {
    stop("Error was caught during the linting of your package. The package
         might be to large to lint all together. Use: lintFile(fileName)")
  })
}

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
