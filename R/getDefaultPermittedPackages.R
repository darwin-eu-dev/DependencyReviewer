getDefaultPermittedPackages <- function() {
  permittedDependencies <- readr::read_csv(
    system.file(
      "extdata",
      "dependencies.csv",
      package = "DependencyReviewer"),
    show_col_types = FALSE)

  return(permittedDependencies)
}
