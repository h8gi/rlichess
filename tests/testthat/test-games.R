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
