# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed. # nolint

# Set target options:
tar_option_set(
  packages = c("tidyverse", "curl", "urltools", "jsonlite"), # packages that your targets need to run
  format = "rds" # default storage format
  # Set other options as needed.
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

# tar_make_future() configuration (okay to leave alone):
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
## tar_source()
source("R/functions.R") # Source other scripts as needed. # nolint

# Replace the target list below with your own:
# Replace the target list below with your own:
list(
  tar_target(access_token, command = Sys.getenv("LICHESS_API_ACCESS_TOKEN")),
  tar_target(
    data,
    get_game_data(username = "h8gi", access_token = access_token),
    format = "feather")
)
