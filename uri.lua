local URI = {}

function urlencode(str)
   if (str) then
      str = string.gsub (str, "\n", "\r\n")
      str = string.gsub (str, "([^%w ])",
         function (c) return string.format ("%%%02X", string.byte(c)) end)
      str = string.gsub (str, " ", "+")
   end
   return str    
end

function paramencode(params)
  if params then 
    local data = {}
    for key, value in pairs(params) do
      data[#data+1] = urlencode(key) .. '=' .. urlencode(value)
    end
    return '?' .. table.concat(data, '&')
  end
  return ''
end

function URI:new(tbl) 
  tbl = tbl or {}
  setmetatable(tbl, self)
  self.__index = self
  return tbl
end

function URI:scheme(scheme)
  if not scheme then
    return self.scheme
  end
  self.scheme = scheme
end

function URI:stringify(relative, params)
  local auth = ''
  local path = self.path
  local par = paramencode(params)
  if relative then
    path = self.path .. '/' .. relative
  end
  if self.user and self.password then auth = string.format("%s:%s@", self.user, self.password) end
  return string.format("%s://%s%s/%s%s", self.scheme, auth, self.host, path, par)
end

return URI