#' Get Lichess User Profile
#'
#' Fetches the public user profile from Lichess. By default (`raw = FALSE`), returns
#' a 1-row tidy [tibble::tibble] containing core user metadata, timestamps, and game counts.
#' If `raw = TRUE`, returns the full parsed JSON list.
#'
#' @details
#' **Lichess API Endpoint:** `GET /api/user/{username}`
#'
#' **Official Documentation:** <https://lichess.org/api#tag/Users/operation/apiUser>
#'
#' @param username Lichess username.
#' @param raw Logical. If `TRUE`, returns the raw nested list from Lichess API. Default is `FALSE`.
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A 1-row [tibble::tibble] (if `raw = FALSE`) or a nested `list` (if `raw = TRUE`).
#' @export
#' @examplesIf interactive()
#' lic_user("h8gi")
lic_user <- function(username, raw = FALSE, token = lic_token()) {
  if (missing(username) || !is.character(username) || length(username) != 1 || !nzchar(username)) {
    cli::cli_abort("{.arg username} must be a single non-empty character string.")
  }

  url <- paste0("https://lichess.org/api/user/", username)
  req <- lic_request(url, token = token) |>
    httr2::req_headers("Accept" = "application/json")

  resp <- httr2::req_perform(req)
  parsed <- jsonlite::fromJSON(httr2::resp_body_string(resp), simplifyVector = TRUE)

  if (isTRUE(raw)) {
    return(parsed)
  }

  # Build a tidy 1-row tibble
  count_info <- parsed$count %||% list()
  play_time <- parsed$playTime %||% list()
  profile_info <- parsed$profile %||% list()

  tibble::tibble(
    id = parsed$id %||% username,
    username = parsed$username %||% username,
    title = parsed$title %||% NA_character_,
    online = isTRUE(parsed$online),
    patron = isTRUE(parsed$patron),
    created_at = lic_from_timestamp(parsed$createdAt),
    seen_at = lic_from_timestamp(parsed$seenAt),
    bio = profile_info$bio %||% NA_character_,
    country = profile_info$country %||% NA_character_,
    location = profile_info$location %||% NA_character_,
    play_time_total_hours = round((play_time$total %||% 0) / 3600, 1),
    play_time_tv_hours = round((play_time$tv %||% 0) / 3600, 1),
    count_all = count_info$all %||% 0L,
    count_rated = count_info$rated %||% 0L,
    count_win = count_info$win %||% 0L,
    count_loss = count_info$loss %||% 0L,
    count_draw = count_info$draw %||% 0L,
    url = parsed$url %||% paste0("https://lichess.org/@/", username)
  )
}

#' @rdname lic_user
#' @export
lic_user_profile <- function(username, raw = FALSE, token = lic_token()) {
  lic_user(username = username, raw = raw, token = token)
}

#' Get Lichess User Performances Summary
#'
#' Extracts performance categories (e.g. bullet, blitz, rapid, puzzle) and ratings
#' for a user as a tidy tibble.
#'
#' @details
#' **Lichess API Endpoint:** Extracted from `GET /api/user/{username}`
#'
#' **Official Documentation:** <https://lichess.org/api#tag/Users/operation/apiUser>
#'
#' @param username Lichess username.
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A [tibble::tibble] with columns `perf`, `games`, `rating`, `rd`, `prog`, `prov`.
#' @export
#' @examplesIf interactive()
#' lic_user_perfs("h8gi")
lic_user_perfs <- function(username, token = lic_token()) {
  prof <- lic_user(username = username, raw = TRUE, token = token)

  if (is.null(prof$perfs)) {
    return(tibble::tibble(
      perf = character(),
      games = integer(),
      rating = integer(),
      rd = integer(),
      prog = integer(),
      prov = logical()
    ))
  }

  perfs_list <- prof$perfs
  perf_names <- names(perfs_list)

  rows <- lapply(perf_names, function(p) {
    item <- perfs_list[[p]]
    tibble::tibble(
      perf = p,
      games = item$games %||% 0L,
      rating = item$rating %||% NA_integer_,
      rd = item$rd %||% NA_integer_,
      prog = item$prog %||% 0L,
      prov = isTRUE(item$prov)
    )
  })

  dplyr::bind_rows(rows)
}

#' Get Rating History of a Lichess User
#'
#' Retrieves the daily rating history across performance types. Note that Lichess generates
#' up-to-date rating history on-demand for authenticated requests.
#'
#' @details
#' **Lichess API Endpoint:** `GET /api/user/{username}/rating-history`
#'
#' **Official Documentation:** <https://lichess.org/api#tag/Users/operation/apiUserRatingHistory>
#'
#' Rating history is generated on demand for authenticated requests (OAuth token).
#' Unauthenticated requests return a cached version if available, otherwise an empty dataset.
#'
#' @param username Lichess username.
#' @param perf_type Optional filter for performance types (e.g. `"bullet"`, `"blitz"`).
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A [tibble::tibble] with columns `username`, `perf`, `date`, and `rating`.
#' @export
#' @examplesIf interactive()
#' lic_user_rating_history("h8gi", perf_type = "bullet")
lic_user_rating_history <- function(username, perf_type = NULL, token = lic_token()) {
  if (missing(username) || !is.character(username) || length(username) != 1 || !nzchar(username)) {
    cli::cli_abort("{.arg username} must be a single non-empty character string.")
  }

  url <- paste0("https://lichess.org/api/user/", username, "/rating-history")
  req <- lic_request(url, token = token) |>
    httr2::req_headers("Accept" = "application/json")

  resp <- httr2::req_perform(req)
  parsed <- jsonlite::fromJSON(httr2::resp_body_string(resp), simplifyVector = FALSE)

  if (length(parsed) == 0) {
    if (is.null(token) || !nzchar(token)) {
      cli::cli_inform(c(
        "i" = "Rating history returned empty. Lichess requires an authenticated request (API token) to generate rating history on demand.",
        "*" = "Set `LICHESS_API_TOKEN` environment variable or provide `token` argument."
      ))
    }
    return(tibble::tibble(
      username = character(),
      perf = character(),
      date = as.Date(character()),
      rating = integer()
    ))
  }

  out_list <- list()

  for (item in parsed) {
    p_name <- tolower(item$name)
    if (!is.null(perf_type) && !(p_name %in% tolower(perf_type))) {
      next
    }

    points <- item$points
    if (length(points) == 0) {
      next
    }

    dates <- vapply(points, function(pt) {
      sprintf("%04d-%02d-%02d", pt[[1]], pt[[2]] + 1L, pt[[3]])
    }, FUN.VALUE = character(1))

    ratings <- vapply(points, function(pt) {
      as.integer(pt[[4]])
    }, FUN.VALUE = integer(1))

    out_list[[length(out_list) + 1]] <- tibble::tibble(
      username = username,
      perf = p_name,
      date = as.Date(dates),
      rating = ratings
    )
  }

  if (length(out_list) == 0) {
    return(tibble::tibble(
      username = character(),
      perf = character(),
      date = as.Date(character()),
      rating = integer()
    ))
  }

  dplyr::bind_rows(out_list)
}

#' @rdname lic_user_rating_history
#' @export
lic_rating_history <- function(username, perf_type = NULL, token = lic_token()) {
  lic_user_rating_history(username = username, perf_type = perf_type, token = token)
}

#' Get Detailed Performance Statistics of a Lichess User
#'
#' Retrieves in-depth stats for a specific game type (e.g. bullet, blitz, rapid),
#' including win/loss counts, streaks, highest/lowest ratings, and average opponent rating.
#'
#' @details
#' **Lichess API Endpoint:** `GET /api/user/{username}/perf/{perf}`
#'
#' **Official Documentation:** <https://lichess.org/api#tag/Users/operation/userPerf>
#'
#' @param username Lichess username.
#' @param perf Performance type (e.g. `"bullet"`, `"blitz"`, `"rapid"`, `"classical"`). Default is `"bullet"`.
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A list containing performance statistics.
#' @export
#' @examplesIf interactive()
#' stats <- lic_user_perf_stats("h8gi", perf = "bullet")
#' stats$stat$count
lic_user_perf_stats <- function(username, perf = "bullet", token = lic_token()) {
  if (missing(username) || !is.character(username) || length(username) != 1 || !nzchar(username)) {
    cli::cli_abort("{.arg username} must be a single non-empty character string.")
  }

  url <- paste0("https://lichess.org/api/user/", username, "/perf/", perf)
  req <- lic_request(url, token = token) |>
    httr2::req_headers("Accept" = "application/json")

  resp <- httr2::req_perform(req)
  jsonlite::fromJSON(httr2::resp_body_string(resp), simplifyVector = TRUE)
}

#' Get Real-time Status of Multiple Lichess Users
#'
#' Fetches the online, playing, and streaming status for up to 100 users in real-time.
#'
#' @details
#' **Lichess API Endpoint:** `GET /api/users/status`
#'
#' **Official Documentation:** <https://lichess.org/api#tag/Users/operation/apiUsersStatus>
#'
#' @param usernames Character vector of Lichess usernames (up to 100).
#' @param with_game_ids Logical. Whether to include current game ID if playing. Default is `FALSE`.
#' @param with_signal Logical. Whether to include network latency signal (1 = poor, 4 = great). Default is `FALSE`.
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A [tibble::tibble] containing user statuses.
#' @export
#' @examplesIf interactive()
#' lic_users_status(c("h8gi", "magnuscarlsen", "hikaru"))
lic_users_status <- function(usernames,
                             with_game_ids = FALSE,
                             with_signal = FALSE,
                             token = lic_token()) {
  if (missing(usernames) || !is.character(usernames) || length(usernames) == 0) {
    cli::cli_abort("{.arg usernames} must be a non-empty character vector.")
  }

  valid_users <- usernames[!is.na(usernames)]
  clean_users <- valid_users[nzchar(trimws(valid_users))]
  if (length(clean_users) == 0) {
    cli::cli_abort("{.arg usernames} must contain at least one valid username.")
  }

  if (length(clean_users) > 100) {
    cli::cli_warn("Lichess API supports a maximum of 100 user IDs per status request. Truncating to first 100.")
    clean_users <- clean_users[seq_len(100)]
  }

  url <- "https://lichess.org/api/users/status"
  req <- lic_request(url, token = token) |>
    httr2::req_headers("Accept" = "application/json")

  query_params <- list(
    ids = paste(clean_users, collapse = ",")
  )
  if (isTRUE(with_game_ids)) {
    query_params$withGameIds <- "true"
  }
  if (isTRUE(with_signal)) {
    query_params$withSignal <- "true"
  }

  req <- httr2::req_url_query(req, !!!query_params)
  resp <- httr2::req_perform(req)

  parsed <- jsonlite::fromJSON(httr2::resp_body_string(resp), simplifyVector = FALSE)

  if (length(parsed) == 0) {
    return(tibble::tibble(
      id = character(),
      name = character(),
      title = character(),
      online = logical(),
      playing = logical(),
      streaming = logical(),
      patron = logical(),
      playing_id = character(),
      signal = integer()
    ))
  }

  rows <- lapply(parsed, function(u) {
    tibble::tibble(
      id = u$id %||% NA_character_,
      name = u$name %||% u$id %||% NA_character_,
      title = u$title %||% NA_character_,
      online = isTRUE(u$online),
      playing = isTRUE(u$playing),
      streaming = isTRUE(u$streaming),
      patron = isTRUE(u$patron),
      playing_id = u$playingId %||% NA_character_,
      signal = if (!is.null(u$signal)) as.integer(u$signal) else NA_integer_
    )
  })

  dplyr::bind_rows(rows)
}

#' Get Crosstable (Head-to-Head Record) Between Two Users
#'
#' Retrieves the total number of games and scores between two players.
#'
#' @details
#' **Lichess API Endpoint:** `GET /api/crosstable/{user1}/{user2}`
#'
#' **Official Documentation:** <https://lichess.org/api#tag/Users/operation/apiCrosstableUser1User2>
#'
#' @param user1 First Lichess username.
#' @param user2 Second Lichess username.
#' @param matchup Logical. If `TRUE` and users are currently playing, includes current match details. Default is `FALSE`.
#' @param raw Logical. If `TRUE`, returns raw parsed JSON list. Default is `FALSE`.
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A 1-row [tibble::tibble] (if `raw = FALSE`) or a `list` (if `raw = TRUE`).
#' @export
#' @examplesIf interactive()
#' lic_user_crosstable("magnuscarlsen", "hikaru")
lic_user_crosstable <- function(user1,
                                user2,
                                matchup = FALSE,
                                raw = FALSE,
                                token = lic_token()) {
  if (missing(user1) || !is.character(user1) || length(user1) != 1 || !nzchar(user1)) {
    cli::cli_abort("{.arg user1} must be a single non-empty character string.")
  }
  if (missing(user2) || !is.character(user2) || length(user2) != 1 || !nzchar(user2)) {
    cli::cli_abort("{.arg user2} must be a single non-empty character string.")
  }

  url <- paste0("https://lichess.org/api/crosstable/", user1, "/", user2)
  req <- lic_request(url, token = token) |>
    httr2::req_headers("Accept" = "application/json")

  if (isTRUE(matchup)) {
    req <- httr2::req_url_query(req, matchup = "true")
  }

  resp <- httr2::req_perform(req)
  parsed <- jsonlite::fromJSON(httr2::resp_body_string(resp), simplifyVector = TRUE)

  if (isTRUE(raw)) {
    return(parsed)
  }

  scores <- parsed$users %||% list()
  u1_id <- tolower(user1)
  u2_id <- tolower(user2)

  u1_score <- as.numeric(scores[[u1_id]] %||% 0)
  u2_score <- as.numeric(scores[[u2_id]] %||% 0)

  tibble::tibble(
    user1 = user1,
    user2 = user2,
    user1_score = u1_score,
    user2_score = u2_score,
    nb_games = as.integer(parsed$nbGames %||% 0L)
  )
}

#' Get Lichess Leaderboard / Top Players
#'
#' Retrieves top-rated players on the leaderboard for a given game speed or variant.
#'
#' @details
#' **Lichess API Endpoint:** `GET /api/player/top/{count}/{perfType}`
#'
#' **Official Documentation:** <https://lichess.org/api#tag/Users/operation/playerTop>
#'
#' Supported `perf_type` options include: `"bullet"`, `"blitz"`, `"rapid"`, `"classical"`,
#' `"ultraBullet"`, `"chess960"`, `"crazyhouse"`, `"antichess"`, `"atomic"`, `"horde"`,
#' `"kingOfTheHill"`, `"racingKings"`, `"threeCheck"`.
#'
#' @param count Number of top players to retrieve (1 to 200). Default is 10.
#' @param perf_type Performance category or variant name. Default is `"blitz"`.
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A tidy [tibble::tibble] containing leaderboard rankings and player stats.
#' @export
#' @examplesIf interactive()
#' lic_leaderboard(perf_type = "rapid", count = 10)
lic_leaderboard <- function(perf_type = "blitz", count = 10, token = lic_token()) {
  if (is.null(perf_type) || !is.character(perf_type) || length(perf_type) != 1 || !nzchar(perf_type)) {
    cli::cli_abort("{.arg perf_type} must be a single non-empty character string.")
  }

  # Normalize common casing/format variations to official Lichess perfType identifiers
  perf_lookup <- c(
    "bullet" = "bullet",
    "blitz" = "blitz",
    "rapid" = "rapid",
    "classical" = "classical",
    "ultrabullet" = "ultraBullet",
    "chess960" = "chess960",
    "crazyhouse" = "crazyhouse",
    "antichess" = "antichess",
    "atomic" = "atomic",
    "horde" = "horde",
    "kingofthehill" = "kingOfTheHill",
    "racingkings" = "racingKings",
    "threecheck" = "threeCheck"
  )
  clean_key <- tolower(gsub("[_-]", "", trimws(perf_type)))
  if (clean_key %in% names(perf_lookup)) {
    perf_type <- perf_lookup[[clean_key]]
  }

  count <- as.integer(count)
  if (is.na(count) || count < 1 || count > 200) {
    cli::cli_abort("{.arg count} must be an integer between 1 and 200.")
  }

  url <- paste0("https://lichess.org/api/player/top/", count, "/", perf_type)
  req <- lic_request(url, token = token) |>
    httr2::req_headers("Accept" = "application/vnd.lichess.v3+json")

  resp <- httr2::req_perform(req)
  parsed <- jsonlite::fromJSON(httr2::resp_body_string(resp), simplifyVector = FALSE)

  users_list <- parsed$users %||% list()

  if (length(users_list) == 0) {
    return(tibble::tibble(
      rank = integer(),
      id = character(),
      username = character(),
      title = character(),
      rating = integer(),
      progress = integer(),
      online = logical(),
      patron = logical(),
      perf_type = character()
    ))
  }

  rows <- lapply(seq_along(users_list), function(idx) {
    u <- users_list[[idx]]
    p_info <- u$perfs[[perf_type]] %||% u$perfs[[1]] %||% list()
    tibble::tibble(
      rank = as.integer(idx),
      id = u$id %||% NA_character_,
      username = u$username %||% u$id %||% NA_character_,
      title = u$title %||% NA_character_,
      rating = as.integer(p_info$rating %||% NA_integer_),
      progress = as.integer(p_info$progress %||% 0L),
      online = isTRUE(u$online),
      patron = isTRUE(u$patron),
      perf_type = perf_type
    )
  })

  dplyr::bind_rows(rows)
}

#' @rdname lic_leaderboard
#' @export
lic_top_players <- function(perf_type = "blitz", count = 10, token = lic_token()) {
  lic_leaderboard(perf_type = perf_type, count = count, token = token)
}
