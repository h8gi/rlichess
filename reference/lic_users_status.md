# Get Real-time Status of Multiple Lichess Users

Fetches the online, playing, and streaming status for up to 100 users in
real-time.

## Usage

``` r
lic_users_status(
  usernames,
  with_game_ids = FALSE,
  with_signal = FALSE,
  token = lic_token()
)
```

## Arguments

- usernames:

  Character vector of Lichess usernames (up to 100).

- with_game_ids:

  Logical. Whether to include current game ID if playing. Default is
  `FALSE`.

- with_signal:

  Logical. Whether to include network latency signal (1 = poor, 4 =
  great). Default is `FALSE`.

- token:

  API access token. By default, retrieved via
  [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md).

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
containing user statuses.

## Details

**Lichess API Endpoint:** `GET /api/users/status`

**Official Documentation:**
<https://lichess.org/api#tag/Users/operation/apiUsersStatus>

## Examples

``` r
if (FALSE) { # interactive()
lic_users_status(c("h8gi", "magnuscarlsen", "hikaru"))
}
```
