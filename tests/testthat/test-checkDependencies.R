library(DependencyReviewer)
library(testthat)
library(withr)

# Set R_USER_CAHCE_DIR to tmpfile for tests
local_envvar(
  R_USER_CACHE_DIR = tempfile()
)

# Test with base
# test_that("base", {
#   expect_message(checkDependencies(packageName = "base"))
# })

