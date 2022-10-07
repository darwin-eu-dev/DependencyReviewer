#' Summarise functions used in R package
#'
#'Deprecated
#'
#' @import funspotr
#' @import here
#' @import dplyr
#'
#' @return tibble
DEP_summariseFunctionUse <- function() {
  r_files <- list.files(here::here("R"))
  deps_used <- list()

  for(i in 1:length(r_files)) {
    deps_used[[i]] <- funspotr::spot_funs(
      file_path = here::here("R",r_files[[i]]),
      show_each_use = TRUE)
  }

  deps_used<-dplyr::bind_rows(deps_used) %>%
    dplyr::group_by(funs, pkgs) %>%
    dplyr::tally() %>%
    dplyr::arrange(desc(n))

  return(deps_used)
}


#' funsUsedInLine
#'
#'Support function for funsUsedInFile
#'
#' @import stringr
#' @import dplyr
#' @import glue
#'
#' @param file_txt file to use
#' @param file_name name of file
#' @param i line
#' @param verbose Prints message when no function found
#'
#' @return data.frame of 3 colums: Package (pkg); Function (fun); Line in
#' script (line)
funsUsedInLine <- function(file_txt, file_name, i, verbose=FALSE) {
  line <- file_txt[i]

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

    # defaultLibs <- rownames(installed.packages(priority="base"))

    df$r_file <- rep(file_name, dim(df)[1])
    df$line <- rep(i, dim(df)[1])
    return(dplyr::tibble(df))

  } else {
    if(verbose == TRUE) {
      message(glue::glue("No functions found for line: ", i))
    }
  }
}


#' funsUsedInFile
#'
#' @import dplyr
#' @import here
#'
#' @param files Files to get functions from
#' @param verbose Verbosity
#'
#' @return table
funsUsedInFile <- function(files, verbose = FALSE) {
  dplyr::bind_rows(lapply(X = files, FUN = function(file) {
    if(verbose) {
      message(glue::glue("Started on file: ", file))
    }

    file_txt <- readLines(here::here("R", file))

    out <- sapply(
      X = 1:length(file_txt),
      FUN = funsUsedInLine,
      file_txt = file_txt,
      file_name = file)
  }))
}

#' Summarise functions used in R package
#'
#' @param r_files r_files
#' @param verbose Default: FALSE; prints message to console which file is
#' currently being worked on.
#'
#' @import dplyr
#' @export
#' @return tibble
summariseFunctionUse <- function(r_files, verbose = FALSE) {
  deps_used <- funsUsedInFile(r_files, verbose)

  if (nrow(deps_used) == 0) {
    deps_used <- tibble(
      r_file = character(0),
      line = numeric(0),
      pkg = character(0),
      fun = character(0))
  }

  deps_used <- dplyr::bind_rows(deps_used) %>%
    dplyr::relocate(r_file, line, pkg, fun) %>%
    dplyr::arrange(r_file, line, pkg, fun)

  deps_used$pkg[deps_used$fun %in% ls("package:base")] <- "base"
  return(deps_used)
}
