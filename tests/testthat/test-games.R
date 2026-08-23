test_that("lic_normalize_games correctly determines color and win status", {
  sample_df <- tibble::tibble(
    id = c("g1", "g2", "g3", "g4"),
    players.white.user.name = c("playerA", "playerB", "playerA", "playerB"),
    players.black.user.name = c("playerB", "playerA", "playerB", "playerA"),
    winner = c("white", "white", "black", NA_character_),
    opening.name = c("Sicilian Defense", "French Defense", "Sicilian Defense", "French Defense"),
    opening.eco = c("B20", "C00", "B20", "C00")
  )

  res <- lic_normalize_games(sample_df, username = "playerA")

  expect_equal(res$user_color, c("white", "black", "white", "black"))
  expect_equal(res$user_result, c("win", "loss", "loss", "draw"))
  expect_equal(res$win, c(TRUE, FALSE, FALSE, FALSE))
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

  normalized <- lic_normalize_games(sample_df, username = "playerA")
  stats <- lic_stats_openings(normalized, min_games = 2)

  expect_equal(nrow(stats), 1)
  expect_equal(stats$opening_name, "Italian Game")
  expect_equal(stats$n, 3)
  expect_equal(stats$wins, 2)
  expect_equal(stats$losses, 1)
  expect_equal(stats$draws, 0)
  expect_equal(stats$winrate, 2 / 3)
})
