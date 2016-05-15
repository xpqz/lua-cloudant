https://gist.github.com/tylerneylon/59f4bcf316be525b30ab

```lua
local url = "http://127.0.0.1:8000/api/getstrings/"
local body = "message=getstrings"
local headers = {
    ["content-length"] = body:len(),
    ["Content-Type"] = "application/x-www-form-urlencoded"
  }

local response = {}
local r, c, h = http.request{
  url= url,
  method = "POST",
  headers = headers,
  source = ltn12.source.string(body),
  sink = ltn12.sink.table(response)

}
```

```lua
local http = require("socket.http")
local ltn12 = require("ltn12")

-- The Request Bin test URL: http://requestb.in/12j0kaq1
function sendRequest()
local path = "http://requestb.in/12j0kaq1?param_1=one&param_2=two&param_3=three"
  local payload = [[ {"key":"My Key","name":"My Name","description":"The description","state":1} ]]
  local response_body = { }

  local res, code, response_headers, status = http.request
  {
    url = path,
    method = "POST",
    headers =
    {
      ["Authorization"] = "Maybe you need an Authorization header?", 
      ["Content-Type"] = "application/json",
      ["Content-Length"] = payload:len()
    },
    source = ltn12.source.string(payload),
    sink = ltn12.sink.table(response_body)
  }
  luup.task('Response: = ' .. table.concat(response_body) .. ' code = ' .. code .. '   status = ' .. status,1,'Sample POST request with JSON data',-1)
end
```
http://w3.impa.br/~diego/software/luasocket/ltn12.html

