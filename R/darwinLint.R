#' darwinLintPackage
#'
#' Darwin lintr object, using default lintr object with camelCase
#'
#' @param path Default: ".", Path to package
#'
#' @return List of lint objects.
#' @import lintr
#' @export
#'
#' @examples
#' darwinLintPackage()
darwinLintPackage <- function(path = ".") {
  tryCatch({
    lintr::lint_package(
      path = path,
      linters = lintr::linters_with_defaults(
        lintr::object_name_linter(styles = "camelCase")))
  }, error = function(e) {
    cli::cli_alert_danger(e)
    stop(
    "Error was caught during the linting of your package. The package
    might be to large to lint all together. Use: darwinLintFile(fileName)")
  })
}


#' darwinLintFile
#'
#' Lint a given file.
#'
#' @return list of lint objects.
#'
#' @import lintr
#'
#' @param fileName Path to file to lint
#'
#' @export
#'
#' @examples
#' darwinLintFile(
#'   fileName = system.file(package = "DependencyReviewer", "testScript.R")
#' )
darwinLintFile <- function(fileName) {
  lintr::lint(
    filename = fileName,
    linters = lintr::linters_with_defaults(
      lintr::object_name_linter(styles = "camelCase")
    )
  )
}


#' darwinLintScore
#'
#' Function that scores the lintr output as a percentage per message type
#' (style, warning, error). Lintr messages / lines assessed * 100
#'
#' @param lintFunction
#'     Lint function to use
#' @param ...
#'     Other parameters a Lint function might need (i.e. file name)
#' @return
#'     A tibble of percentage scores per type of Lint message.
#' @export
#' @examples
#' # With darwin file lintr
#' darwinLintScore(
#'   lintFunction = darwinLintFile,
#'   system.file(package = "DependencyReviewer", "testScript.R")
#' )
#'
#' # With standard package lintr
#' darwinLintScore(
#'   lintFunction = lintr::lint_package,
#'   system.file(package = "DependencyReviewer")
#' )
darwinLintScore <- function(lintFunction, ...) {
  lintTable <- data.frame(lintFunction(...))

  files <- unique(paste0(
    unique(lintTable$filename)
  ))

  nLines <- sum(unlist(lapply(
    X = files,
    FUN = function(file) {
      suppressWarnings(length(readLines(file)))
    }
  )))

  pct <- lintTable %>%
    dplyr::group_by(.data$type) %>%
    dplyr::tally() %>%
    dplyr::summarise(.data$type, pct = round(n / nLines * 100, 2))

  if (nrow(pct) == 0) {
    cli::cli_alert_info(cli::col_green(
      "{nrow(pct)} Lintr messages found"
    ))
  } else {
    invisible(lapply(X = seq_len(nrow(pct)), FUN = function(i) {
      if (pct[i, 1] == "error") {
        cli::cli_alert_info(cli::col_red(
          "{pct[i, 1]}: {pct[i, 2]}% of lines of code have linting messages"
        ))
      } else if (pct[i, 1] == "warning") {
        cli::cli_alert_info(cli::col_yellow(
          "{pct[i, 1]}: {pct[i, 2]}% of lines of code have linting messages"
        ))
      } else if (pct[i, 1] == "style") {
        cli::cli_alert_info(cli::col_blue(
          "{pct[i, 1]}: {pct[i, 2]}% of lines of code have linting messages"
        ))
      } else {
        cli::cli_alert_info(cli::col_magenta(
          "{pct[i, 1]}: {pct[i, 2]}% of lines of code have linting messages"
        ))
      }
    }))
  }
  return(pct)
}
