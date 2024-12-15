
```R
tinytex::tlmgr_install("luatexja")
tinytex::tlmgr_install("haranoaji")
```

tokenを更新したら以下を実行する必要があります。

```R
tar_invalidate(access_token)
```

data 取得
```sh
curl 'https://lichess.org/api/games/user/h8gi?prefType=bullet&moves=false&opening=true' -H "Authorization: Bearer $LICHESS_API_ACCESS_TOKEN" -H "Accept: application/x-ndjson" > raw_data.json
```
