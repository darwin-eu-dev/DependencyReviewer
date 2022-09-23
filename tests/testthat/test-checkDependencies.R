test_that("checkDependencies", {
  # # current package
  # messages <- checkDependencies()
  # expect_null(messages)

  # other installed package
  messages <- checkDependencies(packageName = "dplyr")
  expect_null(messages)
})
