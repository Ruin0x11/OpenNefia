local Role = {}

function Role.has(chara, role_id)
   if not chara.roles then
      return false
   end

   for _, role in ipairs(chara.roles) do
      if role.id == role_id then
         return true
      end
   end

   return false
end

return Role
