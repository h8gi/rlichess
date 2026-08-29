#' Calculate Opening Statistics
#'
#' Summarizes game statistics grouped by opening and player color.
#'
#' @details
#' This is an **offline data aggregation** function (no API network request).
#' It calculates win rates, chess score rates, game counts, and results from tidy game data.
#'
#' @param data Normalized game data returned by [lic_tidy_games()].
#' @param min_games Minimum number of games required to include in the summary.
#'
#' @return A [tibble::tibble] with opening names, total games (`n`), wins (`wins`),
#'   losses (`losses`), draws (`draws`), win rate (`winrate`), score (`score`), and score rate (`score_rate`).
#' @export
#' @examples
#' sample_games <- tibble::tibble(
#'   user_color = c("white", "white", "black"),
#'   opening.name = c("Ruy Lopez", "Ruy Lopez", "Sicilian Defense"),
#'   opening.eco = c("C60", "C60", "B20"),
#'   user_result = c("win", "draw", "loss")
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
      winrate = numeric(),
      score = numeric(),
      score_rate = numeric()
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
      score = .data$wins + 0.5 * .data$draws,
      score_rate = .data$score / .data$n,
      .groups = "drop"
    ) |>
    dplyr::filter(.data$n >= min_games) |>
    dplyr::arrange(dplyr::desc(.data$n))
}

#' Calculate Head-to-Head Opponent Statistics
#'
#' Aggregates game records grouped by opponent name to view head-to-head records.
#'
#' @details
#' This is an **offline data aggregation** function (no API network request).
#'
#' @param data Tidy game data returned by [lic_tidy_games()].
#' @param min_games Minimum number of games played against the opponent to include. Default is 1.
#'
#' @return A [tibble::tibble] with columns: `opponent_name`, `n`, `wins`, `losses`, `draws`,
#'   `winrate`, `score`, `score_rate`, `avg_opponent_rating`, and `rating_diff_total`.
#' @export
#' @examples
#' sample_games <- tibble::tibble(
#'   opponent_name = c("MagnusCarlsen", "MagnusCarlsen", "Hikaru"),
#'   user_result = c("loss", "draw", "win"),
#'   opponent_rating = c(2850L, 2850L, 2820L),
#'   user_rating_diff = c(-4L, 1L, 8L)
#' )
#' lic_stats_opponents(sample_games, min_games = 1)
lic_stats_opponents <- function(data, min_games = 1) {
  if (nrow(data) == 0 || !"opponent_name" %in% names(data)) {
    return(tibble::tibble(
      opponent_name = character(),
      n = integer(),
      wins = integer(),
      losses = integer(),
      draws = integer(),
      winrate = numeric(),
      score = numeric(),
      score_rate = numeric(),
      avg_opponent_rating = numeric(),
      rating_diff_total = integer()
    ))
  }

  has_opp_rating <- "opponent_rating" %in% names(data)
  has_user_diff <- "user_rating_diff" %in% names(data)

  data |>
    dplyr::filter(!is.na(.data$opponent_name) & nzchar(.data$opponent_name)) |>
    dplyr::group_by(opponent_name = .data$opponent_name) |>
    dplyr::summarise(
      n = dplyr::n(),
      wins = if ("user_result" %in% names(data)) sum(.data$user_result == "win", na.rm = TRUE) else 0L,
      losses = if ("user_result" %in% names(data)) sum(.data$user_result == "loss", na.rm = TRUE) else 0L,
      draws = if ("user_result" %in% names(data)) sum(.data$user_result == "draw", na.rm = TRUE) else 0L,
      winrate = .data$wins / .data$n,
      score = .data$wins + 0.5 * .data$draws,
      score_rate = .data$score / .data$n,
      avg_opponent_rating = if (has_opp_rating) round(mean(.data$opponent_rating, na.rm = TRUE), 1) else NA_real_,
      rating_diff_total = if (has_user_diff) sum(.data$user_rating_diff, na.rm = TRUE) else NA_integer_,
      .groups = "drop"
    ) |>
    dplyr::filter(.data$n >= min_games) |>
    dplyr::arrange(dplyr::desc(.data$n))
}

#' Calculate Performance Statistics by Time and Day
#'
#' Aggregates game results by hour of the day, day of the week, or both.
#'
#' @details
#' This is an **offline data aggregation** function (no API network request).
#' Useful for detecting peak performance hours or tilt patterns.
#'
#' @param data Tidy game data containing `created_at` (POSIXct).
#' @param by Aggregation breakdown: `"hour"` (0..23), `"wday"` (Mon..Sun), or `"both"`. Default is `"hour"`.
#' @param tz Time zone string used for formatting hours and days (e.g. `"UTC"`, `"America/New_York"`, `"Asia/Tokyo"`). Default is `"UTC"`.
#'
#' @return A [tibble::tibble] containing game counts, win rates, scores, and rating changes grouped by the chosen time unit.
#' @export
#' @examples
#' sample_games <- tibble::tibble(
#'   created_at = as.POSIXct(
#'     c("2025-01-01 14:00:00", "2025-01-01 14:30:00", "2025-01-02 21:00:00"),
#'     tz = "UTC"
#'   ),
#'   user_result = c("win", "win", "loss"),
#'   user_rating_diff = c(10L, 8L, -9L)
#' )
#' lic_stats_time(sample_games, by = "hour")
lic_stats_time <- function(data, by = c("hour", "wday", "both"), tz = "UTC") {
  by <- match.arg(by)
  day_names <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")

  if (nrow(data) == 0 || !"created_at" %in% names(data)) {
    cols <- switch(by,
      "hour" = list(hour = integer()),
      "wday" = list(wday = factor(character(), levels = day_names)),
      "both" = list(wday = factor(character(), levels = day_names), hour = integer())
    )
    return(tibble::tibble(
      !!!cols,
      n = integer(),
      wins = integer(),
      losses = integer(),
      draws = integer(),
      winrate = numeric(),
      score = numeric(),
      score_rate = numeric(),
      rating_diff_total = integer()
    ))
  }

  has_user_diff <- "user_rating_diff" %in% names(data)

  df <- data |>
    dplyr::filter(!is.na(.data$created_at))

  if (nrow(df) == 0) {
    cols <- switch(by,
      "hour" = list(hour = integer()),
      "wday" = list(wday = factor(character(), levels = day_names)),
      "both" = list(wday = factor(character(), levels = day_names), hour = integer())
    )
    return(tibble::tibble(
      !!!cols,
      n = integer(),
      wins = integer(),
      losses = integer(),
      draws = integer(),
      winrate = numeric(),
      score = numeric(),
      score_rate = numeric(),
      rating_diff_total = integer()
    ))
  }

  # Extract formatted hour and weekday in the specified tz (locale independent)
  hour_vec <- as.integer(strftime(df$created_at, "%H", tz = tz))
  wday_num <- as.integer(strftime(df$created_at, "%u", tz = tz)) # 1 (Mon) to 7 (Sun)
  wday_vec <- day_names[wday_num]

  df$hour <- hour_vec
  df$wday <- factor(wday_vec, levels = day_names)

  grp_cols <- switch(by,
    "hour" = "hour",
    "wday" = "wday",
    "both" = c("wday", "hour")
  )

  res <- df |>
    dplyr::group_by(dplyr::across(dplyr::all_of(grp_cols))) |>
    dplyr::summarise(
      n = dplyr::n(),
      wins = if ("user_result" %in% names(df)) sum(.data$user_result == "win", na.rm = TRUE) else 0L,
      losses = if ("user_result" %in% names(df)) sum(.data$user_result == "loss", na.rm = TRUE) else 0L,
      draws = if ("user_result" %in% names(df)) sum(.data$user_result == "draw", na.rm = TRUE) else 0L,
      winrate = .data$wins / .data$n,
      score = .data$wins + 0.5 * .data$draws,
      score_rate = .data$score / .data$n,
      rating_diff_total = if (has_user_diff) sum(.data$user_rating_diff, na.rm = TRUE) else NA_integer_,
      .groups = "drop"
    )

  if (by == "hour") {
    res <- dplyr::arrange(res, .data$hour)
  } else if (by == "wday") {
    res <- dplyr::arrange(res, .data$wday)
  } else {
    res <- dplyr::arrange(res, .data$wday, .data$hour)
  }

  res
}

#' Calculate Clock Usage and Time Trouble Statistics
#'
#' Analyzes move time duration and remaining clock time distribution per game and color.
#'
#' @details
#' This is an **offline data aggregation** function (no API network request).
#' Requires ply-by-ply move data returned by [lic_tidy_moves()].
#'
#' @param data Ply-by-ply move data returned by [lic_tidy_moves()] containing `game_id`, `color`, and `clock`.
#' @param threshold_time_trouble Threshold in seconds below which a move is counted as time trouble. Default is 10.
#'
#' @return A [tibble::tibble] with columns: `game_id`, `color`, `moves_count`, `avg_move_time`,
#'   `max_move_time`, `min_clock`, and `time_trouble_moves`.
#' @export
#' @examples
#' sample_moves <- tibble::tibble(
#'   game_id = rep("g1", 6),
#'   ply = 1:6,
#'   color = c("white", "black", "white", "black", "white", "black"),
#'   clock = c(180, 179, 175, 170, 160, 155)
#' )
#' lic_stats_clocks(sample_moves)
lic_stats_clocks <- function(data, threshold_time_trouble = 10) {
  if (nrow(data) == 0 || !"clock" %in% names(data) || !"game_id" %in% names(data) || !"color" %in% names(data)) {
    return(tibble::tibble(
      game_id = character(),
      color = character(),
      moves_count = integer(),
      avg_move_time = numeric(),
      max_move_time = numeric(),
      min_clock = numeric(),
      time_trouble_moves = integer()
    ))
  }

  # Compute per-move duration within each game_id and color
  df <- data |>
    dplyr::filter(!is.na(.data$clock)) |>
    dplyr::group_by(.data$game_id, .data$color) |>
    dplyr::mutate(
      prev_clock = dplyr::lag(.data$clock),
      move_time = pmax(0, .data$prev_clock - .data$clock)
    )

  df |>
    dplyr::summarise(
      moves_count = dplyr::n(),
      avg_move_time = if (all(is.na(.data$move_time))) NA_real_ else round(mean(.data$move_time, na.rm = TRUE), 1),
      max_move_time = if (all(is.na(.data$move_time))) NA_real_ else round(max(.data$move_time, na.rm = TRUE), 1),
      min_clock = if (all(is.na(.data$clock))) NA_real_ else round(min(.data$clock, na.rm = TRUE), 1),
      time_trouble_moves = sum(.data$clock <= threshold_time_trouble, na.rm = TRUE),
      .groups = "drop"
    )
}
