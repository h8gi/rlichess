# Get Lichess User Profile

Fetches the public user profile from Lichess. By default
(`raw = FALSE`), returns a 1-row tidy
[tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
containing core user metadata, timestamps, and game counts. If
`raw = TRUE`, returns the full parsed JSON list.

## Usage

``` r
lic_user(username, raw = FALSE, token = lic_token())

lic_user_profile(username, raw = FALSE, token = lic_token())
```

## Arguments

- username:

  Lichess username.

- raw:

  Logical. If `TRUE`, returns the raw nested list from Lichess API.
  Default is `FALSE`.

- token:

  API access token. By default, retrieved via
  [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md).

## Value

A 1-row
[tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html) (if
`raw = FALSE`) or a nested `list` (if `raw = TRUE`).

## Details

**Lichess API Endpoint:** `GET /api/user/{username}`

**Official Documentation:**
<https://lichess.org/api#tag/Users/operation/apiUser>

## Examples

``` r
lic_user("h8gi")
#> # A tibble: 1 × 18
#>   id    username title online patron created_at          seen_at            
#>   <chr> <chr>    <chr> <lgl>  <lgl>  <dttm>              <dttm>             
#> 1 h8gi  h8gi     NA    FALSE  FALSE  2019-10-22 16:37:29 2026-08-29 13:18:53
#> # ℹ 11 more variables: bio <chr>, country <chr>, location <chr>,
#> #   play_time_total_hours <dbl>, play_time_tv_hours <dbl>, count_all <int>,
#> #   count_rated <int>, count_win <int>, count_loss <int>, count_draw <int>,
#> #   url <chr>
```
