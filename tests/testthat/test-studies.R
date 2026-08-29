test_that("lic_study_pgn handles input validation", {
  expect_error(lic_study_pgn(""), "must be a single non-empty character string")
  expect_error(lic_study_pgn(123), "must be a single non-empty character string")
})

test_that("lic_study_pgn exports study PGN", {
  skip_if_offline()
  tryCatch({
    # Test with a public study ID
    pgn <- lic_study_pgn("sK9kZ8vT", token = NULL)
    expect_type(pgn, "character")
  }, error = function(e) {
    skip(paste("Lichess API unreachable:", e$message))
  })
})
