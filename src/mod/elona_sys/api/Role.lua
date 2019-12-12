local Role = {}

function Role.has(chara, role_id)
   return not not Role.get(chara, role_id)
end

function Role.get(chara, role_id)
   if not chara.roles then
      return nil
   end

   return chara.roles[role_id]
end

return Role
