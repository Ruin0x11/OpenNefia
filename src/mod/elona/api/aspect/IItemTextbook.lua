local IAspect = require("api.IAspect")
local IItemLocalizableExtra = require("mod.elona.api.aspect.IItemLocalizableExtra")
local IItemReadable = require("mod.elona.api.aspect.IItemReadable")
local Gui = require("api.Gui")
local Input = require("api.Input")
local I18N = require("api.I18N")
local Enum = require("api.Enum")

local IItemTextbook = class.interface("IItemTextbook",
                                  {
                                     skill_id = "string"
                                  },
                                  {
                                     IAspect,
                                     IItemReadable,
                                     IItemLocalizableExtra
                                  })

IItemTextbook.default_impl = "mod.elona.api.aspect.ItemTextbookAspect"

function IItemTextbook:localize_action()
   return "base:aspect._.elona.IItemTextbook.action_name"
end

function IItemTextbook:on_read(item, params)
   -- >>>>>>>> shade2/command.hsp:4447 	if iId(ci)=idBookSkill{ ...
   local skill_id = self:calc(item, "skill_id")
   local chara = params.chara
   if chara:is_player() and not chara:has_skill(skill_id) then
      Gui.mes("action.read.book.not_interested")
      if not Input.yes_no() then
         return "player_turn_query"
      end
   end

   chara:start_activity("elona.training", {skill_id=skill_id,item=item})

   return "turn_end"
   -- <<<<<<<< shade2/command.hsp:4454 		} ...         end,
end

function IItemTextbook:localize_extra(s, item)
   if item:calc("identify_state") >= Enum.IdentifyState.Full then
      local skill_name = I18N.localize("base.skill", self:calc(item, "skill_id"), "name")
      return I18N.get("base:aspect._.elona.IItemTextbook.title", s, skill_name)
   end
end

return IItemTextbook
