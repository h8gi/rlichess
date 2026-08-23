test_that("lichess_openings dataset is valid", {
  data("lichess_openings", package = "rlichess", envir = environment())
  expect_s3_class(lichess_openings, "tbl_df")
  expect_named(lichess_openings, c("eco", "name", "pgn"))
  expect_gt(nrow(lichess_openings), 3000)
  expect_true("B20" %in% lichess_openings$eco)
})
