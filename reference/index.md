# Package index

## Authentication

Manage Personal API access tokens for authenticated requests.

- [`lic_token()`](https://h8gi.github.io/rlichess/reference/lic_token.md)
  : Get Lichess API Token

## API Clients: Games

Direct interfaces to the Lichess Games API (HTTP requests).

- [`lic_games_user()`](https://h8gi.github.io/rlichess/reference/lic_games_user.md)
  [`lic_get_games()`](https://h8gi.github.io/rlichess/reference/lic_games_user.md)
  : Download Games of a Lichess User
- [`lic_game()`](https://h8gi.github.io/rlichess/reference/lic_game.md)
  [`lic_get_game()`](https://h8gi.github.io/rlichess/reference/lic_game.md)
  : Download a Single Lichess Game
- [`lic_games_export_ids()`](https://h8gi.github.io/rlichess/reference/lic_games_export_ids.md)
  [`lic_get_games_by_ids()`](https://h8gi.github.io/rlichess/reference/lic_games_export_ids.md)
  : Download Multiple Lichess Games by IDs

## API Clients: Users & Ratings

Direct interfaces to the Lichess Users and Ratings API (HTTP requests).

- [`lic_user()`](https://h8gi.github.io/rlichess/reference/lic_user.md)
  [`lic_user_profile()`](https://h8gi.github.io/rlichess/reference/lic_user.md)
  : Get Lichess User Profile
- [`lic_user_perfs()`](https://h8gi.github.io/rlichess/reference/lic_user_perfs.md)
  : Get Lichess User Performances Summary
- [`lic_user_rating_history()`](https://h8gi.github.io/rlichess/reference/lic_user_rating_history.md)
  [`lic_rating_history()`](https://h8gi.github.io/rlichess/reference/lic_user_rating_history.md)
  : Get Rating History of a Lichess User
- [`lic_user_perf_stats()`](https://h8gi.github.io/rlichess/reference/lic_user_perf_stats.md)
  : Get Detailed Performance Statistics of a Lichess User
- [`lic_users_status()`](https://h8gi.github.io/rlichess/reference/lic_users_status.md)
  : Get Real-time Status of Multiple Lichess Users
- [`lic_user_crosstable()`](https://h8gi.github.io/rlichess/reference/lic_user_crosstable.md)
  : Get Crosstable (Head-to-Head Record) Between Two Users
- [`lic_leaderboard()`](https://h8gi.github.io/rlichess/reference/lic_leaderboard.md)
  [`lic_top_players()`](https://h8gi.github.io/rlichess/reference/lic_leaderboard.md)
  : Get Lichess Leaderboard / Top Players

## API Clients: Studies

Direct interfaces to the Lichess Studies API.

- [`lic_study_pgn()`](https://h8gi.github.io/rlichess/reference/lic_study_pgn.md)
  : Export Study PGN from Lichess

## API Clients: Opening Explorer

Direct interfaces to the Lichess and Masters Opening Explorer databases.

- [`lic_explorer_lichess()`](https://h8gi.github.io/rlichess/reference/lic_explorer_lichess.md)
  [`lic_opening_explorer()`](https://h8gi.github.io/rlichess/reference/lic_explorer_lichess.md)
  : Query Lichess Opening Explorer Database
- [`lic_explorer_masters()`](https://h8gi.github.io/rlichess/reference/lic_explorer_masters.md)
  [`lic_masters_explorer()`](https://h8gi.github.io/rlichess/reference/lic_explorer_masters.md)
  : Query Lichess Masters Opening Explorer
- [`lic_explorer_player()`](https://h8gi.github.io/rlichess/reference/lic_explorer_player.md)
  : Query Player Opening Explorer Database

## API Clients: Puzzles

Direct interfaces to the Lichess Puzzles API.

- [`lic_puzzle_daily()`](https://h8gi.github.io/rlichess/reference/lic_puzzle_daily.md)
  : Get Daily Lichess Puzzle
- [`lic_puzzle_activity()`](https://h8gi.github.io/rlichess/reference/lic_puzzle_activity.md)
  : Get User Puzzle Activity

## Tidy Wranglers (Offline Transformation)

Offline data manipulation functions that unnest, standardize, and format
chess data into tidy tibbles.

- [`lic_tidy_games()`](https://h8gi.github.io/rlichess/reference/lic_tidy_games.md)
  : Tidy Lichess Game Data
- [`lic_tidy_moves()`](https://h8gi.github.io/rlichess/reference/lic_tidy_moves.md)
  : Tidy Game Moves, Clocks, and Evaluations
- [`lic_normalize_games()`](https://h8gi.github.io/rlichess/reference/lic_normalize_games.md)
  : Normalize Game Data (Legacy Alias)

## Chess Analytics (Offline Statistics)

Offline analysis tools to summarize win rates, repertoire performance,
and tactical metrics.

- [`lic_stats_openings()`](https://h8gi.github.io/rlichess/reference/lic_stats_openings.md)
  : Calculate Opening Statistics
- [`lic_stats_opponents()`](https://h8gi.github.io/rlichess/reference/lic_stats_opponents.md)
  : Calculate Head-to-Head Opponent Statistics
- [`lic_stats_time()`](https://h8gi.github.io/rlichess/reference/lic_stats_time.md)
  : Calculate Performance Statistics by Time and Day
- [`lic_stats_clocks()`](https://h8gi.github.io/rlichess/reference/lic_stats_clocks.md)
  : Calculate Clock Usage and Time Trouble Statistics

## Package Datasets

Built-in datasets included with the package.

- [`lichess_openings`](https://h8gi.github.io/rlichess/reference/lichess_openings.md)
  : Lichess Chess Openings Database
