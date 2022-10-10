testthat::test_that("summariseFunctionUse one file type", {
  testthat::expect_type(
    object = summariseFunctionUse(
      r_files = "checkDependencies.R",
      in_package = TRUE),
    type = "list")
})

testthat::test_that("summariseFunctionUse multiple files type", {
  r_files <- list.files(here::here("R"))

  testthat::expect_type(
    object = summariseFunctionUse(
      r_files = r_files,
      in_package = TRUE),
    type = "list")
})

testthat::test_that("summariseFunctionUse invalid file", {
  # Suppress Warning, only interested in Error
  testthat::expect_error(
    object = suppressWarnings(summariseFunctionUse(
      r_files = "someRandomFile.R",
      in_package = TRUE)),
    regexp = "\\w+\\.R not found")
})

testthat::test_that("summariseFunctionUse no file", {
  testthat::expect_error(
    object = summariseFunctionUse(),
    regexp = "argument .+ is missing.+")
})

testthat::test_that("summariseFunctionUse no file, verbose", {
  testthat::expect_error(
    object = summariseFunctionUse(verbose = TRUE),
    regexp = "argument .+ is missing.+")
})

testthat::test_that("summariseFunctionUse no file, in_package = FALSE", {
  testthat::expect_error(
    object = summariseFunctionUse(in_package = FALSE),
    regexp = "argument .+ is missing.+")
})

testthat::test_that("summariseFunctionUse no file, in_package, VERBOSE", {
  testthat::expect_error(
    object = summariseFunctionUse(verbose = TRUE, in_package = FALSE),
    regexp = "argument .+ is missing.+")
})

testthat::test_that("summariseFunctionUse verbose one file", {
  testthat::expect_message(
    object = summariseFunctionUse(
      r_files = "checkDependencies.R",
      verbose = TRUE,
      in_package = TRUE),
    regexp = "Started on file: .+")
})

testthat::test_that("summariseFunctionUse verbose multiple files", {
  r_files <- list.files("R")

  testthat::expect_message(
    object = summariseFunctionUse(
      r_files = c("checkDependencies.R", "getDefaultPermittedPackages.R"),
      verbose = TRUE,
      in_package = TRUE), regexp = "Started on file: .+")
})
