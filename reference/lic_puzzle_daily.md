# Get Daily Lichess Puzzle

Retrieves today's featured puzzle from Lichess.

## Usage

``` r
lic_puzzle_daily(token = lic_token())
```

## Arguments

- token:

  API access token. By default, retrieved via
  [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md).

## Value

A list containing puzzle metadata (puzzle ID, rating, plays, FEN, moves,
themes).

## Examples

``` r
if (FALSE) { # \dontrun{
puzzle <- lic_puzzle_daily()
puzzle$puzzle$rating
} # }
```
