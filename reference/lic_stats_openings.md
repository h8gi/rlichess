# Calculate Opening Statistics

Summarizes game statistics grouped by opening and player color.

## Usage

``` r
lic_stats_openings(data, min_games = 10)
```

## Arguments

- data:

  Normalized game data returned by
  [`lic_tidy_games()`](https://h8gi.github.io/rlichess/reference/lic_tidy_games.md).

- min_games:

  Minimum number of games required to include in the summary.

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
with opening names, total games (`n`), wins (`wins`), losses (`losses`),
draws (`draws`), and win rate (`winrate`).

## Details

This is an **offline data aggregation** function (no API network
request). It calculates win rates, game counts, and results from
normalized game data.

## Examples

``` r
sample_games <- tibble::tibble(
  user_color = c("white", "white", "black"),
  opening.name = c("Ruy Lopez", "Ruy Lopez", "Sicilian Defense"),
  opening.eco = c("C60", "C60", "B20"),
  user_result = c("win", "win", "loss")
)
lic_stats_openings(sample_games, min_games = 1)
#> # A tibble: 2 × 8
#>   user_color opening_name     opening_eco     n  wins losses draws winrate
#>   <chr>      <chr>            <chr>       <int> <int>  <int> <int>   <dbl>
#> 1 white      Ruy Lopez        C60             2     2      0     0       1
#> 2 black      Sicilian Defense B20             1     0      1     0       0
```
