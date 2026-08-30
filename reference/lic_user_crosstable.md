# Get Crosstable (Head-to-Head Record) Between Two Users

Retrieves the total number of games and scores between two players.

## Usage

``` r
lic_user_crosstable(
  user1,
  user2,
  matchup = FALSE,
  raw = FALSE,
  token = lic_token()
)
```

## Arguments

- user1:

  First Lichess username.

- user2:

  Second Lichess username.

- matchup:

  Logical. If `TRUE` and users are currently playing, includes current
  match details. Default is `FALSE`.

- raw:

  Logical. If `TRUE`, returns raw parsed JSON list. Default is `FALSE`.

- token:

  API access token. By default, retrieved via
  [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md).

## Value

A 1-row
[tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html) (if
`raw = FALSE`) or a `list` (if `raw = TRUE`).

## Details

**Lichess API Endpoint:** `GET /api/crosstable/{user1}/{user2}`

**Official Documentation:**
<https://lichess.org/api#tag/Users/operation/apiCrosstableUser1User2>

## Examples

``` r
if (FALSE) { # interactive()
lic_user_crosstable("magnuscarlsen", "hikaru")
}
```
