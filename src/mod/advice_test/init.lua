local Advice = require("api.Advice")
local Rand = require("api.Rand")
local Color = require("mod.extlibs.api.Color")

local function all_rubynus()
   return "elona.rubynus"
end

-- Advice.add("filter_return", ItemMaterial.choose_random_material_2, "All materials are now rubynus", all_rubynus)

local function to_putit(chara)
   if chara then
      chara.image = "elona.chara_race_slime"
      chara.portrait = nil
      chara.color = {Color:new_hsl(Rand.rnd(360), 1, 1):to_rgb()}
   end
   return chara
end

-- Advice.add("filter_return", Chara.create, "Everyone looks like a putit", to_putit)

-- require("mod.advice_test.event.skip_train_confirm")
