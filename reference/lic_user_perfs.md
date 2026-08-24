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
#> # A tibble: 9 × 6
#>   perf           games rating    rd  prog prov 
#>   <chr>          <int>  <int> <int> <int> <lgl>
#> 1 bullet         49004   2216    45   -15 FALSE
#> 2 blitz           1709   2077    52     8 FALSE
#> 3 rapid             82   2156   152  -108 TRUE 
#> 4 classical          5   1889   364     0 TRUE 
#> 5 correspondence     2   2200   403     0 TRUE 
#> 6 puzzle          6071   2067    67     0 FALSE
#> 7 storm              0     NA    NA     0 FALSE
#> 8 racer              0     NA    NA     0 FALSE
#> 9 streak             0     NA    NA     0 FALSE
```
