# Shiny UI
shiny::shinyUI(
  shiny::pageWithSidebar(
    shiny::headerPanel("Dependency Reviewer"),

    shiny::sidebarPanel(
      shiny::selectInput(
        inputId = "file",
        label = "File",
        choices = list.files(here::here("R"))),

      shiny::checkboxGroupInput(
        inputId = "excludes",
        label = "Exclude Packages",
        choices = c("base", "unknown")),

      shiny::hr(),
      DT::dataTableOutput("tbl")
    ),

    shiny::mainPanel(
      shinyAce::aceEditor(
        outputId = "ace",
        value = "x <- 3\n\nif(x == 3) {\n\ty <- 'a'}",
        cursorId = "cursor",
        selectionId = "selection",
        mode = "r",
        readOnly = TRUE,
      ),
      width = 6,
      shiny::plotOutput("plot")
    )
  )
)
