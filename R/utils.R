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

#' Convert Date/POSIXct/Character to Milliseconds Timestamp
#'
#' @param x A Date, POSIXt, numeric, or Date-like character string.
#' @return A character string representing UNIX timestamp in milliseconds, or `NULL`.
#' @noRd
lic_to_timestamp <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }

  if (is.numeric(x)) {
    if (x < 1e11) {
      return(sprintf("%.0f", x * 1000))
    }
    return(sprintf("%.0f", x))
  }

  if (is.character(x)) {
    x <- as.POSIXct(x, tz = "UTC")
  }

  if (inherits(x, "Date")) {
    x <- as.POSIXct(x, tz = "UTC")
  }

  if (inherits(x, "POSIXt")) {
    ms <- as.numeric(x) * 1000
    return(sprintf("%.0f", ms))
  }

  cli::cli_abort("Unsupported date/time format for timestamp conversion.")
}

#' Convert Epoch Milliseconds to POSIXct
#'
#' @param ms Numeric vector of epoch milliseconds.
#' @return POSIXct datetime vector in UTC.
#' @noRd
lic_from_timestamp <- function(ms) {
  if (is.null(ms)) {
    return(as.POSIXct(character(), tz = "UTC"))
  }
  as.POSIXct(as.numeric(ms) / 1000, origin = "1970-01-01", tz = "UTC")
}
