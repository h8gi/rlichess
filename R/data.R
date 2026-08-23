#' Lichess Chess Openings Database
#'
#' A dataset containing chess opening names, ECO (Encyclopaedia of Chess Openings)
#' codes, and move sequences (PGN format).
#'
#' @format A tibble with 3,378 rows and 3 variables:
#' \describe{
#'   \item{eco}{ECO code (e.g. "B20", "C50")}
#'   \item{name}{Name of the opening variation (e.g. "Sicilian Defense", "Italian Game")}
#'   \item{pgn}{Move sequence in PGN notation}
#' }
#' @source <https://github.com/lichess-org/chess-openings>
#' @examples
#' data(lichess_openings)
#' head(lichess_openings)
"lichess_openings"
