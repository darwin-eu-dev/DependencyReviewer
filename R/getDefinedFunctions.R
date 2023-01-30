# Copyright 2022 DARWIN EU®
#
# This file is part of DependencyReviewer
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

#' getDefinedFunctions
#'
#' Gets all the defined functions in a file, stored in a a tibble, with the
#' following columns: file (filename), start (start line in file), size (Amount
#' of lines occupied by function), fun (function name).
#'
#' @param filePath File path to the R-file to be investigated
#' @param verbose Prints message as to what file is currently being worked on.
#' Usefull if used in an apply funciton, investigating alot of different files.
#'
#' @import glue
#'
#' @return Returns a tibble object.
#' @export
#'
#' @examples
#' filePath <- system.file(package = "DependencyReviewer", "testScript.R")
#' df <- getDefinedFunctions(filePath)
getDefinedFunctions <- function(filePath, verbose = FALSE) {
  # Read lines
  lines <- readLines(filePath, warn = FALSE)

  if (verbose) {
    message(glue::glue("working on file: {basename(filePath)}"))
  }

  # Get defined functions
  constructorIndices <- grep(
    pattern = "\\w+[ ]?<\\-[ ]?function\\(",
    x = paste0(lines))

  funsRaw <- lines[constructorIndices]
  funNames <- stringr::str_extract(string = funsRaw, pattern = "[\\w\\d\\.]+")

  # Per function, get indices of body
  dplyr::bind_rows(lapply(
    X = seq_len(length(funNames)),
    FUN = function(i) {
      df <- getBodyIndices(constructorIndices[i], lines)
      df["fun"] <- funNames[i]
      df["size"] <- df["end"] - df["start"]
      df["file"] <- tail(unlist(stringr::str_split(filePath, "/")), 1)
      df <- df %>% select(c("file", "start", "size", "fun"))
      return(df)
    }))
}

#' getBodyIndices
#'
#' Helper function for getDefinedFunctions, retrieves offset indeces for where
#' the body of the function starts.
#'
#' @param line Line index of the function constructor.
#' @param lines All lines of the R-file to be investigated.
#'
#' @return Returns a data.frame with the start and end indices of lines.
getBodyIndices <- function(line, lines) {
  # Parameters
  switchOff <- FALSE

  # Get start of body
  startFunLine <- goToBody(line, lines)

  endFunLine <- startFunLine
  cntOpen <- 0
  cntClosed <- 0

  while (switchOff == FALSE) {
    checkOpen <- stringr::str_detect(string = lines[endFunLine], "\\{")
    checkClose <- stringr::str_detect(string = lines[endFunLine], "\\}")

    if (is.na(checkOpen) || is.na(checkClose)) {
      cntOpen <- max(c(cntOpen, cntClosed))
      cntClosed <- max(c(cntOpen, cntClosed))
    } else {
      if (checkOpen) {
        cntOpen <- cntOpen + 1
      }

      if (checkClose) {
        cntClosed <- cntClosed + 1
      }
    }

    if (cntOpen == cntClosed) {
      endFunLine <- endFunLine
      switchOff <- TRUE
    } else {
      endFunLine <- endFunLine + 1
    }
  }
  return(data.frame(start = startFunLine, end = endFunLine))
}

#' goToBody
#'
#' Helper function for getBodyIndices and getDefinedFunctions. Computes the
#' starting index of the function body.
#'
#' @param line Line number of the constructor of the function.
#' @param lines Lines of the R-file to be investigated.
#'
#' @return Returns a numeric index.
goToBody <- function(line, lines) {
  startFun <- FALSE
  line <- line
  while (startFun == FALSE) {
    checkOpen <- stringr::str_detect(string = lines[line], "\\{")
    if (checkOpen) {
      startFun <- TRUE
    } else {
      line <- line + 1
    }
  }
  return(line)
}
