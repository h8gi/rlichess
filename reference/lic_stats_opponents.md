# Calculate Head-to-Head Opponent Statistics

Aggregates game records grouped by opponent name to view head-to-head
records.

## Usage

``` r
lic_stats_opponents(data, min_games = 1)
```

## Arguments

- data:

  Tidy game data returned by
  [`lic_tidy_games()`](https://h8gi.github.io/rlichess/reference/lic_tidy_games.md).

- min_games:

  Minimum number of games played against the opponent to include.
  Default is 1.

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
with columns: `opponent_name`, `n`, `wins`, `losses`, `draws`,
`winrate`, `score`, `score_rate`, `avg_opponent_rating`, and
`rating_diff_total`.

## Details

This is an **offline data aggregation** function (no API network
request).

## Examples

``` r
sample_games <- tibble::tibble(
  opponent_name = c("MagnusCarlsen", "MagnusCarlsen", "Hikaru"),
  user_result = c("loss", "draw", "win"),
  opponent_rating = c(2850L, 2850L, 2820L),
  user_rating_diff = c(-4L, 1L, 8L)
)
lic_stats_opponents(sample_games, min_games = 1)
#> # A tibble: 2 × 10
#>   opponent_name     n  wins losses draws winrate score score_rate
#>   <chr>         <int> <int>  <int> <int>   <dbl> <dbl>      <dbl>
#> 1 MagnusCarlsen     2     0      1     1       0   0.5       0.25
#> 2 Hikaru            1     1      0     0       1   1         1   
#> # ℹ 2 more variables: avg_opponent_rating <dbl>, rating_diff_total <int>
```
