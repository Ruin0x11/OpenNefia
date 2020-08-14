local Env = require("api.Env")
local Chara = require("api.Chara")
local Draw = require("api.Draw")
local Event = require("api.Event")
local Gui = require("api.Gui")
local IChara = require("api.chara.IChara")
local Log = require("api.Log")

local config = require("internal.config")
local env = require("internal.env")

local CharaMakeCaption = require("api.gui.menu.chara_make.CharaMakeCaption")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")

local CharaMakeWrapper = class.class("CharaMakeWrapper", IUiLayer)

CharaMakeWrapper:delegate("input", IInput)

function CharaMakeWrapper:init(menus)
   self.x = 0
   self.y = 0
   self.width = Draw.get_width()
   self.height = Draw.get_height()
   self.menus = menus
   self.submenu_trail = {}
   self.results = {}
   self.gene_used = "gene"

   self.caption = CharaMakeCaption:new()

   self.input = InputHandler:new()

   self:proceed()
end

function CharaMakeWrapper:make_keymap()
   return {}
end

function CharaMakeWrapper:set_caption(text)
   text = text or self.submenu.caption
   self.caption:set_data(text)
end

function CharaMakeWrapper:current_result()
   return self.results[#self.submenu_trail]
end

function CharaMakeWrapper:proceed()
   local menu_id
   if self.submenu then
      menu_id = self.menus[#self.submenu_trail+2]
   else
      menu_id = self.menus[#self.submenu_trail+1]
   end

   local success, layer_class = xpcall(env.safe_require, debug.traceback, menu_id)

   if not success then
      local err = layer_class
      -- TODO turn this into a log warning
      Log.error("Error loading menu %s:\n\t%s", menu_id, err)
      self:go_back()
      return
   elseif class == nil then
      Log.error("Cannot find menu %s", menu_id)
      self:go_back()
      return
   end

   -- Get the result returned from the last menu, or a blank one if
   -- still on the first menu.
   local in_progress_result = self:current_result() or { chara = nil }

   local submenu
   success, submenu = xpcall(function()
         local sm = layer_class:new(in_progress_result)
         class.assert_is_an(ICharaMakeSection, sm)
         return sm
   end, debug.traceback)

   if not success then
      local err = submenu
      Log.error("Error instantiating charamake menu:\n\t%s", err)
      return
   end

   if self.submenu then
      table.insert(self.submenu_trail, self.submenu)
   end
   self.submenu = submenu

   self:set_caption(self.submenu.caption)
   self:relayout()

   Gui.play_sound(self.submenu.intro_sound)

   self.input:forward_to(self.submenu)
   self.input:halt_input()
end

function CharaMakeWrapper:go_back()
   if #self.submenu_trail == 0 then return end

   self.submenu = table.remove(self.submenu_trail)
   self.submenu:on_charamake_query_menu()

   self.caption:set_data(self.submenu.caption)
   self:relayout()

   self.input:forward_to(self.submenu)
   self.input:halt_input()
end

function CharaMakeWrapper:go_to_start()
   while #self.submenu_trail > 0 do
      self:go_back()
   end

   -- call the constructor of the first menu again.
   self.submenu = nil
   self:proceed()
end

function CharaMakeWrapper:relayout(x, y, width, height)
   self.x = x or 0
   self.y = y or 0
   self.width = width or Draw.get_width()
   self.height = height or Draw.get_height()
   self.t = UiTheme.load()
   self.caption:relayout(self.x + 20, self.y + 30)

   if self.submenu then
      self.submenu:relayout(self.x, self.y, self.width, self.height)
   end
end

function CharaMakeWrapper:draw()
   self.t.base.void:draw(self.x, self.y, self.width, self.height, {255, 255, 255})

   self.caption:draw()

   Draw.set_font(13, "bold") -- 13 - en * 2
   Draw.text("Press F1 to show help.", self.x + 20, self.height - 20, {0, 0, 0})

   if self.gene_used then
      Draw.text("Gene from " .. self.gene_used, self.x + 20, self.height - 36)
   end

   if self.submenu then
      self.submenu:draw()
   end
end

function CharaMakeWrapper:handle_action(act)
   if act == "go_to_start" then
      self:go_to_start()
   end
end

function CharaMakeWrapper:initialize_player(chara)
   assert(chara.name, "Character must have name set")
   assert(chara.race, "Character must have race set")
   assert(chara.class, "Character must have class set")

   Event.trigger("base.on_initialize_player", {chara=chara})
   config["base._save_id"] = chara.name
end

function CharaMakeWrapper:update()
   if not self.submenu then
      return nil, "canceled"
   end

   local result, canceled = self.submenu:update()
   local action = result and result.chara_make_action

   if canceled then
      if action then
         self:handle_action(action)
      else
         if #self.submenu_trail == 0 then
            self.canceled = true
         else
            self:go_back()
         end
      end
   elseif result then
      assert(type(result) == "table", "Charamake menu result must be table")
      result.menu_id = Env.get_require_path(self.submenu.__class)

      local has_next = self.menus[#self.submenu_trail+2] ~= nil
      if has_next then
         self.results[#self.submenu_trail+1] = table.deepcopy(result)
         self:proceed()
      else
         assert(class.is_an(IChara, result.chara))

         local success, err = xpcall(
            function()
               for _, menu in ipairs(self.submenu_trail) do
                  menu:on_charamake_finish(result)
               end
               self.submenu:on_charamake_finish(result)
            end,
            debug.traceback)

         if not success then
            Log.error("Error running final character making step:\n\t%s", err)
            self.submenu:on_query() -- reset canceled
         else
            self:initialize_player(result.chara)
            return result
         end
      end
   end

   if self.canceled then
      return nil, "canceled"
   end
end

return CharaMakeWrapper
