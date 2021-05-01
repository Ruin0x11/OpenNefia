local Draw = require("api.Draw")
local I18N = require("api.I18N")
local Ui = require("api.Ui")
local MapObjectBatch = require("api.draw.MapObjectBatch")
local Gui = require("api.Gui")
local ICharaElonaFlags = require("mod.elona.api.aspect.chara.ICharaElonaFlags")

local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")

local ChooseNpcMenu = class.class("ChooseNpcMenu", IUiLayer)

ChooseNpcMenu:delegate("pages", "chosen")
ChooseNpcMenu:delegate("input", IInput)

local UiListExt = function(choose_npc_menu)
   local E = {}

   function E:get_item_text(entry)
      return entry.text
   end
   function E:draw_select_key(item, i, key_name, x, y)
      if (i - 1) % 2 == 0 then
         Draw.filled_rect(x - 1, y, 640, 18, {12, 14, 16, 16})
      end

      UiList.draw_select_key(self, item, i, key_name, x, y)
   end
   function E:draw_item_text(text, entry, i, x, y, x_offset)
      choose_npc_menu.map_object_batch:add(entry.chara, x - 44, y - 7, nil, nil, entry.color, true)
      UiList.draw_item_text(self, text, entry, i, x, y, x_offset)

      Draw.text(entry.info, x + 288, y + 2)
      Draw.text(entry.info2, x + 428, y + 2)
   end
   function E:draw()
      UiList.draw(self)
      choose_npc_menu.map_object_batch:draw()
      choose_npc_menu.map_object_batch:clear()
   end

   return E
end

function ChooseNpcMenu.generate_list(charas, topic)
   local filter_ = function(chara)
      -- >>>>>>>> shade2/command.hsp:1185 	if cnt=0		: continue ...
      if chara:is_player() then
         return false
      end

      if chara:calc_aspect_base(ICharaElonaFlags, "is_being_escorted_sidequest") then
         return false
      end
      -- <<<<<<<< shade2/command.hsp:1186 	if cBit(cGuardTemp,cnt)=true:continue ..

      return true
   end

   local list = fun.iter(charas):filter(filter_)
      :map(function(chara)
            local gender = I18N.capitalize(I18N.get("ui.sex3." .. chara:calc("gender")))
            local age = I18N.get("ui.npc_list.age_counter", chara:calc("age"))
            local info2

            if topic then
               info2 = topic.formatter(chara)
            else
               info2 = ""
            end

            return {
               text = utf8.wide_sub(chara:calc("name"), 0, 36),
               icon = chara:calc("image"),
               color = {255, 255, 255},
               info = ("Lv.%d %s%s"):format(chara:calc("level"), gender, age),
               info2 = info2,
               chara = chara,
               ordering = chara:calc("level")
            }
          end)
      :to_list()

   table.insertion_sort(list, function(a, b) return a.ordering > b.ordering end)

   return list
end

function ChooseNpcMenu:init(charas, topic)
   self.data = ChooseNpcMenu.generate_list(charas, topic)
   self.pages = UiList:new_paged(self.data, 16)
   self.custom_topic = topic or nil
   if self.custom_topic then
      assert(type(self.custom_topic.header_status) == "string")
      assert(type(self.custom_topic.formatter) == "function")
   end

   self.window = UiWindow:new("ui.npc_list.title", true, "key help")
   table.merge(self.pages, UiListExt(self))

   self.map_object_batch = nil

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())
end

function ChooseNpcMenu:on_query()
   Gui.play_sound("base.pop2")
end

function ChooseNpcMenu:make_keymap()
   return {
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end,
   }
end

function ChooseNpcMenu:relayout()
   self.width = 700
   self.height = 448
   self.x, self.y = Ui.params_centered(self.width, self.height)

   self.t = UiTheme.load(self)

   self.map_object_batch = MapObjectBatch:new()

   self.window:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 58, self.y + 66, self.width, self.height)
end

function ChooseNpcMenu:draw()
   self.window:draw()

   Ui.draw_topic("ui.npc_list.name", self.x + 28, self.y + 36)
   Ui.draw_topic("ui.npc_list.info", self.x + 350, self.y + 36)

   if self.custom_topic then
      Ui.draw_topic(self.custom_topic.header_status, self.x + 490, self.y + 36)
   end

   self.pages:draw()
end

function ChooseNpcMenu:update()
   if self.canceled then
      return nil, "canceled"
   end

   if self.pages.chosen then
      return self.pages:selected_item().chara
   end

   self.pages:update()
end

function ChooseNpcMenu:release()
   if self.chip_batch then
      self.chip_batch:release()
   end
end

return ChooseNpcMenu
