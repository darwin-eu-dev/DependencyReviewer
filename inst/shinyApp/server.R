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

# Libraries
library(dplyr)

# Shiny Server
shinyServer(function(input, output, session) {
  # DependencyReviewer::darwinLintScore(DependencyReviewer::darwinLintPackage)
  readFile <- shiny::reactive({
    if (input$file != "ALL") {
      paste(readLines(paste0(.path, "/", input$file)),
            collapse = "\n")
    }
  })

  # UpdateAceEditor
  observe({
    shinyAce::updateAceEditor(editorId = "ace",
                              session = session,
                              value = readFile())
  })

  # Set output for table with filter
  output$tbl <- DT::renderDataTable({
    if (input$file == "ALL") {
      DependencyReviewer::summariseFunctionUse(r_files = list.files(.path, full.names = TRUE)) %>%
        filter(!pkg %in% input$excludes)
    } else {
      DependencyReviewer::summariseFunctionUse(r_files = paste0(.path, "/", input$file)) %>%
        dplyr::select(-"r_file") %>%
        filter(!pkg %in% input$excludes)
    }
  })

  getData <- reactive({
    if (input$file == "ALL") {
      DependencyReviewer::summariseFunctionUse(r_files = list.files(.path, full.names = TRUE))
    } else {
      DependencyReviewer::summariseFunctionUse(r_files = paste0(.path, "/", input$file))
    }
  })

  # Exclude packages
  observe({
    updateCheckboxGroupInput(
      inline = TRUE,
      session = session,
      inputId = "excludes",
      choices = unique(getData()$pkg)
    )
  })

  output$plot <- renderPlot(height = 1080,
                            expr = {
                              data <- getData()

                              data_sub <- data %>%
                                dplyr::group_by(fun, pkg) %>%
                                dplyr::tally() %>%
                                dplyr::arrange(desc(n)) %>%
                                filter(!pkg %in% input$excludes)

                              ggplot2::ggplot(data = data_sub,
                                              mapping = ggplot2::aes(x = fun, y = n, fill = pkg)) +
                                ggplot2::geom_col() +
                                ggplot2::facet_wrap(vars(pkg),
                                                    scales = "free_x",
                                                    ncol = 2) +
                                ggplot2::theme_bw() +
                                ggplot2::theme(legend.position = "none",
                                               axis.text.x = (ggplot2::element_text(
                                                 angle = 45,
                                                 hjust = 1,
                                                 vjust = 1
                                               )))
                            })

  graphData <- reactive({
    DependencyReviewer::getGraphData(
      excluded_packages = input$excludes_all,
      package_types = input$dep_kinds
    )
    # "Not all packages are availible,
    # check the console for more information."
  })

  observe({
    updateSliderInput(
      session = session,
      inputId = "nPkgs",
      value = input$nPkgsNum,
      max = length(igraph::V(graphData()))
    )
  })

  observe({
    updateNumericInput(
      session = session,
      inputId = "nPkgsNum",
      value = input$nPkgs,
      max = length(igraph::V(graphData()))
    )
  })

  output$graph <- renderPlot({
    shiny::withProgress(
      message = "Creating graph",
      min = 0,
      max = 2,
      expr = {
        shiny::incProgress(amount = 1,
                           message = "Fetching Dependency Data")

        graphData <- graphData()

        shiny::incProgress(amount = 2,
                           message = "Plotting Dependencies in Graph")

        cols <- factor(as.character(apply(
          X = igraph::distances(graphData, igraph::V(graphData)[1]),
          MARGIN = 2,
          FUN = max
        )))

        GGally::ggnet2(
          net = graphData,
          arrow.size = 6,
          arrow.gap = 0.025,
          label = TRUE,
          palette = "Set2",
          color.legend = "distance",
          color = cols,
          legend.position = "bottom",
          edge.alpha = 0.25
        )
      }
    )
  })

  observe({
    graphData <- graphData()

    options <- names(tail(igraph::V(graphData),-1))

    shiny::updateSelectInput(session = session,
                             inputId = "path_to_pkg",
                             choices = options)
  })

  output$graph_path <- renderPlot({
    graphData <- graphData()

    subV <- igraph::all_simple_paths(
      graph = graphData,
      from = igraph::V(graphData)[1],
      to = input$path_to_pkg,
      cutoff = input$cutoff
    )

    # Add to single graph
    graphSub <- lapply(
      X = subV,
      FUN = function(v) {
        igraph::induced_subgraph(graphData, v)
      }
    )

    # Union
    graphUnion <- do.call(igraph::union, graphSub)

    cols <- factor(as.character(apply(
      igraph::distances(graphUnion, names(igraph::V(graphData)[1])), 2, max
    )))

    # Plot graph
    GGally::ggnet2(
      net = graphUnion,
      arrow.size = 6,
      arrow.gap = 0.025,
      label = TRUE,
      palette = "Set2",
      color.legend = "distance",
      color = cols,
      legend.position = "bottom"
    )
  })

  # getLintrTable <- shiny::reactive({
  #   out <- DependencyReviewer::darwinLintScore(DependencyReviewer::darwinLintPackage)
  #   return(out)
  # })
  #
  # output$lintrTable <- DT::renderDataTable({
  #   shiny::withProgress(expr = {
  #     shiny::setProgress(value = 0, message = "Running Lintr on package")
  #
  #     out <- DT::datatable(getLintrTable())
  #
  #     shiny::setProgress(value = 1, message = "Supplying output in table")
  #   }, min = 0, max = 1)
  #   return(out)
  # })
})
