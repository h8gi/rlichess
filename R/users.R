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
#' @examples
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
#' @examples
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
#' @examples
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
#' @examples
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
