library(DependencyReviewer)
library(testthat)

local_envvar(
  R_USER_CACHE_DIR = tempfile()
)

# test_that("Void", {
#   expect_s3_class(getDefaultPermittedPackages(), "data.frame")
# })
