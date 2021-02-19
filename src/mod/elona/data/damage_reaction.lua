local Magic = require("mod.elona_sys.api.Magic")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Effect = require("mod.elona.api.Effect")

data:add {
   _type = "base.damage_reaction",
   _id = "cut",

   on_damage = function(chara, power, params)
      -- >>>>>>>> elona122/shade2/action.hsp:1328                 if p=rsResCut{ ..
      Gui.mes_c_visible("damage.reactive_attack.thorns", chara, "Purple")
      chara:damage_hp(math.clamp(params.damage / 10, 1, params.target:calc("max_hp") / 10), params.target, { element = "elona.cut", element_power = power })
      -- <<<<<<<< elona122/shade2/action.hsp:1332                 } ..
   end
}

data:add {
   _type = "base.damage_reaction",
   _id = "ether",

   on_damage = function(chara, power, params)
      -- >>>>>>>> elona122/shade2/action.hsp:1333                 if p=rsResEther{ ..
      Gui.mes_c_visible("damage.reactive_attack.ether_thorns", chara, "Purple")
      chara:damage_hp(math.clamp(params.damage / 10, 1, params.target:calc("max_hp") / 10), params.target, { element = "elona.ether", element_power = power })
      -- <<<<<<<< elona122/shade2/action.hsp:1337                 } ..
   end
}

data:add {
   _type = "base.damage_reaction",
   _id = "acid",

   on_damage = function(chara, power, params)
      -- >>>>>>>> elona122/shade2/action.hsp:1338                 if p=rsResAcid :if attackSkill!rsM ..
      if params.attack_skill ~= "elona.martial_arts" and Rand.one_in(5) then
         Effect.damage_item_acid(params.weapon)
      end
      -- <<<<<<<< elona122/shade2/action.hsp:1338                 if p=rsResAcid :if attackSkill!rsM ..

      -- >>>>>>>> elona122/shade2/action.hsp:1342             if dmg>cMHP(tc)/10{ ..
      if params.damage > params.target:calc("max_hp") / 10 then
         Gui.mes_c_visible("damage.reactive_attack.acids", params.target, "Purple")
         Magic.cast("elona.acid_ground", { source = params.target, target = params.target, power = power })
      end
      -- <<<<<<<< elona122/shade2/action.hsp:1349             } ..
   end
}
