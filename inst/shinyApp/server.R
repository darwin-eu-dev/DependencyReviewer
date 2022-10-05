# Shiny Server
shiny::shinyServer(function(input, output, session) {
  # output$log <- renderText({
  #   req(input$ace_cursor)
  #   paste0(
  #     "Cursor position: row ", input$ace_cursor$row,
  #     ", column ", input$ace_cursor$col,
  #     "\nSelection: \"", input$ace_selection, "\""
  #   )
  # })

  readFile <- shiny::reactive({
    paste(
      readLines(here::here("R", input$file)),
      collapse = "\n")
  })

  shiny::observe({
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

  getData <- shiny::reactive({
    DependencyReviewer::summariseFunctionUse(
      r_files = input$file)
  })

  observe({
    shiny::updateCheckboxGroupInput(
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
