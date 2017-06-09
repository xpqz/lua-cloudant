local luaunit = require 'luaunit'
local Cloudant = require 'cloudant'

local user = os.getenv 'CLOUDANT_USER'
local password = os.getenv 'CLOUDANT_PASSWORD'
local host = os.getenv 'CLOUDANT_HOST'

local cdt = Cloudant:new{user=user, password=password, host=host}
cdt:authenticate() -- cookie auth

TestCRUD = {}
  function TestCRUD:setUp()
    cdt:database 'luatest'
    cdt:createdb()
  end

  function TestCRUD:tearDown()
    cdt:deletedb()
  end

  function TestCRUD:testCreateDocument()
    status = cdt:create{hello='world'}
    luaunit.assertNotNil(status.id)
    luaunit.assertNotNil(status.rev)
  end

  function TestCRUD:testReadDocument() -- NOTE: reading writes not a good idea!
    status = cdt:create{hello='read'}
    doc = cdt:read(status.id, {rev=status.rev})
    luaunit.assertEquals(status.id, doc._id)
    luaunit.assertEquals(status.rev, doc._rev)
    luaunit.assertEquals(doc.hello, 'read')
  end

  function TestCRUD:testDeleteDocument() -- NOTE: reading writes not a good idea!
    status = cdt:create{hello='delete'}
    result = cdt:delete(status.id, status.rev)
    luaunit.assertNotNil(result.id)
    luaunit.assertNotNil(result.rev)
    luaunit.assertEquals(status.id, result.id)
    luaunit.assertNotEquals(status.rev, result.rev)
  end

  function TestCRUD:testBulkDocs()
    status = cdt:bulkdocs{
      {hello='bd1'},
      {hello='bd2'},
      {hello='bd3'},
      {hello='bd4'}
    }
    
    luaunit.assertEquals(#status, 4)
  end

-- end of table TestCrud

os.exit(luaunit.LuaUnit.run())