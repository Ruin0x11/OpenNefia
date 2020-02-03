local Chara = require("api.Chara")
local Draw = require("api.Draw")
local Event = require("api.Event")
local Gui = require("api.Gui")
local IChara = require("api.chara.IChara")
local Log = require("api.Log")

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
   self.trail = {}
   self.results = {}
   self.gene_used = "gene"

   self.caption = CharaMakeCaption:new()

   self.input = InputHandler:new()

   self:proceed()
end

function CharaMakeWrapper:make_keymap()
   return {}
end

function CharaMakeWrapper:proceed()
   local menu_id
   if self.submenu then
      menu_id = self.menus[#self.trail+2]
   else
      menu_id = self.menus[#self.trail+1]
   end

   local success, layer_class = xpcall(function() return env.safe_require(menu_id) end,
      function(err) return debug.traceback(err) end)

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

   local submenu
   success, submenu = xpcall(function()
         local sm = layer_class:new()
         class.assert_is_an(ICharaMakeSection, sm)
         return sm
   end,
      function(err)
         return debug.traceback(err)
   end)
   if not success then
      local err = submenu
      Log.error("Error instantiating charamake menu:\n\t%s:", err)
      self:go_back()
      return
   end

   if self.submenu then
      table.insert(self.trail, self.submenu)
   end
   self.submenu = submenu

   self.caption:set_data(self.submenu.caption)
   self:relayout()

   Gui.play_sound(self.submenu.intro_sound)

   self.input:forward_to(self.submenu)
   self.input:halt_input()
end

function CharaMakeWrapper:go_back()
   if #self.trail == 0 then return end

   self.submenu = table.remove(self.trail)
   -- TODO: self.submenu:on_resume_query(), to reset canceled state

   self.caption:set_data(self.submenu.caption)
   self:relayout()

   self.input:forward_to(self.submenu)
   self.input:halt_input()
end

function CharaMakeWrapper:go_to_start()
   while #self.trail > 0 do
      self:go_back()
   end

   -- call the constructor of the first menu again.
   self.submenu = nil
   self:proceed()
end

function CharaMakeWrapper:get_section_result(fq_name)
   for _, menu in ipairs(self.trail) do
      if env.get_require_path(menu) == fq_name then
         return menu:charamake_result()
      end
   end

   return nil
end

local on_initialize_player = Event.create(
   "on_initialize_player",
   { chara = "IChara", results = "{any,...}" },
   [[
Called when the player character's stats have finished being rerolled.
]]
)

function CharaMakeWrapper:make_chara()
   local default_id = "content.player" -- TODO
   local chara = Chara.create(default_id, nil, nil, {no_build = true, ownerless = true})

   local make_pairs = function(menu) return env.get_require_path(menu), menu:charamake_result() end
   local results = fun.iter(self.trail):map(make_pairs):to_map()

   for _, menu in ipairs(self.trail) do
      menu:on_make_chara(chara, results)
   end

   on_initialize_player({chara=chara})

   chara:build()

   return chara
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
   self.t.void:draw(self.x, self.y, self.width, self.height, {255, 255, 255})

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
   else
      if #self.trail == 0 then
         self.canceled = true
      else
         self:go_back()
      end
   end
end

function CharaMakeWrapper:update()
   if not self.submenu then
      return nil, "canceled"
   end

   local result, canceled = self.submenu:update()
   if result or canceled then
      print(result, canceled)
   end
   if canceled then
      local act = table.maybe(result, "chara_make_action")
      self:handle_action(act)
   elseif result then
      self.results[self.submenu.__class.__name] = result

      local has_next = self.menus[#self.trail+2] ~= nil
      if has_next then
         self:proceed()
      elseif class.is_an(IChara, result) then
         local success, err = xpcall(
            function()
               for _, menu in ipairs(self.trail) do
                  menu:on_charamake_finish(result)
               end
            end,
            debug.traceback)

         if not success then
            Log.error("Error running final character making step:\n\t%s", err)
            self.submenu:on_query() -- reset canceled
         else
            return result
         end
      else
         Log.error("No character was returned by the final character making screen.")
      end
   end

   if self.canceled then
      return nil, "canceled"
   end
end

return CharaMakeWrapper
