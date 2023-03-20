library(DependencyReviewer)
library(testthat)
library(withr)

local_envvar(
  R_USER_CACHE_DIR = tempfile()
)

test_that("getGraphData", {
  skip_on_os(c("mac", "linux"))
  skip_if_offline()
  expect_s3_class(getGraphData(
    system.file(package = "base")), "igraph")
})
