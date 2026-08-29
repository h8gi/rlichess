test_that("lic_to_timestamp converts dates properly", {
  ts <- rlichess:::lic_to_timestamp("2025-01-01")
  expect_true(is.character(ts))
  expect_gt(nchar(ts), 10)

  ts2 <- rlichess:::lic_to_timestamp(as.Date("2025-01-01"))
  expect_equal(ts, ts2)
})

test_that("lic_tidy_games correctly calculates user perspective and columns", {
  sample_df <- tibble::tibble(
    id = c("g1", "g2", "g3", "g4"),
    createdAt = c(1609459200000, 1609545600000, 1609632000000, 1609718400000),
    players.white.user.name = c("playerA", "playerB", "playerA", "playerB"),
    players.black.user.name = c("playerB", "playerA", "playerB", "playerA"),
    players.white.rating = c(2000, 2100, 2010, 2110),
    players.black.rating = c(2100, 2000, 2110, 2010),
    players.white.ratingDiff = c(10, 8, -10, -5),
    players.black.ratingDiff = c(-10, -8, 10, 5),
    winner = c("white", "white", "black", NA_character_),
    opening.name = c("Sicilian Defense", "French Defense", "Sicilian Defense", "French Defense"),
    opening.eco = c("B20", "C00", "B20", "C00")
  )

  res <- lic_tidy_games(sample_df, username = "playerA")

  expect_equal(res$user_color, c("white", "black", "white", "black"))
  expect_equal(res$user_result, c("win", "loss", "loss", "draw"))
  expect_equal(res$win, c(TRUE, FALSE, FALSE, FALSE))
  expect_equal(res$user_rating, c(2000, 2000, 2010, 2010))
  expect_equal(res$opponent_rating, c(2100, 2100, 2110, 2110))
  expect_equal(res$opponent_name, c("playerB", "playerB", "playerB", "playerB"))
  expect_equal(res$user_rating_diff, c(10, -8, -10, 5))
  expect_s3_class(res$created_at, "POSIXct")
})

test_that("lic_tidy_moves expands moves into long tibble format", {
  sample_game <- tibble::tibble(
    id = "g1",
    moves = "e4 e5 Nf3 Nc6 Bc4 Bc5",
    clocks = list(c(18000, 17950, 17800, 17700, 17600, 17500))
  )

  moves_df <- lic_tidy_moves(sample_game)

  expect_s3_class(moves_df, "tbl_df")
  expect_equal(nrow(moves_df), 6)
  expect_equal(moves_df$ply, 1:6)
  expect_equal(moves_df$move_number, c(1, 1, 2, 2, 3, 3))
  expect_equal(moves_df$color, c("white", "black", "white", "black", "white", "black"))
  expect_equal(moves_df$san, c("e4", "e5", "Nf3", "Nc6", "Bc4", "Bc5"))
  expect_equal(moves_df$clock, c(180, 179.5, 178, 177, 176, 175))
  expect_true(all(is.na(moves_df$eval)))
  expect_true(all(is.na(moves_df$mate)))
  expect_true(all(is.na(moves_df$judgment)))
})

test_that("lic_tidy_moves parses evaluations, mate scores, and move judgments", {
  eval_df <- data.frame(
    cp = c(25, -15, 120, 250, NA, NA),
    mate = c(NA, NA, NA, NA, 2, 1),
    judgment.name = c(NA, NA, NA, "Inaccuracy", "Blunder", NA)
  )

  sample_game_mate <- tibble::tibble(
    id = "g_mate",
    moves = "e4 e5 Nf3 Nc6 Bc4 Qf6 Qxf7#",
    evals = list(eval_df)
  )

  res <- lic_tidy_moves(sample_game_mate)

  expect_equal(nrow(res), 7)
  expect_equal(res$eval[1:4], c(0.25, -0.15, 1.20, 2.50))
  expect_true(is.na(res$eval[5]))
  expect_true(is.na(res$eval[6]))
  expect_true(is.na(res$eval[7]))

  expect_true(all(is.na(res$mate[1:4])))
  expect_equal(res$mate[5], 2L)
  expect_equal(res$mate[6], 1L)
  expect_true(is.na(res$mate[7]))

  expect_equal(res$judgment[4], "Inaccuracy")
  expect_equal(res$judgment[5], "Blunder")
  expect_true(is.na(res$judgment[6]))
})


test_that("lic_stats_openings aggregates correctly", {
  sample_df <- tibble::tibble(
    id = c("g1", "g2", "g3"),
    players.white.user.name = c("playerA", "playerA", "playerA"),
    players.black.user.name = c("playerB", "playerC", "playerD"),
    winner = c("white", "white", "black"),
    opening.name = c("Italian Game", "Italian Game", "Italian Game"),
    opening.eco = c("C50", "C50", "C50")
  )

  normalized <- lic_tidy_games(sample_df, username = "playerA")
  stats <- lic_stats_openings(normalized, min_games = 2)

  expect_equal(nrow(stats), 1)
  expect_equal(stats$opening_name, "Italian Game")
  expect_equal(stats$n, 3)
  expect_equal(stats$wins, 2)
  expect_equal(stats$losses, 1)
  expect_equal(stats$draws, 0)
  expect_equal(stats$winrate, 2 / 3)
})

test_that("lic_tidy_games handles AI opponents correctly", {
  # Case 1: User is Black vs AI (White)
  ai_game_black <- tibble::tibble(
    id = "ai_g1",
    players.white.aiLevel = 3L,
    players.black.user.name = "playerA",
    players.black.rating = 1600L,
    winner = "black",
    status = "mate"
  )

  res1 <- lic_tidy_games(ai_game_black, username = "playerA")
  expect_equal(res1$user_color, "black")
  expect_equal(res1$user_result, "win")
  expect_equal(res1$win, TRUE)
  expect_equal(res1$opponent_name, "Stockfish Level 3")
  expect_true(is.na(res1$opponent_rating))

  # Case 2: User is White vs AI (Black)
  ai_game_white <- tibble::tibble(
    id = "ai_g2",
    players.white.user.name = "playerA",
    players.white.rating = 1600L,
    players.black.aiLevel = 5L,
    winner = "black",
    status = "mate"
  )

  res2 <- lic_tidy_games(ai_game_white, username = "playerA")
  expect_equal(res2$user_color, "white")
  expect_equal(res2$user_result, "loss")
  expect_equal(res2$win, FALSE)
  expect_equal(res2$opponent_name, "Stockfish Level 5")
  expect_true(is.na(res2$opponent_rating))
})

test_that("lic_tidy_games handles aborted games and non-participating users", {
  # Aborted game
  aborted_df <- tibble::tibble(
    id = "g_abort",
    players.white.user.name = "playerA",
    players.black.user.name = "playerB",
    status = "aborted"
  )

  res_abort <- lic_tidy_games(aborted_df, username = "playerA")
  expect_equal(res_abort$user_color, "white")
  expect_equal(res_abort$user_result, "aborted")
  expect_true(is.na(res_abort$win))

  # Non-participating user
  other_df <- tibble::tibble(
    id = "g_other",
    players.white.user.name = "playerA",
    players.black.user.name = "playerB",
    winner = "white"
  )

  res_other <- lic_tidy_games(other_df, username = "playerC")
  expect_true(is.na(res_other$user_color))
  expect_true(is.na(res_other$user_result))
  expect_true(is.na(res_other$win))
  expect_true(is.na(res_other$opponent_name))
})

test_that("lic_tidy_games populates standardized columns", {
  game_df <- tibble::tibble(
    id = "g_std",
    players.white.user.name = "playerA",
    players.black.user.name = "playerB",
    clock.initial = 180L,
    clock.increment = 2L,
    opening.name = "Italian Game",
    opening.eco = "C50"
  )

  res <- lic_tidy_games(game_df)
  expect_equal(res$white_name, "playerA")
  expect_equal(res$black_name, "playerB")
  expect_equal(res$time_control, "180+2")
  expect_equal(res$opening_name, "Italian Game")
  expect_equal(res$opening_eco, "C50")
})

test_that("lic_games_export_ids handles validation and fetches multiple games", {
  expect_error(lic_games_export_ids(character(0)), "must be a non-empty character vector")
  expect_error(lic_games_export_ids(123), "must be a non-empty character vector")
  expect_error(lic_games_export_ids(c("", " ")), "must contain at least one valid game ID")

  # Truncation warning on >300 IDs
  expect_warning(
    res_trunc <- tryCatch(
      lic_games_export_ids(as.character(1:305), token = "dummy"),
      error = function(e) NULL
    ),
    "supports a maximum of 300 game IDs"
  )

  skip_if_offline()
  tryCatch({
    res <- lic_games_export_ids(c("0tMlsM69", "q7ZvsdUF"), token = NULL)
    expect_s3_class(res, "tbl_df")
    if (nrow(res) > 0) {
      expect_true("id" %in% names(res))
      expect_true(all(c("0tMlsM69", "q7ZvsdUF") %in% res$id))
    }

    # NA handling and single game
    res_na <- lic_games_export_ids(c("0tMlsM69", NA), token = NULL)
    expect_s3_class(res_na, "tbl_df")
    if (nrow(res_na) > 0) {
      expect_equal(res_na$id, "0tMlsM69")
    }

    # Empty result on non-existent game ID
    res_empty <- lic_games_export_ids(c("nonexist"), token = NULL)
    expect_s3_class(res_empty, "tbl_df")
    expect_equal(nrow(res_empty), 0)

    # Alias check
    res_alias <- lic_get_games_by_ids(c("0tMlsM69"), token = NULL)
    expect_s3_class(res_alias, "tbl_df")
  }, error = function(e) {
    skip(paste("Lichess API unreachable:", e$message))
  })
})


