library(tidyverse)
library(httr)
library(curl)
library(urltools)
library(jsonlite)

## win or lose
## https://github.com/lichess-org/scalachess/blob/0a7d6f2c63b1ca06cd3c958ed3264e738af5c5f6/src/main/scala/Status.scala#L50
## val finishedWithWinner = List(Mate, Resign, Timeout, Outoftime, Cheat, NoStart, VariantEnd)
finished_with_winner <- c("mate", "resign", "timeout", "outoftime", "cheated", "noStart", "variantEnd")

readRenviron("./.env")
access_token <- Sys.getenv("access_token")

pr <- GET("https://lichess.org/api/account",
  add_headers("Authorization" = str_c("Bearer ", access_token)))

## R ndjson as tibble

h <- new_handle() |> handle_setheaders(
  "Authorization" = str_c("Bearer ", access_token),
  "Accept" = "application/x-ndjson"
)

url <- "https://lichess.org/api/games/user/h8gi" |>
  param_set(key = "perfType", value = "bullet") |>
  param_set(key = "opening", value = "true") |>
  param_set(key = "moves", value = "false") |>
  param_set(key = "max", value = 500)


con <- curl(url, handle = h)

game_json <- stream_in(con = con)

game_tbl <- flatten(game_json) |> as_tibble()

tibble()

game_tbl |> filter(status %in% finished_with_winner)
