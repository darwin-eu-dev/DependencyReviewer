#' getDefaultPermittedpackages
#'
#' @return tibble of two columns (package, version) with all 'allowed'
#' packages.
#'
#' @export
#'
#' @examples
#' getDefaultPermittedPackages()
getDefaultPermittedPackages <- function() {
  permittedDependencies <- readr::read_csv(
    system.file(
      "extdata",
      "dependencies.csv",
      package = "DependencyReviewer"),
    show_col_types = FALSE)

  return(permittedDependencies)
}
