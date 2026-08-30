# Custom redactor for rlichess fixtures
# Strips secret authentication tokens and headers
httptest2::set_redactor(function(req) {
  req |>
    httptest2::redact_headers(c("Authorization", "X-Api-Key", "Cookie", "Set-Cookie"))
})
