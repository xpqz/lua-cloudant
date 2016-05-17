## Lua-Cloudant

Cloudant = require "cloudant"

cdt = Cloudant:new{user="...", password="...", host="ABC.cloudant.com"}
cdt:database("database")

doc = cdt:read("0FF068B8-C082-9BA0-9E02-DF2340BDB1E3", {rev= "1-25f742e015dd334b7525f42a49e38df5"})
res = cdt:create{hello="world"}

res = cdt:update("0FF068B8-C082-9BA0-9E02-DF2340BDB1E3", "1-25f742e015dd334b7525f42a49e38df5", {hello="the audience"})


