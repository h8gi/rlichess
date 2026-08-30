# Download a Single Lichess Game

Retrieves full details of a specific game by its ID.

## Usage

``` r
lic_game(
  game_id,
  moves = TRUE,
  clocks = TRUE,
  evals = TRUE,
  opening = TRUE,
  token = lic_token()
)

lic_get_game(
  game_id,
  moves = TRUE,
  clocks = TRUE,
  evals = TRUE,
  opening = TRUE,
  token = lic_token()
)
```

## Arguments

- game_id:

  Lichess game ID (e.g. `"0tMlsM69"`).

- moves:

  Logical. Include move notation. Default is `TRUE`.

- clocks:

  Logical. Include move clock times. Default is `TRUE`.

- evals:

  Logical. Include Stockfish evaluations. Default is `TRUE`.

- opening:

  Logical. Include opening details. Default is `TRUE`.

- token:

  API access token. By default, retrieved via
  [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md).

## Value

A single-row
[tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
containing game details.

## Details

**Lichess API Endpoint:** `GET /game/export/{gameId}`

**Official Documentation:**
<https://lichess.org/api#tag/Games/operation/gamePgn>

## Examples

``` r
if (FALSE) { # interactive()
lic_game("0tMlsM69")
}
```
