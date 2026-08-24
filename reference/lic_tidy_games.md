# Tidy Lichess Game Data

Enriches and standardizes raw game data with user-perspective columns,
readable timestamps, and opponent details.

## Usage

``` r
lic_tidy_games(data, username = NULL)
```

## Arguments

- data:

  Raw game tibble returned by
  [`lic_games_user()`](https://h8gi.github.io/rlichess/reference/lic_games_user.md)
  or
  [`lic_game()`](https://h8gi.github.io/rlichess/reference/lic_game.md).

- username:

  Target username to calculate user-centric perspective. If `NULL`,
  user-centric columns (`user_color`, `user_result`, `win`) will not be
  computed.

## Value

A tidy
[tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
with standardized column names and types.

## Details

This is an **offline data transformation** function (no API network
request). It standardizes raw data returned by
[`lic_games_user()`](https://h8gi.github.io/rlichess/reference/lic_games_user.md)
or
[`lic_game()`](https://h8gi.github.io/rlichess/reference/lic_game.md).

## Examples

``` r
sample_raw <- tibble::tibble(
  id = "demo123",
  createdAt = 1730000000000,
  players.white.user.name = "h8gi",
  players.black.user.name = "opponent",
  players.white.rating = 2100L,
  players.black.rating = 2050L,
  winner = "white"
)
lic_tidy_games(sample_raw, username = "h8gi")
#> # A tibble: 1 × 15
#>   id          createdAt players.white.user.name players.black.user.name
#>   <chr>           <dbl> <chr>                   <chr>                  
#> 1 demo123 1730000000000 h8gi                    opponent               
#> # ℹ 11 more variables: players.white.rating <int>, players.black.rating <int>,
#> #   winner <chr>, created_at <dttm>, user_color <chr>, user_result <chr>,
#> #   win <lgl>, user_rating <int>, opponent_rating <int>, opponent_name <chr>,
#> #   user_rating_diff <int>
```
