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

#' getDefaultPermittedpackages
#'
#' Gets permitted packages
#'
#' @return tibble of two columns (package, version) with all 'allowed'
#' packages.
#'
#' @import readr
#'
#' @export
getDefaultPermittedPackages <- function() {
  permittedDependencies <- readr::read_csv(
    system.file(
      "extdata",
      "dependencies.csv",
      package = "DependencyReviewer"),
    show_col_types = FALSE)

  # Get base packages
  basePackages <- data.frame(installed.packages(priority = "base")) %>%
    dplyr::select(Package, Built) %>%
    dplyr::rename(package = Package, version = Built) %>%
    dplyr::tibble()

  # Get CRAN packages
  cranPackages <- data.frame(available.packages()) %>%
    dplyr::select(Package, Version) %>%
    dplyr::rename(package = Package, version = Version) %>%
    dplyr::tibble()

  # Get HADES packages
  hadesPackages <- read.table(
    file = "https://raw.githubusercontent.com/OHDSI/Hades/main/extras/packages.csv",
    sep = ",",
    header = TRUE) %>% select(name) %>%
    mutate(version = rep("*", length(names))) %>%
    rename(package = name) %>%
    tibble()

  permittedPackages <- dplyr::bind_rows(
    basePackages,
    cranPackages,
    hadesPackages,
    permittedPackages
  )

  return(permittedPackages)
}
