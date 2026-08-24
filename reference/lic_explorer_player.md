# Query Player Opening Explorer Database

Retrieves opening statistics for a specific player's game history.

## Usage

``` r
lic_explorer_player(
  username,
  color = "white",
  play = NULL,
  fen = NULL,
  speeds = c("blitz", "rapid", "bullet"),
  token = lic_token()
)
```

## Arguments

- username:

  Target player's Lichess username.

- color:

  Player color perspective (`"white"` or `"black"`). Default is
  `"white"`.

- play:

  Move sequence in UCI or SAN.

- fen:

  FEN position string.

- speeds:

  Character vector of game speeds (e.g.
  `c("blitz", "rapid", "bullet")`).

- token:

  API access token. By default, retrieved via
  [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md).

## Value

A list containing aggregate stats (`white`, `draws`, `black`) and
candidate `moves` tibble.

## Details

**Lichess API Endpoint:** `GET https://explorer.lichess.ovh/player`

**Official Documentation:**
<https://lichess.org/api#tag/Opening-Explorer/operation/openingExplorerPlayer>

## Examples

``` r
player_exp <- lic_explorer_player("h8gi", color = "white", play = "e4")
player_exp$moves
#> # A tibble: 1 × 6
#>   uci   san   white draws black averageRating
#>   <chr> <chr> <int> <int> <int>         <int>
#> 1 e2e4  e4     1000   300   700          2200
```
