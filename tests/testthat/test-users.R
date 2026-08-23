test_that("lic_user_profile handles input validation", {
  expect_error(lic_user_profile(""), "must be a single non-empty character string")
  expect_error(lic_user_profile(123), "must be a single non-empty character string")
})

test_that("lic_user_profile returns profile for valid user", {
  skip_if_offline()
  user <- lic_user_profile("h8gi", token = NULL)
  expect_equal(tolower(user$username), "h8gi")
  expect_true("perfs" %in% names(user))
})

test_that("lic_user_perfs returns structured tibble for valid user", {
  skip_if_offline()
  perfs <- lic_user_perfs("h8gi", token = NULL)
  expect_s3_class(perfs, "tbl_df")
  expect_true("bullet" %in% perfs$perf)
  expect_true(is.integer(perfs$games) || is.numeric(perfs$games))
})

test_that("lic_rating_history returns tibble structure", {
  skip_if_offline()
  res <- lic_rating_history("h8gi", token = NULL)
  expect_s3_class(res, "tbl_df")
  expect_named(res, c("username", "perf", "date", "rating"))
})
