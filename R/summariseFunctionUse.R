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


#' funsUsedInLine
#'
#' Support function for funsUsedInFile.
#'
#' @import stringr
#' @import dplyr
#'
#' @param file_txt file to use
#' @param file_name name of file
#' @param i line
#' @param verbose Prints message when no function found
#'
#' @return data.frame of 3 colums: Package (pkg); Function (fun); Line in
#' script (line)
funsUsedInLine <- function(file_txt, file_name, i, verbose = FALSE) {
  line <- file_txt[i]
  if (!startsWith(line, "#")) {
    line <- paste(stringr::str_split(
        string = line,
        pattern = "\\w+\\$",
        simplify = TRUE),
      collapse = "")

    fun_vec <- unlist(stringr::str_extract_all(
      string = line,
      pattern = "(\\w+::(?:\\w+\\.)?\\w+\\(|(?:\\w+\\.)?\\w+\\()"))

    fun_vec <- stringr::str_remove_all(
      string = fun_vec,
      pattern = "\\(")

    fun_vec <- stringr::str_split(
      string = fun_vec,
      pattern = "::")

    if(length(fun_vec) > 0) {
      fun_vec <- lapply(
        X = fun_vec,
        FUN = function(x) {
          if(length(x) == 1) {
            x <- list("unknown", x)
          } else {
            list(x)
          }
        })

      df <- data.frame(t(sapply(fun_vec, unlist)))
      names(df) <- c("pkg", "fun")

      df$r_file <- rep(basename(file_name), dim(df)[1])
      df$line <- rep(i, dim(df)[1])
      return(dplyr::tibble(df))

    } else {
      if(verbose == TRUE) {
        message(paste0("No functions found for line: ", i))
      }
    }
  }
}


#' funsUsedInFile
#'
#' Support function
#'
#' @import dplyr
#'
#' @param files Files to get functions from
#' @param verbose Verbosity
#'
#' @return table
funsUsedInFile <- function(files, verbose = FALSE) {
  dplyr::bind_rows(lapply(X = files, FUN = function(file) {
    if(verbose) {
      message(paste0("Started on file: ", file))
    }
    file_txt <- readLines(file)

    out <- sapply(
      X = 1:length(file_txt),
      FUN = funsUsedInLine,
      file_txt = file_txt,
      file_name = file)
  }))
}

#' summariseFunctionUse
#'
#' Summarise functions used in R package
#'
#' @param r_files Complete path(s) to files to be investigated
#' @param verbose Default: FALSE; prints message to console which file is
#' currently being worked on.
#'
#' @import dplyr
#'
#' @return tibble
#'
#' @export
#' @examples
#' summariseFunctionUse(
#'   r_files = system.file(package = "DependencyReviewer", "testScript.R"))
#'
#' # Only in an interactive session
#' if (interactive()) {
#'   summariseFunctionUse(list.files(here::here("R"), full.names = TRUE))
#' }
summariseFunctionUse <-
  function(r_files,
           verbose = FALSE) {
    #tryCatch({
    deps_used <- funsUsedInFile(r_files, verbose)
    # }, error = function(e) {
    #   stop(paste(r_files, "not found"))
    # })

    if (nrow(deps_used) == 0) {
      warning("No functions found, output will be empty")
      deps_used <- dplyr::tibble(
        r_file = character(0),
        line = numeric(0),
        pkg = character(0),
        fun = character(0)
      )
    }

    deps_used <- dplyr::bind_rows(deps_used) %>%
      dplyr::relocate(.data$r_file, .data$line, .data$pkg, .data$fun) %>%
      dplyr::arrange(.data$r_file, .data$line, .data$pkg, .data$fun)

    deps_used$pkg[deps_used$fun %in% ls("package:base")] <- "base"
    return(deps_used)
  }

