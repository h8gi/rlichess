# rlichess

<!-- badges: start -->
[![R-CMD-check](https://github.com/h8gi/rlichess/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/h8gi/rlichess/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`rlichess` は、Lichess (https://lichess.org) の対局データ、プレイヤー情報、オープニング統計、パズルデータを取得し、Tidyverse（`dplyr`, `ggplot2` 等）で直感的に分析できるように設計された R パッケージです。

## インストール

```R
# devtools::install_github("h8gi/rlichess")
# または
# pak::pak("h8gi/rlichess")
```

## 基本機能と使い方

### 1. APIトークンの設定 (任意)

Lichess Personal Access Token を環境変数に設定しておくと、レート制限が大幅に緩和され、日次レーティング推移のオンデマンド取得が可能になります。

```R
Sys.setenv(LICHESS_API_TOKEN = "your_personal_token_here")
```

### 2. 対局データの取得と Tidy 化

```R
library(rlichess)
library(dplyr)

# 1. ユーザーの対局データを取得 (日付フィルタや評価値・時計の指定が可能)
raw_games <- lic_get_games(
  username = "h8gi",
  perf_type = "bullet",
  since = "2025-01-01",
  max = 100,
  clocks = TRUE,
  evals = TRUE
)

# 2. ユーザー視点での手番・勝敗・対戦相手情報・日時に整形 (Tidy 化)
games <- lic_tidy_games(raw_games, username = "h8gi")

# 3. 1手ごとのロング形式テーブルに展開 (着手ごとの消費時間や評価値分析用)
moves_df <- lic_tidy_moves(games)
head(moves_df)

# 4. オープニング別の戦績・勝率を集計
opening_stats <- lic_stats_openings(games, min_games = 5)
```

### 3. ユーザープロファイル・レーティング履歴の取得

```R
# ユーザーの種目別レーティング・対局数一覧
perfs <- lic_user_perfs("h8gi")

# 日次レーティング推移の取得 (日付・レーティング値の tibble)
history <- lic_rating_history("h8gi", perf_type = "bullet")

# 種目別の詳細パフォーマンス統計 (勝敗数・連勝記録・最高/最低レーティング)
stats <- lic_user_perf_stats("h8gi", perf = "bullet")
```

### 4. オープニングエクスプローラー (Lichess DB / Masters DB)

```R
# 初手 e4 c5 (Sicilian) の Lichess 対局統計と候補手一覧を取得
explorer <- lic_opening_explorer(play = "e4,c5")
explorer$moves

# FIDE マスター対局データベースの検索
masters <- lic_masters_explorer(play = "e4,c5")
masters$moves
```

### 5. 付属データセット

Lichess の全オープニングデータベース（3,378件の ECO コード、戦形名、PGN 初手定義）が同梱されています。

```R
data(lichess_openings)
head(lichess_openings)
```

## 開発フロー

- `devtools::load_all()`: 開発中コードの読み込み
- `devtools::document()`: ドキュメントおよび NAMESPACE の自動更新
- `devtools::test()`: ユニットテストの実行
- `devtools::check()`: CRAN ガイドライン準拠チェック
