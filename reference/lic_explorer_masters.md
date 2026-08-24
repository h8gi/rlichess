# Query Lichess Masters Opening Explorer

Retrieves opening statistics from historical FIDE master-level games
(2200+ FIDE).

## Usage

``` r
lic_explorer_masters(
  fen = NULL,
  play = NULL,
  since = NULL,
  until = NULL,
  token = lic_token()
)

lic_masters_explorer(
  fen = NULL,
  play = NULL,
  since = NULL,
  until = NULL,
  token = lic_token()
)
```

## Arguments

- fen:

  FEN position string.

- play:

  Move sequence in UCI or SAN.

- since:

  Year from which to filter games (e.g. 1952).

- until:

  Year until which to filter games.

- token:

  API access token. By default, retrieved via
  [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md).

## Value

A list containing aggregate stats (`white`, `draws`, `black`), candidate
`moves` tibble, and top `topGames`.

## Examples

``` r
if (FALSE) { # \dontrun{
masters <- lic_explorer_masters(play = "e4,c5")
masters$moves
} # }
```
