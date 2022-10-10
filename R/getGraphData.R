#' getGraphData
#'
#' @return
#' @export
#'
getGraphData <- function() {
  # Get all dependencies using pak
  data <- pak::local_dev_deps(dependencies = TRUE)

  # Reformat dependencies to long format
  pkg_deps <- dplyr::bind_rows(lapply(X = 1:nrow(data), FUN = function(row) {
    deps <- unique(unlist(data[row, ]["deps"]))

    pkg <- unlist(rep(data[row, ]["package"], length(deps)))
    dplyr::tibble(pkg = pkg, deps = deps)
  }))

  # Filter for just package names
  pkg_deps <- pkg_deps %>%
    dplyr::filter(grepl(
      pattern = "[a-z]+",
      x = tolower(deps)))

  # Convert tibble to graph
  net_data <- as_tbl_graph(
    x = pkg_deps,
    directed = TRUE)
}
