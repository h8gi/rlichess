test_that("lic_explorer_player validates username", {
  expect_error(lic_explorer_player(""), "must be a single non-empty character string")
  expect_error(lic_explorer_player(123), "must be a single non-empty character string")
})
