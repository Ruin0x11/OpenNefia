local data = require("internal.data")

local ICharaRoles = class.interface("ICharaRoles")

function ICharaRoles:init()
   self.roles = {}
end

function ICharaRoles:iter_roles(role_id)
   data["base.role"]:ensure(role_id)
   local filter = function() return true end
   if role_id then
      filter = function(role) return role._id == role_id end
   end
   return fun.iter(self.roles):filter(filter)
end

function ICharaRoles:add_role(role_id, metadata)
   data["base.role"]:ensure(role_id)
   metadata = metadata or {}

   local role = { _id = role_id }
   table.merge(role, metadata)

   self.roles[#self.roles+1] = role
end

function ICharaRoles:find_role(role_id)
   return self:iter_roles(role_id):nth(1)
end

function ICharaRoles:has_any_roles()
   return #self.roles > 0
end

return ICharaRoles
