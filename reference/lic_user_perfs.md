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
if (FALSE) { # interactive()
perfs <- lic_user_perfs("h8gi")
}
```
