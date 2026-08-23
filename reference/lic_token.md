# Get Lichess API Token

Retrieves the Lichess Personal API access token from environment
variables. Checks `LICHESS_API_TOKEN` and `LICHESS_API_ACCESS_TOKEN`.

## Usage

``` r
lic_token(token = NULL)
```

## Arguments

- token:

  Optional character string specifying the token explicitly.

## Value

A character string token, or `NULL` if not set.

## Examples

``` r
lic_token()
#> NULL
```
