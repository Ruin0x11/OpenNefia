data:add {
   _type = "base.feat",
   _id = "door",

   elona_id = 21,
   image = 194,
   is_solid = true,
   is_opaque = true,

   params = { opened = "boolean", open_sound = "string", close_sound = "string", opened_tile = "string", closed_tile = "string" },
   open_sound = "base.door1",
   close_sound = "base.door2",

   closed_tile = 194,
   opened_tile = 195,

   on_refresh = function(self)
      -- HACK
      self.opened = not not self.opened

      self:mod("can_open", not self.opened, "set")
      self:mod("can_close", self.opened, "set")
      self:mod("is_solid", not self.opened, "set")
      self:mod("is_opaque", not self.opened, "set")
      if self.opened then
         self:mod("image", self.opened_tile)
      else
         self:mod("image", self.closed_tile)
      end
   end,
   on_bumped_into = function(self, chara)
      self:on_open()
   end,
   on_open = function(self, chara)
      if self.opened then
         return
      end

      self.opened = true

      if self.open_sound then
         local Gui = require("api.Gui")
         Gui.play_sound(self.open_sound, self.x, self.y)
      end

      self:refresh()
   end,
   on_close = function(self, chara)
      if not self.opened then
         return
      end

      self.opened = false

      if self.close_sound then
         local Gui = require("api.Gui")
         Gui.play_sound(self.close_sound, self.x, self.y)
      end

      self:refresh()
   end
}

local function gen_stair(down)
   local field = (down and "on_descend") or "on_ascend"
   local id = (down and "stairs_down") or "stairs_up"
   local elona_id = (down and 11) or 10
   local image = (down and 196) or 195

   return {
      _type = "base.feat",
      _id = id,

      elona_id = elona_id,
      image = image,
      is_solid = false,
      is_opaque = false,

      params = { generator = "string", generator_params = "table", map_uid = "number" },

      on_refresh = function(self)
         self:mod("can_activate", true)
      end,

      on_activate = function(self, chara)
         if not chara:is_player() then
            return
         end

         local Gui = require("api.Gui")
         local Map = require("api.Map")

         local map
         if self.map_uid == nil then
            local success
            success, map = Map.generate(self.generator, self.generator_params)
            if not success then
               Gui.mes("Couldn't load map: " .. map)
               return "player_turn_query"
            end
         end

         Gui.play_sound("base.exitmap1")
         Map.travel_to(map)

         return "player_turn_query"
      end,

      [field] = function(self, chara)
         self:on_activate(chara)
      end
   }
end

data:add(gen_stair(true))
data:add(gen_stair(false))
