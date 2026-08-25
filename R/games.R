#' Download Games of a Lichess User
#'
#' Fetches game data for a given user from the Lichess API in NDJSON format.
#'
#' @details
#' **Lichess API Endpoint:** `GET /api/games/user/{username}`
#'
#' **Official Documentation:** <https://lichess.org/api#tag/Games/operation/apiGamesUser>
#'
#' Rate limits: Anonymous requests are throttled at 20 games/sec. Authenticated
#' OAuth requests receive 30 games/sec (or 60 games/sec when fetching your own games).
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
#' games <- lic_games_user("h8gi", perf_type = "bullet", max = 5)
#' games
lic_games_user <- function(username,
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

  resp <- tryCatch({
    httr2::req_perform(req)
  }, error = function(e) {
    if (grepl("429", e$message)) {
      cli::cli_warn(c(
        "!" = "Lichess game stream rate limit (429) encountered. Returning empty tibble.",
        "i" = "Wait a moment before retrying or use authenticated requests for higher limits."
      ))
      return(NULL)
    }
    rlang::abort(e$message, parent = e)
  })

  if (is.null(resp)) {
    return(tibble::tibble())
  }

  body <- httr2::resp_body_string(resp)

  if (!nzchar(trimws(body))) {
    return(tibble::tibble())
  }

  con <- textConnection(body)
  on.exit(close(con), add = TRUE)

  df <- jsonlite::stream_in(con, verbose = FALSE)
  tibble::as_tibble(jsonlite::flatten(df))
}

#' @rdname lic_games_user
#' @export
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
  lic_games_user(
    username = username,
    perf_type = perf_type,
    since = since,
    until = until,
    max = max,
    vs = vs,
    rated = rated,
    color = color,
    analysed = analysed,
    opening = opening,
    moves = moves,
    clocks = clocks,
    evals = evals,
    token = token
  )
}

#' Download a Single Lichess Game
#'
#' Retrieves full details of a specific game by its ID.
#'
#' @details
#' **Lichess API Endpoint:** `GET /game/export/{gameId}`
#'
#' **Official Documentation:** <https://lichess.org/api#tag/Games/operation/gamePgn>
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
#' lic_game("0tMlsM69")
lic_game <- function(game_id,
                     moves = TRUE,
                     clocks = TRUE,
                     evals = TRUE,
                     opening = TRUE,
                     token = lic_token()) {
  if (missing(game_id) || !is.character(game_id) || length(game_id) != 1 || !nzchar(game_id)) {
    cli::cli_abort("{.arg game_id} must be a single non-empty character string.")
  }

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

#' @rdname lic_game
#' @export
lic_get_game <- function(game_id,
                         moves = TRUE,
                         clocks = TRUE,
                         evals = TRUE,
                         opening = TRUE,
                         token = lic_token()) {
  lic_game(
    game_id = game_id,
    moves = moves,
    clocks = clocks,
    evals = evals,
    opening = opening,
    token = token
  )
}

#' Tidy Lichess Game Data
#'
#' Enriches and standardizes raw game data with user-perspective columns,
#' readable timestamps, and opponent details.
#'
#' @details
#' This is an **offline data transformation** function (no API network request).
#' It standardizes raw data returned by [lic_games_user()] or [lic_game()].
#'
#' @param data Raw game tibble returned by [lic_games_user()] or [lic_game()].
#' @param username Target username to calculate user-centric perspective. If `NULL`,
#'   user-centric columns (`user_color`, `user_result`, `win`) will not be computed.
#'
#' @return A tidy [tibble::tibble] with standardized column names and types.
#' @export
#' @examples
#' sample_raw <- tibble::tibble(
#'   id = "demo123",
#'   createdAt = 1730000000000,
#'   players.white.user.name = "h8gi",
#'   players.black.user.name = "opponent",
#'   players.white.rating = 2100L,
#'   players.black.rating = 2050L,
#'   winner = "white"
#' )
#' lic_tidy_games(sample_raw, username = "h8gi")
lic_tidy_games <- function(data, username = NULL) {
  if (nrow(data) == 0) {
    return(data)
  }

  res <- data

  if ("createdAt" %in% names(res)) {
    res$created_at <- lic_from_timestamp(res$createdAt)
  }
  if ("lastMoveAt" %in% names(res)) {
    res$last_move_at <- lic_from_timestamp(res$lastMoveAt)
  }

  # Standardize player names and handle AI opponents
  w_user <- if ("players.white.user.name" %in% names(res)) {
    res[["players.white.user.name"]]
  } else if ("players.white.user.id" %in% names(res)) {
    res[["players.white.user.id"]]
  } else {
    rep(NA_character_, nrow(res))
  }

  b_user <- if ("players.black.user.name" %in% names(res)) {
    res[["players.black.user.name"]]
  } else if ("players.black.user.id" %in% names(res)) {
    res[["players.black.user.id"]]
  } else {
    rep(NA_character_, nrow(res))
  }

  w_ai <- if ("players.white.aiLevel" %in% names(res)) res[["players.white.aiLevel"]] else rep(NA_integer_, nrow(res))
  b_ai <- if ("players.black.aiLevel" %in% names(res)) res[["players.black.aiLevel"]] else rep(NA_integer_, nrow(res))

  white_name <- dplyr::case_when(
    !is.na(w_user) & nzchar(w_user) ~ w_user,
    !is.na(w_ai) ~ paste0("Stockfish Level ", w_ai),
    TRUE ~ NA_character_
  )

  black_name <- dplyr::case_when(
    !is.na(b_user) & nzchar(b_user) ~ b_user,
    !is.na(b_ai) ~ paste0("Stockfish Level ", b_ai),
    TRUE ~ NA_character_
  )

  res$white_name <- white_name
  res$black_name <- black_name

  # Standardize opening columns if present
  if ("opening.name" %in% names(res) && !"opening_name" %in% names(res)) {
    res$opening_name <- res[["opening.name"]]
  }
  if ("opening.eco" %in% names(res) && !"opening_eco" %in% names(res)) {
    res$opening_eco <- res[["opening.eco"]]
  }

  # Standardize time control if clock info is present
  if ("clock.initial" %in% names(res) && "clock.increment" %in% names(res)) {
    res$time_control <- paste0(res[["clock.initial"]], "+", res[["clock.increment"]])
  }

  if (!is.null(username) && nzchar(username)) {
    target_user <- tolower(username)

    white_ids <- tolower(dplyr::coalesce(w_user, ""))
    black_ids <- tolower(dplyr::coalesce(b_user, ""))

    is_white <- (white_ids == target_user)
    is_black <- (black_ids == target_user)

    user_color <- dplyr::case_when(
      is_white ~ "white",
      is_black ~ "black",
      TRUE ~ NA_character_
    )

    winner <- if ("winner" %in% names(res)) dplyr::coalesce(res[["winner"]], "") else rep("", nrow(res))
    status <- if ("status" %in% names(res)) dplyr::coalesce(res[["status"]], "") else rep("", nrow(res))

    user_result <- dplyr::case_when(
      is.na(user_color) ~ NA_character_,
      status %in% c("aborted", "noStart") ~ "aborted",
      winner == user_color ~ "win",
      winner == "" ~ "draw",
      TRUE ~ "loss"
    )

    win <- dplyr::case_when(
      is.na(user_result) ~ NA,
      user_result == "win" ~ TRUE,
      user_result %in% c("loss", "draw") ~ FALSE,
      TRUE ~ NA
    )

    w_rat <- if ("players.white.rating" %in% names(res)) res[["players.white.rating"]] else rep(NA_integer_, nrow(res))
    b_rat <- if ("players.black.rating" %in% names(res)) res[["players.black.rating"]] else rep(NA_integer_, nrow(res))

    user_rating <- dplyr::case_when(
      user_color == "white" ~ w_rat,
      user_color == "black" ~ b_rat,
      TRUE ~ NA_integer_
    )
    opponent_rating <- dplyr::case_when(
      user_color == "white" ~ b_rat,
      user_color == "black" ~ w_rat,
      TRUE ~ NA_integer_
    )

    opponent_name <- dplyr::case_when(
      user_color == "white" ~ black_name,
      user_color == "black" ~ white_name,
      TRUE ~ NA_character_
    )

    w_diff <- if ("players.white.ratingDiff" %in% names(res)) res[["players.white.ratingDiff"]] else rep(NA_integer_, nrow(res))
    b_diff <- if ("players.black.ratingDiff" %in% names(res)) res[["players.black.ratingDiff"]] else rep(NA_integer_, nrow(res))

    user_rating_diff <- dplyr::case_when(
      user_color == "white" ~ w_diff,
      user_color == "black" ~ b_diff,
      TRUE ~ NA_integer_
    )

    res$user_color <- user_color
    res$user_result <- user_result
    res$win <- win
    res$user_rating <- user_rating
    res$opponent_rating <- opponent_rating
    res$opponent_name <- opponent_name
    res$user_rating_diff <- user_rating_diff
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
#' @details
#' This is an **offline data transformation** function (no API network request).
#' It unnests the move string (`moves`), clock array (`clocks`), and evaluation array (`evals`)
#' from game records into a tidy ply-by-ply dataset.
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
#'   \item{eval}{Stockfish evaluation in pawns (Centipawns / 100, if available)}
#'   \item{mate}{Forced mate in moves (e.g. `+2` for White mate in 2, `-1` for Black mate in 1)}
#'   \item{judgment}{Computer move assessment (`"Inaccuracy"`, `"Mistake"`, `"Blunder"`, or `NA`)}
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
      eval = numeric(),
      mate = integer(),
      judgment = character()
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

    clocks_vec <- if ("clocks" %in% names(data) && is.list(data$clocks)) {
      ck <- data$clocks[[i]]
      if (length(ck) >= num_plies) as.numeric(ck[seq_len(num_plies)]) / 100 else rep(NA_real_, num_plies)
    } else {
      rep(NA_real_, num_plies)
    }

    evals_vec <- rep(NA_real_, num_plies)
    mate_vec <- rep(NA_integer_, num_plies)
    judgment_vec <- rep(NA_character_, num_plies)

    if ("evals" %in% names(data) && is.list(data$evals)) {
      ev <- data$evals[[i]]
      if (is.data.frame(ev)) {
        n_ev <- min(nrow(ev), num_plies)
        if (n_ev > 0) {
          if ("cp" %in% names(ev)) {
            evals_vec[seq_len(n_ev)] <- as.numeric(ev$cp[seq_len(n_ev)]) / 100
          }
          if ("mate" %in% names(ev)) {
            mate_vec[seq_len(n_ev)] <- as.integer(ev$mate[seq_len(n_ev)])
          }
          if ("judgment.name" %in% names(ev)) {
            judgment_vec[seq_len(n_ev)] <- as.character(ev[["judgment.name"]][seq_len(n_ev)])
          } else if ("judgment" %in% names(ev) && is.data.frame(ev$judgment) && "name" %in% names(ev$judgment)) {
            judgment_vec[seq_len(n_ev)] <- as.character(ev$judgment$name[seq_len(n_ev)])
          }
        }
      }
    }

    rows[[length(rows) + 1]] <- tibble::tibble(
      game_id = gid,
      ply = plies,
      move_number = move_nums,
      color = colors,
      san = moves_vec,
      clock = clocks_vec,
      eval = evals_vec,
      mate = mate_vec,
      judgment = judgment_vec
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
      eval = numeric(),
      mate = integer(),
      judgment = character()
    ))
  }

  dplyr::bind_rows(rows)
}
