testthat::test_that("runShiny server.R exists", {
  expect_true("server.R" %in% list.files(system.file(
    package = "DependencyReviewer", "shinyApp")))
})

testthat::test_that("runShiny ui.R exists", {
  expect_true("ui.R" %in% list.files(system.file(
    package = "DependencyReviewer", "shinyApp")))
})

testthat::test_that("runShiny class", {
  expect_s3_class(object = DependencyReviewer::runShiny(), class = "shiny.appobj")
})
