# Download Games of a Lichess User

Fetches game data for a given user from the Lichess API in NDJSON
format.

## Usage

``` r
lic_games_user(
  username,
  perf_type = NULL,
  since = NULL,
  until = NULL,
  max = NULL,
  vs = NULL,
  rated = NULL,
  color = NULL,
  analysed = NULL,
  opening = TRUE,
  moves = TRUE,
  clocks = FALSE,
  evals = FALSE,
  token = lic_token()
)

lic_get_games(
  username,
  perf_type = NULL,
  since = NULL,
  until = NULL,
  max = NULL,
  vs = NULL,
  rated = NULL,
  color = NULL,
  analysed = NULL,
  opening = TRUE,
  moves = TRUE,
  clocks = FALSE,
  evals = FALSE,
  token = lic_token()
)
```

## Arguments

- username:

  Lichess username.

- perf_type:

  Optional game type filter (e.g. `"bullet"`, `"blitz"`, `"rapid"`,
  `"classical"`).

- since:

  Download games played since this timestamp or Date (e.g.
  `"2025-01-01"` or `as.Date(...)`).

- until:

  Download games played until this timestamp or Date.

- max:

  Maximum number of games to download. Default is `NULL` (all games).

- vs:

  Filter for games played against a specific opponent username.

- rated:

  Logical. Whether to fetch only rated games. Default is `NULL`.

- color:

  Filter for player's color: `"white"` or `"black"`.

- analysed:

  Logical. Whether to fetch only games with computer analysis.

- opening:

  Logical. Whether to include opening name and ECO code. Default is
  `TRUE`.

- moves:

  Logical. Whether to include PGN moves string. Default is `TRUE`.

- clocks:

  Logical. Whether to include clock times for each move. Default is
  `FALSE`.

- evals:

  Logical. Whether to include Stockfish evaluations. Default is `FALSE`.

- token:

  API access token. By default, retrieved via
  [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md).

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
containing raw game records.

## Details

**Lichess API Endpoint:** `GET /api/games/user/{username}`

**Official Documentation:**
<https://lichess.org/api#tag/Games/operation/apiGamesUser>

Rate limits: Anonymous requests are throttled at 20 games/sec.
Authenticated OAuth requests receive 30 games/sec (or 60 games/sec when
fetching your own games).

## Examples

``` r
if (FALSE) { # nzchar(Sys.getenv("LICHESS_API_TOKEN"))
games <- lic_games_user("h8gi", perf_type = "bullet", max = 5)
}
```
