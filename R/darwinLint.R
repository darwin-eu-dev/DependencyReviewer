#' darwinLint
#'
#' Darwin lintr object, using default lintr object with camelCase.
#'
#' @import lintr
#' @export
#'
#' @examples
#' darwinLint()
darwinLint <- function() {
  lintr::lint_package(
    path = ".",
    linters = lintr::linters_with_defaults(
      lintr::object_name_linter(styles = "camelCase")))
}
