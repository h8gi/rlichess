#' Get Lichess API Token
#'
#' Retrieves the Lichess Personal API access token from environment variables.
#' Checks `LICHESS_API_TOKEN` and `LICHESS_API_ACCESS_TOKEN`.
#'
#' @param token Optional character string specifying the token explicitly.
#' @return A character string token, or `NULL` if not set.
#' @export
#' @examples
#' lic_token()
lic_token <- function(token = NULL) {
  if (!is.null(token) && nzchar(token)) {
    return(token)
  }

  env_token <- Sys.getenv("LICHESS_API_TOKEN", "")
  if (!nzchar(env_token)) {
    env_token <- Sys.getenv("LICHESS_API_ACCESS_TOKEN", "")
  }

  if (nzchar(env_token)) {
    return(env_token)
  }

  NULL
}
