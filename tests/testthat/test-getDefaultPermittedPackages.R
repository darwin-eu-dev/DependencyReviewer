test_that("check getDefaultPermittedPackages", {

  # working example
  deps<-getDefaultPermittedPackages()
  expect_true(is.character(deps))

})
