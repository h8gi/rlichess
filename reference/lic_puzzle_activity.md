# Get User Puzzle Activity

Retrieves recent puzzle attempts for the authenticated user in NDJSON
format. Requires authentication token with puzzle read permission.

## Usage

``` r
lic_puzzle_activity(max = 50, token = lic_token())
```

## Arguments

- max:

  Maximum number of puzzle activities to fetch. Default is 50.

- token:

  API access token. By default, retrieved via
  [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md).

## Value

A tidy
[tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html) of
puzzle attempts.

## Details

**Lichess API Endpoint:** `GET /api/puzzle/activity`

**Official Documentation:**
<https://lichess.org/api#tag/Puzzles/operation/apiPuzzleActivity>

## Examples

``` r
puzzles <- lic_puzzle_activity(max = 20)
```
