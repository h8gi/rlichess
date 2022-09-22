library(tidyverse)
library(httr)
library(jsonlite)

readRenviron("./.env")
access_token <- Sys.getenv("access_token")

data <- GET("https://lichess.org/api/games/user/h8gi",
  add_headers(Accept = "application/x-ndjson"),
  query = list(max = 10, perfType = "bullet", opening = "true", moves = "false"))

game_json <- data |> content(as="text", encoding = "utf-8") |> textConnection() |> stream_in()

## win or lose
## https://github.com/lichess-org/scalachess/blob/0a7d6f2c63b1ca06cd3c958ed3264e738af5c5f6/src/main/scala/Status.scala#L50
## val finishedWithWinner = List(Mate, Resign, Timeout, Outoftime, Cheat, NoStart, VariantEnd)
finished_with_winner <- c("mate", "resign", "timeout", "outoftime", "cheated", "noStart", "variantEnd")
