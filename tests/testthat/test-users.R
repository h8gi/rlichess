test_that("lic_user handles input validation", {
  expect_error(lic_user(""), "must be a single non-empty character string")
  expect_error(lic_user(123), "must be a single non-empty character string")
})

test_that("lic_user returns tidy tibble by default and raw list with raw = TRUE", {
  httptest2::with_mock_dir("user_profile", {
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
  })
})

test_that("lic_user_perfs returns structured tibble for valid user", {
  httptest2::with_mock_dir("user_perfs", {
    perfs <- lic_user_perfs("h8gi", token = NULL)
    expect_s3_class(perfs, "tbl_df")
    expect_true("bullet" %in% perfs$perf)
    expect_true(is.integer(perfs$games) || is.numeric(perfs$games))
  })
})

test_that("lic_user_rating_history returns tibble structure and aliases work", {
  httptest2::with_mock_dir("user_rating_history", {
    res <- lic_user_rating_history("h8gi", token = NULL)
    expect_s3_class(res, "tbl_df")
    expect_named(res, c("username", "perf", "date", "rating"))

    # Test alias
    res_alias <- lic_rating_history("h8gi", token = NULL)
    expect_equal(names(res), names(res_alias))
  })
})

test_that("lic_user_perf_stats returns detailed stats list", {
  httptest2::with_mock_dir("user_perf_stats", {
    stats <- lic_user_perf_stats("h8gi", perf = "bullet", token = NULL)
    expect_type(stats, "list")
    expect_true("stat" %in% names(stats) || "perf" %in% names(stats))
  })
})

test_that("lic_users_status validates inputs and returns tidy status tibble", {
  expect_error(lic_users_status(character(0)), "must be a non-empty character vector")
  expect_error(lic_users_status(123), "must be a non-empty character vector")
  expect_error(lic_users_status(c("", " ")), "must contain at least one valid username")

  # Truncation warning on >100 users
  expect_warning(
    httptest2::with_mock_dir("users_status_trunc", {
      lic_users_status(as.character(1:105), token = "dummy")
    }),
    "supports a maximum of 100 user IDs"
  )

  httptest2::with_mock_dir("users_status", {
    st <- lic_users_status(c("h8gi", "magnuscarlsen"), with_game_ids = TRUE, token = NULL)
    expect_s3_class(st, "tbl_df")
    expect_true(nrow(st) >= 1)
    expect_named(st, c("id", "name", "title", "online", "playing", "streaming", "patron", "playing_id", "signal"))
    expect_type(st$online, "logical")
    expect_type(st$playing, "logical")

    # NA handling
    st_na <- lic_users_status(c("h8gi", NA), token = NULL)
    expect_s3_class(st_na, "tbl_df")
    expect_equal(st_na$id, "h8gi")
  })
})

test_that("lic_user_crosstable validates inputs and returns head-to-head score", {
  expect_error(lic_user_crosstable("", "hikaru"), "must be a single non-empty character string")
  expect_error(lic_user_crosstable("magnuscarlsen", ""), "must be a single non-empty character string")
  expect_error(lic_user_crosstable(123, "hikaru"), "must be a single non-empty character string")

  httptest2::with_mock_dir("user_crosstable", {
    # Default tidy tibble
    ct <- lic_user_crosstable("Lance5500", "TryingHard87", token = NULL)
    expect_s3_class(ct, "tbl_df")
    expect_equal(nrow(ct), 1)
    expect_named(ct, c("user1", "user2", "user1_score", "user2_score", "nb_games"))
    expect_equal(ct$user1, "Lance5500")
    expect_equal(ct$user2, "TryingHard87")
    expect_true(is.numeric(ct$user1_score))
    expect_true(is.numeric(ct$user2_score))
    expect_true(is.integer(ct$nb_games))

    # Same user crosstable
    ct_same <- lic_user_crosstable("Lance5500", "Lance5500", token = NULL)
    expect_s3_class(ct_same, "tbl_df")
    expect_equal(nrow(ct_same), 1)

    # raw = TRUE
    ct_raw <- lic_user_crosstable("Lance5500", "TryingHard87", raw = TRUE, token = NULL)
    expect_true(is.list(ct_raw))
    expect_true("users" %in% names(ct_raw))
  })
})

test_that("lic_leaderboard validates inputs and returns top player rankings", {
  expect_error(lic_leaderboard(perf_type = ""), "must be a single non-empty character string")
  expect_error(lic_leaderboard(count = 0), "must be an integer between 1 and 200")
  expect_error(lic_leaderboard(count = 300), "must be an integer between 1 and 200")

  httptest2::with_mock_dir("leaderboard", {
    top <- lic_leaderboard(perf_type = "blitz", count = 5, token = NULL)
    expect_s3_class(top, "tbl_df")
    expect_equal(nrow(top), 5)
    expect_equal(top$rank, 1:5)
    expect_true("rating" %in% names(top))
    expect_true("username" %in% names(top))
    expect_equal(top$perf_type, rep("blitz", 5))

    # Normalization check (lowercase/snake_case mapping to CamelCase variants)
    top_norm <- lic_leaderboard(perf_type = "ultrabullet", count = 3, token = NULL)
    expect_s3_class(top_norm, "tbl_df")
    expect_equal(nrow(top_norm), 3)
    expect_equal(top_norm$perf_type, rep("ultraBullet", 3))

    # Alias check
    top_alias <- lic_top_players(perf_type = "bullet", count = 3, token = NULL)
    expect_s3_class(top_alias, "tbl_df")
    expect_equal(nrow(top_alias), 3)
  })
})
