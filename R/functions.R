## win or lose
## https://github.com/lichess-org/scalachess/blob/0a7d6f2c63b1ca06cd3c958ed3264e738af5c5f6/src/main/scala/Status.scala#L50
## val finishedWithWinner = List(Mate, Resign, Timeout, Outoftime, Cheat, NoStart, VariantEnd)
## finished_with_winner <- c("mate", "resign", "timeout", "outoftime", "cheated", "noStart", "variantEnd")
## timeout: when player leaves the game
## outoftime: clock flag

## download game data from lichess.org
get_game_data <- function(username, access_token) {
  h <- new_handle() |> handle_setheaders(
    "Authorization" = str_c("Bearer ", access_token),
    "Accept" = "application/x-ndjson"
  )

  url <- "https://lichess.org/api/games/user/" |> str_c(username) |>
    param_set(key = "perfType", value = "bullet") |>
    param_set(key = "opening", value = "true") |>
    param_set(key = "moves", value = "false") ## |>
    ## param_set(key = "max", value = 500)

  ## Full JSON IO stream from URL to file connection.
  tmp <- tempfile()
  con_in <- curl(url, handle = h)
  con_out <- file(tmp, open = "wb")
  stream_in(con = con_in, handler = function(df) {
    df |>
      flatten() |>
      stream_out(con_out, pagesize = 100)
  }, pagesize = 500)
  close(con_out)
  ## stream it back in
  stream_in(file(tmp)) |> as_tibble()
}

normalize_game_data <- function(data, username) {
  data |>
    replace_na(list(
      players.white.user.name = "",
      players.black.user.name = ""
    )) |>
    mutate(
      color = if_else(players.white.user.name == username, "white", "black"),
      win = color == winner)
}

## data |>
##   group_by(color, opening.name) |>
##   summarise(n = n(), winrate = sum(win, na.rm = TRUE) / n()) |>
##   arrange(desc(n)) |>
##   filter(n > 50) |>
##   group_split() |> map(knitr::kable)
