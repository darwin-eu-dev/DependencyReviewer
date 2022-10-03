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
      dplyr::select(-"r_file")
  })

  output$plot <- renderPlot({
    data <- DependencyReviewer::summariseFunctionUse(
      r_files = input$file)

    ggplot2::ggplot(
      data = data %>%
        dplyr::group_by(fun, pkg) %>%
        dplyr::tally() %>%
        dplyr::arrange(desc(n)),
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
