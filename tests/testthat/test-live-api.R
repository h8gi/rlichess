# Live API Integration Tests
# These tests run directly against the live Lichess API (no mocks)
# to detect schema drift, API breaking changes, or upstream issues.
#
# By default, these tests are skipped unless LICHESS_TEST_LIVE="true".

skip_if_not(
  identical(Sys.getenv("LICHESS_TEST_LIVE"), "true"),
  "Skipping live API tests (set LICHESS_TEST_LIVE=true to run)"
)

test_that("Live API: lic_user returns expected profile structure", {
  user <- lic_user("h8gi")
  expect_s3_class(user, "tbl_df")
  expect_equal(nrow(user), 1)
  expect_equal(tolower(user$username), "h8gi")
  expect_true(all(c("id", "username", "created_at", "play_time_total_hours") %in% names(user)))
})

test_that("Live API: lic_users_status returns online/playing status", {
  statuses <- lic_users_status(c("h8gi", "magnuscarlsen"), with_game_ids = TRUE)
  expect_s3_class(statuses, "tbl_df")
  expect_gte(nrow(statuses), 2)
  expect_true(all(c("id", "name", "online", "playing") %in% names(statuses)))
})

test_that("Live API: lic_user_perfs returns ratings tibble", {
  perfs <- lic_user_perfs("h8gi")
  expect_s3_class(perfs, "tbl_df")
  expect_gte(nrow(perfs), 1)
  expect_true(all(c("perf", "rating", "games") %in% names(perfs)))
})

test_that("Live API: lic_leaderboard returns top players", {
  lb <- lic_leaderboard(perf_type = "blitz", count = 3)
  expect_s3_class(lb, "tbl_df")
  expect_equal(nrow(lb), 3)
  expect_true(all(c("id", "username", "rating") %in% names(lb)))
})

test_that("Live API: lic_games_user fetches and decodes NDJSON games", {
  games <- lic_games_user("h8gi", perf_type = "bullet", max = 2)
  expect_s3_class(games, "tbl_df")
  expect_gte(nrow(games), 1)
  expect_true(all(c("id", "speed", "status") %in% names(games)))
})

test_that("Live API: lic_game fetches single game export", {
  game <- lic_game("0tMlsM69")
  expect_s3_class(game, "tbl_df")
  expect_equal(nrow(game), 1)
  expect_equal(unlist(game$id), "0tMlsM69")
})

test_that("Live API: lic_explorer_lichess returns candidate moves", {
  exp <- lic_explorer_lichess(play = "e4,c5")
  expect_type(exp, "list")
  expect_true(all(c("white", "draws", "black", "moves") %in% names(exp)))
  expect_s3_class(exp$moves, "tbl_df")
})

test_that("Live API: lic_puzzle_daily fetches featured tactical puzzle", {
  puzzle <- lic_puzzle_daily()
  expect_type(puzzle, "list")
  expect_true("puzzle" %in% names(puzzle))
  expect_true(all(c("id", "rating", "fen", "solution") %in% names(puzzle$puzzle)))
})

test_that("Live API: lic_study_pgn exports study PGN content", {
  pgn <- lic_study_pgn("Y1yXP80U")
  expect_type(pgn, "character")
  expect_true(nzchar(pgn))
  expect_true(grepl("\\[Event ", pgn))
})
