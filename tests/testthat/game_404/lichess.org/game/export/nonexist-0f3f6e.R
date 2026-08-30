structure(list(method = "GET", url = "https://lichess.org/game/export/nonexist?moves=true&clocks=true&evals=true&opening=true", 
    status_code = 404L, headers = structure(list(server = "nginx", 
        date = "Sun, 30 Aug 2026 06:23:25 GMT", `content-type` = "application/json", 
        `strict-transport-security` = "max-age=63072000; includeSubDomains; preload", 
        `x-frame-options` = "DENY", `permissions-policy` = "interest-cohort=()", 
        `content-encoding` = "gzip"), class = "httr2_headers"), 
    body = charToRaw("{\"error\":\"Not found\"}"), timing = c(redirect = 0, 
    namelookup = 0, connect = 0, pretransfer = 0.000115, starttransfer = 0.384861, 
    total = 0.384999), cache = new.env(parent = emptyenv())), class = "httr2_response")
