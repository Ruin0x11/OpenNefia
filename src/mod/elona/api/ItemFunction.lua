local Gui = require("api.Gui")
local Item = require("api.Item")

local ItemFunction = {}

function ItemFunction.read_ancient_book(item, params)
   -- >>>>>>>> shade2/proc.hsp:1168 *readSpellbook ..
   if item.params.ancient_book_is_deciphered then
      Gui.mes("action.read.book.already_decoded")
      return "turn_end"
   end

   local chara = params.chara or item:get_owning_chara()

   if chara:has_effect("elona.blindness") then
      Gui.mes_visible("action.read.cannot_see", chara)
      return "turn_end"
   end

   -- <<<<<<<< shade2/proc.hsp:1176 		cRowAct(cc)=rowActRead ..

   -- >>>>>>>> shade2/proc.hsp:1180 			if iId(ci)=idMageBook{ ..
   local base_diff = item.params.ancient_book_difficulty
   local difficulty = 50 + base_diff * 50 + base_diff * base_diff * 20
   -- <<<<<<<< shade2/proc.hsp:1182 			}else{ ..

   -- >>>>>>>> shade2/proc.hsp:1186 		cActionPeriod(cc)=p/(2+sLiteracy(pc))+1 ..
   local sep = item:separate()
   sep.chara_using = chara
   assert(Item.is_alive(sep))

   local turns = difficulty / (2 * chara:skill_level("elona.literacy")) + 1
   chara:start_activity("elona.read_ancient_book", { ancient_book = sep }, turns)

   return "turn_end"
   -- <<<<<<<< shade2/proc.hsp:1191 		} ..
end

return ItemFunction
