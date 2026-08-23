# Calculate Opening Statistics

Summarizes game statistics grouped by opening and player color.

## Usage

``` r
lic_stats_openings(data, min_games = 10)
```

## Arguments

- data:

  Normalized game data returned by
  [`lic_normalize_games()`](https://h8gi.github.io/rlichess/reference/lic_normalize_games.md).

- min_games:

  Minimum number of games required to include in the summary.

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
with opening names, total games (`n`), wins (`wins`), losses (`losses`),
draws (`draws`), and win rate (`winrate`).

## Examples

``` r
if (FALSE) { # \dontrun{
games <- lic_get_games("h8gi", max = 100) |>
  lic_normalize_games(username = "h8gi")
stats <- lic_stats_openings(games, min_games = 5)
} # }
```
