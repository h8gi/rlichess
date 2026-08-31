# Get started with rlichess

**rlichess** is a modern, tidy R client designed for chess players,
analysts, and researchers. It bridges the [Lichess REST & Streaming
API](https://lichess.org/api) with the `tidyverse` ecosystem, allowing
you to seamlessly fetch games, user statistics, opening databases, and
tactical puzzles into tidy tibbles.

------------------------------------------------------------------------

## 1. Package Architecture

`rlichess` separates data access, data cleaning, and statistical
calculations into three clear layers:

    ┌────────────────────────────────────────────────────────┐
    │ Layer 1: API Clients (Network / HTTP Requests)          │
    │   • lic_games_user()      • lic_game()                 │
    │   • lic_user()            • lic_user_rating_history()  │
    │   • lic_explorer_*()      • lic_puzzle_*()             │
    └──────────────────────────┬─────────────────────────────┘
                               │ Raw tibble / list
                               ▼
    ┌────────────────────────────────────────────────────────┐
    │ Layer 2: Tidy Wranglers (Offline Data Transformation)  │
    │   • lic_tidy_games()  (user-centric perspective/dates) │
    │   • lic_tidy_moves()  (1-row-per-ply move unnesting)   │
    └──────────────────────────┬─────────────────────────────┘
                               │ Tidy tibble
                               ▼
    ┌────────────────────────────────────────────────────────┐
    │ Layer 3: Chess Analytics & Visualization               │
    │   • lic_stats_openings()                               │
    │   • standard dplyr / tidyr / ggplot2 workflows         │
    └────────────────────────────────────────────────────────┘

------------------------------------------------------------------------

## 2. Installation & Setup

Install the latest version from GitHub:

``` r

# install.packages("pak")
pak::pak("h8gi/rlichess")

# or using devtools / remotes
devtools::install_github("h8gi/rlichess")
```

``` r

library(rlichess)
library(dplyr)
```

### Personal API Token (Optional)

While public endpoints can be accessed anonymously, configuring a
Lichess Personal Access Token increases rate limits (up to 30–60
games/second) and enables on-demand rating history generation.

Add your token to your `.Renviron` file:

``` bash
LICHESS_API_TOKEN="lip_your_personal_access_token_here"
```

In R code, `rlichess` automatically picks it up via
[`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md):

``` r

lic_token()
#> NULL
```

------------------------------------------------------------------------

## 3. Layer 1: API Clients

### Fetching User Games

[`lic_games_user()`](https://h8gi.github.io/rlichess/reference/lic_games_user.md)
downloads game records directly from Lichess in NDJSON format. You can
filter by date range, time control, opponent, or computer analysis:

``` r

# Download recent bullet games
raw_games <- lic_games_user(
  username = "h8gi",
  perf_type = "bullet",
  max = 20,
  clocks = TRUE,
  evals = TRUE
)
raw_games
#> # A tibble: 20 × 27
#>    id       rated variant  speed perf  createdAt lastMoveAt status source winner
#>    <chr>    <lgl> <chr>    <chr> <chr>     <dbl>      <dbl> <chr>  <chr>  <chr> 
#>  1 AXBibRN8 TRUE  standard bull… bull…   1.79e12    1.79e12 resign pool   white 
#>  2 gORsq16G TRUE  standard bull… bull…   1.79e12    1.79e12 resign pool   black 
#>  3 D5pMHeCg TRUE  standard bull… bull…   1.79e12    1.79e12 mate   pool   black 
#>  4 qei6pEuL TRUE  standard bull… bull…   1.79e12    1.79e12 mate   pool   black 
#>  5 atG4qVZT TRUE  standard bull… bull…   1.79e12    1.79e12 outof… pool   white 
#>  6 2sYDFK0W TRUE  standard bull… bull…   1.79e12    1.79e12 draw   pool   NA    
#>  7 W3mr5jsG TRUE  standard bull… bull…   1.79e12    1.79e12 outof… pool   white 
#>  8 TC9t8GoA TRUE  standard bull… bull…   1.79e12    1.79e12 resign pool   white 
#>  9 4po9beqL TRUE  standard bull… bull…   1.79e12    1.79e12 mate   pool   white 
#> 10 BuZlcs98 TRUE  standard bull… bull…   1.79e12    1.79e12 resign pool   white 
#> 11 FSsSfAlv TRUE  standard bull… bull…   1.79e12    1.79e12 resign pool   black 
#> 12 8oFG02Mj TRUE  standard bull… bull…   1.79e12    1.79e12 resign pool   black 
#> 13 jFoczXbp TRUE  standard bull… bull…   1.79e12    1.79e12 resign pool   black 
#> 14 RqkzZ9U5 TRUE  standard bull… bull…   1.79e12    1.79e12 resign pool   white 
#> 15 Na6l6uua TRUE  standard bull… bull…   1.79e12    1.79e12 mate   pool   black 
#> 16 ejpvlHRm TRUE  standard bull… bull…   1.79e12    1.79e12 outof… pool   black 
#> 17 nFYLjddF TRUE  standard bull… bull…   1.79e12    1.79e12 mate   pool   black 
#> 18 7q1PvMRm TRUE  standard bull… bull…   1.79e12    1.79e12 outof… pool   black 
#> 19 O7NHsEUI TRUE  standard bull… bull…   1.79e12    1.79e12 resign pool   black 
#> 20 GladFNfD TRUE  standard bull… bull…   1.79e12    1.79e12 resign pool   white 
#> # ℹ 17 more variables: moves <chr>, clocks <list>, players.white.rating <int>,
#> #   players.white.ratingDiff <int>, players.white.user.name <chr>,
#> #   players.white.user.id <chr>, players.white.user.flair <chr>,
#> #   players.black.rating <int>, players.black.ratingDiff <int>,
#> #   players.black.user.name <chr>, players.black.user.id <chr>,
#> #   opening.eco <chr>, opening.name <chr>, opening.ply <int>,
#> #   clock.initial <int>, clock.increment <int>, clock.totalTime <int>
```

### Downloading a Single Game or Multiple Games by IDs

``` r

# Single game
game <- lic_game("0tMlsM69")
game %>%
  select(id, speed, rated, winner, status)
#> # A tibble: 1 × 5
#>   id        speed     rated     winner    status   
#>   <list>    <list>    <list>    <list>    <list>   
#> 1 <chr [1]> <chr [1]> <lgl [1]> <chr [1]> <chr [1]>

# Batch export multiple games by IDs (up to 300)
batch_games <- lic_games_export_ids(c("0tMlsM69", "q7ZvsdUF"))
batch_games
#> # A tibble: 2 × 29
#>   id       rated variant  speed  perf  createdAt lastMoveAt status source winner
#>   <chr>    <lgl> <chr>    <chr>  <chr>     <dbl>      <dbl> <chr>  <chr>  <chr> 
#> 1 0tMlsM69 TRUE  standard bullet bull…   1.76e12    1.76e12 outof… arena  white 
#> 2 q7ZvsdUF TRUE  standard blitz  blitz   1.51e12    1.51e12 draw   arena  NA    
#> # ℹ 19 more variables: moves <chr>, players.white.rating <int>,
#> #   players.white.ratingDiff <int>, players.white.user.name <chr>,
#> #   players.white.user.id <chr>, players.white.user.title <chr>,
#> #   players.black.rating <int>, players.black.ratingDiff <int>,
#> #   players.black.user.name <chr>, players.black.user.title <chr>,
#> #   players.black.user.id <chr>, opening.eco <chr>, opening.name <chr>,
#> #   opening.ply <int>, arenaTour.id <chr>, arenaTour.name <chr>, …
```

### User Profiles, Status, Crosstable & Leaderboards

``` r

# Core user profile summary as a 1-row tidy tibble
user <- lic_user("h8gi")
user %>%
  select(username, created_at, play_time_total_hours, count_all)
#> # A tibble: 1 × 4
#>   username created_at          play_time_total_hours count_all
#>   <chr>    <dttm>                              <dbl>     <int>
#> 1 h8gi     2019-10-22 16:37:29                 1749.     51238

# Check real-time online and playing status for multiple users
statuses <- lic_users_status(c("h8gi", "magnuscarlsen", "hikaru"), with_game_ids = TRUE)
statuses
#> # A tibble: 3 × 9
#>   id            name     title online playing streaming patron playing_id signal
#>   <chr>         <chr>    <chr> <lgl>  <lgl>   <lgl>     <lgl>  <chr>       <int>
#> 1 h8gi          h8gi     NA    TRUE   FALSE   FALSE     FALSE  NA             NA
#> 2 magnuscarlsen MagnusC… GM    FALSE  FALSE   FALSE     FALSE  NA             NA
#> 3 hikaru        Hikaru   NA    FALSE  FALSE   FALSE     FALSE  NA             NA

# Head-to-head match crosstable between two players
crosstable <- lic_user_crosstable("Lance5500", "TryingHard87")
crosstable
#> # A tibble: 1 × 5
#>   user1     user2        user1_score user2_score nb_games
#>   <chr>     <chr>              <dbl>       <dbl>    <int>
#> 1 Lance5500 TryingHard87         1.5         1.5        3

# Leaderboard / top players ranking
top_blitz <- lic_leaderboard(perf_type = "blitz", count = 5)
top_blitz
#> # A tibble: 5 × 9
#>    rank id                username title rating progress online patron perf_type
#>   <int> <chr>             <chr>    <chr>  <int>    <int> <lgl>  <lgl>  <chr>    
#> 1     1 cutemouse83       cutemou… GM      2982        8 FALSE  FALSE  blitz    
#> 2     2 aspiringstar      aspirin… GM      2982        4 FALSE  FALSE  blitz    
#> 3     3 dr_tiger          Dr_Tiger GM      2941       -7 FALSE  FALSE  blitz    
#> 4     4 vladimirovich9000 Vladimi… GM      2940      -22 FALSE  FALSE  blitz    
#> 5     5 athena-pallada    athena-… GM      2928        3 FALSE  FALSE  blitz

# Performance ratings across all game types
perfs <- lic_user_perfs("h8gi")
perfs
#> # A tibble: 9 × 6
#>   perf           games rating    rd  prog prov 
#>   <chr>          <int>  <int> <int> <int> <lgl>
#> 1 bullet         49288   2209    45    16 FALSE
#> 2 blitz           1710   2086    52     7 FALSE
#> 3 rapid             82   2156   153  -108 TRUE 
#> 4 classical          5   1889   364     0 TRUE 
#> 5 correspondence     2   2200   403     0 TRUE 
#> 6 puzzle          6071   2067    68     0 FALSE
#> 7 storm              0     NA    NA     0 FALSE
#> 8 racer              0     NA    NA     0 FALSE
#> 9 streak             0     NA    NA     0 FALSE

# Daily rating history
history <- lic_user_rating_history("h8gi", perf_type = "bullet")
#> ℹ Rating history returned empty. Lichess requires an authenticated request (API
#>   token) to generate rating history on demand.
#> • Set `LICHESS_API_TOKEN` environment variable or provide `token` argument.
head(history)
#> # A tibble: 0 × 4
#> # ℹ 4 variables: username <chr>, perf <chr>, date <date>, rating <int>

# In-depth performance statistics
stats <- lic_user_perf_stats("h8gi", perf = "bullet")
stats$stat$count
#> $all
#> [1] 49291
#> 
#> $rated
#> [1] 49289
#> 
#> $win
#> [1] 24034
#> 
#> $loss
#> [1] 23286
#> 
#> $draw
#> [1] 1971
#> 
#> $tour
#> [1] 230
#> 
#> $berserk
#> [1] 0
#> 
#> $opAvg
#> [1] 2083.29
#> 
#> $seconds
#> [1] 5540624
#> 
#> $disconnects
#> [1] 12
```

### Study PGN Export

``` r

# Export full study PGN (or specific chapter)
pgn <- lic_study_pgn("Y1yXP80U")
cat(substr(pgn, 1, 300))
#> [Event "FIDE Candidates Tournament 2026"]
#> [Site "lichess.org"]
#> [Date "2026.03.29"]
#> [Round "1.1"]
#> [White "Caruana, Fabiano"]
#> [Black "Nakamura, Hikaru"]
#> [Result "1-0"]
#> [WhiteElo "2795"]
#> [WhiteTitle "GM"]
#> [WhiteFideId "2020009"]
#> [BlackElo "2810"]
#> [BlackTitle "GM"]
#> [BlackFideId "2016192"]
#> [TimeControl "
```

### Opening Explorer Databases

Query Lichess’s vast opening database (over billions of games) or
historical FIDE master-level games (2200+ FIDE):

``` r

# Query Sicilian Defense (1. e4 c5) in Lichess database
exp <- lic_explorer_lichess(play = "e4,c5")
#> ℹ Opening Explorer requires an API access token (OAuth2).
#> • Set `LICHESS_API_TOKEN` environment variable or provide `token` argument.
exp$moves
#> # A tibble: 0 × 6
#> # ℹ 6 variables: uci <chr>, san <chr>, white <int>, draws <int>, black <int>,
#> #   averageRating <int>

# Query FIDE master tournament games
masters <- lic_explorer_masters(play = "e4,c5")
#> ℹ Masters Opening Explorer requires an API access token (OAuth2).
#> • Set `LICHESS_API_TOKEN` environment variable or provide `token` argument.
masters$moves
#> # A tibble: 0 × 0

# Query a specific player's personal opening repertoire
player_exp <- lic_explorer_player("h8gi", color = "white", play = "e4")
#> ℹ Player Opening Explorer requires an API access token (OAuth2).
#> • Set `LICHESS_API_TOKEN` environment variable or provide `token` argument.
player_exp$moves
#> # A tibble: 0 × 0
```

### Daily Tactical Puzzle

``` r

daily <- lic_puzzle_daily()
daily$puzzle$id
#> [1] "Zjt5N"
daily$puzzle$rating
#> [1] 2073
```

------------------------------------------------------------------------

## 4. Layer 2: Tidy Wranglers

Raw API data often contains nested JSON objects and unformatted move
strings. Layer 2 provides offline transformation functions to clean and
reshape this data.

### Tidying Game Metadata (`lic_tidy_games`)

[`lic_tidy_games()`](https://h8gi.github.io/rlichess/reference/lic_tidy_games.md)
parses raw game data into a user-centric perspective: - Converts
timestamps into standard `POSIXct` datetime vectors (`created_at`,
`last_move_at`). - Identifies the player’s color (`user_color`) and
match result (`user_result`, `win`). - Extracts opponent names
(`opponent_name`), opponent ratings (`opponent_rating`), and rating
differences (`user_rating_diff`).

``` r

games <- lic_tidy_games(raw_games, username = "h8gi")

games %>%
  select(id, created_at, user_color, user_result, user_rating, opponent_name, opening.name) %>%
  head()
#> # A tibble: 6 × 7
#>   id       created_at          user_color user_result user_rating opponent_name
#>   <chr>    <dttm>              <chr>      <chr>             <int> <chr>        
#> 1 AXBibRN8 2026-08-29 12:44:15 white      win                2204 allaneliuthr 
#> 2 gORsq16G 2026-08-29 12:42:56 white      loss               2210 Dondoctor    
#> 3 D5pMHeCg 2026-08-29 12:41:22 black      win                2203 GrobXenomorph
#> 4 qei6pEuL 2026-08-29 12:38:54 black      win                2197 certificates 
#> 5 atG4qVZT 2026-08-29 12:35:00 white      win                2191 KapyLeBro    
#> 6 2sYDFK0W 2026-08-29 12:33:07 black      draw               2190 KapyLeBro    
#> # ℹ 1 more variable: opening.name <chr>
```

### Unpacking Move Sequences (`lic_tidy_moves`)

To analyze move-by-move evaluations, clock times, or time management,
[`lic_tidy_moves()`](https://h8gi.github.io/rlichess/reference/lic_tidy_moves.md)
unpacks game move strings into a long-format tibble where **each row
corresponds to one half-move (ply)**:

``` r

moves_df <- lic_tidy_moves(games)

moves_df %>%
  filter(game_id == first(game_id)) %>%
  select(ply, move_number, color, san, clock, eval) %>%
  head(10)
#> # A tibble: 10 × 6
#>      ply move_number color san   clock  eval
#>    <int>       <int> <chr> <chr> <dbl> <dbl>
#>  1     1           1 white d4     60.0    NA
#>  2     2           1 black Nf6    60.0    NA
#>  3     3           2 white Nf3    59.6    NA
#>  4     4           2 black g6     60.0    NA
#>  5     5           3 white g3     59.6    NA
#>  6     6           3 black Bg7    59.7    NA
#>  7     7           4 white Bg2    59.6    NA
#>  8     8           4 black O-O    59.4    NA
#>  9     9           5 white O-O    59.6    NA
#> 10    10           5 black d6     59.3    NA
```

------------------------------------------------------------------------

## 5. Layer 3: Chess Analytics

### Opening Win Rates

Summarize performance across different opening variations:

``` r

opening_stats <- lic_stats_openings(games, min_games = 1)
opening_stats
#> # A tibble: 12 × 10
#>    user_color opening_name    opening_eco     n  wins losses draws winrate score
#>    <chr>      <chr>           <chr>       <int> <int>  <int> <int>   <dbl> <dbl>
#>  1 black      Caro-Kann Defe… B15             5     3      2     0   0.6     3  
#>  2 white      Englund Gambit… A40             3     1      2     0   0.333   1  
#>  3 black      Caro-Kann Defe… B10             2     1      1     0   0.5     1  
#>  4 white      Zukertort Open… A04             2     1      1     0   0.5     1  
#>  5 black      Bird Opening    A02             1     1      0     0   1       1  
#>  6 black      Caro-Kann Defe… B12             1     0      0     1   0       0.5
#>  7 black      Indian Defense… A46             1     0      1     0   0       0  
#>  8 white      English Defense A40             1     1      0     0   1       1  
#>  9 white      Englund Gambit… A40             1     0      1     0   0       0  
#> 10 white      Horwitz Defense A40             1     0      1     0   0       0  
#> 11 white      Indian Defense… A49             1     1      0     0   1       1  
#> 12 white      Ware Opening    A00             1     0      1     0   0       0  
#> # ℹ 1 more variable: score_rate <dbl>
```

------------------------------------------------------------------------

## 6. Built-in Dataset: `lichess_openings`

`rlichess` bundles the official Lichess opening database containing
3,378 ECO codes, opening names, and move sequences:

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
