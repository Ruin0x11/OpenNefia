local Event = require("api.Event")
local DamagePopup = require("mod.damage_popups.api.DamagePopup")

Event.register("base.on_init_save", "Init save (damage popups)", function()
                  save.damage_popups.popups = { count = 0 }
end)

Event.register("base.on_map_changed", "Clear damage popups", DamagePopup.clear)

DamagePopup.install()

Event.register("base.after_damage_hp",
               "damage popups",
               function(source, p)
                  local Map = require("api.Map")
                  if Map.is_in_fov(p.chara.x, p.chara.y) then
                     DamagePopup.add(p.chara.x, p.chara.y, tostring(p.damage))
                  end
               end,
               {priority=500000})

Event.register("elona.on_physical_attack_miss",
               "damage popups",
               function(source, p)
                  local Map = require("api.Map")
                  if Map.is_in_fov(p.target.x, p.target.y) then
                     if p.hit == "evade" then
                        DamagePopup.add(p.target.x, p.target.y, "evade!!")
                     else
                        DamagePopup.add(p.target.x, p.target.y, "miss")
                     end
                  end
               end,
               {priority=500000})

Event.register("base.on_heal_chara_hp",
               "damage popups",
               function(source, p)
                  if p.quiet then return end
                  if source:is_in_fov() then
                     DamagePopup.add(source.x, source.y, tostring(p.amount), { 175, 255, 175 })
                  end
               end,
               {priority=500000})

Event.register("base.on_heal_chara_mp",
               "damage popups",
               function(source, p)
                  if p.quiet then return end
                  if source:is_in_fov() then
                     DamagePopup.add(source.x, source.y, tostring(p.amount), { 175, 175, 255 })
                  end
               end,
               {priority=500000})
