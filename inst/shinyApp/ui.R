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

# Shiny UI
shiny::shinyUI(
  shiny::fluidPage(
    shinyjs::useShinyjs(),
    title = shiny::titlePanel(
      title = "Dependency Reviewer",
      windowTitle = TRUE),
    shiny::verticalLayout(
      fluid = TRUE,

      shiny::inputPanel(
        width = 3,
        shiny::selectInput(
          inputId = "file",
          label = "File",
          choices = c("ALL", list.files(here::here("R")))),

        shiny::checkboxGroupInput(
          inline = TRUE,
          inputId = "excludes",
          label = "Exclude Packages",
          choices = c("base", "unknown"))
      ),

      mainPanel = shiny::mainPanel(
        width = 12,
        shiny::tabsetPanel(
          type = "tabs",
          tabPanel(
            title = "Function Review",
            fluidRow(
              splitLayout(
                cellWidths = c("50%", "50%"),
                DT::dataTableOutput(
                  outputId = "tbl"),
                shinyAce::aceEditor(
                  outputId = "ace",
                  value = "x <- 3\n\nif(x == 3) {\n\ty <- 'a'}",
                  cursorId = "cursor",
                  selectionId = "selection",
                  mode = "r",
                  readOnly = TRUE)
              )
            )
          ),
        tabPanel(
          "Plot",
          shiny::plotOutput("plot")
          ),
        tabPanel(
          "Dependency Graph",
          shiny::sidebarLayout(
            sidebarPanel = shiny::sidebarPanel(width = 2,
              shiny::selectInput(
                inputId = "model",
                label = "Layout",
                choices = c(
                  "kk",
                  "drl",
                  "stress",
                  "fr",
                  "lgl",
                  "graphopt",
                  "dendrogram"),
                selected = "kk"),

              shiny::numericInput(
                inputId = "iter",
                label = "Iterations",
                value = 1000),

              shiny::sliderInput(
                inputId = "nPkgs",
                label = "Number of Dependency layers",
                min = 1,
                max = 100,
                value = 10),

              shiny::numericInput(
                inputId = "nPkgsNum",
                label = "Numeric: ",
                min = 1,
                max = 100,
                value = 10)
              ),

            mainPanel = shiny::mainPanel(
              shiny::plotOutput(
                outputId = "graph",
                height = "60em",
                width = "60em")
            )
          )
          )
        )
      )
    )
  )
)
