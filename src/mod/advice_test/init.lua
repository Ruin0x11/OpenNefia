local Advice = require("api.Advice")
local ItemMaterial = require("mod.elona.api.ItemMaterial")
local Chara = require("api.Chara")
local Color = require("mod.elona_sys.api.Color")
local Rand = require("api.Rand")
local Log = require("api.Log")

local function all_rubynus()
   return "elona.rubynus"
end

-- Advice.add("filter_return", ItemMaterial.choose_random_material_2, "All materials are now rubynus", all_rubynus)

local function to_putit(chara)
   if chara then
      chara.image = "elona.chara_race_slime"
      chara.portrait = nil
      chara.color = Color.hsv_to_rgb(Rand.rnd(256), 255, 255)
   end
   return chara
end

-- Advice.add("filter_return", Chara.create, "Everyone looks like a putit", to_putit)
