
local request = require 'http.request'
local json = require 'cjson'
local mime = require 'mime'
local URI = require 'uri'

local Cloudant = { baseuri = nil }

local function urlencode(str)
   if (str) then
      str = string.gsub (str, "\n", "\r\n")
      str = string.gsub (str, "([^%w ])",
         function (c) return string.format ("%%%02X", string.byte(c)) end)
      str = string.gsub (str, " ", "+")
   end
   return str    
end

function Cloudant:new(tbl) 
  tbl = tbl or {}
  setmetatable(tbl, self)

  self.__index = self

  assert(tbl.user)
  assert(tbl.password)

  self.baseuri = URI:new {
    scheme = 'https',
    host = assert(tbl.host),
    path = ''
  }

  self.auth = 'Basic ' .. mime.b64(string.format('%s:%s', tbl.user, tbl.password))

  return tbl
end

function Cloudant:database(name)
  self.dbname = assert(name)
end

function Cloudant:url(endpoint)
  return self.baseuri:stringify(self.dbname .. '/' .. endpoint)
end

function Cloudant:instanceurl(endpoint)
  return self.baseuri:stringify(endpoint)
end

function Cloudant:request(method, url, params, data)
  local req = request.new_from_uri(url)
  req.headers:upsert(':method', method)
  if data then
    req.headers:append('content-type', 'application/json')
    req:set_body(json.encode(data))
  end
  if self.cookie then
    req.headers:append('cookie', self.cookie)
  else -- fallback on basic
    req.headers:append('Authorization', self.auth)
  end

  return req:go()
end

function Cloudant:authenticate()
  local req = request.new_from_uri(self:instanceurl('_session'))
  local authdata = string.format('name=%s&password=%s', urlencode(self.user), urlencode(self.password))
  req.headers:upsert(':method', 'POST')
  req.headers:append('content-type', 'application/x-www-form-urlencoded')
  req:set_body(authdata)
  local headers, stream = req:go()
  self.cookie = headers:get('set-cookie')
end
  
local function body(headers, stream)
  return json.decode(stream:get_body_as_string())
end

-- The CouchDB document API --

function Cloudant:bulkdocs(data, options)
  return body(self:request('POST', self:url('_bulk_docs'), options, {docs=data}))
end

function Cloudant:read(docid, options)
  return body(self:request('GET', self:url(docid), options, nil))
end

function Cloudant:create(body, options) 
  local data = self:bulkdocs({body}, options)
  return data[1]
end

function Cloudant:update(docid, revid, body, options)
  body._id = docid
  body._rev = revid
  local data = self:bulkdocs({body}, options)
  return data[1]
end

function Cloudant:delete(docid, revid)
 local data = self:bulkdocs({{_id=docid, _rev=revid, _deleted=true}}, nil)
 return data[1]
end

function Cloudant:alldocs(options)
    return body(self:request('GET', self:url('_all_docs'), options, nil))
end

-- The CouchDB instance API --

function Cloudant:createdb()
  return body(self:request('PUT', self:instanceurl(self.dbname), nil, nil))
end

function Cloudant:dbinfo()
  return body(self:request('GET', self:instanceurl(self.dbname), nil, nil))
end

function Cloudant:deletedb()
  return body(self:request('DELETE', self:instanceurl(self.dbname), nil, nil))
end

function Cloudant:listdbs()
  return body(self:request('GET', self:instanceurl(''), nil, nil))
end

-- The CouchDB replication API --

function Cloudant:changes(options)
    return self:request('GET', self:url('_changes'), options, nil)
end


return Cloudant
