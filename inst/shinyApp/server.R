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
  readFile <- shiny::reactive({
    if(input$file != "ALL") {
    paste(
      readLines(here::here("R", input$file)),
      collapse = "\n")
      }
  })

  # UpdateAceEditor
  observe({
    shinyAce::updateAceEditor(
      editorId = "ace",
      session = session,
      value = readFile())
  })

  # Set output for table with filter
  output$tbl <- DT::renderDataTable({
    if(input$file == "ALL") {
      DependencyReviewer::summariseFunctionUse(
        r_files = list.files(here::here("R"))) %>%
        filter(!pkg %in% input$excludes)
    } else {
      DependencyReviewer::summariseFunctionUse(
        r_files = input$file) %>%
        dplyr::select(-"r_file") %>%
        filter(!pkg %in% input$excludes)
    }
  })

  getData <- reactive({
    if(input$file == "ALL") {
      DependencyReviewer::summariseFunctionUse(
        r_files = list.files(here::here("R")))
    } else {
      DependencyReviewer::summariseFunctionUse(
        r_files = input$file)
    }
  })

  # Exclude packages
  observe({
    updateCheckboxGroupInput(
      inline = TRUE,
      session = session,
      inputId = "excludes",
      choices = unique(getData()$pkg))
  })

  output$plot <- renderPlot(
    height = 1080,
    expr = {
      data <- getData()

      data_sub <- data %>%
        dplyr::group_by(fun, pkg) %>%
        dplyr::tally() %>%
        dplyr::arrange(desc(n)) %>%
        filter(!pkg %in% input$excludes)

      ggplot2::ggplot(
        data = data_sub,
        mapping = ggplot2::aes(x = fun, y = n, fill = pkg)) +
        ggplot2::geom_col() +
        ggplot2::facet_wrap(
          vars(pkg),
          scales = "free_x",
          ncol=2) +
        ggplot2::theme_bw() +
        ggplot2::theme(
          legend.position = "none",
          axis.text.x = (ggplot2::element_text(
            angle = 45,
            hjust = 1,
            vjust = 1)))
  })

  graphData <- reactive({
    DependencyReviewer::getGraphData(
      excluded_packages = input$excludes_all)
    # "Not all packages are availible,
    # check the console for more information."
  })

  observe({
    updateSliderInput(
      session = session,
      inputId = "nPkgs",
      value = input$nPkgsNum,
      max = length(igraph::V(graphData())))
  })

  observe({
    updateNumericInput(
      session = session,
      inputId = "nPkgsNum",
      value = input$nPkgs,
      max = length(igraph::V(graphData())))
  })

  output$graph <- renderPlot({
    shiny::withProgress(
      message = "Creating graph",
      min = 0,
      max = 2,
      expr = {
        shiny::incProgress(
          amount = 1,
          message = "Fetching Dependency Data")

        graph <- graphData()

        shiny::incProgress(
          amount = 2,
          message = "Plotting Dependencies in Graph")

        fEdge <- graph %>% tidygraph::activate(edges) %>% dplyr::pull(from)
        tEdge <- graph %>% tidygraph::activate(edges) %>% dplyr::pull(to)

        pFrom <- fEdge[fEdge <= input$nPkgs]
        pTo <- tEdge[fEdge <= input$nPkgs]

        if(input$model %in% c("kk", "fr", "lgl")) {
          shinyjs::enable("iter")
          shinyjs::enable("nPkgs")
          shinyjs::enable("nPkgsNum")

          g <- ggraph::ggraph(
            graph,
            layout = input$model,
            maxiter = input$iter) +
            ggraph::geom_node_text(
              mapping = ggplot2::aes(
                filter = name %in% names(igraph::V(graph)[unique(c(pFrom, pTo))]),
                label = name),
              size = 5,
              colour = "red") +
            ggraph::geom_edge_fan(
              mapping = ggplot2::aes(
                filter = from %in% pFrom & to %in% pTo))
        } else if(input$model %in% c("drl", "stress", "graphopt")) {
          shinyjs::enable("nPkgs")
          shinyjs::enable("nPkgsNum")
          shinyjs::disable(id = "iter")

          g <- ggraph::ggraph(
            graph,
            layout = input$model) +
            ggraph::geom_node_text(
              mapping = ggplot2::aes(
                filter = name %in% names(igraph::V(graph)[unique(c(pFrom, pTo))]),
                label = name),
              size = 5,
              colour = "red") +
            ggraph::geom_edge_fan(
              mapping = ggplot2::aes(
                filter = from %in% pFrom & to %in% pTo))
        } else if(input$model == "dendrogram") {
          shinyjs::disable(id = "iter")
          shinyjs::disable(id = "nPkgs")
          shinyjs::disable(id = "nPkgsNum")

          g <- ggraph::ggraph(
            graph = graph,
            layout = input$model,
            circular = TRUE) +
            ggraph::geom_edge_diagonal() +
            ggraph::geom_node_text(
              check_overlap = TRUE,
              mapping = ggplot2::aes(
                x = x * 1.005,
                y = y * 1.005,
                label = name,
                angle = -((-ggraph::node_angle(x, y) + 90) %% 180) + 90),
              size = 5,
              colour = "red",
              hjust = 'outward')
        }
        g + ggplot2::coord_fixed() +
          ggplot2::theme_void()
      })
    })
})
