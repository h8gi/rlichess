# Calculate Clock Usage and Time Trouble Statistics

Analyzes move time duration and remaining clock time distribution per
game and color.

## Usage

``` r
lic_stats_clocks(data, threshold_time_trouble = 10)
```

## Arguments

- data:

  Ply-by-ply move data returned by
  [`lic_tidy_moves()`](https://h8gi.github.io/rlichess/reference/lic_tidy_moves.md)
  containing `game_id`, `color`, and `clock`.

- threshold_time_trouble:

  Threshold in seconds below which a move is counted as time trouble.
  Default is 10.

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
with columns: `game_id`, `color`, `moves_count`, `avg_move_time`,
`max_move_time`, `min_clock`, and `time_trouble_moves`.

## Details

This is an **offline data aggregation** function (no API network
request). Requires ply-by-ply move data returned by
[`lic_tidy_moves()`](https://h8gi.github.io/rlichess/reference/lic_tidy_moves.md).

## Examples

``` r
sample_moves <- tibble::tibble(
  game_id = rep("g1", 6),
  ply = 1:6,
  color = c("white", "black", "white", "black", "white", "black"),
  clock = c(180, 179, 175, 170, 160, 155)
)
lic_stats_clocks(sample_moves)
#> # A tibble: 2 × 7
#>   game_id color moves_count avg_move_time max_move_time min_clock
#>   <chr>   <chr>       <int>         <dbl>         <dbl>     <dbl>
#> 1 g1      black           3            12            15       155
#> 2 g1      white           3            10            15       160
#> # ℹ 1 more variable: time_trouble_moves <int>
```
