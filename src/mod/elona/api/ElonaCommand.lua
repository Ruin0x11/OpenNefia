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
local Hunger = require("mod.elona.api.Hunger")
local Quest = require("mod.elona_sys.api.Quest")
local Save = require("api.Save")
local Const = require("api.Const")
local Feat = require("api.Feat")
local global = require("mod.elona.internal.global")
local RandomEvent = require("mod.elona.api.RandomEvent")
local Calc = require("mod.elona.api.Calc")

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

   player:start_activity("elona.mining", {x = x, y = y})
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
      local skill = Skill.random_attribute()
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

local function do_chara_sleep(chara)
   -- >>>>>>>> shade2/proc.hsp:667 	repeat maxSaveChara ...
   for _, effect_proto in data["base.effect"]:iter() do
      if chara:has_effect(effect_proto._id) then
         if effect_proto.on_sleep == "remove" then
            chara:remove_effect(effect_proto._id)
         elseif type(effect_proto.on_sleep) == "function" then
            effect_proto.on_sleep(chara)
         elseif effect_proto.on_sleep ~= nil then
            Log.error("Invalid effect.on_sleep callback: %s", tostring(effect_proto.on_sleep))
         end
      end
   end

   chara:heal_to_max()

   if chara.has_anorexia then
      chara.anorexia_count = chara.anorexia_count - Rand.rnd(6)
   else
      chara.anorexia_count = chara.anorexia_count - Rand.rnd(3)
   end
   if chara.anorexia_count < 0 then
      Hunger.cure_anorexia(chara)
      chara.anorexia_count = 0
   end

   Effect.heal_insanity(chara, 10)

   if chara:calc("has_lay_hand") then
      chara.is_lay_hand_available = true
   end

   chara:emit("elona.on_chara_sleep")
   -- <<<<<<<< shade2/proc.hsp:691 	loop ..
end

local function do_sleep(player, bed, no_animation, sleep_hours)
   if player:calc("catches_god_signal") then
      -- TODO god talk
   end

   if not no_animation then
      Gui.play_music("elona.coda")
      Gui.mes_halt()
   end

   local bg = UiTheme.load().base.bg_night

   local fade_in_finished = false
   if not no_animation then
      local bg_cb = function()
         while true do
            if fade_in_finished then
               bg:draw(0, 0, Draw.get_width(), Draw.get_height(), { 255, 255, 255 })
            end
            Draw.yield(200)
         end
      end
      Gui.start_background_draw_callback(bg_cb, "elona.sleep", 500000)

      local cb = function()
         local i = 0
         while i <= 20 do
            if i >= 20 then
               fade_in_finished = true
            end
            bg:draw(0, 0, Draw.get_width(), Draw.get_height(), { 255, 255, 255, i * 10 })
            local frames_passed = select(3, Draw.yield(200))
            i = i + frames_passed
         end
         fade_in_finished = true
      end
      Gui.start_draw_callback(cb)
      Gui.wait_for_draw_callbacks()
   end

   save.elona_sys.awake_hours = 0

   for _, chara in player:iter_party_members() do
      do_chara_sleep(chara)
   end

   local time_slept = sleep_hours or Calc.calc_player_sleep_hours(player)

   for _ = 1, time_slept do
      World.pass_time_in_seconds(60 * 60, "hour")
      save.base.date.minute = 0
      if not no_animation then
         Gui.wait(500)
      end
   end

   -- TODO gene

   Effect.wake_up_everyone()

   local hunger_adj = 1
   if player:has_trait("elona.perm_slow_food") then
      hunger_adj = 2
   end
   player.nutrition = player.nutrition - math.floor(Const.HUNGER_SLEEP_DECREMENT_AMOUNT / hunger_adj)
   Gui.mes_c("activity.sleep.slept_for", "Green", time_slept)

   local add_potential = true

   if not Item.is_alive(bed) then
      add_potential = false
   else
      if not bed:has_category("elona.furniture_bed") then
         add_potential = false
      end
   end

   if add_potential then
      local count = ElonaCommand.increment_sleep_potential(player)
      Gui.mes_c("activity.sleep.wake_up.good", "Green", count)
   else
      Gui.mes("activity.sleep.wake_up.so_so")
   end

   if not no_animation then
      Input.query_more()
      Gui.play_default_music()
      Gui.stop_draw_callback("elona.sleep")
   end

   Save.queue_autosave()
end

function ElonaCommand.do_sleep(player, bed, no_animation, sleep_hours)
   -- >>>>>>>> shade2/proc.hsp:651 *sleep ...
   local map = player:current_map()
   local quest = Quest.get_immediate_quest()
   if quest or map:has_type("quest") then
      Gui.mes("activity.sleep.but_you_cannot")
      return "player_turn_query"
   end

   if config.base.skip_sleep_animation then
      no_animation = true
   end

   RandomEvent.set_kind("sleep")
   global.is_player_sleeping = true

   local ok, err = xpcall(do_sleep, debug.traceback, player, bed, no_animation, sleep_hours)

   RandomEvent.set_kind()
   global.is_player_sleeping = false

   if not ok then
      error(err)
   end
   -- <<<<<<<< shade2/proc.hsp:751 	return ..
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
   ---    local enc = ammo:add_temporary_enchantment("elona.ammo", 100, { ... })
   ---    ammo.params.ammo_loaded = #ammo.temp["enchantments"] -- set by reference to enchantment table
   ---    -- ...
   ---    local prev = ammo.params.ammo_loaded
   ---    ammo:refresh() -- clears ammo.temp
   ---    local enc = ammo:add_temporary_enchantment("elona.ammo", 100, { ... })
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
   --- instead of `ammo:iter_merged_enchantments()`. This is a special behavior
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
   local iter = ammo:iter_merged_enchantments():filter(function(enc) return enc._id == "elona.ammo" end)

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

local function enter_field_map(player)
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

local function choose_command_dwim(player)
   -- >>>>>>>> shade2/main.hsp:1242 		inv_getHeader -1 :p=0 ..
   local command
   local map = player:current_map()

   for _, feat in Feat.at(player.x, player.y, map) do
      if feat:has_event_handler("elona_sys.on_feat_search") then
         command = Command.search
      end
      if feat:has_event_handler("elona_sys.on_feat_ascend") then
         command = ElonaCommand.ascend
      end
      if feat:has_event_handler("elona_sys.on_feat_descend") then
         command = ElonaCommand.descend
      end
   end

   for _, item in Item.at(player.x, player.y, map) do
      if item:has_category("elona.container") then
         command = ElonaCommand.open
      elseif item:has_category("elona.furniture_well") then
         Log.error("TODO dip")
         -- command = Command.dip
      elseif item:has_category("elona.furniture_altar") then
         Log.error("TODO god")
         if player:calc("god") then
            --command = Command.offer
         else
            --command = Command.pray
         end
      elseif item:calc("can_use") then
         command = ElonaCommand.use
      elseif item:calc("can_read") then
         command = ElonaCommand.read
      end
   end

   if command == nil and map:has_type("world_map") then
      return enter_field_map
   end

   return command or Command.search
   -- <<<<<<<< shade2/main.hsp:1255 		loop ..
end

local function feats_under(player, field)
   return Feat.at(player.x, player.y, player:current_map()):filter(function(f) return f:calc(field) end)
end

function ElonaCommand.descend(player)
   local f = feats_under(player, "can_descend"):nth(1)
   if f then
      local result = f:emit("elona_sys.on_feat_descend", {chara=player}, "player_turn_query")
      return result or "player_turn_query"
   end

   for _, item in Item.at(player.x, player.y, player:current_map())
   :filter(function(i) return i:calc("can_descend") end)
   do
      local result = item:emit("elona_sys.on_item_descend", {chara=player}, nil)
      if result then
         return result
      end
   end

   Gui.mes("action.use_stairs.no.downstairs")
   return "player_turn_query"
end

function ElonaCommand.ascend(player)
   local f = feats_under(player, "can_ascend"):nth(1)
   if f then
      local result = f:emit("elona_sys.on_feat_ascend", {chara=player}, "player_turn_query")
      return result or "player_turn_query"
   end

   for _, item in Item.at(player.x, player.y, player:current_map())
   :filter(function(i) return i:calc("can_ascend") end)
   do
      local result = item:emit("elona_sys.on_item_ascend", {chara=player}, nil)
      if result then
         return result
      end
   end

   Gui.mes("action.use_stairs.no.upstairs")
   return "player_turn_query"
end

function ElonaCommand.enter_action(player)
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

   target.own_name = name
   target.name = target.own_name
   target.has_own_name = true
   Gui.mes("action.interact.name.you_named", target)

   Gui.update_screen()

   return "player_turn_query"
   -- <<<<<<<< shade2/command.hsp:1926 	gosub *screen_refresh :goto *pc_turn ..
end

return ElonaCommand
