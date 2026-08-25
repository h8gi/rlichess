# Tidy Game Moves, Clocks, and Evaluations

Expands game move sequences, clock times, and Stockfish evaluations into
a long-format tidy tibble where each row corresponds to one half-move
(ply).

## Usage

``` r
lic_tidy_moves(data)
```

## Arguments

- data:

  A game tibble containing an `id` and a `moves` column.

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
with columns:

- game_id:

  Lichess game identifier

- ply:

  Half-move index (1, 2, 3, ...)

- move_number:

  Full-move number (1, 1, 2, 2, ...)

- color:

  Color playing the move (`"white"` or `"black"`)

- san:

  Standard Algebraic Notation of the move (e.g. `"e4"`, `"Nf3"`)

- clock:

  Remaining clock time in seconds (if available)

- eval:

  Stockfish evaluation in pawns (Centipawns / 100, if available)

- mate:

  Forced mate in moves (e.g. `+2` for White mate in 2, `-1` for Black
  mate in 1)

- judgment:

  Computer move assessment (`"Inaccuracy"`, `"Mistake"`, `"Blunder"`, or
  `NA`)

## Details

This is an **offline data transformation** function (no API network
request). It unnests the move string (`moves`), clock array (`clocks`),
and evaluation array (`evals`) from game records into a tidy ply-by-ply
dataset.

## Examples

``` r
sample_game <- tibble::tibble(
  id = "demo123",
  moves = "e4 e5 Nf3 Nc6 Bb5"
)
lic_tidy_moves(sample_game)
#> # A tibble: 5 × 9
#>   game_id   ply move_number color san   clock  eval  mate judgment
#>   <chr>   <int>       <int> <chr> <chr> <dbl> <dbl> <int> <chr>   
#> 1 demo123     1           1 white e4       NA    NA    NA NA      
#> 2 demo123     2           1 black e5       NA    NA    NA NA      
#> 3 demo123     3           2 white Nf3      NA    NA    NA NA      
#> 4 demo123     4           2 black Nc6      NA    NA    NA NA      
#> 5 demo123     5           3 white Bb5      NA    NA    NA NA      
```
