# Lichess Chess Openings Database

A dataset containing chess opening names, ECO (Encyclopaedia of Chess
Openings) codes, and move sequences (PGN format).

## Usage

``` r
lichess_openings
```

## Format

A tibble with 3,378 rows and 3 variables:

- eco:

  ECO code (e.g. "B20", "C50")

- name:

  Name of the opening variation (e.g. "Sicilian Defense", "Italian
  Game")

- pgn:

  Move sequence in PGN notation

## Source

<https://github.com/lichess-org/chess-openings>

## Examples

``` r
data(lichess_openings)
head(lichess_openings)
#> # A tibble: 6 × 3
#>   eco   name                       pgn                                          
#>   <chr> <chr>                      <chr>                                        
#> 1 A00   Amar Gambit                1. Nh3 d5 2. g3 e5 3. f4 Bxh3 4. Bxh3 exf4   
#> 2 A00   Amar Opening               1. Nh3                                       
#> 3 A00   Amar Opening: Gent Gambit  1. Nh3 d5 2. g3 e5 3. f4 Bxh3 4. Bxh3 exf4 5…
#> 4 A00   Amar Opening: Paris Gambit 1. Nh3 d5 2. g3 e5 3. f4                     
#> 5 A00   Amsterdam Attack           1. e3 e5 2. c4 d6 3. Nc3 Nc6 4. b3 Nf6       
#> 6 A00   Anderssen's Opening        1. a3                                        
```
