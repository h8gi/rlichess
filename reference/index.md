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

## Package Datasets

Built-in datasets included with the package.

- [`lichess_openings`](https://h8gi.github.io/rlichess/reference/lichess_openings.md)
  : Lichess Chess Openings Database
