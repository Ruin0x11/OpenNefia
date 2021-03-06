-- Elona's original (non-recipe) crafting system, using materials.
local Production = {}
local Gui = require("api.Gui")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local Rand = require("api.Rand")
local Itemgen = require("mod.tools.api.Itemgen")
local Skill = require("mod.elona_sys.api.Skill")

function Production.can_create(chara, recipe_id)
   -- >>>>>>>> shade2/material_data.hsp:176 	#module ...
   local recipe = data["elona.production_recipe"]:ensure(recipe_id)

   if not chara:has_skill(recipe.skill_used)
      or chara:skill_level(recipe.skill_used) < recipe.required_skill_level
   then
      return false
   end

   for _, material in ipairs(recipe.materials) do
      local count = chara.materials[material._id] or 0
      if count < material.amount then
         return false
      end
   end

   return true
   -- <<<<<<<< shade2/material_data.hsp:186 	#global ..
end

function Production.calc_skill_exp_gained(chara, skill, materials_used)
   -- >>>>>>>> shade2/calculation.hsp:153 *expProduct ...
   return 50 + materials_used * 20
   -- <<<<<<<< shade2/calculation.hsp:155 	return ..
end

function Production.produce_item(chara, recipe_id)
   if not Production.can_create(chara, recipe_id) then
      return nil
   end


   -- >>>>>>>> shade2/material.hsp:178 		matUse=0 ...
   local recipe = data["elona.production_recipe"]:ensure(recipe_id)

   local materials_used = 0
   for _, material in ipairs(recipe.materials) do
      chara.materials[material._id] = math.max(chara.materials[material._id] - material.amount, 0)
      materials_used = materials_used + material.amount
   end

   Gui.play_sound("base.build1")

   local quality = Enum.Quality.Normal
   if Rand.rnd(200 + recipe.required_skill_level) < chara:skill_level(recipe.skill_used) + 20 then
      quality = Enum.Quality.Great
   end
   if Rand.rnd(100 + recipe.required_skill_level) < chara:skill_level(recipe.skill_used) + 20 then
      quality = Enum.Quality.Good
   end

   local filter = {
      id = recipe.item_id,
      level = Calc.calc_object_level(chara:skill_level(recipe.skill_used)),
      quality = Calc.calc_object_quality(quality)
   }

   local item = Itemgen.create(nil, nil, filter, chara)
   if item then
      Gui.mes("production.you_crafted", item:build_name(1))
      local exp = Production.calc_skill_exp_gained(chara, recipe.skill_used, materials_used)
      Skill.gain_skill_exp(chara, recipe.skill_used, exp)
      chara:refresh()
      Gui.refresh_hud()

      return item
   end

   return nil
   -- <<<<<<<< shade2/material.hsp:194 		call charaRefresh,(r1=pc):gosub *screen_drawStat ..
end

return Production
