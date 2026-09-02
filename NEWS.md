# rlichess 0.1.0

Initial CRAN/GitHub release of **rlichess**, a modern, tidyverse-aligned R client for the Lichess API (<https://lichess.org/api>) and chess data analysis toolkit.

### Layer 1: API Clients (Data Access)
* **User Games**:
  * `lic_games_user()`: Stream games for any Lichess user in NDJSON format with flexible filtering (date range, speeds, rated, opponent, computer evaluation).
  * `lic_game()`: Download detailed JSON data for a single game by game ID or URL.
  * `lic_games_export_ids()`: Batch download multiple games by IDs (up to 300 games in a single request).
* **User Profiles & Social**:
  * `lic_user()`: Fetch core user profile summaries returned as a 1-row tidy tibble.
  * `lic_users_status()`: Query real-time online, playing, and streaming statuses for multiple users.
  * `lic_user_crosstable()`: Retrieve head-to-head match history and scores between two players.
  * `lic_leaderboard()`: Query top-rated players across all game variants (bullet, blitz, rapid, classical, chess960, etc.).
  * `lic_user_perfs()`: Extract current ratings, provisional status, and total games across performance types.
  * `lic_user_rating_history()`: Retrieve historical rating progression points formatted as a tidy tibble.
  * `lic_user_perf_stats()`: Retrieve in-depth performance statistics (streaks, best wins, worst losses).
* **Opening Explorer**:
  * `lic_explorer_lichess()`: Query opening statistics and candidate moves from the Lichess game database.
  * `lic_explorer_masters()`: Query historical FIDE master-level games (2200+ FIDE).
  * `lic_explorer_player()`: Query a specific player's personal opening repertoire.
* **Tactical Puzzles**:
  * `lic_puzzle_daily()`: Fetch today's featured tactical puzzle.
  * `lic_puzzle_activity()`: Stream recent puzzle attempt history for authenticated users.
* **Studies**:
  * `lic_study_pgn()`: Export full study PGNs or specific chapters.
* **Authentication**:
  * `lic_token()`: Retrieve Personal API tokens from `LICHESS_API_TOKEN` environment variables.

### Layer 2: Tidy Wranglers (Data Transformation)
* `lic_tidy_games()`: Reshape raw game data into player-centric perspectives (calculates results, dates, opponent names, ratings, and rating differences).
* `lic_tidy_moves()`: Unpack PGN move sequences into a long-format tibble with one row per half-move (ply), including move clocks and Stockfish evaluations.

### Layer 3: Chess Analytics (Offline Statistics)
* `lic_stats_openings()`: Calculate win rates, draw rates, and performance metrics grouped by chess opening.
* `lic_stats_opponents()`: Aggregate head-to-head opponent records and rating differentials.
* `lic_stats_time()`: Analyze win rates and game volume by hour of day or day of week.
* `lic_stats_streaks()`: Compute consecutive winning, losing, and undefeated streaks.
* `lic_stats_overview()`: Summary performance metrics dashboard across speeds and colors.

### Bundled Datasets
* `lichess_openings`: Built-in dataset containing 3,378 ECO codes, opening names, and standard PGN move sequences.

### Infrastructure & Testing
* 100% deterministic, offline unit test suite powered by `httptest2` mocks.
* Richly evaluated vignettes with mock recordings for all API endpoints.
* Live API integration test suite (`tests/testthat/test-live-api.R`) triggered on version releases.
* Full CRAN compliance: 0 errors, 0 warnings, 0 non-standard notes.
