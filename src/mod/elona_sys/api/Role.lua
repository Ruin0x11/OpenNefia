local Role = {}

function Role.has(chara, role_id)
   return not not Role.get(chara, role_id)
end

function Role.get(chara, role_id)
   if not chara.roles then
      return nil
   end

   for _, role in ipairs(chara.roles) do
      if role.id == role_id then
         return role
      end
   end

   return nil
end

return Role
