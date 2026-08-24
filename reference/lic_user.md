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
if (FALSE) { # interactive()
user <- lic_user("h8gi")
user$created_at
}
```
