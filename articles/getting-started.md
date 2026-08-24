# Getting Started with rlichess

`rlichess` provides an intuitive and tidy interface to the Lichess API
(<https://lichess.org/api>) for chess players and data analysts working
with R and tidyverse.

## Installation

You can install `rlichess` directly from GitHub:

``` r

# install.packages("pak")
pak::pak("h8gi/rlichess")

# or using devtools
devtools::install_github("h8gi/rlichess")
```

``` r

library(rlichess)
library(dplyr)
```

## 1. Authentication (Optional but Recommended)

Lichess offers generous public API access. However, providing a Personal
Access Token increases rate limits (up to 30–60 games/sec) and allows
on-demand rating history retrieval.

You can set your token in your `.Renviron` file:

``` bash
LICHESS_API_TOKEN="your_personal_access_token"
```

In R code, `rlichess` automatically picks it up via
[`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md):

``` r

# Check if token is available
lic_token()
```

## 2. Downloading & Tidying Game Data

### Downloading User Games

Use
[`lic_get_games()`](https://h8gi.github.io/rlichess/reference/lic_games_user.md)
to fetch games for any Lichess user. You can filter by date, speed/perf,
or opponent:

``` r

# Download recent bullet games since 2025
raw_games <- lic_get_games(
  username = "h8gi",
  perf_type = "bullet",
  since = "2025-01-01",
  max = 50,
  clocks = TRUE,
  evals = TRUE
)
```

### Tidying into User-Centric Format

[`lic_tidy_games()`](https://h8gi.github.io/rlichess/reference/lic_tidy_games.md)
enriches raw NDJSON records into a tidy format with readable dates
(`POSIXct`), color (`"white"` / `"black"`), win/loss results, and rating
differences:

``` r

games <- lic_tidy_games(raw_games, username = "h8gi")

games %>%
  select(id, created_at, user_color, user_result, user_rating, opponent_name, opening.name) %>%
  head()
```

### Expanding Move Sequences (Long Format)

For in-depth move-by-move analysis (evaluations, clock times, blunders),
[`lic_tidy_moves()`](https://h8gi.github.io/rlichess/reference/lic_tidy_moves.md)
unpacks games into a long format where each row is a half-move (ply):

``` r

moves_df <- lic_tidy_moves(games)

moves_df %>%
  filter(game_id == first(game_id)) %>%
  select(ply, move_number, color, san, clock, eval) %>%
  head(10)
```

## 3. Opening Analysis

### Opening Win Rates

Summarize win rates for each opening variation:

``` r

stats <- lic_stats_openings(games, min_games = 5)
stats
```

### Exploring Lichess Opening Database

Query Lichess’s vast opening database for candidate moves and win
statistics:

``` r

# Query Sicilian Defense (1. e4 c5)
explorer <- lic_opening_explorer(play = "e4,c5")

# Candidate moves
explorer$moves
```

### Master Games Explorer

Search historical games played by FIDE titled masters (2200+):

``` r

masters <- lic_masters_explorer(play = "e4,c5")
masters$moves
```

## 4. User Profiles & Rating History

Retrieve user ratings and historical progress:

``` r

# Current performance summaries
perfs <- lic_user_perfs("h8gi")
perfs

# Detailed stats for bullet
stats <- lic_user_perf_stats("h8gi", perf = "bullet")

# Daily rating history
history <- lic_rating_history("h8gi", perf_type = "bullet")
```

## 5. Daily Puzzle

Fetch today’s featured puzzle:

``` r

daily_puzzle <- lic_puzzle_daily()
daily_puzzle$puzzle$rating
```
