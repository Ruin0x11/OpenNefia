local Chara = require("api.Chara")
local Rand = require("api.Rand")
local Itemgen = require("mod.tools.api.Itemgen")
local Filters = require("mod.elona.api.Filters")
local I18N = require("api.I18N")

local collect = {
   _id = "collect",
   _type = "elona_sys.quest",

   elona_id = 1011,
   ordering = 10000,
   client_chara_type = 3,
   reward = "elona.supply",
   reward_fix = 60,

   min_fame = 0,
   chance = 14,

   params = {
      target_chara_uid = "number",
      target_name = "string",
      target_item_id = "string"
   },

   difficulty = function()
      return Chara.player():calc("level") / 3
   end,

   deadline_days = function() return Rand.rnd(3) + 2 end,

   generate = function(self, client, start, map)
      local target_chara, target_item

      local charas = Rand.shuffle(map:iter_charas():to_list())

      for _, chara in ipairs(charas)  do
         if chara.uid ~= client.uid then
            if Chara.is_alive(chara, map)
               and chara:reaction_towards(Chara.player(), "original") > 0
               and not chara.roles["elona.guard"]
               and not chara.roles["elona.non_quest_target"]
            then
               local item = Itemgen.create(nil, nil, { level = 40, quality = 2, categories = Filters.fsetcollect }, chara)
               if item then
                  item.count = 0 -- TODO
                  target_chara = chara
                  target_item = item
                  break
               end
            end
         end
      end

      if not target_chara then
         return false, "No target character found."
      end

      self.params = {
         target_chara_uid = target_chara.uid,
         target_name = target_chara.name,
         target_item_id = target_item._id
      }

      return true
   end,
   locale_data = function(self)
      return {
         item_name = I18N.get("item." .. self.params.target_item_id .. ".name"),
         target_name = self.params.target_name
      }
   end
}
data:add(collect)
