local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Input = require("api.Input")
local Anim = require("mod.elona_sys.api.Anim")
local Rand = require("api.Rand")
local Mef = require("api.Mef")
local Effect = require("mod.elona.api.Effect")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local Charagen = require("mod.elona.api.Charagen")
local RandomEventPrompt = require("api.gui.RandomEventPrompt")
local Weather = require("mod.elona.api.Weather")
local Servant = require("mod.elona.api.Servant")
local StayingCharas = require("api.StayingCharas")
local Area = require("api.Area")
local Nefia = require("mod.elona.api.Nefia")
local Rank = require("mod.elona.api.Rank")
local I18N = require("api.I18N")
local Prompt = require("api.gui.Prompt")
local WinMenu = require("mod.elona.api.gui.WinMenu")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local UiTheme = require("api.gui.UiTheme")
local Draw = require("api.Draw")
local Item = require("api.Item")
local ElonaPos = require("mod.elona.api.ElonaPos")
local MapObject = require("api.MapObject")
local Filters = require("mod.elona.api.Filters")
local Itemgen = require("mod.elona.api.Itemgen")
local Save = require("api.Save")

local DeferredEvents = {}

function DeferredEvents.ragnarok(chara)
   -- >>>>>>>> shade2/action.hsp:1413 	if enc=encRagnarok{ ..
   chara = chara or Chara.player()

   local tx, ty, tdx, tdy = Gui.visible_tile_bounds()

   local map = chara:current_map()
   if Map.is_world_map(map) then
      return
   end

   Weather.change_to("elona.etherwind")
   Gui.mes("event.ragnarok")
   Gui.update_screen()
   Input.query_more()

   local cb = Anim.ragnarok()
   Gui.start_draw_callback(cb)

   for i = 1, 200 do
      for _ = 1, 2 do
         local x = Rand.rnd(map:width())
         local y = Rand.rnd(map:height())
         map:set_tile(x, y, "elona.destroyed")
      end

      local x = Rand.between(tx, tdx)
      local y = Rand.between(ty, tdy)
      if x < 0 or y < 0 or x >= map:width() or y >= map:height() or Rand.one_in(5) then
         x = Rand.rnd(map:width())
         y = Rand.rnd(map:height())
      end

      Mef.create("elona.fire", x, y, { duration = Rand.rnd(15) + 20, power = 50, origin = chara }, map)
      Effect.damage_map_fire(x, y, chara, map)

      if (i - 1) % 4 == 0 then
         local level = 100
         local quality = Calc.calc_object_quality(Enum.Quality.Good)
         local race_filter
         if Rand.one_in(4) then
            race_filter = "elona.giant"
         else
            race_filter = "elona.dragon"
         end

         local spawned = Charagen.create(x, y, { level = level, quality = quality, race_filter = race_filter })
         if spawned then
            spawned.is_summoned = true
         end
      end

      if (i - 1) % 7 == 0 then
         if Rand.one_in(7) then
            Gui.play_sound("base.crush1", x, y)
         else
            Gui.play_sound("base.fire1", x, y)
         end
         Gui.wait(25)
      end
   end
   -- <<<<<<<< shade2/action.hsp:1416 		} ..
end

function DeferredEvents.sleep_ambush()
   -- >>>>>>>> shade2/main.hsp:2047 	case evSleepAmbush ...
   local player = Chara.player()
   local map = player:current_map()
   if not map:has_type("world_map") then
      Gui.mes("event.beggars")
      for _ = 1, 3 do
         Chara.create("elona.robber", player.x, player.y, { level = player.level }, map)
      end
   end
   -- <<<<<<<< shade2/main.hsp:2054 	swbreak ..
end

function DeferredEvents.first_ally()
   -- >>>>>>>> shade2/main.hsp:1689 	case evFirstAlly ..
   local prompt = RandomEventPrompt:new(
      "random_event._.elona.reunion_with_pet.title",
      "random_event._.elona.reunion_with_pet.text",
      "base.bg_re13",
      {
        "random_event._.elona.reunion_with_pet.choices._1",
        "random_event._.elona.reunion_with_pet.choices._2",
        "random_event._.elona.reunion_with_pet.choices._3",
        "random_event._.elona.reunion_with_pet.choices._4"
      })

   local index = prompt:query()

   local ALLIES = {
      [1] = "elona.dog",
      [2] = "elona.cat",
      [3] = "elona.brown_bear",
      [4] = "elona.little_girl",
   }
   -- <<<<<<<< shade2/main.hsp:1709 	swbreak ..
   local id = ALLIES[index]

   local player = Chara.player()
   local ally = Chara.create(id, player.x, player.y, { level = player:calc("level") * 2 / 3 + 1 }, player:current_map())
   player:recruit_as_ally(ally)
end

function DeferredEvents.welcome_home(map)
   -- >>>>>>>> shade2/main.hsp:1910 	case evWelcome ...
   local can_welcome = function(chara)
      return Chara.is_alive(chara)
         and not chara:find_role("elona.special")
         and not chara:find_role("elona.adventurer")
         and (Servant.is_servant(chara)
                 or chara:relation_towards(Chara.player()) == Enum.Relation.Neutral
                 or StayingCharas.is_staying_in_map_global(chara, map))
   end

   local extra_talks = 0

   local welcome = function(chara)
      chara:set_emotion_icon("elona.happy", 20)
      local has_talk = chara:say("base.welcome")
      if not has_talk then
         extra_talks = extra_talks + 1
      end
   end

   Chara.iter_all(map):filter(can_welcome):each(welcome)

   for _ = 1, extra_talks do
      Gui.mes_c("event.okaeri", "SkyBlue")
   end

   -- TODO maid guests
   -- <<<<<<<< shade2/main.hsp:1932 	swbreak ..
end

function DeferredEvents.marry(target, origin)
   -- >>>>>>>> shade2/main.hsp:1712 	case evMarry ...
   Gui.play_music("elona.wedding")

   local prompt = RandomEventPrompt:new(
      "random_event._.elona.marriage.title",
      I18N.get("random_event._.elona.marriage.text", target, origin),
      "base.bg_re14",
      {
         "random_event._.elona.marriage.choices._1"
      })

   prompt:query()

   local map = target:current_map()
   for _ = 1, 5 do
      local filter = {
         level = Calc.calc_object_level(target:calc("level"), map),
         quality = Calc.calc_object_quality(Enum.Quality.Good),
         categories = {Rand.choice(Filters.fsetchest)}
      }

      Itemgen.create(origin.x, origin.y, filter, map)
   end

   Item.create("elona.potion_of_cure_corruption", origin.x, origin.y, {}, map)
   Item.create("elona.platinum_coin", origin.x, origin.y, {amount=Rand.rnd(3)+2}, map)
   Gui.mes("common.something_is_put_on_the_ground")

   Save.queue_autosave()
   -- <<<<<<<< shade2/main.hsp:1730 	swbreak ..
end

function DeferredEvents.nefia_boss(map, boss_uid)
   local area = Area.for_map(map)
   if area == nil then
      return
   end

   local boss
   if boss_uid and boss_uid >= 0 then
      boss = map:get_object_of_type("base.chara", map)
   end

   if boss == nil then
      boss = Nefia.spawn_boss(map)
      Nefia.set_boss_uid(area, boss.uid)
   end

   -- >>>>>>>> shade2/main.hsp:1747 	txt lang("どうやら最深層まで辿り着いたらしい…","It seems you have  ...
   Gui.mes("event.reached_deepest_level")
   Gui.mes_c("event.guarded_by_lord", "Red", map.name, boss)
   Gui.play_default_music(map)
   -- <<<<<<<< shade2/main.hsp:1748 	txtEf coRed : txtMore:txt lang("気をつけろ！この階は"+mapNa ..
end

function DeferredEvents.nefia_boss_defeated(map)
   local area = Area.for_map(map)
   if area == nil then
      return
   end

   Gui.play_music("elona.victory")
   Gui.play_sound("base.complete1")

   local player = Chara.player()
   local uid = Nefia.get_boss_uid(area)
   local boss
   if math.type(uid) == "integer" and uid >= 0 then
      boss = map:get_object_of_type("base.chara", uid)
   end

   Nefia.create_boss_rewards(player, boss)

   -- >>>>>>>> shade2/main.hsp:1762 	txtEf coGreen:txtQuestComplete:txtMore:txtQuestIt ...
   Gui.mes_c("quest.completed", "Green")
   Gui.mes("common.something_is_put_on_the_ground")
   Rank.modify("elona.crawler", 300, 8)

   local fame_gained = Nefia.calc_boss_fame_gained(player)
   Gui.mes_c("quest.gain_fame", "Green", fame_gained)
   player.fame = player.fame + fame_gained
   -- <<<<<<<< shade2/main.hsp:1765 	cFame(pc)+=gQuestFame ..

   -- >>>>>>>> shade2/main.hsp:1771 	}else{ ...
   Nefia.set_boss_uid(area, -1) -- No more bosses in this map.
   -- <<<<<<<< shade2/main.hsp:1773 	} ..
end

function DeferredEvents.lily_end_life(chara)
   -- >>>>>>>> shade2/main.hsp:1808 	case evKillMother ...
   local x, y = chara.x, chara.y
   local map = chara:current_map()
   chara:damage_hp(math.max(chara.hp, 9999), "elona.unknown")
   chara.state = "Dead"
   chara:remove_ownership()

   Item.create("elona.platinum_coin", x, y, {amount=4}, map)

   Sidequest.set_progress("elona.pael_and_her_mom", 1001)
   local pael = Chara.find("elona.pael", "others", map)
   if pael then
      if Chara.is_alive(pael) and not pael:is_player() then
         Gui.mes_c("event.pael", "Blue")
         local player = Chara.player()
         pael:set_relation_towards(player, Enum.Relation.Enemy)
         pael:set_target(player, 1000)
      end
   end
   -- <<<<<<<< shade2/main.hsp:1817  ..
end

function DeferredEvents.anim_cb_nuke(draw_x, draw_y)
   local _
   local i = 0
   local frames_passed = 0
   local shake0 = 0
   local shake1 = 0
   local shake2 = 0
   local shake3 = 0
   local played_sound = false
   local offset_x = 0
   local offset_y = 0

   local t = UiTheme.load()

   while i <= 40 do
      if frames_passed > 0 then
         if i >= 14 and not played_sound then
            Gui.play_sound("base.atk_fire")
            played_sound = true
         end
         if i < 16 then
            offset_x = 0
            offset_y = 0
         else
            offset_x = 5 - Rand.rnd(10)
            offset_y = 5 - Rand.rnd(10)
         end
         if i > 8 then
            shake0 = shake0 - 1
         else
            shake0 = shake0 + 1
         end
         if i > 14 then
            shake1 = shake1 + 1
         elseif i < 12 then
            shake1 = math.floor(i / 2) % 2
         elseif i >= 12 then
            shake1 = i % 3
         end
         if i > 4 then
            shake2 = shake2 + 1
            shake3 = shake3 + 1
         end
      end

      local sw = Draw.get_width()
      local sh = Draw.get_height()

      local dx = math.floor(sw / 2 - 1) + offset_x
      local dy = math.floor(sh / 2 - 1) + offset_y

      Draw.set_color(0, 0, 0)
      Draw.filled_rect(0, 0, sw, sh)

      Draw.set_color(255, 255, 255)
      t.base.bg22:draw(offset_x, offset_y, sw, sh)

      -- Ring
      local alpha = 255 - (shake0 * 5)
      Draw.set_color(255, 255, 255, alpha)
      local x = dx
      local y = dy
      local w = math.clamp(shake0 * 32, 0, 192)
      local h = math.clamp(shake0 * 8, 0, 48)
      local frame = math.floor(i / 2) % 2 + 1
      t.base.anim_nuke_ring:draw_region(frame, x, y, w, h, nil, true)

      -- Explosion
      Draw.set_color(255, 255, 255, 255)
      local x = dx
      local y = dy - math.clamp(math.floor(i * 3 / 2), 0, 18) - 16
      local w = math.clamp(i * 12, 0, 144)
      local h = math.clamp(i * 6, 0, 72)
      local frame = shake1 + 1
      if frame < 8 then
         t.base.anim_nuke_explosion:draw_region(frame, x, y, w, h, nil, true)
      end

      -- Lower smoke trail
      local alpha = math.clamp(shake2 * 6, 0, 100)
      Draw.set_color(255, 255, 255, alpha)
      local x = dx
      local y = dy - math.clamp(shake2 * 2, 0, 40)
      local w = math.clamp(shake2 * 8, 0, 240)
      local h = math.clamp(shake2 * 5, 0, 96)
      t.base.anim_nuke_smoke_1:draw(x, y, w, h, nil, true)

      -- Upper smoke trail
      alpha = shake3 * 10
      Draw.set_color(255, 255, 255, alpha)
      local x = dx
      local y = dy - math.clamp(shake3 * 2, 0, 160) - 6
      local w = math.clamp(shake2 * 10, 0, 96)
      local h = math.clamp(shake2 * 10, 0, 96)
      t.base.anim_nuke_smoke_2:draw(x, y, w, h, nil, true)

      -- Lower cloud
      alpha = math.clamp(shake3 * 5, 0, 100)
      Draw.set_color(255, 255, 255, alpha)
      local x = dx
      local y = dy - 4
      local w = math.clamp(shake2 * 8, 0, 400)
      local h = math.clamp(shake2, 0, 48)
      local frame = (math.floor(i/4) % 2) + 1
      t.base.anim_nuke_cloud:draw_region(frame, x, y, w, h, nil, true)

      -- Upper cloud
      alpha = shake3 * 10
      Draw.set_color(255, 255, 255, alpha)
      local x = dx
      local y = dy - 48 - math.clamp(shake3 * 2, 0, 148)
      local frame = (math.floor(i/3) % 2) + 1
      t.base.anim_nuke_cloud:draw_region(frame, x, y, nil, nil, nil, true)

      _, _, frames_passed = Draw.yield(config.base.anime_wait + 50)
      i = i + frames_passed
   end
end

function DeferredEvents.nuke(x, y, map, origin)
   -- >>>>>>>> shade2/main.hsp:1934 	case evNuke ...
   if map:has_type("world_map") then
      return
   end

   Gui.mes_c("event.bomb", "Red")
   Input.query_more()

   Gui.start_draw_callback(DeferredEvents.anim_cb_nuke, "must_wait", "elona.nuke")

   Gui.update_screen()

   local range = 31
   local element_id = "elona.chaos"

   -- Ignore LOS when making ball affected positions
   local function test_los(map, x, y, tx, ty)
      return true
   end
   local positions = ElonaPos.make_ball(x, y, range, map, test_los)

   local element = data["base.element"]:ensure(element_id)
   local color = element.color
   local sound = element.sound

   local cb = Anim.ball(positions, color, sound, x, y, map)
   Gui.start_draw_callback(cb)

   for _, pos in ipairs(positions) do
      local tx = pos[1]
      local ty = pos[2]

      local demolish = false
      if not map:can_access(tx, ty) then
         demolish = true
      end
      if not Rand.one_in(4) or demolish then
         map:set_tile(tx, ty, "elona.destroyed")
      end
      if Rand.one_in(10) or demolish then
         Mef.create("elona.fire", tx, ty, { duration = Rand.rnd(15) + 20, power = 50, origin = origin }, map)
      end

      local target = Chara.at(tx, ty, map)

      if target then
         local damage = 1000
         target:damage_hp(damage, "elona.nuke")
      end

      Effect.damage_map_fire(tx, ty, origin, map)
   end

   if x == 33 and y == 16 and map._archetype == "elona.palmia" then
      if Sidequest.progress("elona.red_blossom_in_palmia") == 1 then
         Sidequest.set_progress("elona.red_blossom_in_palmia", 2)
         Sidequest.update_journal()
      end
   end

   if MapObject.is_map_object(origin, "base.chara") then
      if map:has_type("town") or map:has_type("village") then
         local karma_delta = -80 + origin:trait_level("elona.perm_evil") * 60
         Effect.modify_karma(origin, karma_delta)
      else
         Effect.modify_karma(origin, -10)
      end
   end
   -- <<<<<<<< shade2/main.hsp:1997 	swbreak ..
end

function DeferredEvents.proc_guild_intruder(guild_id, chara, map)
   -- >>>>>>>> shade2/main.hsp:2038 	case evGuild ...
   if chara:calc("guild") ~= guild_id then
      Gui.mes_c("event.alarm", "Red")
      for _, other in Chara.iter_others(map):filter(Chara.is_alive) do
         other:set_relation_towards(chara, Enum.Relation.Enemy)
         other:set_target(chara, 250)
      end
   end
   -- <<<<<<<< shade2/main.hsp:2045 	swbreak ..
end

function DeferredEvents.lesimas_final_boss()
   local player = Chara.player()
   local map = player:current_map()
   local zeome = assert(Chara.find("elona.zeome", "all", map))
   Effect.try_to_chat(zeome, player, true)
end

function DeferredEvents.calc_win_comment()
   -- >>>>>>>> shade2/text.hsp:375 #deffunc txtSetWinWord	int a ...
   local choices = I18N.get_choice_count("win.words")

   local arr = fun.range(choices):to_list()
   Rand.shuffle(arr)

   local to_win_comment = function(i)
      return I18N.get("win.words._" .. (i-1))
   end

   local win_comments = fun.iter(arr):take(3):map(to_win_comment):to_list()

   local prompt = Prompt:new(win_comments, 310, false)
   local result = prompt:query()
   return win_comments[result.index]
   -- <<<<<<<< shade2/text.hsp:391 	return 	 ..
end

local function show_orphe_dialog()
   -- >>>>>>>> shade2/main.hsp:1394 	if jp{ ...
   Gui.mes_clear()
   Gui.mes("win.event.text._0")

   local player = Chara.player()
   local map = player:current_map()
   local orphe = Chara.find("elona.orphe", "others", map)
   if not Chara.is_alive(orphe) then
      orphe = assert(Chara.create("elona.orphe", player.x, player.y, {}, player:current_map()))
   end
   Gui.update_screen()
   Gui.play_music("elona.chaos")
   Input.query_more()
   Gui.mes_clear()

   Gui.mes("win.event.text._1")
   Gui.mes("win.event.text._2")
   Gui.mes("win.event.text._3")
   Input.query_more()
   Gui.mes_clear()

   Gui.mes("win.event.text._4")
   Gui.mes("win.event.text._5")
   Gui.mes("win.event.text._6")
   Input.query_more()
   Gui.mes_clear()

   Gui.mes("win.event.text._7")
   Gui.mes("win.event.text._8")
   Input.query_more()
   Gui.mes_clear()

   Gui.mes("win.event.text._9")
   Input.query_more()

   Effect.try_to_chat(orphe, player, true, "elona.orphe:dialog")

   Gui.mes_clear()
   Gui.mes("win.event.text._10")
   Input.query_more()
   Gui.mes_clear()

   orphe:vanquish()
   Gui.update_screen()

   Gui.mes("win.event.text._11")
   Input.query_more()
   -- <<<<<<<< shade2/main.hsp:1428 		} ..
end

function DeferredEvents.show_win_event()
   Gui.update_screen()
   Gui.play_sound("base.complete1")
   Gui.stop_music()
   Gui.mes("win.conquer_lesimas")

   local win_comment = DeferredEvents.calc_win_comment()

   show_orphe_dialog()

   Gui.play_music("elona.march2")
   Gui.fade_out()

   WinMenu:new(Chara.player(), win_comment):query()
end

function DeferredEvents.win()
   -- >>>>>>>> shade2/main.hsp:1651 	gosub *win ...
   local going = true
   while going do
      DeferredEvents.show_win_event()

      Gui.mes("win.watch_event_again")
      going = Input.yes_no()
   end

   Sidequest.set_progress("elona.main_quest", 180)

   local player = Chara.player()
   Chara.create("elona.orphe", player.x, player.y, {}, player:current_map())
   -- <<<<<<<< shade2/main.hsp:1652 	flt :chara_create -1,23,cX(pc),cY(pc) ..
end

function DeferredEvents.little_sister(x, y, map)
   -- >>>>>>>> shade2/main.hsp:1656 	case evLittleSister ...
   -- TODO show house
   local little_sister = Chara.create("elona.little_sister", x, y, {}, map)
   if little_sister then
      Gui.mes_c("event.little_sister", "SkyBlue", little_sister)
   end
   -- <<<<<<<< shade2/main.hsp:1659 	swbreak ..
end

return DeferredEvents
