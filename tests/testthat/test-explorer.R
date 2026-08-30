test_that("lic_explorer_player validates username", {
  expect_error(lic_explorer_player(""), "must be a single non-empty character string")
  expect_error(lic_explorer_player(123), "must be a single non-empty character string")
})

test_that("lic_explorer_lichess queries opening database", {
  httptest2::with_mock_dir("explorer_lichess", {
    exp <- lic_explorer_lichess(play = "e4,c5", token = NULL)
    expect_type(exp, "list")
    expect_true(all(c("white", "draws", "black", "moves") %in% names(exp)))
    expect_s3_class(exp$moves, "tbl_df")

    # Alias check
    exp_alias <- lic_opening_explorer(play = "e4,c5", token = NULL)
    expect_equal(names(exp), names(exp_alias))
  })
})

test_that("lic_explorer_masters queries masters database", {
  httptest2::with_mock_dir("explorer_masters", {
    masters <- lic_explorer_masters(play = "e4,c5", token = NULL)
    expect_type(masters, "list")
    expect_true(all(c("white", "draws", "black", "moves", "topGames") %in% names(masters)))
    expect_s3_class(masters$moves, "tbl_df")

    # Alias check
    masters_alias <- lic_masters_explorer(play = "e4,c5", token = NULL)
    expect_equal(names(masters), names(masters_alias))
  })
})

test_that("lic_explorer_player queries player opening database", {
  httptest2::with_mock_dir("explorer_player", {
    p_exp <- lic_explorer_player("h8gi", color = "white", play = "e4", token = NULL)
    expect_type(p_exp, "list")
    expect_true(all(c("white", "draws", "black", "moves") %in% names(p_exp)))
    expect_s3_class(p_exp$moves, "tbl_df")
  })
})
