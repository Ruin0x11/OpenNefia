local Chara = require("api.Chara")
local Assert = require("api.test.Assert")

function test_ICharaRoles_remove_role()
   local chara = Chara.create("elona.putit", nil, nil, {ownerless=true})

   chara:add_role("elona.special")
   chara:add_role("elona.informer")
   chara:add_role("elona.informer")
   chara:add_role("elona.bartender")

   Assert.eq(4, chara:iter_roles():length())
   Assert.is_truthy(chara:find_role("elona.special"))
   Assert.is_truthy(chara:find_role("elona.informer"))
   Assert.is_truthy(chara:find_role("elona.bartender"))

   chara:remove_role("elona.informer")

   Assert.eq(3, chara:iter_roles():length())
   Assert.is_truthy(chara:find_role("elona.special"))
   Assert.is_truthy(chara:find_role("elona.informer"))
   Assert.is_truthy(chara:find_role("elona.bartender"))

   chara:remove_role("elona.informer")

   Assert.eq(2, chara:iter_roles():length())
   Assert.is_truthy(chara:find_role("elona.special"))
   Assert.eq(nil, chara:find_role("elona.informer"))
   Assert.is_truthy(chara:find_role("elona.bartender"))
end

function test_ICharaRoles_remove_role__table()
   local chara = Chara.create("elona.putit", nil, nil, {ownerless=true})

   chara:add_role("elona.special")
   chara:add_role("elona.informer")
   chara:add_role("elona.bartender")

   Assert.eq(3, chara:iter_roles():length())
   Assert.is_truthy(chara:find_role("elona.special"))
   Assert.is_truthy(chara:find_role("elona.informer"))
   Assert.is_truthy(chara:find_role("elona.bartender"))

   local role = Assert.is_truthy(chara:find_role("elona.informer"))
   chara:remove_role(role)

   Assert.eq(2, chara:iter_roles():length())
   Assert.is_truthy(chara:find_role("elona.special"))
   Assert.eq(nil, chara:find_role("elona.informer"))
   Assert.is_truthy(chara:find_role("elona.bartender"))
end

function test_ICharaRoles_remove_all_roles()
   local chara = Chara.create("elona.putit", nil, nil, {ownerless=true})

   chara:add_role("elona.special")
   chara:add_role("elona.informer")
   chara:add_role("elona.informer")
   chara:add_role("elona.bartender")

   Assert.eq(4, chara:iter_roles():length())
   Assert.is_truthy(chara:find_role("elona.special"))
   Assert.is_truthy(chara:find_role("elona.informer"))
   Assert.is_truthy(chara:find_role("elona.bartender"))

   chara:remove_all_roles("elona.informer")

   Assert.eq(2, chara:iter_roles():length())
   Assert.is_truthy(chara:find_role("elona.special"))
   Assert.eq(nil, chara:find_role("elona.informer"))
   Assert.is_truthy(chara:find_role("elona.bartender"))
end
