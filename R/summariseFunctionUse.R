#' Summarise functions used in R package
#'
#'Deprecated
#'
#' @return tibble
#'
#' @examples
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
#' @param file_txt file to use
#' @param i line
#' @param verbose Prints message when no function found
#'
#' @return data.frame of 3 colums: Package (pkg); Function (fun); Line in
#' script (line)
#'
#' @examples
funsUsedInLine <- function(file_txt, i, verbose=FALSE) {
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

    df$pkg[df$fun %in% ls("package:base")] <- "base"
    df$pkg[df$fun %in% ls("package:methods")] <- "methods"


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
#' @param files
#'
#' @return table
#' @export
#'
#' @examples
funsUsedInFile <- function(files) {
  dplyr::bind_rows(lapply(X = files, FUN = function(file) {
    file_txt <- readLines(here::here("R", file))
    sapply(1:length(file_txt), funsUsedInLine, file_txt = file_txt)
  }))
}

#' Summarise functions used in R package
#'
#'Deperecated
#'
#' @return tibble
#'
#' @examples
summariseFunctionUse <- function(r_files) {
  deps_used <- funsUsedInFile(r_files)

  deps_used <- dplyr::bind_rows(deps_used) %>%
    dplyr::group_by(fun, pkg, line) %>%
    dplyr::tally() %>%
    dplyr::arrange(desc(n))

  return(deps_used)
}
