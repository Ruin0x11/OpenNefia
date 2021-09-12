local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local Fishing = require("mod.elona.api.Fishing")
local Draw = require("api.Draw")
local UiTheme = require("api.gui.UiTheme")

local function get_fish(chara, fishing_pole)
   -- >>>>>>>> shade2/proc.hsp:877 *get_fish ...
   local fish_id = Fishing.random_fish_id(fishing_pole)
   local fish = Fishing.create_fish(fish_id, chara)
   if fish then
      Gui.mes("activity.fishing.get", fish:build_name(1))
      fish:stack(true)
   end
   return fish
   -- <<<<<<<< shade2/proc.hsp:883 	return ..
end

local PCC_DIRS = {
   South = 0,
   West = 1,
   East = 3,
   North = 2,
   Northwest = 2,
   Northeast = 2,
   Southwest = 0,
   Southeast = 0,
}

-- >>>>>>>> shade2/screen.hsp:1384 *fishing_draw ...
local function fishing_draw_cb(params, chara)
   local dir = PCC_DIRS[chara.direction] or 0
   local fish_x = params.x
   local fish_y = params.y
   local cx = chara.x
   local cy = chara.y
   local t = UiTheme.load()
   local tw, th = Draw.get_coords():get_size()

   return function(draw_x, draw_y)
      while true do
         Rand.set_seed(chara.turns_alive / 3)

         if params.animation == 4 then
            local sx, sy = Gui.tile_to_screen(fish_x, fish_y)
            sx = sx + draw_x
            sy = sy + draw_y
            local fish_asset = t.base.fishing_fish
            local fish_frame = (math.floor(params.animation_frame / 2) % 2) + 1
            if params.animation_frame > 15 then
               sx = sx + (cx - fish_x) * 8 * (params.animation_frame - 15)
               sy = sy + (cy - fish_y) * 8 * (params.animation_frame - 15) + params.animation_frame

               fish_asset:draw_region(fish_frame, sx, sy - 44)
            else
               local x = sx
               local y = sy - params.animation_frame * 3 + 14
               local width = fish_asset:get_width() / 2
               local height = math.clamp(params.animation_frame * 5, 1, fish_asset:get_height())
               Draw.set_scissor(x, y, width, height)
               fish_asset:draw_region(fish_frame, x, y)
               Draw.set_scissor()
            end
         else
            local sx, sy = Gui.tile_to_screen(cx, cy)
            sx = sx + draw_x + 20
            if dir == 1 then
               sx = sx - tw
            elseif dir == 3 then
               sx = sx + tw
            end
            sy = sy + draw_y + 20
            if dir == 0 then
               sy = sy + th
            elseif dir == 2 then
               sy = sy - th
            end

            local ap = Rand.rnd(2)
            if params.animation == 1 then
               ap = params.animation_frame
            elseif params.animation >= 2 then
               ap = 10
            end

            local fishing_bob = t.base.fishing_bob
            local x = sx
            local y = sy - 5 + ap
            local width = fishing_bob:get_width()
            local height = fishing_bob:get_height() - 4 - ap
            Draw.set_scissor(x, y, width, height)
            fishing_bob:draw(x, y, width, height)
            Draw.set_scissor()

            sx, sy = Gui.tile_to_screen(cx, cy)
            sx = sx + draw_x
            sy = sy + draw_y

            local fishing_line = t.base.fishing_line
            local sx2, sy2
            if dir == 0 then
               sx2 = tw / 2 + Rand.rnd(3) - 1
               sy2 = th / 2 + 12
               fishing_line:draw(sx + sx2, sy + sy2 + 40, nil, nil, nil, true)
            elseif dir == 1 then
               sx2 = tw / 2 - 26
               sy2 = th / 2 - 12 + Rand.rnd(3) - 3
               fishing_line:draw(sx + sx2 - 16, sy + sy2 + 25, nil, nil, nil, true)
            elseif dir == 2 then
               sx2 = tw / 2 + Rand.rnd(3) + 1
               sy2 = th / 2 - 46
            elseif dir == 3 then
               sx2 = tw / 2 + 26
               sy2 = th / 2 - 12 + Rand.rnd(3) - 3
               fishing_line:draw(sx + sx2 + 14, sy + sy2 + 25, nil, nil, nil, true)
            end

            local fishing_pole = t.base.fishing_pole
            local rot = math.deg(0.5 * dir * math.pi)
            if dir == 2 then
               Draw.set_scissor(sx + sx2, sy + sy2, fishing_pole:get_width(), fishing_pole:get_height() / 2)
               fishing_pole:draw(sx + sx2, sy + sy2, nil, nil, nil, true, rot)
               Draw.set_scissor()
            else
               fishing_pole:draw(sx + sx2, sy + sy2, nil, nil, nil, true, rot)
            end
         end

         Rand.set_seed()

         Draw.yield(config.base.general_wait * 2)
      end
   end
end
-- <<<<<<<< shade2/screen.hsp:1424  ..

data:add {
   _type = "base.activity",
   _id = "fishing",
   elona_id = 7,

   params = { x = types.uint, y = types.uint, fishing_pole = types.map_object("base.item"), no_animation = types.optional(types.boolean) },
   default_turns = 100,

   animation_wait = 40,
   auto_turn_anim = "base.fishing",

   on_interrupt = "prompt",
   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            Gui.mes("activity.fishing.start")
            Gui.play_sound("base.fish_cast", self.params.x, self.params.y)
            params.chara:set_item_using(self.params.fishing_pole)

            if config.elona.debug_fishing then
               get_fish(params.chara, self.params.fishing_pole)
               return "stop"
            end

            self.params.animation = 0
            self.params.animation_frame = 0
            self.params.state = 0
            self.params.fish = nil
            self.params.chara_y_offset = params.chara.y_offset or 0

            local draw_cb = fishing_draw_cb(self.params, params.chara)
            Gui.start_background_draw_callback(draw_cb, "elona.fishing", 100000)

            if self.params.no_animation then
               Gui.update_screen()
            end
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            local p = self.params
            params.chara.y_offset = p.chara_y_offset

            if Rand.one_in(5) then
               p.state = 1
               p.fish = Fishing.random_fish_id(p.fishing_pole)
            end

            -- TODO pass flag to disable LOS recalculation in
            -- Gui.update_screen()
            --
            -- TODO more efficient Gui.update_screen() in general

            if p.state == 1 then
               if Rand.one_in(5) then
                  if not p.no_animation then
                     local cb = function()
                        local _
                        local dt, frames_passed
                        local times = 4 + Rand.rnd(4)
                        local i = 1
                        while i < times do
                           p.animation = 1
                           p.animation_frame = 3 + Rand.rnd(3)
                           Gui.add_effect_map("base.effect_map_splash", p.x, p.y, 2)
                           _, _, frames_passed, dt = Draw.yield(config.base.general_wait * 2)
                           i = i + frames_passed
                           Gui.step_effect_map()
                           Gui.update_screen(dt)
                        end
                     end
                     Gui.start_draw_callback(cb, nil, "elona.fishing_1")
                  end

                  if Rand.one_in(3) then
                     p.state = 2
                  end
                  if Rand.one_in(6) then
                     p.state = 0
                  end
                  p.animation = 0
               end
            end
            if p.state == 2 then
               p.animation = 2
               Gui.play_sound("base.water2", p.x, p.y)
               params.chara:set_emotion_icon("elona.notice", 2)

               if not p.no_animation then
                  local cb = function()
                     local _
                     local dt, frames_passed
                     local times = 8 + Rand.rnd(10)
                     local i = 1
                     while i < times do
                        _, _, frames_passed, dt = Draw.yield(config.base.general_wait * 2)
                        i = i + frames_passed
                        Gui.update_screen(dt)
                        Gui.step_effect_map()
                     end
                  end
                  Gui.start_draw_callback(cb, nil, "elona.fishing_2")
               end

               if not Rand.one_in(10) then
                  p.state = 3
               else
                  p.state = 0
               end
               p.animation = 0
            end
            if p.state == 3 then
               p.animation = 3

               if not p.no_animation then
                  local cb = function()
                     local _
                     local dt, frames_passed
                     local times = 28 + Rand.rnd(15)
                     local i = 1
                     local played_this_frame = false
                     while i < times do
                        if (i-1) % 7 == 0 and not played_this_frame then
                           Gui.play_sound("base.fish_fight", p.x, p.y)
                           played_this_frame = true
                        else
                           played_this_frame = false
                        end
                        p.animation_frame = i - 1

                        -- >>>>>>>> shade2/module.hsp:825 					if fishAnime@=3:if fishAnime@(1)¥8<4:py-=(fis ...
                        if p.animation_frame % 8 < 4 then
                           params.chara.y_offset = p.chara_y_offset - (p.animation_frame % 4) ^ 2
                        else
                           params.chara.y_offset = p.chara_y_offset + ((p.animation_frame % 4) ^ 2 - 9)
                        end
                        -- <<<<<<<< shade2/module.hsp:825 					if fishAnime@=3:if fishAnime@(1)¥8<4:py-=(fis ..

                        Gui.add_effect_map("base.effect_map_splash_2", p.x, p.y, 2)
                        _, _, frames_passed, dt = Draw.yield(config.base.general_wait * 2)
                        i = i + frames_passed
                        Gui.update_screen(dt)
                        Gui.step_effect_map()
                     end
                  end
                  Gui.start_draw_callback(cb, nil, "elona.fishing_3")
               end

               local difficulty = data["elona.fish"]:ensure(p.fish).power
               if difficulty >= Rand.rnd(params.chara:skill_level("elona.fishing") + 1) then
                  p.state = 0
               else
                  p.state = 4
               end
            end
            if p.state == 4 then
               p.animation = 4
               p.animation_frame = 0
               Gui.play_sound("base.fish_get", params.chara.x, params.chara.y)
               params.chara.y_offset = self.params.chara_y_offset

               if not p.no_animation then
                  local cb = function()
                     local _
                     local dt, frames_passed
                     local i = 1
                     while i < 21 do
                        p.animation_frame = i - 1
                        if i == 2 then
                           Gui.add_effect_map("base.effect_map_ripple", p.x, p.y, 3)
                        end
                        _, _, frames_passed, dt = Draw.yield(config.base.general_wait * 2)
                        i = i + frames_passed
                        Gui.update_screen(dt)
                        Gui.step_effect_map()
                     end
                  end
                  Gui.start_draw_callback(cb, nil, "elona.fishing_4")
               end

               Gui.play_sound(Rand.choice({"base.get1", "base.get2"}))
               get_fish(params.chara, p.fishing_pole)
               Skill.gain_skill_exp(params.chara, "elona.fishing", 100)
               params.chara:set_emotion_icon("elona.happy", 3)
               params.chara:remove_activity()

               return "turn_end"
            end
            if Rand.one_in(10) then
               params.chara:damage_sp(1)
            end

            return "turn_end"
         end
      },
      {
         id = "base.on_activity_cleanup",
         name = "cleanup",

         callback = function(self, params)
            params.chara.y_offset = self.params.chara_y_offset
            params.chara:set_item_using(nil)
            Gui.stop_draw_callback("elona.fishing")
            Gui.stop_draw_callback("elona.fishing_1")
            Gui.stop_draw_callback("elona.fishing_2")
            Gui.stop_draw_callback("elona.fishing_3")
            Gui.stop_draw_callback("elona.fishing_4")
         end
      },
      {
         id = "base.on_activity_finish",
         name = "finish",

         callback = function(self, params)
            Gui.mes("activity.fishing.fail")
         end
      }
   }
}
