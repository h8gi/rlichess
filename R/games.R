#' Download Games of a Lichess User
#'
#' Fetches game data for a given user from the Lichess API in NDJSON format.
#'
#' @param username Lichess username.
#' @param perf_type Optional game type filter (e.g. `"bullet"`, `"blitz"`, `"rapid"`, `"classical"`).
#' @param max Maximum number of games to download. Default is `NULL` (all games).
#' @param rated Logical. Whether to fetch only rated games. Default is `NULL`.
#' @param opening Logical. Whether to include opening name and ECO code. Default is `TRUE`.
#' @param moves Logical. Whether to include PGN moves. Default is `FALSE`.
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
                          max = NULL,
                          rated = NULL,
                          opening = TRUE,
                          moves = FALSE,
                          token = lic_token()) {
  if (missing(username) || !is.character(username) || length(username) != 1 || !nzchar(username)) {
    cli::cli_abort("{.arg username} must be a single non-empty character string.")
  }

  url <- paste0("https://lichess.org/api/games/user/", username)

  req <- lic_request(url, token = token) |>
    httr2::req_headers("Accept" = "application/x-ndjson")

  query_params <- list(
    opening = if (isTRUE(opening)) "true" else "false",
    moves = if (isTRUE(moves)) "true" else "false"
  )

  if (!is.null(perf_type)) {
    query_params$perfType <- perf_type
  }
  if (!is.null(max)) {
    query_params$max <- as.character(max)
  }
  if (!is.null(rated)) {
    query_params$rated <- if (isTRUE(rated)) "true" else "false"
  }

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

#' Normalize Game Data
#'
#' Enriches game data with user-perspective columns such as `color`, `win`, `result`, and `status`.
#'
#' @param data Raw game tibble returned by [lic_get_games()].
#' @param username Target username to calculate user-centric perspective.
#'
#' @return A [tibble::tibble] with normalized columns.
#' @export
#' @examples
#' \dontrun{
#' raw <- lic_get_games("h8gi", max = 20)
#' games <- lic_normalize_games(raw, username = "h8gi")
#' }
lic_normalize_games <- function(data, username) {
  if (nrow(data) == 0) {
    return(data)
  }

  white_col <- if ("players.white.user.name" %in% names(data)) "players.white.user.name" else "players.white.user.id"
  black_col <- if ("players.black.user.name" %in% names(data)) "players.black.user.name" else "players.black.user.id"

  target_user <- tolower(username)

  white_users <- tolower(dplyr::coalesce(data[[white_col]], ""))
  black_users <- tolower(dplyr::coalesce(data[[black_col]], ""))

  winner <- if ("winner" %in% names(data)) dplyr::coalesce(data[["winner"]], "") else rep("", nrow(data))

  color <- dplyr::if_else(white_users == target_user, "white", "black")

  result <- dplyr::case_when(
    winner == "" ~ "draw",
    winner == color ~ "win",
    TRUE ~ "loss"
  )

  data |>
    dplyr::mutate(
      user_color = color,
      user_result = result,
      win = (result == "win")
    )
}
