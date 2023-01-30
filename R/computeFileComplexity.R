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

#' computeFileComplexity
#'
#' Computes the complexity of a R, Java, or C++ file based on a point system.
#' The amount of points is the sum of the number of defined Functions;
#' Conditions used (if, else, while); iterators used (apply functions, for-
#' loops); switch-cases used; logical operators used (>, ==, <, etc.).
#'
#' @param filePath Path to the file to be investigated.
#' @param fileExtension Optional; Extension of the file. Supported types are:
#' 1) R, 2) java, 3) cpp. If left blank, the file extension of the file defined
#' in the filePath parameter is used.
#'
#' @return Returns a data.frame with the following columns: 1) file, name of
#' the file investigated; 2) lines, number of lines of the investigated file;
#' 3) complexity, complexity score.
#' @export
#'
#' @examples
#' filePath <- system.file(package = "DependencyReviewer", "testScript.R")
#' df <- computeFileComplexity(filePath)
computeFileComplexity <- function(filePath, fileExtension = "") {
  if (fileExtension == "") {
    fileExtension <- tail(
      x = unlist(stringr::str_split(basename(filePath), "\\.")),
      n = 1)
  }

  # Get patterns
  patterns <- getPatterns(fileExtension)

  # read in file
  lines <- readLines(filePath)

  complexity <- sum(unlist(lapply(
    X = patterns,
    FUN = function(pat) {
      sum(stringr::str_count(string = lines, pattern = unlist(pat)))
    }
  )))

  return(data.frame(
    file = basename(filePath),
    lines = length(lines),
    complexity = complexity))
}

#' getPatterns
#'
#' Gets one of the supported patterns: 1) R, 2) java, 2) cpp.
#'
#' @param type File type, one of 'R', 'java', 'cpp'.
#'
#' @return Returns a list of patterns
getPatterns <- function(type) {
  rPat <- list(
    rFun = "function[ ]?\\(",
    rCon = "(if[ ]?\\(|else[ ]?\\{|else if[ ]\\(|while[ ]?\\()",
    rIter = "(apply\\(|for[ ]?\\()",
    rSwitch = "switch[ ]?\\(",
    rLog = "((\\&\\&|\\&)|(\\|\\||\\|)|(>\\=|\\=\\=|<\\=)|>|<)")

  javaPat <- list(
    jFun = paste0(
      "(public|protected|private|static|\\s) ",
      "+[\\w\\<\\>\\[\\]]+\\s+(\\w+) ",
      "*\\([^\\)]*\\) *(\\{?|[^;])"
    ),
    jCon = rPat["rCon"],
    jIter = "for[ ]?\\(",
    jSwitch = rPat["rSwitch"],
    jLog = rPat["rLog"])

  cppPat <- list(
    cFun = paste0(
      "^\\s*(?:(?:inline|static)\\s+){0,2}(?!",
      "else|typedef|return)\\w+\\s+\\*?\\s*(\\w+)\\s*\\([^0]+\\)\\s*;?"
    ),
    cCon = rPat["rCon"],
    cIter = javaPat["jIter"],
    cSwitch = rPat["rSwitch"],
    cLog = rPat["rLog"])

  return(switch(
    grep(tolower(type), c("r", "java", "cpp")),
    rPat,
    javaPat,
    cppPat))
}
