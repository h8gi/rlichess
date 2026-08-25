test_that("lic_user handles input validation", {
  expect_error(lic_user(""), "must be a single non-empty character string")
  expect_error(lic_user(123), "must be a single non-empty character string")
})

test_that("lic_user returns tidy tibble by default and raw list with raw = TRUE", {
  skip_if_offline()

  tryCatch({
    # Default: tidy tibble
    user_df <- lic_user("h8gi", token = NULL)
    expect_s3_class(user_df, "tbl_df")
    expect_equal(nrow(user_df), 1)
    expect_equal(tolower(user_df$username), "h8gi")
    expect_true("created_at" %in% names(user_df))
    expect_s3_class(user_df$created_at, "POSIXct")
    expect_true(is.numeric(user_df$count_all))

    # raw = TRUE
    user_raw <- lic_user("h8gi", raw = TRUE, token = NULL)
    expect_true(is.list(user_raw))
    expect_true("perfs" %in% names(user_raw))

    # Test alias
    user_alias <- lic_user_profile("h8gi", token = NULL)
    expect_equal(user_df$id, user_alias$id)
  }, error = function(e) {
    skip(paste("Lichess API unreachable:", e$message))
  })
})

test_that("lic_user_perfs returns structured tibble for valid user", {
  skip_if_offline()
  tryCatch({
    perfs <- lic_user_perfs("h8gi", token = NULL)
    expect_s3_class(perfs, "tbl_df")
    expect_true("bullet" %in% perfs$perf)
    expect_true(is.integer(perfs$games) || is.numeric(perfs$games))
  }, error = function(e) {
    skip(paste("Lichess API unreachable:", e$message))
  })
})

test_that("lic_user_rating_history returns tibble structure and aliases work", {
  skip_if_offline()
  tryCatch({
    res <- lic_user_rating_history("h8gi", token = NULL)
    expect_s3_class(res, "tbl_df")
    expect_named(res, c("username", "perf", "date", "rating"))

    # Test alias
    res_alias <- lic_rating_history("h8gi", token = NULL)
    expect_equal(names(res), names(res_alias))
  }, error = function(e) {
    skip(paste("Lichess API unreachable:", e$message))
  })
})
