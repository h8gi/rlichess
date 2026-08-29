#' Export Study PGN from Lichess
#'
#' Downloads PGN representation of a study or an individual study chapter from Lichess.
#' For private or unlisted studies, an authenticated API token with `study:read` scope is required.
#'
#' @details
#' **Lichess API Endpoint:** `GET /api/study/{studyId}.pgn` or `GET /api/study/{studyId}/{chapterId}.pgn`
#'
#' **Official Documentation:** <https://lichess.org/api#tag/Studies/operation/studyAllChaptersPgn>
#'
#' @param study_id 8-character study identifier (or study URL).
#' @param chapter_id Optional chapter identifier. If `NULL` (default), exports all chapters of the study.
#' @param clocks Logical. Include clock comments in PGN moves when available. Default is `TRUE`.
#' @param comments Logical. Include analysis annotations and comments when available. Default is `TRUE`.
#' @param variations Logical. Include non-mainline variation branches when available. Default is `TRUE`.
#' @param orientation Logical. Include `Orientation` PGN tag with chapter orientation. Default is `FALSE`.
#' @param token API access token. By default, retrieved via [lic_token()].
#'
#' @return A character string containing the exported PGN text.
#' @export
#' @examplesIf interactive()
#' pgn <- lic_study_pgn("fXQ9y9rA")
#' cat(substr(pgn, 1, 300))
lic_study_pgn <- function(study_id,
                          chapter_id = NULL,
                          clocks = TRUE,
                          comments = TRUE,
                          variations = TRUE,
                          orientation = FALSE,
                          token = lic_token()) {
  if (missing(study_id) || !is.character(study_id) || length(study_id) != 1 || !nzchar(study_id)) {
    cli::cli_abort("{.arg study_id} must be a single non-empty character string.")
  }

  clean_study_id <- sub("^.*/", "", trimws(study_id))
  clean_study_id <- sub("\\.pgn$", "", clean_study_id)

  if (!nzchar(clean_study_id)) {
    cli::cli_abort("{.arg study_id} is invalid.")
  }

  url <- if (!is.null(chapter_id) && nzchar(chapter_id)) {
    clean_chapter_id <- sub("^.*/", "", trimws(chapter_id))
    clean_chapter_id <- sub("\\.pgn$", "", clean_chapter_id)
    paste0("https://lichess.org/api/study/", clean_study_id, "/", clean_chapter_id, ".pgn")
  } else {
    paste0("https://lichess.org/api/study/", clean_study_id, ".pgn")
  }

  req <- lic_request(url, token = token) |>
    httr2::req_headers("Accept" = "application/x-chess-pgn")

  query_params <- list(
    clocks = if (isTRUE(clocks)) "true" else "false",
    comments = if (isTRUE(comments)) "true" else "false",
    variations = if (isTRUE(variations)) "true" else "false",
    orientation = if (isTRUE(orientation)) "true" else "false"
  )

  req <- httr2::req_url_query(req, !!!query_params)
  resp <- httr2::req_perform(req)

  httr2::resp_body_string(resp)
}
