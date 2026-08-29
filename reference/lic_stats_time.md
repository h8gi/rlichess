# Calculate Performance Statistics by Time and Day

Aggregates game results by hour of the day, day of the week, or both.

## Usage

``` r
lic_stats_time(data, by = c("hour", "wday", "both"), tz = "UTC")
```

## Arguments

- data:

  Tidy game data containing `created_at` (POSIXct).

- by:

  Aggregation breakdown: `"hour"` (0..23), `"wday"` (Mon..Sun), or
  `"both"`. Default is `"hour"`.

- tz:

  Time zone string used for formatting hours and days (e.g. `"UTC"`,
  `"America/New_York"`, `"Asia/Tokyo"`). Default is `"UTC"`.

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
containing game counts, win rates, scores, and rating changes grouped by
the chosen time unit.

## Details

This is an **offline data aggregation** function (no API network
request). Useful for detecting peak performance hours or tilt patterns.

## Examples

``` r
sample_games <- tibble::tibble(
  created_at = as.POSIXct(
    c("2025-01-01 14:00:00", "2025-01-01 14:30:00", "2025-01-02 21:00:00"),
    tz = "UTC"
  ),
  user_result = c("win", "win", "loss"),
  user_rating_diff = c(10L, 8L, -9L)
)
lic_stats_time(sample_games, by = "hour")
#> # A tibble: 2 × 9
#>    hour     n  wins losses draws winrate score score_rate rating_diff_total
#>   <int> <int> <int>  <int> <int>   <dbl> <dbl>      <dbl>             <int>
#> 1    14     2     2      0     0       1     2          1                18
#> 2    21     1     0      1     0       0     0          0                -9
```
