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

# Shiny Server
#' Title
#'
#' @param input
#' @param output
#' @param session
#'
#' @importFrom shiny shinyServer, observe, reactive, updateCheckboxGroupInput
#' @import shinyAce
#' @import ggplot2
#' @import here
#' @import DT
#' @import ggplot2
#' @import dplyr

#'
#' @return
#'
#' @examples
shinyServer(function(input, output, session) {
  readFile <- shiny::reactive({
    paste(
      readLines(here::here("R", input$file)),
      collapse = "\n")
  })

  observe({
    shinyAce::updateAceEditor(
      editorId = "ace",
      session = session,
      value = readFile())
  })

  output$tbl <- DT::renderDataTable({
    DependencyReviewer::summariseFunctionUse(
      r_files = input$file) %>%
      dplyr::select(-"r_file") %>%
      filter(!pkg %in% input$excludes)
  })

  getData <- reactive({
    DependencyReviewer::summariseFunctionUse(
      r_files = input$file)
  })

  observe({
    updateCheckboxGroupInput(
      inline = TRUE,
      session = session,
      inputId = "excludes",
      choices = unique(getData()$pkg))
  })

  output$plot <- renderPlot({
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
})
