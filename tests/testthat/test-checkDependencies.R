library(testthat)
library(DependencyReviewer)

test_that("Void", {
  expect_message(checkDependencies())
})

test_that("ggplot2", {
  expect_message(checkDependencies(packageName = "ggplot2"), c("approved"))
})

test_that("ggplot2", {
  expect_message(checkDependencies(
    packageName = "ggplot2",
    dependencyType = c("Imports", "suggests")
  ),
  c("approved"))
})
