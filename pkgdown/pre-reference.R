# Pre-reference setup for pkgdown example execution
# Provide offline fixtures for streaming endpoints to avoid HTTP 429 during documentation builds

sample_ndjson <- paste(
  '{"id":"demoGame1","rated":true,"variant":"standard","speed":"bullet","perf":"bullet","createdAt":1730000000000,"lastMoveAt":1730000060000,"status":"resign","winner":"white","moves":"e4 e5 Nf3 Nc6","players":{"white":{"user":{"name":"h8gi","id":"h8gi"},"rating":2200},"black":{"user":{"name":"opponent","id":"opponent"},"rating":2150}},"opening":{"eco":"C44","name":"King Pawn Game"}}',
  '{"id":"demoGame2","rated":true,"variant":"standard","speed":"bullet","perf":"bullet","createdAt":1730000100000,"lastMoveAt":1730000180000,"status":"mate","winner":"black","moves":"d4 d5 c4 e6","players":{"white":{"user":{"name":"opponent2","id":"opponent2"},"rating":2180},"black":{"user":{"name":"h8gi","id":"h8gi"},"rating":2205}},"opening":{"eco":"D30","name":"Queen\'s Gambit Declined"}}',
  sep = "\n"
)

# Mock httr2 responses during pkgdown reference build
options(httr2_mock = function(req) {
  url <- req$url
  if (grepl("/api/games/user/", url)) {
    httr2::response(
      status_code = 200L,
      headers = list("Content-Type" = "application/x-ndjson"),
      body = charToRaw(sample_ndjson)
    )
  } else if (grepl("explorer.lichess.ovh", url)) {
    mock_explorer <- '{"white":1500,"draws":500,"black":1000,"moves":[{"uci":"e2e4","san":"e4","white":1000,"draws":300,"black":700,"averageRating":2200}]}'
    httr2::response(
      status_code = 200L,
      headers = list("Content-Type" = "application/json"),
      body = charToRaw(mock_explorer)
    )
  } else if (grepl("/api/puzzle/activity", url)) {
    mock_activity <- '{"id":"00008","date":1730000000000,"win":true,"puzzle":{"id":"00008","rating":1850}}'
    httr2::response(
      status_code = 200L,
      headers = list("Content-Type" = "application/x-ndjson"),
      body = charToRaw(mock_activity)
    )
  } else {
    NULL # Fall through to real HTTP request for stable endpoints (lic_user, lic_game, lic_puzzle_daily)
  }
})
