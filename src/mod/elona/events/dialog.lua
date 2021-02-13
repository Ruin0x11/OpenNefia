local Event = require("api.Event")

local function calc_dialog_choices(speaker, params, result)
   table.insert(result, {"talk", "talk.npc.common.choices.talk"})

   for _, role in ipairs(speaker.roles) do
      local id = role._id
      local role_data = data["base.role"]:ensure(id)
      if role_data.dialog_choices then
         for _, choice in ipairs(role_data.dialog_choices) do
            if type(choice) == "function" then
               local choices = choice(speaker, params)
               assert(type(choices) == "table")
               for _, choice in ipairs(choices) do
                  table.insert(result, choice)
               end
            else
               table.insert(result, choice)
            end
         end
      end
   end

   return result
end

Event.register("elona.calc_dialog_choices", "Default NPC dialog choices", calc_dialog_choices)
