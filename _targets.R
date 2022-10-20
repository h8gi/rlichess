# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
# library(tarchetypes) # Load other packages as needed. # nolint

# Set target options:
tar_option_set(
  packages = c("tidyverse", "curl", "urltools", "jsonlite", "kableExtra"), # packages that your targets need to run
  format = "rds" # default storage format
  # Set other options as needed.
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

# tar_make_future() configuration (okay to leave alone):
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
source("R/functions.R") # Source other scripts as needed. # nolint

# Replace the target list below with your own:
# Replace the target list below with your own:
list(
  tar_target(access_token, command = Sys.getenv("LICHESS_API_ACCESS_TOKEN")),
  tar_target(
    raw_data,
    get_game_data(username = "h8gi", access_token = access_token),
    format = "feather"
  ),
  tar_target(
    data,
    normalize_game_data(raw_data, username = "h8gi"),
    format = "feather"
  ),
  tar_target(min_game_number, 50),
  tar_target(
    opening_winrate,
    data |>
      group_by(color, opening.name) |>
      summarise(n = n(), winrate = sum(win, na.rm = TRUE) / n()) |>
      arrange(desc(winrate)) |>
      filter(n > min_game_number) |> group_split()
  ),
  tar_target(
    white_opening_winrate,
    opening_winrate[[2]]
  ),
  tar_target(
    black_opening_winrate,
    opening_winrate[[1]]
  ),
  tar_quarto(
    report,
    "report.qmd"
  )
)
