--- @usage Gui.add_async_callback(Anim.swarm(20, 20))
--- @module Anim
local Anim = {}

local UiTheme = require("api.gui.UiTheme")
local Rand = require("api.Rand")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Pos = require("api.Pos")
local Draw = require("api.Draw")

local anim_wait = 80 * 0.5

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
   local t = UiTheme.load()
   local anim = data["elona_sys.basic_anim"]:ensure(anim_id)
   local sx, sy = Gui.tile_to_screen(tx, ty)
   local asset = t[anim.asset]
   assert(asset, ("Asset not found: %s"):format(anim.asset))
   assert(asset.count_x)

   if not Map.is_in_fov(tx, ty) or anim_wait == 0 then
      return function() end
   end

   local frames = anim.frames or asset.count_x
   local sound = anim.sound or nil
   local wait = anim.wait or 3.5
   local rotation = anim.rotation or 0

   return function(draw_x, draw_y)
      sx = draw_x + sx
      sy = draw_y + sy

      if sound then
         Gui.play_sound(sound)
      end

      local frame = 1
      while frame <= frames do
         asset:draw_region(frame, sx + 24, sy + 8, nil, nil, {255, 255, 255}, rotation * frame)

         local _, _, frames_passed = Draw.yield(anim_wait * wait)
         frame = frame + frames_passed
      end
   end
end

function Anim.make_animation(scx, scy, asset_id, duration, draw_cb)
   local t = UiTheme.load()
   local asset = t[asset_id]
   assert(asset, ("Asset not found: %s"):format(asset_id))

   return function(draw_x, draw_y)
      scx = scx + draw_x
      scy = scy + draw_y

      local frame = 0
      while frame <= duration - 1 do
         draw_cb(asset, scx, scy, frame)

         local _, _, frames_passed = Draw.yield(anim_wait)
         frame = frame + frames_passed
      end
   end
end

function Anim.make_particle_animation(scx, scy, asset_id, duration, max_particles, create_particle_cb, draw_cb)
   local t = UiTheme.load()
   local asset = t[asset_id]
   assert(asset, ("Asset not found: %s"):format(asset_id))

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

         local _, _, frames_passed = Draw.yield(anim_wait)
         frame = frame + frames_passed
      end
   end
end

function Anim.failure_to_cast(tx, ty)
   if not Map.is_in_fov(tx, ty) then
      return function() end
   end

   Gui.play_sound("base.fizzle", tx, ty)

   local scx, scy = pos_centered(tx, ty)
   local tw, th = Draw.get_coords():get_size()

   local draw = function(asset, x, y, frame)
      local scaling = (frame + 40) / tw
      local w = math.floor(asset:get_width() * scaling)
      local h = math.floor(asset:get_height() * scaling)
      asset:draw(x, y - th / 6, w, h, {255, 255, 255}, true, 75 * frame)
   end

   return Anim.make_animation(scx, scy, "failure_to_cast_effect", 12, draw)
end

function Anim.bolt(start_x, start_y, end_x, end_y)
   return function(draw_x, draw_y)
      -- TODO
   end
end

function Anim.ranged_attack(start_x, start_y, end_x, end_y, chip, color, sound, impact_sound)
   return function(draw_x, draw_y)
      if not Map.is_in_fov(start_x, start_y) and not Map.is_in_fov(end_x, end_y) then
         return
      end

      if chip == nil then
         local t = UiTheme.load()
         chip = t.ranged_attack_magic_arrow
      end

      if sound then
         Gui.play_sound(sound, start_x, start_y)
      end

      local tw, th = Draw.get_coords():get_size()
      local sx, sy = Gui.tile_to_screen(start_x, start_y)
      sx = draw_x + sx
      sy = draw_y + sy

      local count = math.floor(Pos.dist(start_x, start_y, end_x, end_y) / 2) + 1

      local frame = 1
      while frame <= count do
         sx = sx - math.floor((start_x - end_x) * tw / count)
         sy = sy - math.floor((start_y - end_y) * th / count)

         if is_in_screen(sx, sy) then
            chip:draw(sx + math.floor(tw / 2), sy + math.floor(th / 2), tw, th, color, true, math.deg(math.atan2(end_x - start_x, start_y - end_y)))

         end

         local _, _, frames_passed = Draw.yield(anim_wait)
         frame = frame + frames_passed
      end

      if impact_sound then
         Gui.play_sound(impact_sound, end_x, end_y)
      end
   end
end

function Anim.swarm(tx, ty)
   Gui.play_sound("base.atk1", tx, ty)
   local scx, scy = pos_centered(tx, ty)
   local tw, _ = Draw.get_coords():get_size()

   local draw = function(asset, x, y, frame)
      local scaling = (frame * 8 + 18) / tw
      local w = math.floor(asset:get_width() * scaling)
      local h = math.floor(asset:get_height() * scaling)
      asset:draw(x, y, w, h, {255,255,255}, true, 30 * frame - 45)
   end

   return Anim.make_animation(scx, scy, "swarm_effect", 4, draw)
end

function Anim.melee_attack(tx, ty, debris, kind, damage_percent, is_critical)
   local t = UiTheme.load()

   return function(draw_x, draw_y)
      local count = math.min(damage_percent / 4 + 1, 20)

      local particle
      if debris then
         particle = t.melee_attack_debris
      else
         particle = t.melee_attack_blood
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
            t.anim_critical:draw_region(frame, sx - 24, sy - 32)
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
            t.swarm_effect:draw(sx + points[1][1] + 24,
                                sy + points[1][2] + 10,
                                (frame - 1) * 10 + count,
                                (frame - 1) * 10 + count,
                                nil,
                                true,
                                0.5 + (frame - 1) * 0.8)
         elseif kind == 1 then
            if frame < 5 then
               t.anim_slash:draw_region(frame, sx, sy)
            end
         elseif kind == 2 then
            if frame < 5 then
               t.anim_bash:draw_region(frame, sx, sy)
            end
         end

         local _, _, frames_passed = Draw.yield(anim_wait)
         frame = frame + frames_passed
      end
   end
end

function Anim.gene_engineering(tx, ty)
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
               t.anim_gene:draw_region(frame + 5, draw_x, draw_y - j * 96)
            else
               t.anim_gene:draw_region(frame, draw_x, draw_y - j * 96)
            end
         end

         local _, _, frames_passed = Draw.yield(anim_wait * 2.25)
         i = i + frames_passed
      end
   end
end

--- @tparam {{x=int,y=int},...} positions
--- @tparam[opt] id:base.sound sound
function Anim.miracle(positions, sound)
   sound = sound or "base.heal1"

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
               t.anim_miracle:draw_region(region+1, draw_x + w.x, draw_y + anim_y)
               if w.duration <= 14 and w.duration >= 6 then
                  local region2 = 10 + math.floor((14 - w.duration) / 2) + 1
                  t.anim_miracle:draw_region(region2, draw_x + w.x, draw_y + anim_y + 16)
               end

               local anim_x = math.floor(math.clamp(anim_y / 55 + 1, 0, 7 - math.clamp((11 - w.duration) * 2, 0, 7)))
               for j = 1, anim_x do
                  local region2 = "beam_1"
                  if w.duration < 15 then
                     region2 = "beam_2"
                  end
                  t.anim_miracle:draw_region(region2, draw_x + w.x, draw_y + anim_y - j * 55)
                  if j == anim_x then
                     t.anim_miracle:draw_region("beam_3", draw_x + w.x, draw_y + anim_y - j * 55 - 40)
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
         _, _, delta = Draw.yield(anim_wait * 2.25)
         loops = loops + delta
      end
   end
end

function Anim.ragnarok()
   return function(draw_x, draw_y)
      -- TODO
   end
end

function Anim.breaking(tx, ty)
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

   return Anim.make_particle_animation(scx, scy, "breaking_effect", 5, 4, create, draw)
end

return Anim
