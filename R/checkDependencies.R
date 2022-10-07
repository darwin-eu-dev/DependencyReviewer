# Copyright 2022 DARWIN EU®
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

#' getDiffVersions
#'
#' Helper function
#'
#' @import dplyr
#'
#' @param dependencies Dependencies
#' @param permittedPackages permittedPackages
#'
#' @return Versions of permitted packages
#'
#' @examples
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
#' Helper function
#'
#' @import dplyr
#'
#' @param dependencies Dependencies
#' @param permittedPackages Packages that are permitted as character vector
#'
#' @return Returns vector of not permitted packages
#'
#' @examples
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

#' messagePermission
#'
#' Helper message function
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
#' Helper message function
#'
#' @import cli
#'
#' @param i iterator
#' @param diffVersions different versions
#'
#' @examples
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
#'
#' @return
#'
#' @examples
checkDependencies <- function(
    packageName = NULL,
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
