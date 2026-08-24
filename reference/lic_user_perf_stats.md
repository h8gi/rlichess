# Get Detailed Performance Statistics of a Lichess User

Retrieves in-depth stats for a specific game type (e.g. bullet, blitz,
rapid), including win/loss counts, streaks, highest/lowest ratings, and
average opponent rating.

## Usage

``` r
lic_user_perf_stats(username, perf = "bullet", token = lic_token())
```

## Arguments

- username:

  Lichess username.

- perf:

  Performance type (e.g. `"bullet"`, `"blitz"`, `"rapid"`,
  `"classical"`). Default is `"bullet"`.

- token:

  API access token. By default, retrieved via
  [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md).

## Value

A list containing performance statistics.

## Details

**Lichess API Endpoint:** `GET /api/user/{username}/perf/{perf}`

**Official Documentation:**
<https://lichess.org/api#tag/Users/operation/userPerf>

## Examples

``` r
if (FALSE) { # interactive()
stats <- lic_user_perf_stats("h8gi", perf = "bullet")
stats$stat$count
}
```
