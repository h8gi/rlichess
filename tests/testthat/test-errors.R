test_that("lic_user raises clear error on 404 non-existent user", {
  httptest2::with_mock_dir("user_404", {
    expect_error(
      lic_user("this_user_definitely_does_not_exist_999999", token = NULL),
      "404 Not Found"
    )
  })
})

test_that("lic_game raises clear error on non-existent game ID", {
  httptest2::with_mock_dir("game_404", {
    expect_error(
      lic_game("nonexist9", token = NULL),
      "404 Not Found"
    )
  })
})
