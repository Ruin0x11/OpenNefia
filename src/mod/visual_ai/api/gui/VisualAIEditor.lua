local Ui = require("api.Ui")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")
local VisualAIPlanTrail = require("mod.visual_ai.api.gui.VisualAIPlanTrail")
local VisualAIPlanGrid = require("mod.visual_ai.api.gui.VisualAIPlanGrid")
local VisualAIInsertMenu = require("mod.visual_ai.api.gui.VisualAIInsertMenu")
local VisualAIPlan = require("mod.visual_ai.api.plan.VisualAIPlan")
local utils = require("mod.visual_ai.internal.utils")
local Gui = require("api.Gui")

local VisualAIEditor = class.class("VisualAIEditor", IUiLayer)

VisualAIEditor:delegate("input", IInput)

function VisualAIEditor:init(plan, opts)
   opts = opts or {}
   if opts.chara then
      save.visual_ai.editing_chara = opts.chara
   end

   self.plan = plan or VisualAIPlan:new()
   self.last_category = nil
   self.interactive = opts.interactive

   self.win = UiWindow:new("visual_ai.gui.menu.title", true)
   self.grid = VisualAIPlanGrid:new(self.plan)
   self.trail = VisualAIPlanTrail:new(self.plan)

   self.input = InputHandler:new()
   self.input:forward_to(self.grid)
   self.input:bind_keys(self:make_keymap())
end

function VisualAIEditor:make_keymap()
   return {
      enter = function() self:add() end,
      escape = function() self.canceled = true end,

      ["visual_ai.insert"]            = function() self:insert("true_branch") end,
      ["visual_ai.insert_down"]       = function() self:insert("false_branch") end,
      ["visual_ai.delete"]            = function() self:delete("true_branch") end,
      ["visual_ai.delete_merge_down"] = function() self:delete("false_branch") end,
      ["visual_ai.delete_to_right"]   = function() self:delete_to_right() end,
      ["visual_ai.swap_branches"]     = function() self:swap_branches() end,
   }
end

function VisualAIEditor:on_query()
   Gui.play_sound("base.pop2")
   self.canceled = false
end

function VisualAIEditor:refresh_grid()
   self.grid:refresh()
   self.trail:refresh()
end

function VisualAIEditor:add()
   local tile = self.grid:selected_tile()
   if tile == nil then
      return
   end

   Gui.play_sound("base.ok1")

   if tile.type == "empty" then
      print(self.last_category)
      local result, canceled = VisualAIInsertMenu:new("visual_ai.gui.menu.insert_block", self.last_category):query()
      self.last_category = result.last_category
      if canceled then
         return
      end
      local block = tile.plan:add_block(result.block)
      if not utils.is_block_terminal(block) then
         self.grid:move_cursor(1, 0)
      end
   elseif tile.type == "block" then
      local result, canceled = VisualAIInsertMenu:new("visual_ai.gui.menu.replace_block", tile.block.proto.type, tile.block.proto._id):query()
      self.last_category = tile.block.proto.type
      if canceled then
         return
      end
      local block = tile.plan:replace_block(tile.block, result.block)
      if not utils.is_block_terminal(block) then
         self.grid:move_cursor(1, 0)
      end
   end

   self:refresh_grid()
end

function VisualAIEditor:insert(split_type)
   local tile = self.grid:selected_tile()
   if tile == nil then
      return
   end

   local result, canceled = VisualAIInsertMenu:new("visual_ai.gui.menu.insert_block", self.last_category):query()
   self.last_category = result.last_category
   if canceled then
      return
   end

   tile.plan:insert_block_before(tile.block, result.block, split_type)
   self:refresh_grid()
end

function VisualAIEditor:delete(merge_type)
   local tile = self.grid:selected_tile()
   if tile == nil or tile.type ~= "block" then
      return
   end

   Gui.play_sound("base.ok1")

   tile.plan:remove_block(tile.block, merge_type)
   self:refresh_grid()
end

function VisualAIEditor:delete_to_right()
   local tile = self.grid:selected_tile()
   if tile == nil or tile.type ~= "block" then
      return
   end

   Gui.play_sound("base.ok1")

   tile.plan:remove_block_and_rest(tile.block)
   self:refresh_grid()
end

function VisualAIEditor:swap_branches()
   local tile = self.grid:selected_tile()
   if tile == nil or tile.type ~= "block" then
      return
   end

   Gui.play_sound("base.ok1")

   tile.plan:swap_branches(tile.block)
   self:refresh_grid()
   self:halt_input()
end

function VisualAIEditor:relayout(x, y, width, height)
   self.width = 800
   self.height = 480

   self.x, self.y = Ui.params_centered(self.width, self.height - 16)
   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)

   local grid_w = self.width - 272
   local grid_h = self.height - 80
   local grid_x = self.x + 40
   local grid_y = self.y + 40
   self.grid:relayout(grid_x,
                      grid_y,
                      grid_w - (grid_w % self.grid.tile_size_px),
                      grid_h - (grid_h % self.grid.tile_size_px))

   self.trail:relayout(self.x + grid_w,
                       self.y + 20,
                       320,
                       self.height - 40)
end

function VisualAIEditor:draw()
   self.win:draw()
   self.grid:draw()
   self.trail:draw()
end

function VisualAIEditor:update(dt)
   if self.grid.changed then
      local trail, selected_idx = self.grid:get_trail_and_index()
      self.trail:set_trail(trail, selected_idx)
   end

   self.win:update(dt)
   self.grid:update(dt)
   self.trail:update(dt)

   if self.canceled then
      save.visual_ai.editing_chara = nil
      if self.interactive then
         return self.plan, nil
      else
         return nil, "canceled"
      end
   end
end

return VisualAIEditor
