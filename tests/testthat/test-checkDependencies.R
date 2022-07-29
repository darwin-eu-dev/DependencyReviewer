test_that("checkDependencies", {

  # # current package
  # messages <- checkDependencies()
  # expect_null(messages)

  # other installed package
  library(dplyr)
  messages <- checkDependencies(packageName="dplyr")
  expect_null(messages)

})
