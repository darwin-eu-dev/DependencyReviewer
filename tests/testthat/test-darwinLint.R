library(DependencyReviewer)
library(testthat)

test_that("Lint file", {
  path <- normalizePath(system.file(
    package = "DependencyReviewer", "testScript.R"))

  expect_type(darwinLintFile(path), "list")
})

test_that("Lint package", {
  path <- normalizePath(paste0(.Library, "/base"))
  expect_type(darwinLintPackage(path = path), "list")
})

test_that("Lint score file", {
  path <- normalizePath(system.file(
    package = "DependencyReviewer", "testScript.R"))

  expect_s3_class(darwinLintScore(
    lintFunction = darwinLintFile,
    path), "data.frame")
})
