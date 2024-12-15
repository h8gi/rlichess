## win or lose
## https://github.com/lichess-org/scalachess/blob/0a7d6f2c63b1ca06cd3c958ed3264e738af5c5f6/src/main/scala/Status.scala#L50
## val finishedWithWinner = List(Mate, Resign, Timeout, Outoftime, Cheat, NoStart, VariantEnd)
## finished_with_winner <- c("mate", "resign", "timeout", "outoftime", "cheated", "noStart", "variantEnd")
## timeout: when player leaves the game
## outoftime: clock flag

read_game_data <- function(filename) {
  json_lines <- readLines(file(filename))
  map(json_lines, ~ unlist(fromJSON(.x))) |> bind_rows() |> type_convert()
}

normalize_game_data <- function(data, username) {
  data |>
    replace_na(list(
      players.white.user.name = "",
      players.black.user.name = ""
    )) |>
    mutate(
      createdAt = as_datetime(createdAt / 1000),
      lastMoveAt = as_datetime(lastMoveAt / 1000),
      color = if_else(players.white.user.name == username, "white", "black"),
      win = color == winner)
}

## data |>
##   group_by(color, opening.name) |>
##   summarise(n = n(), winrate = sum(win, na.rm = TRUE) / n()) |>
##   arrange(desc(n)) |>
##   filter(n > 50) |>
##   group_split() |> map(knitr::kable)
