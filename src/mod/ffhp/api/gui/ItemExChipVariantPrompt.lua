local Draw = require("api.Draw")
local DirectionPrompt = require("api.gui.DirectionPrompt")
local Enum = require("api.Enum")
local Direction = Enum.Direction
local Gui = require("api.Gui")

local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")

local ItemExChipVariantPrompt = class.class("ItemExChipVariantPrompt", IUiLayer)

ItemExChipVariantPrompt:delegate("input", IInput)

local DIRECTIONS = {
   Direction.South,
   Direction.West,
   Direction.East,
   Direction.North,
   Direction.Southwest,
   Direction.Northwest,
   Direction.Southeast,
   Direction.Northeast,
}

function ItemExChipVariantPrompt:init(center_x, center_y, chip_ids)
   self.dir_prompt = DirectionPrompt:new(center_x, center_y)

   -- TODO support more than 8 chips
   self.dir_to_chip = {}
   for i, dir in ipairs(DIRECTIONS) do
      self.dir_prompt:set_direction_enabled(dir, chip_ids[i] ~= nil)
      self.dir_to_chip[dir] = chip_ids[i]
   end

   self.input = InputHandler:new()
   self.input:forward_to(self.dir_prompt)
   self.input:bind_keys(self:make_keymap())
end

function ItemExChipVariantPrompt:make_keymap()
   return {}
end

function ItemExChipVariantPrompt:on_query()
   -- >>>>>>>> oomSEST/src/southtyris.hsp:50750 						txt -1, lang("どの向きに置く？", "Which direction?") ...
   Gui.mes("ffhp:action.which_direction.chip")
   Gui.play_sound("base.pop2")
   -- <<<<<<<< oomSEST/src/southtyris.hsp:50751 						snd 26 ..
end

function ItemExChipVariantPrompt:relayout()
   -- >>>>>>>> oomSEST/src/southtyris.hsp:50761 						x = (cX(0) - scx) * inf_tiles + inf_screenx  ...
   self.dir_prompt:relayout()

   self.tile_width, self.tile_height = Draw.get_coords():get_size()
   self.chip_batch = Draw.make_chip_batch("chip")
   -- <<<<<<<< oomSEST/src/southtyris.hsp:50762 						y = (cY(0) - scy) * inf_tiles + inf_screeny  ..
end

function ItemExChipVariantPrompt:draw()
   -- >>>>>>>> oomSEST/src/southtyris.hsp:50764 							t++ ...
   self.dir_prompt:draw()

   local x, y = self.dir_prompt.x, self.dir_prompt.y
   local tw, th = self.tile_width, self.tile_height

   local function draw_chip(dir, sx, sy)
      local chip = self.dir_to_chip[dir]
      if chip then
         self.chip_batch:add(chip, sx, sy, nil, nil, nil, true)
      end
   end

   Draw.set_color(255, 255, 255)
   self.chip_batch:clear()

   if not self.dir_prompt.diagonal_only then
      draw_chip("North", x, y - th * 2, 0)
      draw_chip("South", x, y + th * 2, 180)
      draw_chip("East", x + tw * 2, y, 90)
      draw_chip("West", x - tw * 2, y, 270)
   end

   draw_chip("Northwest", x - tw * 2, y - th * 2, 315)
   draw_chip("Southeast", x + tw * 2, y + th * 2, 135)
   draw_chip("Southwest", x + tw * 2, y - th * 2, 45)
   draw_chip("Northeast", x - tw * 2, y + th * 2, 225)

   self.chip_batch:draw()
   -- <<<<<<<< oomSEST/src/southtyris.hsp:50847 							await 30 ..
end

function ItemExChipVariantPrompt:update(dt)
   local result, canceled = self.dir_prompt:update(dt)

   if canceled then
      return nil, "canceled"
   elseif result then
      return { chip = self.dir_to_chip[result] }
   end
end

return ItemExChipVariantPrompt
