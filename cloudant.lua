
local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("json")
local mime = require("mime")
local URI = require("uri")

local Cloudant = { baseuri = nil }

-- headers = { authentication = "Basic " .. (mime.b64("fulano:silva")) }

function dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

function Cloudant:new(tbl) 
  tbl = tbl or {}
  setmetatable(tbl, self)

  self.__index = self

  self.baseuri = URI:new {
    scheme = 'https',
    host = assert(tbl.host),
    user = assert(tbl.user),
    password = assert(tbl.password),
    path = '/'
  }

  return tbl
end

function Cloudant:database(name)
  self.database = assert(name)
end

function Cloudant:url(endpoint)
  return self.baseuri:stringify(self.database .. '/' .. endpoint)
end

function Cloudant:instanceurl(endpoint)
  return self.baseuri:stringify(endpoint)
end

function Cloudant:request(method, url, params, data)
  local response_body = {}
  local req = { url = url, method = method, sink = ltn12.sink.table(response_body) }
  if data then
    local jsonData = json.stringify(data)
    req.source = ltn12.source.string(jsonData)
    req.headers = { ["Content-Type"] = "application/json", ["Content-Length"] = jsonData:len() }
  end

  local res, httpStatus, responseHeaders, status = http.request(req)
  return json.parse(table.concat(response_body))  
end

-- The CouchDB API --

function Cloudant:get(args)
  return self:request('GET', self:url(args.docid), nil, nil)
end

return Cloudant
