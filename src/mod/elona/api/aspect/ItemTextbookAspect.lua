local IItemTextbook = require("mod.elona.api.aspect.IItemTextbook")
local Skill = require("mod.elona_sys.api.Skill")

local ItemTextbookAspect = class.class("ItemTextbookAspect", { IItemTextbook })

function ItemTextbookAspect:init(item, params, gen_params)
   -- >>>>>>>> shade2/item.hsp:619 	if iId(ci)=idBookSkill	:if iBookId(ci)=0:iBookId( ..
   self.skill_id = params.skill_id or Skill.random_skill()
   -- <<<<<<<< shade2/item.hsp:619 	if iId(ci)=idBookSkill	:if iBookId(ci)=0:iBookId( ..
end

return ItemTextbookAspect
