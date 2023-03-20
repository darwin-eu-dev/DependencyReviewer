library(DependencyReviewer)
library(testthat)
library(withr)

local_envvar(
  R_USER_CACHE_DIR = tempfile()
)

test_that("Void", {
  skip_if_offline()
  expect_s3_class(getDefaultPermittedPackages(), "data.frame")
})
