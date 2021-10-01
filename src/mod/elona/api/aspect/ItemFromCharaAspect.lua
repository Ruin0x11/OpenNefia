local IItemFromChara = require("mod.elona.api.aspect.IItemFromChara")
local ElonaChara = require("mod.elona.api.ElonaChara")

local ItemFromCharaAspect = class.class("ItemFromCharaAspect", IItemFromChara)

function ItemFromCharaAspect:init(item, params)
   if params.chara then
      self.chara_id = params.chara._id
      self.color = params.chara.color or nil
      self.image = params.chara.proto.image or params.chara.image or nil
      self.gender = params.chara.gender or nil
   end

   self.chara_id = params.chara_id or self.chara_id
   self.color = params.color or self.color
   self.image = params.image or self.image
   self.gender = params.gender or self.gender

   if self.chara_id then
      local proto = data["base.chara"][self.chara_id]
      if proto then
         self.color = self.color or table.deepcopy(proto.color)
         self.image = self.image or ElonaChara.default_chara_image(proto, self.gender)
      end
   end
end

return ItemFromCharaAspect
