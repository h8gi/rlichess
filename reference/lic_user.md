# Get Lichess User Profile

Fetches the public user profile from Lichess.

## Usage

``` r
lic_user(username, token = lic_token())

lic_user_profile(username, token = lic_token())
```

## Arguments

- username:

  Lichess username.

- token:

  API access token. By default, retrieved via
  [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md).

## Value

A list containing user metadata and performance summaries.

## Examples

``` r
if (FALSE) { # \dontrun{
user <- lic_user("h8gi")
user$username
} # }
```
