library(DependencyReviewer)
library(testthat)

test_that("Lint file", {
  path <- normalizePath(system.file(
    package = "DependencyReviewer", "testScript.R"))

  expect_type(lintFile(path), "list")
})

test_that("Lint package", {
  path <- normalizePath(paste0(.Library, "/base"))
  expect_type(lintPackage(path = path), "list")
})

test_that("Lint score file", {
  path <- normalizePath(system.file(
    package = "DependencyReviewer", "testScript.R"))

  expect_s3_class(lintScore(
    lintFunction = lintFile,
    path), "data.frame")
})
