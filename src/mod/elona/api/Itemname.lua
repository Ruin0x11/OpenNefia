--- Item name functions.
---
--- There's really no good way of abstracting the logic except for
--- writing a separate function for each language.
---
--- @module Itemname
local I18N = require("api.I18N")
local Rand = require("api.Rand")
local Text = require("mod.elona.api.Text")
local Enum = require("api.Enum")
local Quality = Enum.Quality
local ItemMemory = require("mod.elona_sys.api.ItemMemory")
local Effect = require("mod.elona.api.Effect")

local Itemname = {}

local function number_string(i)
   if i >= 0 then
      return "+" .. tostring(i)
   end

   return tostring(i)
end

local function localize_identified_parts(item)
   local s = ""

   local bonus = (item:calc("bonus") or 0)
   if bonus ~= 0 then
      s = s .. number_string(bonus)
   end
   if item.charges and item.charges > 0 then
      s = s .. I18N.get("item.charges", item.charges)
   end

   local dice_x = item:calc("dice_x") or 0
   local dice_y = item:calc("dice_y") or 0
   local damage_bonus = item:calc("damage_bonus") or 0

   if dice_x ~= 0 or item.hit_bonus ~= 0 or damage_bonus ~= 0 then
      local hit_bonus = item:calc("hit_bonus") or 0

      s = s .. " ("
      if dice_x ~= 0 then
         s = s .. tostring(dice_x) .. "d" .. tostring(dice_y)

         if damage_bonus ~= 0 then
            if damage_bonus > 0 then
               s = s .. "+" .. tostring(damage_bonus)
            else
               s = s .. tostring(damage_bonus)
            end
            s = s .. ")"

            if hit_bonus ~= 0 then
               s = s .. "(" .. tostring(hit_bonus) .. ")"
            end
         end
      else
         s = s .. tostring(hit_bonus) .. "," .. tostring(damage_bonus) .. ")"
      end

      local pv = item:calc("pv") or 0
      local dv = item:calc("dv") or 0
      if dv ~= 0 or pv ~= 0 then
         s = s .. " [" .. dv .. "," .. pv .. "]"
      end
   end

   return s
end

local itemname = {}

function itemname.en(item, amount, needs_article)
   local name = ""
   local identify = item:calc("identify_state")

   -- >>>>>>>> shade2/item_func.hsp:495 		}else{	 ..

   -- <<<<<<<< shade2/item_func.hsp:521 		} ..

   local unknown_name = Text.unidentified_item_params(item)

   return name
end

function Itemname.build_name(item, amount, needs_article)
   amount = amount or item.amount

   if ItemMemory.is_known(item._id) and item.identify_state == Enum.IdentifyState.None  then
      Effect.identify_item(item, Enum.IdentifyState.Name)
   end

   local f = itemname[I18N.language()] or itemname.en

   return f(item, number, needs_article)
end

return Itemname
