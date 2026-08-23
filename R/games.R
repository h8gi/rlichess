#' Download Games of a Lichess User
#'
#' Fetches game data for a given user from the Lichess API in NDJSON format.
#'
#' @param username Lichess username.
#' @param perf_type Optional game type filter (e.g. `"bullet"`, `"blitz"`, `"rapid"`, `"classical"`).
#' @param since Download games played since this timestamp or Date (e.g. `"2025-01-01"` or `as.Date(...)`).
#' @param until Download games played until this timestamp or Date.
#' @param max Maximum number of games to download. Default is `NULL` (all games).
#' @param vs Filter for games played against a specific opponent username.
#' @param rated Logical. Whether to fetch only rated games. Default is `NULL`.
#' @param color Filter for player's color: `"white"` or `"black"`.
#' @param analysed Logical. Whether to fetch only games with computer analysis.
#' @param opening Logical. Whether to include opening name and ECO code. Default is `TRUE`.
#' @param moves Logical. Whether to include PGN moves string. Default is `TRUE`.
#' @param clocks Logical. Whether to include clock times for each move. Default is `FALSE`.
#' @param evals Logical. Whether to include Stockfish evaluations. Default is `FALSE`.
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A [tibble::tibble] containing raw game records.
#' @export
#' @examples
#' \dontrun{
#' games <- lic_get_games("h8gi", perf_type = "bullet", max = 50)
#' }
lic_get_games <- function(username,
                          perf_type = NULL,
                          since = NULL,
                          until = NULL,
                          max = NULL,
                          vs = NULL,
                          rated = NULL,
                          color = NULL,
                          analysed = NULL,
                          opening = TRUE,
                          moves = TRUE,
                          clocks = FALSE,
                          evals = FALSE,
                          token = lic_token()) {
  if (missing(username) || !is.character(username) || length(username) != 1 || !nzchar(username)) {
    cli::cli_abort("{.arg username} must be a single non-empty character string.")
  }

  url <- paste0("https://lichess.org/api/games/user/", username)

  req <- lic_request(url, token = token) |>
    httr2::req_headers("Accept" = "application/x-ndjson")

  query_params <- list(
    opening = if (isTRUE(opening)) "true" else "false",
    moves = if (isTRUE(moves)) "true" else "false",
    clocks = if (isTRUE(clocks)) "true" else "false",
    evals = if (isTRUE(evals)) "true" else "false"
  )

  if (!is.null(perf_type)) query_params$perfType <- perf_type
  if (!is.null(max)) query_params$max <- as.character(max)
  if (!is.null(vs)) query_params$vs <- vs
  if (!is.null(color)) query_params$color <- tolower(color)
  if (!is.null(rated)) query_params$rated <- if (isTRUE(rated)) "true" else "false"
  if (!is.null(analysed)) query_params$analysed <- if (isTRUE(analysed)) "true" else "false"

  since_ts <- lic_to_timestamp(since)
  if (!is.null(since_ts)) query_params$since <- since_ts

  until_ts <- lic_to_timestamp(until)
  if (!is.null(until_ts)) query_params$until <- until_ts

  req <- httr2::req_url_query(req, !!!query_params)

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

#' Download a Single Lichess Game
#'
#' Retrieves full details of a specific game by its ID.
#'
#' @param game_id Lichess game ID (e.g. `"0tMlsM69"`).
#' @param moves Logical. Include move notation. Default is `TRUE`.
#' @param clocks Logical. Include move clock times. Default is `TRUE`.
#' @param evals Logical. Include Stockfish evaluations. Default is `TRUE`.
#' @param opening Logical. Include opening details. Default is `TRUE`.
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A single-row [tibble::tibble] containing game details.
#' @export
#' @examples
#' \dontrun{
#' game <- lic_get_game("0tMlsM69")
#' }
lic_get_game <- function(game_id,
                         moves = TRUE,
                         clocks = TRUE,
                         evals = TRUE,
                         opening = TRUE,
                         token = lic_token()) {
  if (missing(game_id) || !is.character(game_id) || length(game_id) != 1 || !nzchar(game_id)) {
    cli::cli_abort("{.arg game_id} must be a single non-empty character string.")
  }

  # Clean game ID (handle both 8-character ID and full URLs)
  game_id <- sub("^.*/", "", game_id)
  game_id <- substr(game_id, 1, 8)

  url <- paste0("https://lichess.org/game/export/", game_id)

  req <- lic_request(url, token = token) |>
    httr2::req_headers("Accept" = "application/json")

  query_params <- list(
    moves = if (isTRUE(moves)) "true" else "false",
    clocks = if (isTRUE(clocks)) "true" else "false",
    evals = if (isTRUE(evals)) "true" else "false",
    opening = if (isTRUE(opening)) "true" else "false"
  )

  req <- httr2::req_url_query(req, !!!query_params)
  resp <- httr2::req_perform(req)

  parsed <- jsonlite::fromJSON(httr2::resp_body_string(resp), simplifyVector = FALSE)
  df <- jsonlite::flatten(jsonlite::fromJSON(jsonlite::toJSON(list(parsed)), simplifyVector = TRUE))
  tibble::as_tibble(df)
}

#' Tidy Lichess Game Data
#'
#' Enriches and standardizes raw game data with user-perspective columns,
#' readable timestamps, and opponent details.
#'
#' @param data Raw game tibble returned by [lic_get_games()] or [lic_get_game()].
#' @param username Target username to calculate user-centric perspective. If `NULL`,
#'   user-centric columns (`user_color`, `user_result`, `win`) will not be computed.
#'
#' @return A tidy [tibble::tibble] with standardized column names and types.
#' @export
#' @examples
#' \dontrun{
#' raw <- lic_get_games("h8gi", max = 20)
#' games <- lic_tidy_games(raw, username = "h8gi")
#' }
lic_tidy_games <- function(data, username = NULL) {
  if (nrow(data) == 0) {
    return(data)
  }

  res <- data

  # Convert timestamps
  if ("createdAt" %in% names(res)) {
    res$created_at <- lic_from_timestamp(res$createdAt)
  }
  if ("lastMoveAt" %in% names(res)) {
    res$last_move_at <- lic_from_timestamp(res$lastMoveAt)
  }

  # Add user-centric perspective if username is provided
  if (!is.null(username) && nzchar(username)) {
    white_col <- if ("players.white.user.name" %in% names(res)) {
      "players.white.user.name"
    } else if ("players.white.user.id" %in% names(res)) {
      "players.white.user.id"
    } else {
      NA_character_
    }

    black_col <- if ("players.black.user.name" %in% names(res)) {
      "players.black.user.name"
    } else if ("players.black.user.id" %in% names(res)) {
      "players.black.user.id"
    } else {
      NA_character_
    }

    target_user <- tolower(username)

    white_users <- if (!is.na(white_col)) tolower(dplyr::coalesce(res[[white_col]], "")) else rep("", nrow(res))
    black_users <- if (!is.na(black_col)) tolower(dplyr::coalesce(res[[black_col]], "")) else rep("", nrow(res))

    winner <- if ("winner" %in% names(res)) dplyr::coalesce(res[["winner"]], "") else rep("", nrow(res))

    color <- dplyr::if_else(white_users == target_user, "white", "black")

    result <- dplyr::case_when(
      winner == "" ~ "draw",
      winner == color ~ "win",
      TRUE ~ "loss"
    )

    res$user_color <- color
    res$user_result <- result
    res$win <- (result == "win")

    # User and opponent ratings
    w_rat <- if ("players.white.rating" %in% names(res)) res[["players.white.rating"]] else rep(NA_integer_, nrow(res))
    b_rat <- if ("players.black.rating" %in% names(res)) res[["players.black.rating"]] else rep(NA_integer_, nrow(res))

    res$user_rating <- dplyr::if_else(color == "white", w_rat, b_rat)
    res$opponent_rating <- dplyr::if_else(color == "white", b_rat, w_rat)

    # Opponent username
    w_name <- if (!is.na(white_col)) res[[white_col]] else rep(NA_character_, nrow(res))
    b_name <- if (!is.na(black_col)) res[[black_col]] else rep(NA_character_, nrow(res))
    res$opponent_name <- dplyr::if_else(color == "white", b_name, w_name)

    # Rating diff
    w_diff <- if ("players.white.ratingDiff" %in% names(res)) res[["players.white.ratingDiff"]] else rep(NA_integer_, nrow(res))
    b_diff <- if ("players.black.ratingDiff" %in% names(res)) res[["players.black.ratingDiff"]] else rep(NA_integer_, nrow(res))
    res$user_rating_diff <- dplyr::if_else(color == "white", w_diff, b_diff)
  }

  tibble::as_tibble(res)
}

#' Normalize Game Data (Legacy Alias)
#'
#' Alias for [lic_tidy_games()] for backward compatibility.
#'
#' @param data Raw game tibble.
#' @param username Target username.
#' @return A tidy tibble.
#' @export
lic_normalize_games <- function(data, username) {
  lic_tidy_games(data, username = username)
}

#' Tidy Game Moves, Clocks, and Evaluations
#'
#' Expands game move sequences, clock times, and Stockfish evaluations into a
#' long-format tidy tibble where each row corresponds to one half-move (ply).
#'
#' @param data A game tibble containing an `id` and a `moves` column.
#'
#' @return A [tibble::tibble] with columns:
#'   \item{game_id}{Lichess game identifier}
#'   \item{ply}{Half-move index (1, 2, 3, ...)}
#'   \item{move_number}{Full-move number (1, 1, 2, 2, ...)}
#'   \item{color}{Color playing the move (`"white"` or `"black"`)}
#'   \item{san}{Standard Algebraic Notation of the move (e.g. `"e4"`, `"Nf3"`)}
#'   \item{clock}{Remaining clock time in seconds (if available)}
#'   \item{eval}{Stockfish evaluation in centipawns or mate (if available)}
#' @export
#' @examples
#' sample_game <- tibble::tibble(
#'   id = "demo123",
#'   moves = "e4 e5 Nf3 Nc6 Bb5"
#' )
#' lic_tidy_moves(sample_game)
lic_tidy_moves <- function(data) {
  if (nrow(data) == 0 || !"moves" %in% names(data)) {
    return(tibble::tibble(
      game_id = character(),
      ply = integer(),
      move_number = integer(),
      color = character(),
      san = character(),
      clock = numeric(),
      eval = numeric()
    ))
  }

  id_col <- if ("id" %in% names(data)) "id" else names(data)[[1]]

  rows <- list()

  for (i in seq_len(nrow(data))) {
    gid <- as.character(data[[id_col]][[i]])
    mv_str <- data$moves[[i]]

    if (is.null(mv_str) || is.na(mv_str) || !nzchar(trimws(mv_str))) {
      next
    }

    moves_vec <- strsplit(trimws(mv_str), "\\s+")[[1]]
    num_plies <- length(moves_vec)

    if (num_plies == 0) {
      next
    }

    plies <- seq_len(num_plies)
    move_nums <- (plies + 1L) %/% 2L
    colors <- ifelse(plies %% 2L == 1L, "white", "black")

    # Clocks
    clocks_vec <- if ("clocks" %in% names(data) && is.list(data$clocks)) {
      ck <- data$clocks[[i]]
      if (length(ck) >= num_plies) as.numeric(ck[seq_len(num_plies)]) / 100 else rep(NA_real_, num_plies)
    } else {
      rep(NA_real_, num_plies)
    }

    # Evals
    evals_vec <- if ("evals" %in% names(data) && is.list(data$evals)) {
      ev <- data$evals[[i]]
      if (is.data.frame(ev) && "cp" %in% names(ev)) {
        as.numeric(ev$cp[seq_len(min(nrow(ev), num_plies))]) / 100
      } else {
        rep(NA_real_, num_plies)
      }
    } else {
      rep(NA_real_, num_plies)
    }

    # Pad evals if shorter
    if (length(evals_vec) < num_plies) {
      evals_vec <- c(evals_vec, rep(NA_real_, num_plies - length(evals_vec)))
    }

    rows[[length(rows) + 1]] <- tibble::tibble(
      game_id = gid,
      ply = plies,
      move_number = move_nums,
      color = colors,
      san = moves_vec,
      clock = clocks_vec,
      eval = evals_vec
    )
  }

  if (length(rows) == 0) {
    return(tibble::tibble(
      game_id = character(),
      ply = integer(),
      move_number = integer(),
      color = character(),
      san = character(),
      clock = numeric(),
      eval = numeric()
    ))
  }

  dplyr::bind_rows(rows)
}
