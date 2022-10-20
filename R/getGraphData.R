#' getGraphData
#'
#' @return net_data graph data
#' @import pak
#' @import dplyr
#' @import tidygraph
#'
#' @export
#'
getGraphData <- function(path = here::here(), excluded_packages = c("")) {
  # Get all dependencies using pak
  data <- pak::local_deps(path, dependencies = TRUE)

  # Filter data
  fData <- data %>% dplyr::filter(!package %in% excluded_packages)

  sapply(
    X = 1:nrow(fData),
    FUN = function(row) {
      fData[["deps"]][[row]] <- fData[["deps"]][[row]] %>%
        filter(!package %in% excluded_packages)
    })

  # Reformat dependencies to long format
  pkg_deps <- dplyr::bind_rows(lapply(X = 1:nrow(fData), FUN = function(row) {
    deps <- unique(unlist(fData[row, ]["deps"]))

    pkg <- unlist(rep(fData[row, ]["package"], length(deps)))
    dplyr::tibble(pkg = pkg, deps = deps)
  }))

  # Filter for just package names
  pkg_deps <- pkg_deps %>%
    dplyr::filter(grepl(
      pattern = "[a-z]+",
      x = tolower(deps)))

  # Convert tibble to graph
  net_data <- tidygraph::as_tbl_graph(
    x = pkg_deps,
    directed = TRUE)
}

