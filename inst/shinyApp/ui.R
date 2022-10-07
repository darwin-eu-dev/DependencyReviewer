# Shiny UI
shiny::shinyUI(
  shiny::fluidPage(
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
          choices = list.files(here::here("R"))),

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
          )
        )
      )
    )
  )
)
