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

    # Get base packages
    basePackages <- data.frame(utils::installed.packages(
      lib.loc = .Library,
      priority = "high"
    )) %>%
      dplyr::select("Package", "Built") %>%
      dplyr::rename(package = "Package", version = "Built") %>%
      dplyr::tibble()

    # Get darwin whiteList
    permittedDependencies <- tryCatch({
       return(utils::read.table(
        file = "https://raw.githubusercontent.com/mvankessel-EMC/DependencyReviewerWhitelists/main/darwin.csv",
        sep = ",",
        header = TRUE) %>%
        dplyr::tibble())
    }, error = function(e) {
      return(NULL)
    }, warning = function(w) {
      return(NULL)
    })

    # Get Tidyverse whiteList
    tidyversePackages <- tryCatch({
       return(utils::read.table(
        file = "https://raw.githubusercontent.com/mvankessel-EMC/DependencyReviewerWhitelists/main/tidyverse.csv",
        sep = ",",
        header = TRUE) %>%
        dplyr::tibble())
    }, error = function(e) {
      return(NULL)
    }, warning = function(w) {
      return(NULL)
    })

    # Get HADES whiteList
    hadesPackages <- tryCatch({
      # Get HADES packages
      hadesPackages <- utils::read.table(
        file = "https://raw.githubusercontent.com/OHDSI/Hades/main/extras/packages.csv",
        sep = ",",
        header = TRUE) %>%
        dplyr::select("name") %>%
        dplyr::mutate(version = rep("*", length(names))) %>%
        dplyr::rename(package = "name") %>%
        dplyr::tibble()

      hadesPackages$package <- paste0("OHDSI/", hadesPackages$package)
      return(hadesPackages)
    }, error = function(e) {
      return(NULL)
    }, warning = function(w) {
      return(NULL)
    })

    sourcePackages <- dplyr::bind_rows(
      tidyversePackages,
      hadesPackages,
      permittedDependencies
    )

    if (nrow(sourcePackages) > 0) {
      depList <- pak::pkg_deps(sourcePackages$package)

      permittedPackages <- dplyr::bind_rows(
        basePackages,
        depList %>%
          dplyr::select("package", version))

      message("Writing temp file")
      utils::write.csv(
        x = permittedPackages,
        file = tmpFile
      )
      return(permittedPackages)
    } else {
      message(
        "Could not make a connection to online resources, please check your internet connection.")
      return(NULL)
    }
  }
}
