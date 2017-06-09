local util = require 'http.util'

local URI = {}

function URI:new(tbl) 
  tbl = tbl or {}
  setmetatable(tbl, self)
  self.__index = self
  return tbl
end

function URI:stringify(relative, params)
  local path = self.path
  local par = ''
  if params then util.dict_to_query(params) end
  if relative then
    path = self.path .. '/' .. relative
  end
  return string.format("%s://%s%s%s", self.scheme, self.host, path, par)
end

return URI