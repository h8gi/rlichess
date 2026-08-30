# Get Lichess Leaderboard / Top Players

Retrieves top-rated players on the leaderboard for a given game speed or
variant.

## Usage

``` r
lic_leaderboard(perf_type = "blitz", count = 10, token = lic_token())

lic_top_players(perf_type = "blitz", count = 10, token = lic_token())
```

## Arguments

- perf_type:

  Performance category or variant name. Default is `"blitz"`.

- count:

  Number of top players to retrieve (1 to 200). Default is 10.

- token:

  API access token. By default, retrieved via
  [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md).

## Value

A tidy
[tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
containing leaderboard rankings and player stats.

## Details

**Lichess API Endpoint:** `GET /api/player/top/{count}/{perfType}`

**Official Documentation:**
<https://lichess.org/api#tag/Users/operation/playerTop>

Supported `perf_type` options include: `"bullet"`, `"blitz"`, `"rapid"`,
`"classical"`, `"ultraBullet"`, `"chess960"`, `"crazyhouse"`,
`"antichess"`, `"atomic"`, `"horde"`, `"kingOfTheHill"`,
`"racingKings"`, `"threeCheck"`.

## Examples

``` r
if (FALSE) { # interactive()
lic_leaderboard(perf_type = "rapid", count = 10)
}
```
