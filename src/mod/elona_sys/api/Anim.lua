--- Animations.
---
--- This ports the various parts of the *anime subroutine.
---
--- Each function returns a function callback that takes two arguments, an X and
--- Y position in screen coordinates. This callback is intended to be passed to
--- Gui.start_draw_callback(), which will handle scheduling of the drawing logic
--- in the engine using coroutines.
---
--- Each callback draws a single frame and then calls Draw.yield(wait_time) to
--- allow the scheduler to wait until the next frame should be drawn, at a 60
--- FPS cadence. Draw.yield() returns the actual time passed and the number of
--- frames passed, from which the animation callback should update the drawing
--- logic appropriately.
---
--- All of this is so we don't have to get hung up by manually redrawing the
--- screen in the middle of a loop while still technically being inside the
--- update() function all the way at the top of the main loop, and instead
--- yielding to the draw() function to handle the drawing parts and still
--- returning to update() every frame.
---
--- @usage Gui.start_draw_callback(Anim.swarm(20, 20))
--- @module Anim
local Anim = {}

local Draw = require("api.Draw")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Pos = require("api.Pos")
local Rand = require("api.Rand")
local UiTheme = require("api.gui.UiTheme")

local function pos_centered(tx, ty)
   local tw, th = Draw.get_coords():get_size()
   local scx, scy = Gui.tile_to_screen(tx, ty)
   scx = scx + math.floor(tw / 2)
   scy = scy + math.floor(th / 2)
   return scx, scy
end

local function is_in_screen(sx, sy)
   local msg_y = Gui.message_window_y()
   return sy >= 0 and sy <= msg_y
      and sx >= 0 and sx <= Draw.get_width()
end

function Anim.load(anim_id, tx, ty)
   -- >>>>>>>> shade2/chara_func.hsp:614:DONE #deffunc animeLoad int p,int tc ..
   local t = UiTheme.load()
   local anim = data["elona_sys.basic_anim"]:ensure(anim_id)
   local sx, sy = Gui.tile_to_screen(tx, ty)
   local asset = t[anim.asset]
   assert(asset, ("Asset not found: %s"):format(anim.asset))
   assert(asset.count_x)

   local map = Map.current()
   if not map or not map:is_in_fov(tx, ty) then
      return function() end
   end

   local frames = anim.frames or asset.count_x
   local sound = anim.sound or nil
   local wait = anim.wait or 3.5
   local rotation = anim.rotation or 0

   if config.base.anime_wait == 0 then
      return function()
         if sound then
            Gui.play_sound(sound, tx, ty)
         end
      end
   end

   return function(draw_x, draw_y)
      sx = draw_x + sx
      sy = draw_y + sy

      if sound then
         Gui.play_sound(sound, tx, ty)
      end

      local frame = 1
      while frame <= frames do
         asset:draw_region(frame, sx + 24, sy + 8, nil, nil, {255, 255, 255}, rotation * frame)

         local _, _, frames_passed = Draw.yield(config.base.anime_wait + wait/2)
         frame = frame + frames_passed
      end
   end
   -- <<<<<<<< shade2/chara_func.hsp:642 	return ..
end

function Anim.make_animation(scx, scy, asset_id, duration, draw_cb, sound_cb)
   local t = UiTheme.load()
   local asset = t[asset_id]
   assert(asset, ("Asset not found: %s"):format(asset_id))

   if config.base.anime_wait == 0 then
      return function()
         if sound_cb then
            sound_cb()
         end
      end
   end

   return function(draw_x, draw_y)
      scx = scx + draw_x
      scy = scy + draw_y

      if sound_cb then
         sound_cb()
      end

      local frame = 0
      while frame <= duration - 1 do
         draw_cb(asset, scx, scy, frame)

         local _, _, frames_passed = Draw.yield(config.base.anime_wait)
         frame = frame + frames_passed
      end
   end
end

function Anim.make_particle_animation(scx, scy, asset_id, duration, max_particles, create_particle_cb, draw_cb)
   local t = UiTheme.load()
   local asset = t[asset_id]
   assert(asset, ("Asset not found: %s"):format(asset_id))

   if config.base.anime_wait == 0 then
      return function() end
   end

   return function(draw_x, draw_y)
      scx = scx + draw_x
      scy = scy + draw_y

      local particles = {}

      for i = 1, max_particles do
         local x, y = create_particle_cb()
         particles[i] = { x, y }
      end

      local frame = 0
      while frame <= duration - 1 do
         for i, p in ipairs(particles) do
            draw_cb(asset, scx, scy, frame, p[1], p[2], i-1)
         end

         local _, _, frames_passed = Draw.yield(config.base.anime_wait)
         frame = frame + frames_passed
      end
   end
end

function Anim.failure_to_cast(tx, ty)
   -- >>>>>>>> shade2/screen.hsp:478:DONE 	case aniFizzle ..
   local sound_cb = function()
      Gui.play_sound("base.fizzle", tx, ty)
   end

   if not Map.is_in_fov(tx, ty) then
      return function() end
   end

   local scx, scy = pos_centered(tx, ty)
   local tw, th = Draw.get_coords():get_size()

   local draw = function(asset, x, y, frame)
      local scaling = (frame + 40) / tw
      local w = math.floor(asset:get_width() * scaling)
      local h = math.floor(asset:get_height() * scaling)
      asset:draw(x, y - th / 6, w, h, {255, 255, 255}, true, 75 * frame)
   end

   return Anim.make_animation(scx, scy, "base.failure_to_cast_effect", 12, draw, sound_cb)
   -- <<<<<<<< shade2/screen.hsp:495 	swbreak ..
end

function Anim.heal(tx, ty, asset, sound, rot_delta, wait)
   -- >>>>>>>> shade2/screen.hsp:497:DONE 	case aniCurse ..
   if config.base.anime_wait == 0 then
      return function()
         if sound then
            Gui.play_sound(sound, tx, ty)
         end
      end
   end

   rot_delta = rot_delta or -1
   wait = wait or config.base.anime_wait

   local particles = {}

   local t = UiTheme.load()
   asset = t[asset]

   return function (draw_x, draw_y)
      if sound then
         Gui.play_sound(sound, tx, ty)
      end

      local frame = 1

      local scx, scy = Gui.tile_to_visible_screen(tx, ty)
      local tw, th = Draw.get_coords():get_size()

      for i = 1, 15 do
         particles[i] = { x = Rand.rnd(tw), y = Rand.rnd(th) - 8, rot = (Rand.rnd(4) + 1) * rot_delta }
      end

      while frame <= 10 do
         local frame2 = frame * 2 - 1

         for j = 1, 15 do
            local p = particles[j]
            asset:draw(scx + p.x, scy + p.y + frame2 / p.rot, tw - frame2 * 2, th - frame2 * 2, nil, true, frame2 * p.rot)
         end

         local _, _, delta = Draw.yield(wait)
         frame = frame + delta
      end
   end
   -- <<<<<<<< shade2/screen.hsp:530 	swbreak ..
end

function Anim.bolt(positions, color, sound, chara_x, chara_y, target_x, target_y, range, map)
   -- >>>>>>>> shade2/screen.hsp:588:DONE 	case aniBolt ...
   if config.base.anime_wait == 0 then
      return function()
         Gui.play_sound("base.bolt1", chara_x, chara_y)
      end
   end

   color = color or {255, 255, 255}
   local rotation = math.deg(math.atan2(target_x - chara_x, chara_y - target_y))

   local t = UiTheme.load()

   local frames = {}
   local total = -1
   local x = chara_x
   local y = chara_y
   local changed = 1

   return function(draw_x, draw_y)
      Gui.play_sound("base.bolt1", chara_x, chara_y)

      local frame = 1
      local draw
      local tw, th = Draw.get_coords():get_size()

      while frame <= 20 do
         draw = true

         if changed then
            if total == -1 then
               local pos = positions[((frame-1)%#positions)+1]
               local dx = pos[1]
               local dy = pos[2]
               x = x + dx
               y = y + dy

               if map:is_in_bounds(x, y) and map:can_see_through(x, y) and is_in_screen(x, y) then
                  if Pos.dist(x, y, chara_x, chara_y) > range then
                     frames[frame] = "stop"
                     total = 4
                  else
                     local sx, sy = Gui.tile_to_screen(x, y)
                     frames[frame] = { x = sx + (tw / 2), y = sy + 8, frame = 1 }
                  end
               else
                  frames[frame] = "stop"
                  total = 4
               end
            else
               total = total - 1
               if total == 0 then
                  break
               end
            end
         end

         if draw then
            for j = 1, #frames do
               if frames[j] == "stop" then break
               elseif frames[j] then
                  if frames[j].frame < 6 then
                     t.base.anim_shock:draw_region(frames[j].frame, draw_x + frames[j].x, draw_y + frames[j].y, nil, nil, color, true, rotation)
                  end
                  if changed then
                     frames[j].frame = frames[j].frame + 1
                  end
               end
            end
         end

         local _, _, delta = Draw.yield(config.base.anime_wait + 30)
         frame = frame + delta
         changed = delta > 0
      end

      if sound then
         Gui.play_sound(sound, chara_x, chara_y)
      end
   end
   -- <<<<<<<< shade2/screen.hsp:621 	swbreak ...
end

local chip_batch = nil

Event.register("base.on_hotload_end", "hotload chip batch (Anim)",
               function()
                  chip_batch = nil
end)

function Anim.ranged_attack(start_x, start_y, end_x, end_y, chip, color, sound, impact_sound)
   if (not Map.is_in_fov(start_x, start_y) and not Map.is_in_fov(end_x, end_y))
      or config.base.anime_wait == 0
   then
      return function()
         if sound then
            Gui.play_sound(sound, start_x, start_y)
         end

         if impact_sound then
            Gui.play_sound(impact_sound, end_x, end_y)
         end
      end
   end

   -- >>>>>>>> shade2/screen.hsp:644:DONE 	case rsThrow ...
   return function(draw_x, draw_y)
      chip_batch = chip_batch or Draw.make_chip_batch("chip")

      if sound then
         Gui.play_sound(sound, start_x, start_y)
      end

      local tw, th = Draw.get_coords():get_size()
      local sx, sy = Gui.tile_to_screen(start_x, start_y)
      sx = draw_x + sx
      sy = draw_y + sy

      local count = math.floor(Pos.dist(start_x, start_y, end_x, end_y) / 2) + 1

      local frame = 1
      while frame < count do
         local cx = sx - frame * math.floor((start_x - end_x) * tw / count)
         local cy = sy - frame * math.floor((start_y - end_y) * th / count)

         if is_in_screen(cx, cy) then
            chip_batch:clear()
            chip_batch:add(chip,
                           cx + math.floor(tw / 2),
                           cy + math.floor(th / 2),
                           tw,
                           th,
                           color,
                           true,
                           math.deg(math.atan2(end_x - start_x, start_y - end_y)))
            chip_batch:draw()
         end

         local _, _, frames_passed = Draw.yield(config.base.anime_wait / 2)
         frame = frame + frames_passed
      end

      if impact_sound then
         Gui.play_sound(impact_sound, end_x, end_y)
      end
   end
   -- <<<<<<<< shade2/screen.hsp:679 	if aniSound:snd aniSound,0,1 ...
end

function Anim.swarm(tx, ty)
   -- >>>>>>>> shade2/screen.hsp:686:DONE 	case aniAttack ...
   local sound_cb = function()
      Gui.play_sound("base.atk1", tx, ty)
   end

   local scx, scy = pos_centered(tx, ty)
   local tw, _ = Draw.get_coords():get_size()

   local draw = function(asset, x, y, frame)
      local scaling = (frame * 8 + 18) / tw
      local w = math.floor(asset:get_width() * scaling)
      local h = math.floor(asset:get_height() * scaling)
      asset:draw(x, y, w, h, {255,255,255}, true, 30 * frame - 45)
   end
   -- <<<<<<<< shade2/screen.hsp:698 	loop ...

   return Anim.make_animation(scx, scy, "base.swarm_effect", 4, draw, sound_cb)
end

function Anim.melee_attack(tx, ty, debris, kind, damage_percent, is_critical)
   -- >>>>>>>> shade2/screen.hsp:701:DONE 	case aniNormalAttack ...
   if config.base.anime_wait == 0 then
      return function() end
   end

   local t = UiTheme.load()

   return function(draw_x, draw_y)
      local count = math.min(damage_percent / 4 + 1, 20)

      local particle
      if debris then
         particle = t.base.melee_attack_debris
      else
         particle = t.base.melee_attack_blood
      end

      local points = {}
      for _ = 1, count do
         points[#points+1] = { Rand.rnd(24) - 12, Rand.rnd(8) }
      end

      local sx, sy = Gui.tile_to_screen(tx, ty)
      sx = sx + draw_x
      sy = sy + draw_y

      local frames = 4
      if is_critical then
         frames = 5
      end

      local frame = 1
      while frame <= frames do
         if is_critical then
            t.base.anim_critical:draw_region(frame, sx - 24, sy - 32)
         end
         local frame2 = frame + 1

         -- increases based on damage percent
         for i = 1, count do
            local px = points[i][1]
            local dx = 24 + px
            if px < 4 then
               dx = dx - frame2
               if frame % 2 == 0 then
                  dx = dx - frame2
               end
            end
            if px > -4 then
               dx = dx + frame2
               if frame % 2 == 0 then
                  dx = dx + frame2
               end
            end

            local dy = points[i][2] + frame2 * math.floor(frame2 / 3)

            particle:draw(sx + dx, sy + dy, 6, 6, nil, true, 0.4 * (frame - 1))
         end

         if kind == 0 then
            t.base.swarm_effect:draw(sx + points[1][1] + 24,
                                     sy + points[1][2] + 10,
                                     (frame - 1) * 10 + count,
                                     (frame - 1) * 10 + count,
                                     nil,
                                     true,
                                     0.5 + (frame - 1) * 0.8)
         elseif kind == 1 then
            if frame < 5 then
               t.base.anim_slash:draw_region(frame, sx, sy)
            end
         elseif kind == 2 then
            if frame < 5 then
               t.base.anim_bash:draw_region(frame, sx, sy)
            end
         end

         local _, _, frames_passed = Draw.yield(config.base.anime_wait)
         frame = frame + frames_passed
      end
   end
   -- <<<<<<<< shade2/screen.hsp:746 	loop ...
end

function Anim.gene_engineering(tx, ty)
   -- >>>>>>>> shade2/screen.hsp:751:DONE 	case aniGene ...
   if config.base.anime_wait == 0 then
      return function()
         Gui.play_sound("base.atk_elec", tx, ty)
      end
   end

   local t = UiTheme.load()

   return function(draw_x, draw_y)
      Gui.play_sound("base.atk_elec", tx, ty)
      if not Map.is_in_fov(tx, ty) then
         return
      end

      local scx, scy = Gui.tile_to_screen(tx, ty)
      draw_x = draw_x + scx - 24
      draw_y = draw_y + scy - 60

      local i = 0
      while i <= 9 do
         for j = 0, math.floor(draw_x / 96) + 1 do
            local frame = math.floor(i / 2) + 1
            if j == 0 then
               t.base.anim_gene:draw_region(frame + 5, draw_x, draw_y - j * 96)
            else
               t.base.anim_gene:draw_region(frame, draw_x, draw_y - j * 96)
            end
         end

         local _, _, frames_passed = Draw.yield(config.base.anime_wait * 2.25)
         i = i + frames_passed
      end
   end
   -- <<<<<<<< shade2/screen.hsp:772 	swbreak ...
end

--- @tparam {{x=int,y=int},...} positions
--- @tparam[opt] id:base.sound sound
function Anim.miracle(positions, sound)
   -- >>>>>>>> shade2/screen.hsp:775:DONE 	case aniHoly ...
   sound = sound or "base.heal1"

   if config.base.anime_wait == 0 then
      return function()
         Gui.play_sound(sound)
      end
   end

   local t = UiTheme.load()

   return function(draw_x, draw_y)
      local work = {}

      for i, pos in ipairs(positions) do
         local sx, sy = Gui.tile_to_screen(pos.x, pos.y)
         sx = sx - 24
         if i ~= 1 then
            sx = sx + 4 - Rand.rnd(8)
         end
         sy = sy + 32

         local msg_y = Gui.message_window_y()
         local visible = draw_y + sy >= 0 and draw_y + sy <= msg_y
            and draw_x + sx >= -20 and draw_x + sx <= Draw.get_width() + 20

         if visible then
            local duration
            if i == 1 then
               duration = 20
            else
               duration = 20 + Rand.rnd(5)
            end

            work[#work+1] = {
               x = sx,
               y = sy,
               duration = duration
            }
         end
      end

      local loops = 0
      local delta = 1
      while true do
         local did_something = false

         for i, w in ipairs(work) do
            i = i - 1
            if w.duration > 0 then
               did_something = true

               local anim_y = (w.y * math.clamp(20 - w.duration, 0, 6) / 6) - 96

               local region = math.clamp(8 - w.duration, 0, 8)
               if w.duration < 15 then
                  region = region + 1
               end
               t.base.anim_miracle:draw_region(region+1, draw_x + w.x, draw_y + anim_y)
               if w.duration <= 14 and w.duration >= 6 then
                  local region2 = 10 + math.floor((14 - w.duration) / 2) + 1
                  t.base.anim_miracle:draw_region(region2, draw_x + w.x, draw_y + anim_y + 16)
               end

               local anim_x = math.floor(math.clamp(anim_y / 55 + 1, 0, 7 - math.clamp((11 - w.duration) * 2, 0, 7)))
               for j = 1, anim_x do
                  local region2 = "beam_1"
                  if w.duration < 15 then
                     region2 = "beam_2"
                  end
                  t.base.anim_miracle:draw_region(region2, draw_x + w.x, draw_y + anim_y - j * 55)
                  if j == anim_x then
                     t.base.anim_miracle:draw_region("beam_3", draw_x + w.x, draw_y + anim_y - j * 55 - 40)
                  end
               end

               if w.duration >= 20 then
                  w.duration = w.duration - (delta * Rand.rnd(2))
               else
                  w.duration = w.duration - delta
               end
            end
         end

         if loops % 2 == 0 and loops < 30 and loops / 3 < #work then
            Gui.play_sound(sound)
         end

         if not did_something then
            break
         end

         local _
         _, _, delta = Draw.yield(config.base.anime_wait * 2.25)
         loops = loops + delta
      end
   end
   -- <<<<<<<< shade2/screen.hsp:825 	swbreak ...
end

function Anim.meteor()
   -- >>>>>>>> shade2/screen.hsp:829 	case aniMeteor ...
   if config.base.anime_wait == 0 then
      return function()
         Gui.play_sound("base.atk_fire")
      end
   end

   local t = UiTheme.load()

   local asset_meteor = t.base.anim_meteor
   local asset_impact = t.base.anim_meteor_impact

   local gen = function()
      return {
         x = 240 + Rand.rnd(Draw.get_width()),
         y = -96,
         frame = Rand.rnd(8)
      }
   end
   local meteors = fun.tabulate(gen):take(75):to_list()

   return function()
      local frame = 0
      local delta = 1
      local drew_any

      repeat
         -- TODO screen shake

         drew_any = false

         -- draw
         for _, m in ipairs(meteors) do
            if m.frame < 16 then
               drew_any = true

               local y = m.y * math.clamp(20 - m.frame, 0, 6) / 6 - 96
               if m.frame >= 10 then
                  -- impact
                  asset_impact:draw_region(math.clamp(m.frame - 10 + 1, 1, 5), m.x - 48, m.y)
               end
               if m.frame < 16 then
                  -- meteor disintegration
                  asset_meteor:draw_region(math.clamp(m.frame - 8, 0, 8)+1, m.x, m.y)
               end
            end
         end

         if delta > 0 and frame % 2 == 0 and frame < 8 and (frame / 3) < #meteors then
            Gui.play_sound("base.atk_fire")
         end

         -- step frame
         for _ = 1, delta do
            for i, m in ipairs(meteors) do
               if m.frame < 9 then
                  -- falling
                  m.x = m.x - (16 + (i % math.floor(Draw.get_width() / 30)))
                  m.y = m.y + 24 + (i % math.floor(Draw.get_height() / 10))
               end
               m.frame = m.frame + 1
            end
         end

         local _
         _, _, delta = Draw.yield(config.base.anime_wait + 40)
         frame = frame + delta
      until not drew_any
   end
   -- <<<<<<<< shade2/screen.hsp:874 	swbreak ...
end

function Anim.ragnarok()
   if config.base.anime_wait == 0 then
      return function()
         Gui.play_sound("base.atk_fire")
      end
   end

   local make_flame = function()
      return {
         x = Rand.rnd(Draw.get_width()),
         y = Rand.rnd(Draw.get_height()) - 96 - 24,
         frame = 0 - Rand.rnd(3)
      }
   end
   local flames = fun.tabulate(make_flame):take(100):to_list()
   local t = UiTheme.load()

   -- >>>>>>>> shade2/screen.hsp:876 	case aniRagna ..
   return function()
      local did_something
      local cur_frame = 0
      local delta = 0
      repeat
         did_something = false
         -- TODO screen shake
         for _, flame in ipairs(flames) do
            local x = flame.x
            local y = flame.y
            local frame = flame.frame

            if frame < 10 then
               did_something = true

               if frame >= 0 then
                  t.base.anim_flame:draw_region(frame + 1, x, y)
                  t.base.anim_flame:draw_region(frame + 1, x, y - 96)
                  flame.frame = flame.frame + 1 * delta
               else
                  flame.frame = flame.frame + Rand.rnd(2) * delta
               end
            end
         end

         if cur_frame % 2 == 0 and cur_frame < 8 and cur_frame / 3 < #flames then
            Gui.play_sound("base.atk_fire")
         end

         local _
         _, _, delta = Draw.yield(config.base.anime_wait + 40)
         cur_frame = cur_frame + delta
      until not did_something
   end
   -- <<<<<<<< shade2/screen.hsp:918 	swbreak ..
end

function Anim.breaking(tx, ty)
   -- >>>>>>>> shade2/screen.hsp:920:DONE 	case aniCrush ..
   if not Map.is_in_fov(tx, ty) then
      return function() end
   end

   local _, th = Draw.get_coords():get_size()

   local create = function() return Rand.rnd(24) - 12, Rand.rnd(8) end
   local draw = function(asset, x, y, frame, px, py, i)
      local x = x + px
      local add = 0
      if i % 2 == 0 then
         add = 1
      end
      if px < 4 then
         x = x - (1 + add) * frame
      end
      if px > -4 then
         x = x + (1 + add) * frame
      end

      local y = y - th / 4 + py + frame * frame / 3

      local w = asset:get_width() / 2
      local h = asset:get_height() / 2
      asset:draw(x, y, w, h, nil, true, 23 * i)
   end

   local scx, scy = pos_centered(tx, ty)

   return Anim.make_particle_animation(scx, scy, "base.breaking_effect", 5, 4, create, draw)
   -- <<<<<<<< shade2/screen.hsp:951 	swbreak ..
end

function Anim.breath(positions, color, sound, chara_x, chara_y, target_x, target_y, map)
   -- >>>>>>>> shade2/screen.hsp:532:DONE 	case aniBreath ..
   if config.base.anime_wait == 0 then
      return function()
         Gui.play_sound("base.breath1", chara_x, chara_y)

         if sound then
            Gui.play_sound(sound, chara_x, chara_y)
         end
      end
   end

   color = color or {255, 255, 255}
   local rotation = math.deg(math.atan2(target_x - chara_x, chara_y - target_y))

   local t = UiTheme.load()

   return function(draw_x, draw_y)
      Gui.play_sound("base.breath1", chara_x, chara_y)

      local frame = 1
      local tw, th = Draw.get_coords():get_size()
      tw = math.floor(tw / 2)
      th = math.floor(th / 2)
      while frame < 6 do
         for _, pos in ipairs(positions) do
            local tx = pos[1]
            local ty = pos[2]
            if map:has_los(chara_x, chara_y, tx, ty) then
               local sx, sy = Gui.tile_to_screen(tx, ty)

               t.base.anim_breath:draw_region(frame, draw_x + sx + tw, draw_y + sy + th, nil, nil, color, true, rotation)
            end
         end

         local _, _, delta = Draw.yield(config.base.anime_wait)
         frame = frame + delta
      end

      if sound then
         Gui.play_sound(sound, chara_x, chara_y)
      end
   end
   -- <<<<<<<< shade2/screen.hsp:551 	swbreak ..
end

function Anim.ball(positions, color, sound, center_x, center_y, map)
   -- >>>>>>>> shade2/screen.hsp:553:DONE 	case aniBallNuke ..
   color = color or {255, 255, 255}

   local t = UiTheme.load()

   return function(draw_x, draw_y)
      Gui.play_sound("base.ball1", center_x, center_y)

      local frame = 1
      local tw, th = Draw.get_coords():get_size()
      tw = tw / 2
      th = th / 2

      while frame <= 10 do
         color[4] = 255
         for _, pos in ipairs(positions) do
            local tx = pos[1]
            local ty = pos[2]
            local sx, sy = Gui.tile_to_screen(tx, ty)
            t.base.anim_ball_2:draw_region(frame, draw_x + sx, draw_y + sy, nil, nil, color)
         end

         color[4] = 250 - frame * frame * 2
         local sx, sy = Gui.tile_to_screen(center_x, center_y)
         t.base.anim_ball:draw_region(frame, draw_x + sx - tw, draw_y + sy - th, nil, nil, color)

         local _, _, delta = Draw.yield(config.base.anime_wait)
         frame = frame + delta
      end

      if sound then
         Gui.play_sound(sound, center_x, center_y)
      end
   end
   -- <<<<<<<< shade2/screen.hsp:586 	swbreak ..
end

function Anim.death(tx, ty, asset, element_id)
   -- >>>>>>>> shade2/chara_func.hsp:646:DONE 	if cfg_animeWait@=0:return ..
   if config.base.anime_wait <= 0 then
      return function() end
   end

   local t = UiTheme.load()
   asset = t[asset]

   local element_anim
   local element_anim_dy
   local element_anim_frames
   if element_id then
      local element_data = data["base.element"]:ensure(element_id)
      if element_data.death_anim then
         element_anim = t[element_data.death_anim]
         element_anim_dy = element_data.death_anim_dy or -16
         element_anim_frames = #element_anim.quads
      end
   end

   local tw, th = Draw.get_coords():get_size()

   local point = function()
      return { x = Rand.rnd(tw) - math.floor(tw / 2), y = math.floor(th / 2) }
   end
   local particles = fun.tabulate(point):take(20):to_list()

   local wait = 15
   if element_anim then
      wait = wait + 20
   end

   return function(draw_x, draw_y)
      local sx, sy = Gui.tile_to_screen(tx, ty)

      local frame = 0

      while frame < 6 do
         local frame2 = frame * 2

         if element_anim and frame < element_anim_frames then
            element_anim:draw_region(frame+1, draw_x + sx - tw / 2, draw_y + sy - (3 * th / 4) + element_anim_dy)
         end

         for i, pos in ipairs(particles) do
            local add_x = ((pos.x < 3)  and 1 or 0) * -(1 + ((i % 2 == 0) and 1 or 0)) * frame2
               + ((pos.x > -4) and 1 or 0) *  (1 + ((i % 2 == 0) and 1 or 0)) * frame2

            asset:draw(draw_x + sx + tw / 2 + pos.x + add_x,
                       draw_y + sy + frame2 * frame2 / 2 - 12 + i,
                       (tw/2) - frame2 * 2,
                       (th/2) - frame2 * 2,
                       nil,
                       true,
                       0.2 * i)
         end

         local _, _, delta = Draw.yield(config.base.anime_wait + wait/2)
         frame = frame + delta
      end
   end
   -- <<<<<<<< shade2/chara_func.hsp:684 	return ..
end

return Anim
