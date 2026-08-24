#' Get Daily Lichess Puzzle
#'
#' Retrieves today's featured puzzle from Lichess.
#'
#' @details
#' **Lichess API Endpoint:** `GET /api/puzzle/daily`
#'
#' **Official Documentation:** <https://lichess.org/api#tag/Puzzles/operation/apiPuzzleDaily>
#'
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A list containing puzzle metadata (puzzle ID, rating, plays, FEN, moves, themes).
#' @export
#' @examples
#' puzzle <- lic_puzzle_daily()
#' puzzle$puzzle$rating
lic_puzzle_daily <- function(token = lic_token()) {
  url <- "https://lichess.org/api/puzzle/daily"
  req <- lic_request(url, token = token) |>
    httr2::req_headers("Accept" = "application/json")

  resp <- httr2::req_perform(req)
  jsonlite::fromJSON(httr2::resp_body_string(resp), simplifyVector = TRUE)
}

#' Get User Puzzle Activity
#'
#' Retrieves recent puzzle attempts for the authenticated user in NDJSON format.
#' Requires authentication token with puzzle read permission.
#'
#' @details
#' **Lichess API Endpoint:** `GET /api/puzzle/activity`
#'
#' **Official Documentation:** <https://lichess.org/api#tag/Puzzles/operation/apiPuzzleActivity>
#'
#' @param max Maximum number of puzzle activities to fetch. Default is 50.
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A tidy [tibble::tibble] of puzzle attempts.
#' @export
#' @examplesIf nzchar(Sys.getenv("LICHESS_API_TOKEN"))
#' puzzles <- lic_puzzle_activity(max = 20)
lic_puzzle_activity <- function(max = 50, token = lic_token()) {
  url <- "https://lichess.org/api/puzzle/activity"
  req <- lic_request(url, token = token) |>
    httr2::req_headers("Accept" = "application/x-ndjson")

  if (!is.null(max)) {
    req <- httr2::req_url_query(req, max = as.character(max))
  }

  resp <- httr2::req_perform(req)
  body <- httr2::resp_body_string(resp)

  if (!nzchar(trimws(body))) {
    return(tibble::tibble())
  }

  con <- textConnection(body)
  on.exit(close(con), add = TRUE)

  df <- jsonlite::stream_in(con, verbose = FALSE)
  tibble::as_tibble(jsonlite::flatten(df))
}
