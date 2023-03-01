#' makeGraph
#'
#' Makes the graph
#'
#' @param funsPerDefFun Functions per defined function data.frame
#' @param width Width of diagram
#' @param height Height of diagram
#' @param pkgName Name of package
#' @param expFuns Exported functinos data.frame
#'
#' @import glue
#' @import DiagrammeR
#'
#' @return diagram of the package
makeGraph <- function(funsPerDefFun, width, height, pkgName, expFuns) {
  pkgDef <- funsPerDefFun %>%
    dplyr::filter(.data$fun %in% .data$name)

  graphSyntx <- unique(unlist(lapply(seq_len(nrow(pkgDef)), function(i) {
    glue::glue("'{pkgDef[i, ]$name}' -> '{pkgDef[i, ]$fun}'")
  })))

  DiagrammeR::grViz(
    diagram = paste0(
      "digraph {
  graph [layout = dot, rankdir = LR]
  node [shape = rectangle]
  Exported [shape = oval]
  Non_exported [shape = rectangle]",
      "subgraph cluster0 {label = <<B>Legend</B>> Exported -> Non_exported}",
      "subgraph cluster1 {label = <<B>", pkgName, "</B>> ",
      paste0(expFuns, " [shape = oval]", collapse = "\n"),
      paste0(graphSyntx, collapse = "\n"), "}",
      "}",
      collapse = "\n"),
    height = height,
    width = width)
}

#' getFunsPerDefFun
#'
#' Gets all function calls per defined function in the package.
#'
#' @param files Vector of files to investigate.
#' @param allFuns allFunctions data.frame
#' @param verbose Verbose messages
#'
#' @import dplyr
#'
#' @return returns data.frame of all functions per defined function of package.
getFunsPerDefFun <- function(files, allFuns, verbose) {
  dplyr::bind_rows(lapply(files, function(file) {
    defFuns <- DependencyReviewer::getDefinedFunctions(file, verbose = verbose)

    dplyr::bind_rows(lapply(seq_len(nrow(defFuns)), function(i) {
      allFuns %>%
        dplyr::filter(.data$r_file %in% defFuns$file) %>%
        dplyr::filter(
          .data$line >= defFuns$start[i] &
            .data$line <= defFuns$start[i] + defFuns$size[i]) %>%
        dplyr::mutate(name = defFuns$fun[i]) %>%
        dplyr::relocate(c("r_file", "name", "line", "pkg", "fun"))
    }))
  }))
}

#' getExportedFunctions
#'
#' Gets all the exported functions of a package, from NAMESPACE.
#'
#' @param path path to package
#'
#' @import glue
#' @import stringr
#'
#' @return vector of exported functions
getExportedFunctions <- function(path) {
  expFuns <- readLines(glue::glue("{path}/NAMESPACE"))

  expFuns <- unlist(stringr::str_extract_all(
    string = expFuns,
    pattern = "export\\(.+\\)"))

  expFuns <- unlist(stringr::str_extract_all(
    string = expFuns,
    pattern = "\\(\\w+\\)"))

  expFuns <- unlist(stringr::str_extract_all(
    string = expFuns,
    pattern = "\\w+"))

  return(expFuns)
}

#' pkgDiagram
#'
#' Creates a diagram of all defined functions in a package.
#'
#' @param pkgPath Path to package
#' @param width Width of diagram
#' @param height Height of diagram
#' @param verbose Verbose messages
#'
#' @import glue
#' @import dplyr
#'
#' @return diagram image
#' @export
#' @examples
#' if (interactive()) {
#'   pkgDiagram(
#'     pkgPath = "./",
#'     width = 1000,
#'     height = 4000,
#'     verbose = TRUE)
#' }
pkgDiagram <- function(pkgPath, width = 1000, height = 1000, verbose = FALSE) {
  path <- normalizePath(pkgPath)

  rPath <- glue::glue("{path}/R")

  files <- list.files(
    path = rPath,
    full.names = TRUE,
    recursive = TRUE)

  expFuns <- getExportedFunctions(path)

  allFuns <- DependencyReviewer::summariseFunctionUse(files)

  funsPerDefFun <- getFunsPerDefFun(files, allFuns, verbose)

  makeGraph(funsPerDefFun, width, height, basename(pkgPath), expFuns)
}


#' exportDiagram
#'
#' Exports the diagram from `pkgDiagram` to a PDF-file.
#'
#' @param diagram Graph object from the `pkgDiagram` function.
#' @param fileName Path to file, where to save the diagram to.
#'
#' @import DiagrammeRsvg
#' @import rsvg
#'
#' @return NULL
#' @export
#'
#' @examples
#' if (interactive()) {
#'   diagram <- pkgDiagram(
#'     pkgPath = "./",
#'     width = 1000,
#'     height = 4000,
#'     verbose = TRUE)
#'
#'   exportDiagram(
#'     diagram = diagram,
#'     "diagram.pdf")
#' }
exportDiagram <- function(diagram, fileName) {
  diagram %>%
    DiagrammeRsvg::export_svg() %>%
    charToRaw() %>%
    rsvg::rsvg_pdf(fileName)
}
