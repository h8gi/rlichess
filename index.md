# rlichess

**rlichess** is a modern, tidy R client for the [Lichess
API](https://lichess.org/api). It provides tools for fetching,
standardizing, and analyzing chess games, opening repertoires, user
profiles, rating histories, and puzzles using tidyverse conventions.

## Features

- **Tidy Game Data**: Fetch user games (NDJSON stream) and convert them
  into tidy tibbles with user-perspective columns (`user_color`,
  `user_result`, `user_rating`, `opponent_name`, `created_at`).
- **Move-by-Move Expansion**: Unpack game move sequences, clock times,
  and Stockfish evaluations into long-format tibbles (1 row per
  half-move).
- **Opening Analysis & Explorer**: Calculate opening win rates and query
  the Lichess/Masters Opening Explorer databases directly from R.
- **User & Rating Analytics**: Retrieve user performance profiles,
  detailed statistics, and daily rating histories.
- **Included Dataset**: Built-in `lichess_openings` dataset containing
  3,378 ECO codes, opening names, and PGN move sequences.
- **Robust Networking**: Powered by `httr2` with automatic retry, rate
  limiting, and friendly error messages.

## Installation

Install the development version from GitHub:

``` r

# install.packages("pak")
pak::pak("h8gi/rlichess")

# or using devtools / remotes
devtools::install_github("h8gi/rlichess")
```

## Quick Start

### 1. API Token Setup (Optional)

While public endpoints can be accessed anonymously, providing a Lichess
Personal Access Token increases rate limits and enables on-demand rating
history retrieval.

Set your token in `.Renviron`:

``` bash
LICHESS_API_TOKEN="your_personal_access_token"
```

In R, `rlichess` automatically loads it via
[`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md):

``` r

library(rlichess)
lic_token()
```

### 2. Download and Tidy Game Data

``` r

library(rlichess)
library(dplyr)

# 1. Download games (supports date filtering, clocks, evals)
raw_games <- lic_get_games(
  username = "h8gi",
  perf_type = "bullet",
  since = "2025-01-01",
  max = 50,
  clocks = TRUE,
  evals = TRUE
)

# 2. Tidy into user-centric format (win/loss, dates, opponent info)
games <- lic_tidy_games(raw_games, username = "h8gi")

# 3. Unpack moves into long format (1 row per half-move)
moves_df <- lic_tidy_moves(games)
head(moves_df)

# 4. Calculate opening win rates
opening_stats <- lic_stats_openings(games, min_games = 5)
head(opening_stats)
```

### 3. User Profiles and Rating History

``` r

# Summary of ratings across performance categories
perfs <- lic_user_perfs("h8gi")

# Daily rating history (returns a tidy tibble of dates and ratings)
history <- lic_rating_history("h8gi", perf_type = "bullet")

# Detailed stats (streaks, best wins, worst losses, average opponent)
stats <- lic_user_perf_stats("h8gi", perf = "bullet")
```

### 4. Opening Explorer (Lichess & Masters Databases)

``` r

# Query Lichess opening database for candidate moves (e.g. 1. e4 c5)
explorer <- lic_opening_explorer(play = "e4,c5")
explorer$moves

# Query FIDE master games (2200+ FIDE)
masters <- lic_masters_explorer(play = "e4,c5")
masters$moves
```

### 5. Daily Puzzle

``` r

# Fetch today's featured puzzle
puzzle <- lic_puzzle_daily()
puzzle$puzzle$rating
```

### 6. Built-in Dataset

``` r

data(lichess_openings)
head(lichess_openings)
```

## Documentation

Full documentation, function references, and vignettes are available
at:  
👉 **<https://h8gi.github.io/rlichess/>**

## Development

- `devtools::load_all()`: Load package functions into memory
- `devtools::document()`: Update roxygen documentation and `NAMESPACE`
- `devtools::test()`: Run `testthat` suite
- `devtools::check()`: Run comprehensive CRAN checks

## License

MIT © Hiroki Yagi
