# === Helper functions
#' getDiffVersions
#'
#' @import dplyr
#'
#' @param dependencies Dependencies
#' @param permittedPackages permittedPackages
#'
#' @return Versions of permitted packages
getDiffVersions <- function(dependencies, permittedPackages) {
  permittedPackages %>%
    dplyr::filter(!is.na(version)) %>%
    dplyr::rename("version_rec"="version") %>%
    dplyr::left_join(
      dependencies,
      by = c("package")) %>%
    dplyr::filter("version_rec" != "version")
}

#' getNotPermitted
#'
#' @import dplyr
#'
#' @param dependencies Dependencies
#' @param permittedPackages Packages that are permitted as character vector
#'
#' @return Returns vector of not permitted packages
getNotPermitted <- function(dependencies, permittedPackages) {
  # check if dependencies are permitted
  not_permitted <- dependencies %>%
    dplyr::filter(package != "R") %>%
    dplyr::anti_join(
      permittedPackages,
      by = "package") %>%
    dplyr::select(.data$package) %>%
    dplyr::arrange(.data$package) %>%
    dplyr::pull()
}

# --- Message functions
#' messagePermission
#'
#' @import cli
#'
#' @param i iterator
#' @param not_permitted Not permitted
messagePermission <- function(i, not_permitted) {
  cli::cli_alert("  {.pkg {i}) {not_permitted[i]}}")
}

#' messagePackageVersion
#'
#' @import cli
#'
#' @param i iterator
#' @param diffVersions different versions
messagePackageVersion <- function(i, diffVersions) {
  cli::cli_alert("  {.pkg {i}) {diffVersions[i]}}")
  cli::cli_alert("    {.pkg currently required: {diffVersions$version[i]}}")
  cli::cli_alert("    {.pkg should be: {diffVersions$version_rec[i]} }")
}

#' Check package dependencies
#'
#' @import dplyr
#' @import cli
#'
#' @param packageName Name of package to profile. If NULL current package
#' @param dependencyType Imports, depends, and/ or suggests
#'
#' @export
checkDependencies <- function(packageName = NULL,
                              dependencyType = c("Imports", "Depends")) {

  # find dependencies
  if(is.null(packageName)) {
    description <-  desc::description$new()
  } else {
    description <- desc::description$new(package = packageName)
  }

  dependencies <- description$get_deps() %>%
    dplyr::filter(.data$type %in% .env$dependencyType) %>%
    dplyr::select("package", "version")

  # dependencies that are permitted
  permittedPackages <- getDefaultPermittedPackages()

  not_permitted <- getNotPermitted(dependencies, permittedPackages)

  n_not_permitted <- length(not_permitted)

  # message
  cli::cli_h2(
    "Checking if package{?s} in {dependencyType} have been approved")

  if(n_not_permitted == 0) {
    cli::cli_alert_success(
      "{.strong All package{?s} in {dependencyType} are  already approved}")
  } else {
    cli::cli_div(theme = list(.alert = list(color = "red")))
    cli::cli_alert_warning(
      "Found {n_not_permitted} package{?s} in {dependencyType} that are not
      approved")
    cli::cli_end()

    sapply(
      X = 1:n_not_permitted,
      FUN = messagePermission,
      not_permitted = not_permitted)

    cli::cli_alert_warning(
    "Please open an issue at https://github.com/darwin-eu/IncidencePrevalence
    to request approval for packages (one issue per package).")
    }

  # check if different version in current compared to recommended
  diffVersions <- getDiffVersions(
    dependencies = dependencies,
    permittedPackages = permittedPackages)

  n_diffVersions <- length(diffVersions$package)

  #message
  cli::cli_h2(
    "Checking if package{?s} in {dependencyType} require recommended version")

  if(n_diffVersions == 0){
    cli::cli_alert_success(
      "Success! No package{?s} in {dependencyType} require a different
      version")
  } else {
    cli::cli_div(theme = list (.alert = list(color = "red")))
    cli::cli_alert_warning(
      "Found {n_diffVersions} package{?s} in {dependencyType} with a different
      version required")
    cli::cli_end()

    sapply(
      X = 1:n_diffVersions,
      FUN = messagePackageVersion,
      diffVersions = diffVersions)

    cli::cli_alert_warning("Please require recommended versions")
  }
invisible(NULL)
}
