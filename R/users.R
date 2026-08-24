#' Get Lichess User Profile
#'
#' Fetches the public user profile from Lichess.
#'
#' @param username Lichess username.
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A list containing user metadata and performance summaries.
#' @export
#' @examples
#' \dontrun{
#' user <- lic_user("h8gi")
#' user$username
#' }
lic_user <- function(username, token = lic_token()) {
  if (missing(username) || !is.character(username) || length(username) != 1 || !nzchar(username)) {
    cli::cli_abort("{.arg username} must be a single non-empty character string.")
  }

  url <- paste0("https://lichess.org/api/user/", username)
  req <- lic_request(url, token = token) |>
    httr2::req_headers("Accept" = "application/json")

  resp <- httr2::req_perform(req)
  jsonlite::fromJSON(httr2::resp_body_string(resp), simplifyVector = TRUE)
}

#' @rdname lic_user
#' @export
lic_user_profile <- function(username, token = lic_token()) {
  lic_user(username = username, token = token)
}

#' Get Lichess User Performances Summary
#'
#' Extracts performance categories (e.g. bullet, blitz, rapid, puzzle) and ratings
#' for a user as a tidy tibble.
#'
#' @param username Lichess username.
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A [tibble::tibble] with columns `perf`, `games`, `rating`, `rd`, `prog`, `prov`.
#' @export
#' @examples
#' \dontrun{
#' perfs <- lic_user_perfs("h8gi")
#' }
lic_user_perfs <- function(username, token = lic_token()) {
  prof <- lic_user(username = username, token = token)

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
#' @param username Lichess username.
#' @param perf_type Optional filter for performance types (e.g. `"bullet"`, `"blitz"`).
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A [tibble::tibble] with columns `username`, `perf`, `date`, and `rating`.
#' @export
#' @examples
#' \dontrun{
#' hist <- lic_user_rating_history("h8gi", perf_type = "bullet")
#' }
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
#' @param username Lichess username.
#' @param perf Performance type (e.g. `"bullet"`, `"blitz"`, `"rapid"`, `"classical"`). Default is `"bullet"`.
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A list containing performance statistics.
#' @export
#' @examples
#' \dontrun{
#' stats <- lic_user_perf_stats("h8gi", perf = "bullet")
#' stats$stat$count
#' }
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
