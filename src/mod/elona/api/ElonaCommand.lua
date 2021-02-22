local Skill = require("mod.elona_sys.api.Skill")
local I18N = require("api.I18N")
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
local Log = require("api.Log")
local Command = require("mod.elona_sys.api.Command")
local FieldMap = require("mod.elona.api.FieldMap")
local MapgenUtils = require("mod.elona.api.MapgenUtils")
local Effect = require("mod.elona.api.Effect")

local ElonaCommand = {}

local last_op = "elona.inv_examine"

function ElonaCommand.quick_inv(player)
   local result, canceled = Input.query_inventory(player, last_op, nil, "elona.main")

   last_op = result.operation

   if canceled then
      return nil, canceled
   end
   return result.result, canceled
end

local function query_inventory(player, op)
   local result, canceled = Input.query_inventory(player, op, nil, "elona.main")
   if canceled then
      return nil, canceled
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
      return nil, canceled
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

function ElonaCommand.open(player)
   return query_inventory(player, "elona.inv_open")
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
   -- >>>>>>>> shade2/command.hsp:4278 *com_fire ...
   local target = Action.find_target(player)

   if not target then
      return "player_turn_query"
   end

   if player:relation_towards(target) >= Enum.Relation.Neutral then
      if not ElonaAction.prompt_really_attack(player, target) then
         return "player_turn_query"
      end
   end

   local weapon, ammo = ElonaAction.get_ranged_weapon_and_ammo(player)
   if weapon == nil then
      local err = ammo
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

   local result = ElonaAction.ranged_attack(player, target, weapon, ammo)

   if not result then
      return "player_turn_query"
   end

   return "turn_end"
   -- <<<<<<<< shade2/command.hsp:4288 	gosub *act_fire:goto *turn_end ..
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
      local skill = Skill.random_stat()
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

   Effect.wake_up_everyone()

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
      -- Gui.play_music()
   end

   -- TODO autosave
   -- TODO shop
end

local function get_ammo_enchantments(ammo)
   --- How ammo works in vanilla:
   ---
   --- There is a field named iAmmo(ci) that holds the index into the item's
   --- enchantments array of the currently used ammo enchantment. When getting the
   --- ammo's capacity or effect, do iEnc(iAmmo(ci), ci). The list of enchantments,
   --- iEnc, is for the most part static.
   ---
   --- How ammo works in OpenNefia:
   ---
   --- The above no longer works, because enchantments are now tracked by the
   --- temporary values system. Consider the following.
   ---
   ---    local ammo = Item.create("elona.bullet")
   ---    local enc = InstancedEnchantment:new("elona.ammo",  100,  { ... })
   ---    ammo:add_temporary_enchantment(enc)
   ---    ammo.params.ammo_loaded = #ammo.temp["enchantments"] -- set by reference to enchantment table
   ---    -- ...
   ---    local prev = ammo.params.ammo_loaded
   ---    ammo:refresh() -- clears ammo.temp
   ---    local enc = InstancedEnchantment:new("elona.ammo",  100,  { ... })
   ---    ammo:add_temporary_enchantment(enc)
   ---    ammo.params.ammo_loaded = #ammo.temp["enchantments"]
   ---    assert(ammo.params.ammo_loaded == prev) -- fails
   ---
   --- This is basically due to the fact that trying to track the enchantment's
   --- index in `ammo.temp["enchantments"]` like with `iAmmo(ci)` won't work if a
   --- temporary enchantment is removed, which changes the maximum size of the
   --- enchantments list.
   ---
   --- For now, only allow selecting ammo that is in `ammo.enchantments` and not
   --- in `ammo.temp["enchantments"]` by calling fun.iter(ammo.enchantments)
   --- instead of `ammo:iter_enchantments()`. This is a special behavior
   --- specifically for the enchantment "elona.ammo". This still works since
   --- values in `ammo.enchantments["temp"]` are references to the original
   --- objects in `ammo.enchantments`. This is not how IModdable usually works
   --- as most of the time values are supposed to be deepcopied into `temp`, but
   --- maintaining references to temporary clones of enchantments would be
   --- unreasonably difficult.
   ---
   --- To implement an effect like "improves the power of all active
   --- enchantments of type X", we'd have to implement IModdable for
   --- InstancedEnchantment, which I think is reasonable to do.
   local iter = fun.iter(ammo.enchantments):filter(function(enc) return enc._id == "elona.ammo" end)

   -- Comparison is by reference, not value
   local current_idx = iter:index_by(function(enc) return ammo.params.ammo_loaded == enc end)

   return iter:to_list(), current_idx
end

function ElonaCommand.ammo(player)
   -- >>>>>>>> elona122/shade2/command.hsp:4694 *com_ammo ..
   local weapon, ammo = ElonaAction.get_ranged_weapon_and_ammo(player)

   if ammo == nil then
      Gui.mes("action.ammo.need_to_equip")
      return "player_turn_query"
   end

   local ammo_encs, current_idx = get_ammo_enchantments(ammo)
   local ammo_enc_count = #ammo_encs

   if ammo_enc_count == 0 then
      ammo.params.ammo_loaded = nil
      Gui.mes("action.ammo.is_not_capable", ammo)
      return "player_turn_query"
   end

   Gui.play_sound("base.ammo")

   if current_idx == nil then
      current_idx = 1
   else
      current_idx = current_idx + 1
      if current_idx > ammo_enc_count then
         current_idx = nil
      end
   end

   if current_idx == nil then
      ammo.params.ammo_loaded = nil
   else
      ammo.params.ammo_loaded = ammo_encs[current_idx]
   end

   Gui.mes("action.ammo.current")
   for i = 0, #ammo_encs do -- off by one
      local name, capacity
      if i == 0 then
         name = I18N.get("action.ammo.normal")
         capacity = I18N.get("action.ammo.unlimited")
      else
         local ammo_enc = ammo_encs[i]
         name = I18N.get("_.base.ammo_enchantment." .. ammo_enc.params.ammo_enchantment_id .. ".name")
         capacity = ("%d/%d"):format(ammo_enc.params.ammo_current, ammo_enc.params.ammo_max)
      end
      local s, color
      if current_idx == i or (current_idx == nil and i == 0) then
         s = ("[%s:%s]"):format(name, capacity)
         color = "Blue"
      else
         s = (" %s:%s "):format(name, capacity)
      end
      Gui.mes_c(s, color)
   end

   return "player_turn_query"
   -- <<<<<<<< elona122/shade2/command.hsp:4739 	goto *pc_turn ..
end

local function choose_command_dwim(player)
   -- >>>>>>>> shade2/main.hsp:1242 		inv_getHeader -1 :p=0 ..
   local command

   for _, item in Item.at(player.x, player.y, player:current_map()) do
      if item:has_category("elona.container") then
         command = ElonaCommand.open
      elseif item:has_category("elona.furniture_well") then
         Log.error("TODO")
         -- command = Command.dip
      elseif item:has_category("elona.furniture_altar") then
         Log.error("TODO")
         if player:calc("god") then
            --command = Command.offer
         else
            --command = Command.pray
         end
      elseif item:calc("can_use") then
         command = ElonaCommand.use
      elseif item:calc("can_read") then
         command = ElonaCommand.read
      elseif item.proto.on_enter_action then
         command = item.proto.on_enter_action(item)
      end
   end

   return command or Command.search
   -- <<<<<<<< shade2/main.hsp:1255 		loop ..
end

local function activate(player, feat)
   Gui.mes(player.name .. " activates the " .. feat.uid .. " ")
   feat:emit("elona_sys.on_feat_activate", {chara=player})
end

local function feats_under(player, field)
   local Feat = require("api.Feat")
   return Feat.at(player.x, player.y, player:current_map()):filter(function(f) return f:calc(field) end)
end

function ElonaCommand.enter_action(player)
   -- TODO iter objects on square, emit get_enter_action
   -- >>>>>>>> shade2/main.hsp:1238 		cell_featRead cX(cc),cY(cc) ..
   local f = feats_under(player, "can_activate"):nth(1)
   if f then
      activate(player, f)
      return "player_turn_query" -- TODO could differ per feat
   end
   -- <<<<<<<< shade2/main.hsp:1240 		if feat(1)=objUpstairs   :key=key_goUp ..

   local is_world_map = Map.current():has_type("world_map")

   if is_world_map then
      local stood_tile = Map.tile(player.x, player.y)
      local map = FieldMap.generate(stood_tile, 34, 22, Map.current())

      -- >>>>>>>> shade2/map.hsp:1586 		if encounter=0{ ...
      for _ = 1, map:calc("max_crowd_density") do
         MapgenUtils.generate_chara(map)
      end
      -- <<<<<<<< shade2/map.hsp:1591 			} ..

      map:set_previous_map_and_location(Map.current(), player.x, player.y)

      Gui.play_sound("base.exitmap1")
      assert(Map.travel_to(map))

      return "turn_begin"
   end

   local command = choose_command_dwim(player)

   return command(player)
end

function ElonaCommand.do_give_ally(player, target)
   -- >>>>>>>> shade2/command.hsp:3243 *com_allyInventory ...
   if target:has_activity() then
      Gui.mes("action.npc.is_busy_now", target)
      return "player_turn_query"
   end

   local result, canceled = Input.query_inventory(player, "elona.inv_give", {target=target,params={is_giving_to_ally=true}}, "elona.ally")
   if canceled then
      return "player_turn_query"
   end
   return result.result
   -- <<<<<<<< shade2/command.hsp:3246  ..
end

function ElonaCommand.do_give_other(player, target)
   local result, canceled = Input.query_inventory(player, "elona.inv_give", {target=target,params={is_giving_to_ally=false}}, nil)
   if canceled then
      return "player_turn_query"
   end
   return result.result
end

function ElonaCommand.do_give(player, target)
   -- >>>>>>>> shade2/command.hsp:1832 	if tc=pc : if gRider!0 : tc=gRider   ...
   if target:is_in_player_party() and not target.is_being_escorted then
      return ElonaCommand.do_give_ally(player, target)
   else
      return ElonaCommand.do_give_other(player, target)
   end
   -- <<<<<<<< shade2/command.hsp:1836 		} ..
end

function ElonaCommand.give(player)
   -- >>>>>>>> shade2/command.hsp:1825 *com_give ...
   Gui.mes("action.which_direction.ask")

   local dir, canceled = Input.query_direction(player)
   if not dir or canceled then
      Gui.mes("ui.invalid_target")
      return "player_turn_query"
   end

   local x, y = Pos.add_direction(dir, player.x, player.y)
   local target = Chara.at(x, y, player:current_map())

   if target == nil or target:is_player() then
      Gui.mes("ui.invalid_target")
      return "player_turn_query"
   end

   -- TODO riding

   return ElonaCommand.do_give(player, target)
   -- <<<<<<<< shade2/command.hsp:1837 	txt strInteractFail:gosub *screen_draw :goto *pc_ ..
end

function ElonaCommand.name(player, target)
   -- >>>>>>>> shade2/command.hsp:1916 *com_name ...
   Gui.mes("action.interact.name.prompt", target)

   local name, canceled = Input.query_text(12, true)
   if canceled or name == "" then
      Gui.mes("action.interact.name.cancel")
      return "player_turn_query"
   end

   target.name = name
   target.has_own_name = true
   Gui.mes("action.interact.name.you_named", target)

   Gui.update_screen()

   return "player_turn_query"
   -- <<<<<<<< shade2/command.hsp:1926 	gosub *screen_refresh :goto *pc_turn ..
end

return ElonaCommand
