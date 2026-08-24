# Get Rating History of a Lichess User

Retrieves the daily rating history across performance types. Note that
Lichess generates up-to-date rating history on-demand for authenticated
requests.

## Usage

``` r
lic_user_rating_history(username, perf_type = NULL, token = lic_token())

lic_rating_history(username, perf_type = NULL, token = lic_token())
```

## Arguments

- username:

  Lichess username.

- perf_type:

  Optional filter for performance types (e.g. `"bullet"`, `"blitz"`).

- token:

  API access token. By default, retrieved via
  [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md).

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
with columns `username`, `perf`, `date`, and `rating`.

## Details

**Lichess API Endpoint:** `GET /api/user/{username}/rating-history`

**Official Documentation:**
<https://lichess.org/api#tag/Users/operation/apiUserRatingHistory>

Rating history is generated on demand for authenticated requests (OAuth
token). Unauthenticated requests return a cached version if available,
otherwise an empty dataset.

## Examples

``` r
if (FALSE) { # \dontrun{
hist <- lic_user_rating_history("h8gi", perf_type = "bullet")
} # }
```
