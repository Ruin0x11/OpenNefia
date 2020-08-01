local Chara = require("api.Chara")
local Draw = require("api.Draw")
local Item = require("api.Item")
local Map = require("api.Map")
local ElonaAction = require("mod.elona.api.ElonaAction")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Pos = require("api.Pos")
local Rand = require("api.Rand")
local UiTheme = require("api.gui.UiTheme")
local World = require("api.World")
local Action = require("api.Action")
local Enum = require("api.Enum")

local ElonaCommand = {}

local last_op = "elona.inv_examine"

function ElonaCommand.quick_inv(player)
   local result, canceled = Input.query_inventory(player, last_op, nil, "elona.main")

   last_op = result.operation

   if canceled then
      return result, canceled
   end
   return result.result, canceled
end

local function query_inventory(player, op)
   local result, canceled = Input.query_inventory(player, op, nil, "elona.main")
   if canceled then
      return result, canceled
   end
   return result.result, canceled
end

function ElonaCommand.inventory(player)
   return query_inventory(player, "elona.inv_examine")
end

function ElonaCommand.bash(player)
   Gui.mes("action.bash.prompt")
   local dir = Input.query_direction()

   if not dir then
      Gui.mes("common.it_is_impossible")
      return "player_turn_query"
   end

   local result = ElonaAction.bash(player, Pos.add_direction(dir, player.x, player.y))

   if not result then
      return "player_turn_query"
   end

   return "turn_end"
end

function ElonaCommand.read(player, item)
   local result, canceled = Input.query_inventory(player, "elona.inv_read", nil, "elona.main")
   if canceled then
      return result, canceled
   end
   return result.result, canceled
end

function ElonaCommand.do_eat(player, item)
   if player:calc("nutrition") > 10000 then
      Gui.mes("ui.inv.eat.too_bloated")
      Gui.update_screen()
      return "player_turn_query"
   end

   local result = ElonaAction.eat(player, item)

   if not result then
      return "player_turn_query"
   end

   return "turn_end"
end

function ElonaCommand.eat(player)
   return query_inventory(player, "elona.inv_eat")
end

function ElonaCommand.drink(player)
   return query_inventory(player, "elona.inv_drink")
end

function ElonaCommand.zap(player)
   return query_inventory(player, "elona.inv_zap")
end

function ElonaCommand.use(player)
   return query_inventory(player, "elona.inv_use")
end

function ElonaCommand.dip(player)
   return query_inventory(player, "elona.inv_dip_source")
end

function ElonaCommand.throw(player)
   return query_inventory(player, "elona.inv_throw")
end

function ElonaCommand.do_dig(player, x, y)
   if player.stamina < 0 then
      Gui.mes("action.dig.too_exhausted")
      return false
   end

   player:start_activity("elona.dig_wall", {x = x, y = y})
   return true
end

function ElonaCommand.dig(player)
   Gui.mes("action.dig.prompt")
   local dir = Input.query_direction()

   if not dir then
      Gui.mes("common.it_is_impossible")
      return "player_turn_query"
   end

   local player = Chara.player()
   local x, y = Pos.add_direction(dir, player.x, player.y)

   if x == player.x and y == player.y then
      player:start_activity("elona.digging_spot")
      return "turn_end"
   end

   -- Don't allow digging into water.
   local tile = player:current_map():tile(x, y)
   local can_dig = tile.is_solid and tile.role ~= Enum.TileRole.Water

   if not can_dig then
      Gui.mes("common.it_is_impossible")
      return "player_turn_query"
   end

   Gui.update_screen()
   local result = ElonaCommand.do_dig(player, x, y)

   if not result then
      return "player_turn_query"
   end

   return "turn_end"
end

function ElonaCommand.fire(player)
   local target = Action.find_target(player)

   if not target then
      return "player_turn_query"
   end

   if player:reaction_towards(target) >= 0 then
      if not ElonaAction.prompt_really_attack(player, target) then
         return "player_turn_query"
      end
   end

   local ranged, err = ElonaAction.get_ranged_weapon_and_ammo(player)
   if ranged == nil then
      if err == "no_ranged_weapon" then
         Gui.mes_duplicate()
         Gui.mes("action.ranged.equip.need_weapon")
      elseif err == "no_ammo" then
         Gui.mes_duplicate()
         Gui.mes("action.ranged.equip.need_ammo")
      elseif err == "wrong_ammo" then
         Gui.mes_duplicate()
         Gui.mes("action.ranged.equip.wrong_ammo")
      end
      return "player_turn_query"
   end

   local result = ElonaAction.ranged_attack(player, target)

   if not result then
      return "player_turn_query"
   end

   return "turn_end"
end

function ElonaCommand.rest(player)
   player:start_activity("elona.resting")

   return "turn_end"
end

function ElonaCommand.increment_sleep_potential(player)
   local stats = data["base.skill"]:iter():filter(function(s) return s.type == "stat" end):extract("_id")
   local levels = 0
   for _, id in stats:unwrap() do
      levels = levels + player:base_skill_level(id)
   end
   levels = math.clamp(math.floor(levels / 6), 10, 1000)
   local exp = levels * levels * levels / 10
   local bed_quality = 1 -- TODO
   player.sleep_experience = math.floor(player.sleep_experience * bed_quality / 100)
   local grown_count = 0
   while true do
      if player.sleep_experience >= exp then
         player.sleep_experience = player.sleep_experience - exp
      elseif grown_count ~= 0 then
         break
      end
      local skill = Rand.choice(config["base._basic_attributes"])
      player:mod_skill_potential(skill, 1)
      grown_count = grown_count + 1
      if grown_count > 6 then
         if Rand.one_in(5) then
            player.sleep_experience = 0
            break
         end
      end
   end

   return grown_count
end

function ElonaCommand.do_sleep(player, bed, params)
   params = params or { no_animation = false, sleep_hours = nil }

   -- TODO is quest

   if player:calc("catches_god_signal") then
   end

   if not params.no_animation then
      Gui.play_music("elona.coda")
      Gui.mes_halt()
   end

   local bg = UiTheme.load().base.bg_night

   if not params.no_animation then
      Draw.run(function(state)
            if state.i > 20 then
               bg:draw(0, 0, Draw.get_width(), Draw.get_height(), { 255, 255, 255 })
               return nil
            end
            bg:draw(0, 0, Draw.get_width(), Draw.get_height(), { 255, 255, 255, state.i * 10 })
            Draw.wait(20 * 10)
            return { i = state.i + 1 }
               end, { i = 0 }, true)
   end

   for _, chara in player:iter_party() do
      chara:emit("elona.on_sleep")
   end

   local time_slept = params.sleep_hours or 7 + Rand.rnd(5)

   for _ = 1, time_slept do
      World.pass_time_in_seconds(60 * 60, "hour")
      save.base.date.minute = 0
      save.elona_sys.awake_hours = 0

      if not params.no_animation then
         Draw.run(function()
               bg:draw(0, 0, Draw.get_width(), Draw.get_height(), { 255, 255, 255 })
               Draw.wait(20 * 25)
         end)
      end
   end

   -- TODO gene

   if not params.no_animation then
      Draw.run(function()
            bg:draw(0, 0, Draw.get_width(), Draw.get_height(), { 255, 255, 255 })
      end)
   end

   ElonaCommand.wake_up_everyone()

   local adj = 1
   if player:has_trait("elona.perm_slow_food") then
      adj = 2
   end
   player.nutrition = player.nutrition - math.floor(1500 / adj)
   Gui.mes_c("activity.sleep.slept_for", "Green", time_slept)

   local add_potential = true

   if not Item.is_alive(bed) then
      add_potential = false
   else
      local is_bed = true -- TODO
      if not is_bed then
         add_potential = false
      end
   end

   if add_potential then
      local count = ElonaCommand.increment_sleep_potential(player)
      Gui.mes_c("activity.sleep.wake_up.good", "Green", count)
   else
      Gui.mes("activity.sleep.wake_up.so_so")
   end

   if not params.no_animation then
      Gui.mes_halt()
      Gui.play_music()
   end

   -- TODO autosave
   -- TODO shop
end

function ElonaCommand.wake_up_everyone(map)
   map = map or Map.current()
   local hour = save.base.date.hour
   if hour >= 7 or hour <= 22 then
      for _, chara in Chara.iter(map) do
         if not chara:is_ally() and chara:has_effect("elona.sleep") then
            if Rand.one_in(10) then
               chara:remove_effect("elona.sleep")
            end
         end
      end
   end
end

return ElonaCommand
