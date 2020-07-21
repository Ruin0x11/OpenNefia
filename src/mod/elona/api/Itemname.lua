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

local function additional_info(item)
   return ""
end

local function additional_info_2(item, number)
   return ""
end

local function additional_info_3(item, number)
   return ""
end

local function cut_point_1_en(item, s)
   local subname = 0
   local material = "raw"
   if item:has_category("elona.furniture") then
      if subname ~= 0 then
         if subname >= 12 then
            subname = 0
         else
            s = s .. "FURNITURE "
         end
      end

      if item.material ~= 0 then
         s = s .. I18N.get("item_material." .. material .. ".name") .. "work "
      end
   end

   -- s = item:emit("elona.calc_itemname_info_1", {}, "")

   -- if item.id == 687 and item.param2 ~= 0 then
   --    s = s .. "undecoded "
   -- end
   -- if item.id == 783 and subname == 0 then
   --    s = s .. "custom "
   -- end

   -- if item.id == 630 then
   --    s = s .. "MATERIAL "
   -- end

   -- if item.id == 729 then
   --    s = s .. "GIFT "
   -- end

   return s
end


function Itemname.en(item, number, needs_article)
   number = number or item.amount
   local data = item.proto
   local category = data.category or 50000 -- TODO
   local subname = item.subname or 0 -- TODO
   local material = "mica" -- TODO

   local s = ""

   local s2 = ""
   local s3 = ""

   local identify_state = item:calc("identify_state")
   local curse_state = item:calc("curse_state")
   local name = item:calc("name")

   if identify_state == "completely" then
      if curse_state == "blessed" then
         s = I18N.get("ui.curse_state.blessed") .. " "
      elseif curse_state == "cursed" then
         s = I18N.get("ui.curse_state.cursed") .. " "
      elseif curse_state == "doomed" then
         s = I18N.get("ui.curse_state.doomed") .. " "
      end

      if not (item.has_random_name and identify_state == "unidentified") then
         s2 = data.originalnameref2 or ""
         assert(s2)

         if string.match(name, "with") then
            s3 = "with"
         else
            s3 = "of"
         end

         if identify_state ~= "unidentified" and s2 == "" then
            if (item:calc("cargo_weight") or 0) > 0 then
               s2 = "cargo"
            end
            if category == 22000 or category == 18000 then
               s2 = "pair"
            end
         end

         if item:has_category("elona.food") and (item.param1 or 0) ~= 0 and (item.param2 or 0) ~= 0 then
            s2 = "dish"
         end
      end

      if s2 ~= "" then
         if number > 1 then
            s = tostring(number) .. " " .. s .. s2 .. "s " .. s3 .. " "
         else
            s = s .. s2 .. " " .. s3 .. " "
         end
      elseif number > 1 then
         s = tostring(number) .. " " .. s
      end

      if material == "raw" and item.params.hours_until_rot < 0 then
         s = s .. "rotten "
      end

      local skip = false
      if item:has_category("elona.food") and (item.param1 or 0) ~= 0 and (item.param2 or 0) ~= 0 then
         skip = true
      end

      s = cut_point_1_en(item, s)

      if not skip then
         local alpha = false
         if identify_state == "completely" and category < 50000 then
            if item:calc("is_eternal_force") then
               alpha = true
               s = s .. "eternal force "
            else
               if subname >= 10000 then
                  if subname < 40000 then
                     s = s .. "EGOMINORN "
                  end
               end
               if item.quality ~= Quality.Unique then
                  if item.quality == Quality.Great or item.quality == Quality.God then
                     s = s .. I18N.get("item_material." .. material .. ".alias") .. I18N.space()
                  else
                     s = s .. I18N.get("item_material." .. material .. ".name") .. I18N.space()
                  end
               end
            end
         end
      end
   end

   local unknown_name = Text.unidentified_item_params(item)

   if identify_state == "unidentified" then
      s = s .. unknown_name
   elseif identify_state ~= "completely" then
      if (item.quality ~= Quality.Great and item.quality ~= Quality.God) or category >= 50000 then
         s = s .. name
      else
         s = s .. unknown_name
      end
   elseif item.quality == Enum.Quality.Unique or item:calc("is_precious") then
      s = s .. name
   else
      s = s .. name

      if category < 50000 and subname >= 10000 and subname < 20000 then
         s = s .. " EGONAME "
      end
      if subname >= 40000 then
         local title = Text.random_title("weapon", subname - 40000)
         if item.quality == Quality.Great then
            s = I18N.space() .. I18N.get("item.miracle_paren", title)
         else
            s = I18N.space() .. I18N.get("item.godly_paren", title)
         end
      end
   end

   if needs_article then
      if identify_state == "completely"
         and (item.quality == Quality.Great or item.quality == Quality.God)
         and category < 50000
      then
         s = "the " .. s
      elseif number == 1 then
         if string.find(s, "^[aeiou]") then
            s = "an " .. s
         else
            s = "a " .. s
         end
      end
   end

   if s2 == "" and item.id ~= 618 and number > 1 then
      s = s .. "s"
   end

   s = s .. additional_info(item)


   if identify_state == "completely" then
      s = s .. localize_identified_parts(item)
   end

   s = s .. additional_info_2(item, number)

   if identify_state == "almost" and category < 50000 then
      s = s .. I18N.get("ui.sense_perception",
                        "ui.quality._" .. item.quality,
                        "item_material." .. material .. ".name")

      if curse_state == "cursed" then
         s = s .. I18N.get("item.approximate_curse_state.cursed")
      elseif curse_state == "doomed" then
         s = s .. I18N.get("item.approximate_curse_state.doomed")
      end
   end

   s = s .. additional_info_3(item, number)

   return s
end

return Itemname
