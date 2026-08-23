# rlichess

<!-- badges: start -->
<!-- badges: end -->

`rlichess` は、Lichess (https://lichess.org) の対局データやプレイヤー情報を取得し、Tidy な形式でチェスのパフォーマンス分析・可視化を行うための R パッケージです。

## インストール

```R
# GitHub からインストール（devtools または pak）
# pak::pak("h8gi/rlichess")
# または
# devtools::install_github("h8gi/rlichess")
```

## 基本的な使い方

### 1. APIトークンの設定 (任意)

Lichess Personal Access Token をお持ちの場合は、環境変数 `LICHESS_API_TOKEN` または `LICHESS_API_ACCESS_TOKEN` に設定しておくとレート制限が緩和されます。

```R
Sys.setenv(LICHESS_API_TOKEN = "your_personal_token_here")
```

### 2. 対局データの取得と整形

```R
library(rlichess)

# 対局データの取得 (NDJSONストリームから tibble に変換)
games <- lic_get_games(
  username = "h8gi",
  perf_type = "bullet",
  max = 100
)

# ユーザー視点での手番や勝敗の付与
tidy_games <- lic_normalize_games(games, username = "h8gi")

# オープニングごとの勝率・戦績集計
stats <- lic_stats_openings(tidy_games, min_games = 5)
head(stats)
```

## 開発フロー

- `devtools::load_all()`: 開発中コードの読み込み
- `devtools::document()`: ドキュメントおよび NAMESPACE の自動更新
- `devtools::test()`: ユニットテストの実行
- `devtools::check()`: CRAN ガイドライン準拠チェック
