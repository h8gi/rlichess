#' Create a standardized Lichess API Request
#'
#' @param url Target endpoint URL.
#' @param token API access token.
#' @return A configured [httr2::request] object.
#' @noRd
lic_request <- function(url, token = lic_token()) {
  req <- httr2::request(url) |>
    httr2::req_user_agent("rlichess R package (https://github.com/h8gi/rlichess)") |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_error(body = function(resp) {
      status <- httr2::resp_status(resp)
      if (status == 401) {
        "Lichess API returned 401 Unauthorized. Check that your API token is valid and not expired."
      } else if (status == 404) {
        "Lichess API returned 404 Not Found. The requested resource or user does not exist."
      } else if (status == 429) {
        "Lichess API returned 429 Too Many Requests. Rate limit exceeded; please wait before retrying."
      } else {
        paste0("Lichess API request failed with status ", status, ".")
      }
    })

  if (!is.null(token) && nzchar(token)) {
    req <- req |> httr2::req_auth_bearer_token(token)
  }

  req
}
