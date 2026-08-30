# Export Study PGN from Lichess

Downloads PGN representation of a study or an individual study chapter
from Lichess. For private or unlisted studies, an authenticated API
token with `study:read` scope is required.

## Usage

``` r
lic_study_pgn(
  study_id,
  chapter_id = NULL,
  clocks = TRUE,
  comments = TRUE,
  variations = TRUE,
  orientation = FALSE,
  token = lic_token()
)
```

## Arguments

- study_id:

  8-character study identifier (or study URL).

- chapter_id:

  Optional chapter identifier. If `NULL` (default), exports all chapters
  of the study.

- clocks:

  Logical. Include clock comments in PGN moves when available. Default
  is `TRUE`.

- comments:

  Logical. Include analysis annotations and comments when available.
  Default is `TRUE`.

- variations:

  Logical. Include non-mainline variation branches when available.
  Default is `TRUE`.

- orientation:

  Logical. Include `Orientation` PGN tag with chapter orientation.
  Default is `FALSE`.

- token:

  API access token. By default, retrieved via
  [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md).

## Value

A character string containing the exported PGN text.

## Details

**Lichess API Endpoint:** `GET /api/study/{studyId}.pgn` or
`GET /api/study/{studyId}/{chapterId}.pgn`

**Official Documentation:**
<https://lichess.org/api#tag/Studies/operation/studyAllChaptersPgn>

## Examples

``` r
if (FALSE) { # interactive()
pgn <- lic_study_pgn("Y1yXP80U")
cat(substr(pgn, 1, 300))
}
```
