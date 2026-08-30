test_that("lic_study_pgn handles input validation", {
  expect_error(lic_study_pgn(""), "must be a single non-empty character string")
  expect_error(lic_study_pgn(123), "must be a single non-empty character string")
  expect_error(lic_study_pgn("Y1yXP80U", chapter_id = 123), "must be a single non-empty character string or NULL")
})

test_that("lic_study_pgn exports study PGN", {
  httptest2::with_mock_dir("study_pgn", {
    # Test with a public study ID
    pgn <- lic_study_pgn("Y1yXP80U", token = NULL)
    expect_type(pgn, "character")
    expect_true(grepl("\\[Event ", pgn))

    # Test chapter export
    pgn_ch <- lic_study_pgn("https://lichess.org/study/Y1yXP80U", chapter_id = "oxgS1aRW", token = NULL)
    expect_type(pgn_ch, "character")
    expect_true(grepl("\\[Event ", pgn_ch))
  })
})
