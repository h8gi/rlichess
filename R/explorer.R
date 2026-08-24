#' Query Lichess Opening Explorer Database
#'
#' Retrieves opening statistics (win rates, popular candidate moves) from the Lichess game database.
#'
#' @param fen FEN position string. Default is the starting chess position.
#' @param play Comma-separated or vector of move sequence in UCI or SAN (e.g. `"e2e4,e7e5"` or `c("e4", "e5")`).
#' @param variant Chess variant (`"standard"`, `"chess960"`, etc.). Default is `"standard"`.
#' @param ratings Integer vector of rating brackets (e.g. `c(1600, 1800, 2000, 2200, 2500)`).
#' @param speeds Character vector of game speeds (e.g. `c("bullet", "blitz", "rapid", "classical")`).
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A list containing aggregate stats (`white`, `draws`, `black`) and a tidy [tibble::tibble] of candidate `moves`.
#' @export
#' @examples
#' \dontrun{
#' exp <- lic_explorer_lichess(play = "e4,c5")
#' exp$moves
#' }
lic_explorer_lichess <- function(fen = NULL,
                                play = NULL,
                                variant = "standard",
                                ratings = c(2000, 2200, 2500),
                                speeds = c("blitz", "rapid"),
                                token = lic_token()) {
  url <- "https://explorer.lichess.ovh/lichess"
  req <- lic_request(url, token = token) |>
    httr2::req_headers("Accept" = "application/json")

  query_params <- list(
    variant = variant
  )

  if (!is.null(fen)) query_params$fen <- fen
  if (!is.null(play)) {
    if (length(play) > 1) play <- paste(play, collapse = ",")
    query_params$play <- play
  }
  if (!is.null(ratings)) {
    query_params$ratings <- paste(ratings, collapse = ",")
  }
  if (!is.null(speeds)) {
    query_params$speeds <- paste(speeds, collapse = ",")
  }

  req <- httr2::req_url_query(req, !!!query_params)
  resp <- httr2::req_perform(req)

  parsed <- jsonlite::fromJSON(httr2::resp_body_string(resp), simplifyVector = TRUE)

  moves_df <- if (!is.null(parsed$moves) && length(parsed$moves) > 0) {
    tibble::as_tibble(parsed$moves)
  } else {
    tibble::tibble(
      uci = character(),
      san = character(),
      white = integer(),
      draws = integer(),
      black = integer(),
      averageRating = integer()
    )
  }

  list(
    white = parsed$white %||% 0L,
    draws = parsed$draws %||% 0L,
    black = parsed$black %||% 0L,
    moves = moves_df,
    opening = parsed$opening %||% NULL
  )
}

#' @rdname lic_explorer_lichess
#' @export
lic_opening_explorer <- function(fen = NULL,
                                 play = NULL,
                                 variant = "standard",
                                 ratings = c(2000, 2200, 2500),
                                 speeds = c("blitz", "rapid"),
                                 token = lic_token()) {
  lic_explorer_lichess(
    fen = fen,
    play = play,
    variant = variant,
    ratings = ratings,
    speeds = speeds,
    token = token
  )
}

#' Query Lichess Masters Opening Explorer
#'
#' Retrieves opening statistics from historical FIDE master-level games (2200+ FIDE).
#'
#' @param fen FEN position string.
#' @param play Move sequence in UCI or SAN.
#' @param since Year from which to filter games (e.g. 1952).
#' @param until Year until which to filter games.
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A list containing aggregate stats (`white`, `draws`, `black`), candidate `moves` tibble, and top `topGames`.
#' @export
#' @examples
#' \dontrun{
#' masters <- lic_explorer_masters(play = "e4,c5")
#' masters$moves
#' }
lic_explorer_masters <- function(fen = NULL,
                                 play = NULL,
                                 since = NULL,
                                 until = NULL,
                                 token = lic_token()) {
  url <- "https://explorer.lichess.ovh/masters"
  req <- lic_request(url, token = token) |>
    httr2::req_headers("Accept" = "application/json")

  query_params <- list()
  if (!is.null(fen)) query_params$fen <- fen
  if (!is.null(play)) {
    if (length(play) > 1) play <- paste(play, collapse = ",")
    query_params$play <- play
  }
  if (!is.null(since)) query_params$since <- as.character(since)
  if (!is.null(until)) query_params$until <- as.character(until)

  req <- httr2::req_url_query(req, !!!query_params)
  resp <- httr2::req_perform(req)

  parsed <- jsonlite::fromJSON(httr2::resp_body_string(resp), simplifyVector = TRUE)

  moves_df <- if (!is.null(parsed$moves) && length(parsed$moves) > 0) {
    tibble::as_tibble(parsed$moves)
  } else {
    tibble::tibble()
  }

  list(
    white = parsed$white %||% 0L,
    draws = parsed$draws %||% 0L,
    black = parsed$black %||% 0L,
    moves = moves_df,
    topGames = if (!is.null(parsed$topGames)) tibble::as_tibble(parsed$topGames) else tibble::tibble(),
    opening = parsed$opening %||% NULL
  )
}

#' @rdname lic_explorer_masters
#' @export
lic_masters_explorer <- function(fen = NULL,
                                 play = NULL,
                                 since = NULL,
                                 until = NULL,
                                 token = lic_token()) {
  lic_explorer_masters(
    fen = fen,
    play = play,
    since = since,
    until = until,
    token = token
  )
}

#' Query Player Opening Explorer Database
#'
#' Retrieves opening statistics for a specific player's game history.
#'
#' @param username Target player's Lichess username.
#' @param color Player color perspective (`"white"` or `"black"`). Default is `"white"`.
#' @param play Move sequence in UCI or SAN.
#' @param fen FEN position string.
#' @param speeds Character vector of game speeds (e.g. `c("blitz", "rapid", "bullet")`).
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A list containing aggregate stats (`white`, `draws`, `black`) and candidate `moves` tibble.
#' @export
#' @examples
#' \dontrun{
#' player_exp <- lic_explorer_player("h8gi", color = "white", play = "e4")
#' player_exp$moves
#' }
lic_explorer_player <- function(username,
                                color = "white",
                                play = NULL,
                                fen = NULL,
                                speeds = c("blitz", "rapid", "bullet"),
                                token = lic_token()) {
  if (missing(username) || !is.character(username) || length(username) != 1 || !nzchar(username)) {
    cli::cli_abort("{.arg username} must be a single non-empty character string.")
  }

  url <- "https://explorer.lichess.ovh/player"
  req <- lic_request(url, token = token) |>
    httr2::req_headers("Accept" = "application/json")

  query_params <- list(
    player = username,
    color = tolower(color)
  )

  if (!is.null(fen)) query_params$fen <- fen
  if (!is.null(play)) {
    if (length(play) > 1) play <- paste(play, collapse = ",")
    query_params$play <- play
  }
  if (!is.null(speeds)) {
    query_params$speeds <- paste(speeds, collapse = ",")
  }

  req <- httr2::req_url_query(req, !!!query_params)
  resp <- httr2::req_perform(req)

  parsed <- jsonlite::fromJSON(httr2::resp_body_string(resp), simplifyVector = TRUE)

  moves_df <- if (!is.null(parsed$moves) && length(parsed$moves) > 0) {
    tibble::as_tibble(parsed$moves)
  } else {
    tibble::tibble()
  }

  list(
    white = parsed$white %||% 0L,
    draws = parsed$draws %||% 0L,
    black = parsed$black %||% 0L,
    moves = moves_df,
    opening = parsed$opening %||% NULL
  )
}
