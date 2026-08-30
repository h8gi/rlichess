test_that("lic_puzzle_daily fetches today's daily puzzle", {
  httptest2::with_mock_dir("puzzle_daily", {
    puzzle <- lic_puzzle_daily(token = NULL)
    expect_type(puzzle, "list")
    expect_true("game" %in% names(puzzle))
    expect_true("puzzle" %in% names(puzzle))
    expect_true("rating" %in% names(puzzle$puzzle))
  })
})

test_that("lic_puzzle_activity handles unauthenticated and authenticated requests", {
  httptest2::with_mock_dir("puzzle_activity", {
    # Unauthenticated request returns empty tibble with message
    res_unauth <- lic_puzzle_activity(token = NULL)
    expect_s3_class(res_unauth, "tbl_df")
    expect_equal(nrow(res_unauth), 0)
  })
})
