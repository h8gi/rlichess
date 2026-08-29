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
draws (`draws`), win rate (`winrate`), score (`score`), and score rate
(`score_rate`).

## Details

This is an **offline data aggregation** function (no API network
request). It calculates win rates, chess score rates, game counts, and
results from tidy game data.

## Examples

``` r
sample_games <- tibble::tibble(
  user_color = c("white", "white", "black"),
  opening.name = c("Ruy Lopez", "Ruy Lopez", "Sicilian Defense"),
  opening.eco = c("C60", "C60", "B20"),
  user_result = c("win", "draw", "loss")
)
lic_stats_openings(sample_games, min_games = 1)
#> # A tibble: 2 × 10
#>   user_color opening_name     opening_eco     n  wins losses draws winrate score
#>   <chr>      <chr>            <chr>       <int> <int>  <int> <int>   <dbl> <dbl>
#> 1 white      Ruy Lopez        C60             2     1      0     1     0.5   1.5
#> 2 black      Sicilian Defense B20             1     0      1     0     0     0  
#> # ℹ 1 more variable: score_rate <dbl>
```
