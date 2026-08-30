# Download Multiple Lichess Games by IDs

Fetches game records for multiple game IDs from the Lichess API in
NDJSON format. Up to 300 game IDs can be requested in a single call.

## Usage

``` r
lic_games_export_ids(
  game_ids,
  moves = TRUE,
  clocks = FALSE,
  evals = FALSE,
  opening = TRUE,
  token = lic_token()
)

lic_get_games_by_ids(
  game_ids,
  moves = TRUE,
  clocks = FALSE,
  evals = FALSE,
  opening = TRUE,
  token = lic_token()
)
```

## Arguments

- game_ids:

  Character vector of Lichess game IDs (up to 300).

- moves:

  Logical. Whether to include PGN moves string. Default is `TRUE`.

- clocks:

  Logical. Whether to include clock times for each move. Default is
  `FALSE`.

- evals:

  Logical. Whether to include Stockfish evaluations. Default is `FALSE`.

- opening:

  Logical. Whether to include opening name and ECO code. Default is
  `TRUE`.

- token:

  API access token. By default, retrieved via
  [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md).

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
containing game records.

## Details

**Lichess API Endpoint:** `POST /api/games/export/_ids`

**Official Documentation:**
<https://lichess.org/api#tag/Games/operation/gamesExportIds>

## Examples

``` r
if (FALSE) { # interactive()
games <- lic_games_export_ids(c("0tMlsM69", "q7ZvsdUF"))
games
}
```
