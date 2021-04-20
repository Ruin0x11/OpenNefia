local Draw = require("api.Draw")
local DirectionPrompt = require("api.gui.DirectionPrompt")

local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")

local ItemExChipVariantPrompt = class.class("ItemExChipVariantPrompt", IUiLayer)

ItemExChipVariantPrompt:delegate("input", IInput)

function ItemExChipVariantPrompt:init(chip_ids)
   self.chip_ids = chip_ids

   self.dir_prompt = DirectionPrompt:new(0, 0, true)

   self.input = InputHandler:new()
   self.input:forward_to(self.dir_prompt)
   self.input:bind_keys(self:make_keymap())
end

function ItemExChipVariantPrompt:make_keymap()
   return {}
end

function ItemExChipVariantPrompt:relayout()
   -- >>>>>>>> oomSEST/src/southtyris.hsp:50761 						x = (cX(0) - scx) * inf_tiles + inf_screenx  ...
   self.x = Draw.get_width() / 2
   self.y = Draw.get_height() / 2

   self.dir_prompt:relayout(self.x, self.y)
   -- <<<<<<<< oomSEST/src/southtyris.hsp:50762 						y = (cY(0) - scy) * inf_tiles + inf_screeny  ..
end

function ItemExChipVariantPrompt:draw()
   self.dir_prompt:draw()
end

function ItemExChipVariantPrompt:update(dt)
   local result, canceled = self.dir_prompt:update(dt)

   if canceled then
      return nil, "canceled"
   elseif result then
      return result
   end
end

return ItemExChipVariantPrompt
