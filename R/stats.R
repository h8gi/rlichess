#' Calculate Opening Statistics
#'
#' Summarizes game statistics grouped by opening and player color.
#'
#' @details
#' This is an **offline data aggregation** function (no API network request).
#' It calculates win rates, game counts, and results from normalized game data.
#'
#' @param data Normalized game data returned by [lic_tidy_games()].
#' @param min_games Minimum number of games required to include in the summary.
#'
#' @return A [tibble::tibble] with opening names, total games (`n`), wins (`wins`),
#'   losses (`losses`), draws (`draws`), and win rate (`winrate`).
#' @export
#' @examples
#' sample_games <- tibble::tibble(
#'   user_color = c("white", "white", "black"),
#'   opening.name = c("Ruy Lopez", "Ruy Lopez", "Sicilian Defense"),
#'   opening.eco = c("C60", "C60", "B20"),
#'   user_result = c("win", "win", "loss")
#' )
#' lic_stats_openings(sample_games, min_games = 1)
lic_stats_openings <- function(data, min_games = 10) {
  if (nrow(data) == 0) {
    return(tibble::tibble(
      user_color = character(),
      opening_name = character(),
      opening_eco = character(),
      n = integer(),
      wins = integer(),
      losses = integer(),
      draws = integer(),
      winrate = numeric()
    ))
  }

  opening_col <- if ("opening_name" %in% names(data)) {
    "opening_name"
  } else if ("opening.name" %in% names(data)) {
    "opening.name"
  } else {
    NA_character_
  }

  eco_col <- if ("opening_eco" %in% names(data)) {
    "opening_eco"
  } else if ("opening.eco" %in% names(data)) {
    "opening.eco"
  } else {
    NA_character_
  }

  if (is.na(opening_col)) {
    cli::cli_abort("Column {.val opening_name} or {.val opening.name} not found in the input data.")
  }

  data |>
    dplyr::filter(!is.na(.data[[opening_col]]) & nzchar(.data[[opening_col]])) |>
    dplyr::group_by(
      user_color = .data$user_color,
      opening_name = .data[[opening_col]],
      opening_eco = if (!is.na(eco_col)) .data[[eco_col]] else ""
    ) |>
    dplyr::summarise(
      n = dplyr::n(),
      wins = sum(.data$user_result == "win", na.rm = TRUE),
      losses = sum(.data$user_result == "loss", na.rm = TRUE),
      draws = sum(.data$user_result == "draw", na.rm = TRUE),
      winrate = .data$wins / .data$n,
      .groups = "drop"
    ) |>
    dplyr::filter(.data$n >= min_games) |>
    dplyr::arrange(dplyr::desc(.data$n))
}
