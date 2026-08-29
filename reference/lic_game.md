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
lic_game("0tMlsM69")
#> # A tibble: 1 × 31
#>   id        rated  variant speed perf  createdAt lastMoveAt status source winner
#>   <list>    <list> <list>  <lis> <lis> <list>    <list>     <list> <list> <list>
#> 1 <chr [1]> <lgl>  <chr>   <chr> <chr> <dbl [1]> <dbl [1]>  <chr>  <chr>  <chr> 
#> # ℹ 21 more variables: moves <list>, clocks <list>,
#> #   players.white.rating <list>, players.white.ratingDiff <list>,
#> #   players.white.user.name <list>, players.white.user.id <list>,
#> #   players.black.rating <list>, players.black.ratingDiff <list>,
#> #   players.black.user.name <list>, players.black.user.title <list>,
#> #   players.black.user.id <list>, opening.eco <list>, opening.name <list>,
#> #   opening.ply <list>, arenaTour.id <list>, arenaTour.name <list>, …
```
