library(DependencyReviewer)
library(testthat)

local_envvar(
  R_USER_CACHE_DIR = tempfile()
)

test_that("getGraphData", {
  testthat::skip_on_os(c("mac", "linux"))
  expect_s3_class(getGraphData(
    system.file(package = "base")), "igraph")
})
