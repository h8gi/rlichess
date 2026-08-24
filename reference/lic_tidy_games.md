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
if (FALSE) { # \dontrun{
raw <- lic_games_user("h8gi", max = 20)
games <- lic_tidy_games(raw, username = "h8gi")
} # }
```
