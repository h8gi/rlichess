# Query Lichess Opening Explorer Database

Retrieves opening statistics (win rates, popular candidate moves) from
the Lichess game database.

## Usage

``` r
lic_explorer_lichess(
  fen = NULL,
  play = NULL,
  variant = "standard",
  ratings = c(2000, 2200, 2500),
  speeds = c("blitz", "rapid"),
  token = lic_token()
)

lic_opening_explorer(
  fen = NULL,
  play = NULL,
  variant = "standard",
  ratings = c(2000, 2200, 2500),
  speeds = c("blitz", "rapid"),
  token = lic_token()
)
```

## Arguments

- fen:

  FEN position string. Default is the starting chess position.

- play:

  Comma-separated or vector of move sequence in UCI or SAN (e.g.
  `"e2e4,e7e5"` or `c("e4", "e5")`).

- variant:

  Chess variant (`"standard"`, `"chess960"`, etc.). Default is
  `"standard"`.

- ratings:

  Integer vector of rating brackets (e.g.
  `c(1600, 1800, 2000, 2200, 2500)`).

- speeds:

  Character vector of game speeds (e.g.
  `c("bullet", "blitz", "rapid", "classical")`).

- token:

  API access token. By default, retrieved via
  [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md).

## Value

A list containing aggregate stats (`white`, `draws`, `black`) and a tidy
[tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html) of
candidate `moves`.

## Details

**Lichess API Endpoint:** `GET https://explorer.lichess.ovh/lichess`

**Official Documentation:**
<https://lichess.org/api#tag/Opening-Explorer/operation/openingExplorerLichess>

Note: As of 2026, Lichess requires OAuth2 / API Token authentication for
explorer queries.

## Examples

``` r
if (FALSE) { # interactive()
exp <- lic_explorer_lichess(play = "e4,c5")
exp$moves
}
```
