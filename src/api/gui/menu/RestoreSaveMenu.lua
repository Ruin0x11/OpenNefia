local Draw = require("api.Draw")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Input = require("api.Input")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local SaveFs = require("api.SaveFs")
local UiList = require("api.gui.UiList")
local UiWindow = require("api.gui.UiWindow")
local UiTheme = require("api.gui.UiTheme")
local Ui = require("api.Ui")
local CharaMakeCaption = require("api.gui.menu.chara_make.CharaMakeCaption")

local fs = require("util.fs")

local IUiLayer = require("api.gui.IUiLayer")

local RestoreSaveMenu = class.class("RestoreSaveMenu", IUiLayer)

local draw = require("internal.draw")

RestoreSaveMenu:delegate("input", IInput)

local UiListExt = function()
   local E = {}

   function E:get_item_text(item)
      return item.header
   end
   function E:draw_select_key(entry, i, key_name, x, y)
      y = self.y + (i-1) * 40
      UiList.draw_select_key(self, entry, i, key_name, x, y)
   end
   function E:draw_item_text(item_name, entry, i, x, y, x_offset, color)
      local subtext = entry.id
      y = self.y + (i-1) * 40

      Draw.set_font(13)
      UiList.draw_item_text(self, item_name, entry, i, x, y + 8, 0, color)

      Draw.set_font(11)
      Draw.text(subtext, x, y - 4, color)
   end

   return E
end

local function read_header(save_id)
   local full_path = SaveFs.save_path("header", save_id)
   local content, err = fs.read(full_path)
   if not content then
      return "er"
   end

   return SaveFs.deserialize(content).header
end

local function read_saves()
   return fun.iter(fs.get_directory_items("save"))
      :map(function(save_id)
            return { id = save_id, header = read_header(save_id) }
         end)
      :to_list()
end

function RestoreSaveMenu:init()
   local saves = read_saves()

   local key_hint = I18N.get("main_menu.continue.key_hint") .. I18N.get("ui.hint.back")
   self.win = UiWindow:new("main_menu.continue.title", true, key_hint)
   self.pages = UiList:new_paged(saves, 4)
   table.merge(self.pages, UiListExt())

   self.input = InputHandler:new()
   self.input.keys:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())
   self.caption = CharaMakeCaption:new("main_menu.continue.which_save")
   self.action = nil
end

function RestoreSaveMenu:query_deletion()
   local id = self.pages:selected_item().id
   self.caption:set_data(I18N.get("main_menu.continue.delete", id))
   if Input.yes_no() then
      self.caption:set_data(I18N.get("main_menu.continue.delete2", id))
      if Input.yes_no() then
         fs.remove(SaveFs.save_path("", id))
         self.pages:set_data(read_saves())
      end
   end
   self.caption:set_data("main_menu.continue.which_save")
end

function RestoreSaveMenu:make_keymap()
    return {
        cancel = function() self.canceled = true end,
        escape = function() self.canceled = true end,
        raw_f2 = function() self.action = "quickstart" end,
        raw_backspace = function() self:query_deletion() end
    }
end

function RestoreSaveMenu:on_hotload_layer()
   table.merge(self.pages, UiListExt())
end

function RestoreSaveMenu:relayout(x, y, width, height)
   self.x = x or 0
   self.y = y or 0
   self.width = width or Draw.get_width()
   self.height = height or Draw.get_height()

   local win_width, win_height = 440, 288
   local win_x, win_y = Ui.params_centered(win_width, win_height)

   self.t = UiTheme.load(self)
   self.win:relayout(win_x, win_y, win_width, win_height)
   self.pages:relayout(win_x + 20 + 20, win_y + 50)
   self.caption:relayout(self.x + 20, self.y + 30)
end

function RestoreSaveMenu:draw()
   self.t.base.void:draw(self.x, self.y, self.width, self.height, {255, 255, 255})
   self.caption:draw()

   self.win:draw()
   if self.pages:len() == 0 then
      Draw.text(I18N.get("main_menu.continue.no_save"), self.win.x + 140, self.win.y + 120)
   end
   self.pages:draw()
end

function RestoreSaveMenu:update(dt)
   if self.pages.chosen then
      Gui.play_sound("base.ok1")
      return self.pages:selected_item().id
   end
   if self.canceled then
      return nil, "canceled"
   end

   self.win:update(dt)
   self.pages:update(dt)
end

return RestoreSaveMenu
