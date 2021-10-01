local IAspect = require("api.IAspect")

local IItemFromChara = class.interface("IItemFromChara",
                                       {
                                          chara_id = { type = "string", optional = true },
                                          image = { type = "string", optional = true },
                                          color = { type = "table", optional = true },
                                          gender = { type = "string", optional = true }
                                       },
                                       { IAspect })

IItemFromChara.default_impl = "mod.elona.api.aspect.ItemFromCharaAspect"

function IItemFromChara:chara_data(item)
   local chara_id = self:calc(item, "chara_id")
   if chara_id == nil then
      return nil
   end
   return data["base.chara"]:ensure(chara_id)
end

return IItemFromChara
