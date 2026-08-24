# rlichess

<!-- badges: start -->
[![R-CMD-check](https://github.com/h8gi/rlichess/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/h8gi/rlichess/actions/workflows/R-CMD-check.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Documentation](https://img.shields.io/badge/docs-pkgdown-blue.svg)](https://h8gi.github.io/rlichess/)
<!-- badges: end -->

**rlichess** is a modern, tidy R client for the [Lichess API](https://lichess.org/api). It provides tools to fetch, clean, and analyze chess games, opening repertoires, user profiles, rating histories, and puzzles using standard tidyverse conventions.

## Architecture

`rlichess` separates data access, cleaning, and analytics into three distinct layers:

1. **Layer 1: API Clients (`lic_*`)**: Direct HTTP wrappers corresponding 1-to-1 with official Lichess API endpoints.
2. **Layer 2: Tidy Wranglers (`lic_tidy_*`)**: Pure offline transformation functions that unnest and standardize chess data into tidy tibbles.
3. **Layer 3: Chess Analytics (`lic_stats_*`)**: Offline statistics and analysis tools (e.g. opening win rates).

## Installation

Install the development version from GitHub:

```r
# install.packages("pak")
pak::pak("h8gi/rlichess")

# or using devtools / remotes
devtools::install_github("h8gi/rlichess")
```

## Quick Example

Download recent games, tidy them into user-centric format, unnest moves into a long tibble, and analyze opening win rates in a single pipeline:

```r
library(rlichess)
library(dplyr)

# 1. Fetch recent games from Lichess API
raw_games <- lic_games_user("h8gi", perf_type = "bullet", max = 50)

# 2. Tidy into user perspective (dates, win/loss, opponent info)
games <- lic_tidy_games(raw_games, username = "h8gi")

# 3. Analyze opening win rates
stats <- lic_stats_openings(games, min_games = 3)
head(stats)

# 4. Unpack 1-row-per-ply moves for move-by-move analysis
moves <- lic_tidy_moves(games)
head(moves)
```

## Documentation & Tutorials

For detailed walkthroughs, authentication setup, and function references, visit the documentation site:

👉 **[https://h8gi.github.io/rlichess/](https://h8gi.github.io/rlichess/)**  
👉 **[Get Started Guide](https://h8gi.github.io/rlichess/articles/rlichess.html)**

## Development

- `devtools::load_all()`: Load package into memory
- `devtools::document()`: Update roxygen documentation and `NAMESPACE`
- `devtools::test()`: Run test suite
- `devtools::check()`: Run comprehensive CRAN check

## License

MIT © Hiroki Yagi
