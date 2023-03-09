#' countLines
#'
#' Counts the lines of a list of files
#'
#' @param files
#'
#' @return
#' @export
#'
#' @examples
countLines <- function(files) {
  sum(unlist(lapply(files, function(file) {
    length(readLines(file, warn = FALSE))
  })))
}

#' countPackageLines
#'
#' Counts the lines of files ending with a specific extension.
#'
#' @param path Path to package
#' @param fileEx File extensions to search for, is case sensitive.
#'
#' @import dplyr
#'
#' @return Tibble
#' @export
countPackageLines <- function(path, fileEx = c("R", "cpp", "sql", "java")) {
  filesList <- lapply(fileEx, function(ex) {
    normalizePath(list.files(
      path = path,
      pattern = paste0("\\.", ex, "$"),
      full.names = TRUE,
      recursive = TRUE))
  })

  names(filesList) <- fileEx

  dplyr::bind_rows(lapply(filesList, function(files) {
    countLines(files)
  })) %>% mutate(package = basename(path))
}
