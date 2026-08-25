# Get Lichess User Performances Summary

Extracts performance categories (e.g. bullet, blitz, rapid, puzzle) and
ratings for a user as a tidy tibble.

## Usage

``` r
lic_user_perfs(username, token = lic_token())
```

## Arguments

- username:

  Lichess username.

- token:

  API access token. By default, retrieved via
  [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md).

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
with columns `perf`, `games`, `rating`, `rd`, `prog`, `prov`.

## Details

**Lichess API Endpoint:** Extracted from `GET /api/user/{username}`

**Official Documentation:**
<https://lichess.org/api#tag/Users/operation/apiUser>

## Examples

``` r
lic_user_perfs("h8gi")
#> Error in httr2::req_perform(req): Failed to perform HTTP request.
#> Caused by error in `curl::curl_fetch_memory()`:
#> ! Timeout was reached [lichess.org]:
#> Failed to connect to lichess.org port 443 after 10002 ms: Timeout was reached
```
