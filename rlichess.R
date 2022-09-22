library(tidyverse)
library(httr)
library(jsonlite)

data <- GET("https://lichess.org/api/games/user/h8gi",
  add_headers(Accept = "application/x-ndjson"),
  query = list(max = 10, perfType = "bullet", opening = "true", moves = "false"))

game_json <- data |> content(as="text", encoding = "utf-8") |> textConnection() |> stream_in()
