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

#' getDefaultPermittedPackages
#'
#' Gets permitted packages
#'
#' @return tibble of two columns (package, version) with all 'allowed'
#' packages.
#'
#' @import readr
#' @import utils
#' @import pak
#' @importFrom pkgdepends new_pkg_deps
#'
#' @export
#' @examples
#' # Run only in interactive session
#' if (interactive()) {
#'   getDefaultPermittedPackages()
#' }
#'
getDefaultPermittedPackages <- function() {
  tmpFile <- list.files(
    path = tempdir(),
    pattern = "tmpPkgs*",
    full.names = TRUE
  )

  if (length(tmpFile) > 0) {
    message("Get from temp file")
    return(dplyr::tibble(utils::read.csv(tmpFile)))
  } else {
    # Create tmp file
    tmpFile <- tempfile(
      pattern = "tmpPkgs",
      tmpdir = tempdir(),
      fileext = ".csv"
    )

    permittedDependencies <- utils::read.table(
      file = "https://raw.githubusercontent.com/mvankessel-EMC/DependencyReviewerWhitelists/main/dependencies.csv",
      sep = ",",
      header = TRUE) %>%
      dplyr::tibble()

    # Get base packages
    basePackages <- data.frame(utils::installed.packages(
      lib.loc = .Library,
      priority = "high"
    )) %>%
      dplyr::select(.data$Package, .data$Built) %>%
      dplyr::rename(package = .data$Package, version = .data$Built) %>%
      dplyr::tibble()

    # Get Tidyverse packages
    tidyversePackages <- utils::read.table(
      file = "https://raw.githubusercontent.com/mvankessel-EMC/DependencyReviewerWhitelists/main/TidyverseDependencies.csv",
      sep = ",",
      header = TRUE) %>%
      dplyr::tibble()

    # Get HADES packages
    hadesPackages <- utils::read.table(
      file = "https://raw.githubusercontent.com/OHDSI/Hades/main/extras/packages.csv",
      sep = ",",
      header = TRUE) %>%
      dplyr::select(.data$name) %>%
      dplyr::mutate(version = rep("*", length(names))) %>%
      dplyr::rename(package = .data$name) %>%
      dplyr::tibble()

    hadesPackages$package <- paste0("OHDSI/", hadesPackages$package)

    sourcePackages <- dplyr::bind_rows(
      tidyversePackages,
      hadesPackages,
      permittedDependencies
    )

    depList <- pak::pkg_deps(sourcePackages$package)

    permittedPackages <- dplyr::bind_rows(
      basePackages,
      depList %>%
        dplyr::select(.data$package, version))

    message("Writing temp file")
    utils::write.csv(
      x = permittedPackages,
      file = tmpFile
    )
    return(permittedPackages)
  }
}
