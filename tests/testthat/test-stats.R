test_that("lic_stats_openings computes score and score_rate correctly", {
  sample_df <- tibble::tibble(
    id = c("g1", "g2", "g3", "g4"),
    players.white.user.name = c("playerA", "playerA", "playerA", "playerA"),
    players.black.user.name = c("playerB", "playerC", "playerD", "playerE"),
    winner = c("white", "black", "", "white"),
    opening.name = c("Italian Game", "Italian Game", "Italian Game", "Sicilian Defense"),
    opening.eco = c("C50", "C50", "C50", "B20")
  )

  normalized <- lic_tidy_games(sample_df, username = "playerA")
  stats <- lic_stats_openings(normalized, min_games = 1)

  italian <- stats[stats$opening_name == "Italian Game", ]
  expect_equal(italian$n, 3)
  expect_equal(italian$wins, 1)
  expect_equal(italian$losses, 1)
  expect_equal(italian$draws, 1)
  expect_equal(italian$winrate, 1 / 3)
  expect_equal(italian$score, 1.5)
  expect_equal(italian$score_rate, 1.5 / 3)
})

test_that("lic_stats_opponents aggregates head-to-head records accurately", {
  sample_df <- tibble::tibble(
    opponent_name = c("playerB", "playerB", "playerC", "playerB"),
    user_result = c("win", "loss", "win", "draw"),
    opponent_rating = c(2000L, 2000L, 2100L, 2000L),
    user_rating_diff = c(10L, -8L, 12L, 1L)
  )

  opp_stats <- lic_stats_opponents(sample_df, min_games = 1)

  expect_s3_class(opp_stats, "tbl_df")
  expect_equal(nrow(opp_stats), 2)
  expect_equal(opp_stats$opponent_name[1], "playerB")
  expect_equal(opp_stats$n[1], 3)
  expect_equal(opp_stats$wins[1], 1)
  expect_equal(opp_stats$losses[1], 1)
  expect_equal(opp_stats$draws[1], 1)
  expect_equal(opp_stats$score[1], 1.5)
  expect_equal(opp_stats$score_rate[1], 0.5)
  expect_equal(opp_stats$avg_opponent_rating[1], 2000)
  expect_equal(opp_stats$rating_diff_total[1], 3L)

  # min_games filter
  opp_filtered <- lic_stats_opponents(sample_df, min_games = 2)
  expect_equal(nrow(opp_filtered), 1)
  expect_equal(opp_filtered$opponent_name, "playerB")
})

test_that("lic_stats_time groups performances by hour and weekday", {
  sample_games <- tibble::tibble(
    created_at = as.POSIXct(c(
      "2025-01-01 10:00:00", # Wednesday
      "2025-01-01 10:30:00", # Wednesday
      "2025-01-02 20:00:00"  # Thursday
    ), tz = "UTC"),
    user_result = c("win", "win", "loss"),
    user_rating_diff = c(8L, 7L, -9L)
  )

  # By hour
  hour_stats <- lic_stats_time(sample_games, by = "hour", tz = "UTC")
  expect_equal(nrow(hour_stats), 2)
  expect_equal(hour_stats$hour, c(10L, 20L))
  expect_equal(hour_stats$n, c(2L, 1L))
  expect_equal(hour_stats$wins, c(2L, 0L))
  expect_equal(hour_stats$score_rate, c(1, 0))
  expect_equal(hour_stats$rating_diff_total, c(15L, -9L))

  # By wday
  wday_stats <- lic_stats_time(sample_games, by = "wday", tz = "UTC")
  expect_equal(nrow(wday_stats), 2)
  expect_equal(as.character(wday_stats$wday), c("Wednesday", "Thursday"))
  expect_equal(wday_stats$n, c(2L, 1L))

  # By both
  both_stats <- lic_stats_time(sample_games, by = "both", tz = "UTC")
  expect_equal(nrow(both_stats), 2)
  expect_named(both_stats, c("wday", "hour", "n", "wins", "losses", "draws", "winrate", "score", "score_rate", "rating_diff_total"))
})

test_that("lic_stats_clocks computes move duration and time trouble accurately", {
  sample_moves <- tibble::tibble(
    game_id = c(rep("g1", 4), rep("g2", 4)),
    ply = rep(1:4, 2),
    color = rep(c("white", "black", "white", "black"), 2),
    clock = c(180, 179, 150, 160, 60, 50, 8, 5) # g2 has time trouble (< 10)
  )

  clock_stats <- lic_stats_clocks(sample_moves, threshold_time_trouble = 10)

  expect_s3_class(clock_stats, "tbl_df")
  expect_equal(nrow(clock_stats), 4) # 2 games x 2 colors

  # g1 white: moves at ply 1 (180), ply 3 (150) -> move_time: NA, 30 -> avg: 30, max: 30, min_clock: 150, trouble: 0
  g1_w <- clock_stats[clock_stats$game_id == "g1" & clock_stats$color == "white", ]
  expect_equal(g1_w$moves_count, 2)
  expect_equal(g1_w$avg_move_time, 30)
  expect_equal(g1_w$max_move_time, 30)
  expect_equal(g1_w$min_clock, 150)
  expect_equal(g1_w$time_trouble_moves, 0)

  # g2 black: moves at ply 2 (50), ply 4 (5) -> min_clock: 5, trouble (< 10): 1
  g2_b <- clock_stats[clock_stats$game_id == "g2" & clock_stats$color == "black", ]
  expect_equal(g2_b$min_clock, 5)
  expect_equal(g2_b$time_trouble_moves, 1)
})
