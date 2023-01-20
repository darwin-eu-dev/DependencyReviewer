library(DependencyReviewer)
library(testthat)

local_envvar(
  R_USER_CACHE_DIR = tempfile()
)

test_that("getGraphData", {
  expect_s3_class(getGraphData(
    system.file(package = "dplyr")), "igraph")
})
