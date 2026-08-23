## Code to prepare `lichess_openings` dataset

library(tibble)
library(dplyr)

openings_raw <- readr::read_tsv(
  "data-raw/openings.tsv",
  col_types = readr::cols(
    eco = readr::col_character(),
    name = readr::col_character(),
    pgn = readr::col_character()
  )
)

lichess_openings <- openings_raw |>
  dplyr::distinct(eco, name, pgn) |>
  tibble::as_tibble()

usethis::use_data(lichess_openings, overwrite = TRUE, compress = "xz")
