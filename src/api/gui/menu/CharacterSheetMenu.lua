local Draw = require("api.Draw")
local Ui = require("api.Ui")

local ChangeAppearanceMenu = require("api.gui.menu.ChangeAppearanceMenu")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local TopicWindow = require("api.gui.TopicWindow")
local UiBuffList = require("api.gui.menu.UiBuffList")
local UiTextGroup = require("api.gui.UiTextGroup")
local UiTheme = require("api.gui.UiTheme")

local CharacterSheetMenu = class.class("CharacterSheetMenu", IUiLayer)

CharacterSheetMenu:delegate("input", IInput)

function CharacterSheetMenu:init(behavior)
   self.width = 700
   self.height = 400

   -- self.portrait = Draw.load_image("graphic/temp/portrait_female.bmp")
   -- self.chip = Draw.load_image("graphic/temp/chara_female.bmp")

   self.topic_win = TopicWindow:new(1, 10)

   self.buff_list = UiBuffList:new()

   self.texts = {}

   self.input = InputHandler:new()
   self.input:forward_to(self.buff_list)
   self.input:bind_keys(self:make_keymap())

   self.caption = "Summary."
end

function CharacterSheetMenu:make_keymap()
   return {
      p = function()
         ChangeAppearanceMenu:new():query()
      end
   }
end

function CharacterSheetMenu:text_level()
   local level = 10
   local exp = 1000
   local required_exp = 1000
   local god_name = "jure"
   local guild_name = "fighters"

   self.texts["level"] =
      UiTextGroup:new({"level", "exp", "gold", "god", "guild"}, { size = 12, style = "bold"})
   self.texts["level"]:relayout(self.x + 355, self.y + 46)

   self.texts["level_val"] =
      UiTextGroup:new({tostring(level), tostring(exp), tostring(required_exp), god_name, guild_name},
         14)
   self.texts["level_val"]:relayout(self.x + 410, self.y + 45)

end

function CharacterSheetMenu:text_name()
   local name = "name"
   local title = "title"
   local race = "race"
   local gender = "female"
   local class = "class"
   local age = "18"
   local height = 100 .. " cm"
   local weight = 100 .. " kg"

   self.texts["name"] =
      UiTextGroup:new({"name", "aka", "race", "sex", "class", "age", "height", "weight"},
         { size = 12, style = "bold"},
         {20, 10, 0},
         4, 4)
   self.texts["name"]:relayout(self.x + 30, self.y + 61)
   self.texts["name_val"] =
      UiTextGroup:new({name, title, race, gender, class, age, height, weight},
         14,
         {20, 10, 0},
         4, 4)

   self.texts["name_val"]:relayout(self.x + 68, -- + en * ((i > 3) * 12)
                                   self.y + 60)
end

function CharacterSheetMenu:text_attr()
   self.texts["attr"] = UiTextGroup:new(table.of("STR", 7), 12)
   self.texts["attr"]:relayout(self.x + 54, self.y + 151)
end

function CharacterSheetMenu:text_time()
   local turns = tostring(1000)
   local days = tostring(1)
   local kills = tostring(100)
   local time = tostring(100)

   self.texts["time"] =
      UiTextGroup:new({"turns", "days", "kills", "time"}, {size = 12, style = "bold"})
   self.texts["time"]:relayout(self.x + 32, self.y + 301)

   self.texts["time_val"] =
      UiTextGroup:new({turns, days, kills, time}, 14)
   self.texts["time_val"]:relayout(self.x + 80, self.y + 299)

end

function CharacterSheetMenu:text_weight()
   local cargo_weight = tostring(1234)
   local cargo_limit = tostring(12)
   local equip_weight = tostring(12593)
   local deepest_level = tostring(193)

   self.texts["weight"] =
      UiTextGroup:new({"cargo_weight", "cargo_limit", "equip_weight", "deepest_level"}, {size = 12, style = "bold"})
   self.texts["weight"]:relayout(self.x + 224, self.y + 301)

   self.texts["weight_val"] =
      UiTextGroup:new({cargo_weight, cargo_limit, equip_weight, deepest_level}, 14)
   self.texts["weight_val"]:relayout(self.x + 287, self.y + 299)
end

function CharacterSheetMenu:text_fame()
   local life = string.format("%d(%d)", 100, 120)
   local mana = string.format("%d(%d)", 100, 120)
   local insanity = tostring(100)
   local speed = string.format("%d(%d)", 100, 120)
   local fame = tostring(1000)
   local karma = tostring(5)

   self.texts["fame"] =
      UiTextGroup:new({"life", "mana", "sanity", "speed", "", "fame", "karma"}, {size = 12, style = "bold"})
   self.texts["fame"]:relayout(self.x + 255, self.y + 151)

   self.texts["fame_val"] =
      UiTextGroup:new({life, mana, insanity, speed, "", fame, karma}, 14)
   self.texts["fame_val"]:relayout(self.x + 310, self.y + 151)
end

function CharacterSheetMenu:relayout()
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y - 10
   self.t = UiTheme.load(self)

   self.topic_win:relayout(self.x + 557, self.y + 23, 87, 120)
   self.buff_list:relayout(self.x + 430, self.y + 151)

   self.texts = {}

   self:text_level()
   self:text_name()
   self:text_attr()
   self:text_time()
   self:text_weight()
   self:text_fame()
end

function CharacterSheetMenu:draw_text()
   self.texts["level"]:draw()
   self.texts["name"]:draw()

   local attr = self.texts["attr"]
   attr:draw()
   Draw.set_color(255, 255, 255)
   for i, t in ipairs(attr.texts) do
      self.t.skill_icons:draw_region(
                        t,
                        attr.x - 17,
                        attr.y + 6 + (i-1) * attr.item_height,
                        nil, nil,
                        {255, 255, 255},
                        true)
   end

   self.texts["time"]:draw()
   self.texts["weight"]:draw()
   self.texts["fame"]:draw()
end

function CharacterSheetMenu:potential_string(pot)
   if pot >= 200 then
      return "Superb"
   elseif pot >= 150 then
      return "Great"
   elseif pot >= 100 then
      return "Good"
   elseif pot >= 50 then
      return "Bad"
   end
   return "Hopeless"
end

function CharacterSheetMenu:draw_attribute_name(attr, x, y)
   local level = string.format("(%d)", 10)
   local ench = true
   if ench then
      level = level .. "*"
   end
   Draw.text(attr, x, y)
   Draw.text(level, x + 32, y)
end

function CharacterSheetMenu:draw_attribute_potential(attr, x, y)
   local pot = potential_string(100)
   Draw.text(pot, x, y)
end

function CharacterSheetMenu:draw_attributes()
   Draw.set_font(14)

   local attrs = table.of("123", 7)
   for i, attr in ipairs(attrs) do
      Draw.set_color(0, 0, 0)
      local x = self.x + 92
      local y = self.y + 152 + (i - 1) * 15
      self:draw_attribute_name(attr, x, y)
      self:draw_attribute_potential(attr, x + 84, y)
   end
end

function CharacterSheetMenu:draw_weapon_info()
   Draw.set_font(12, "bold") -- sizefix - en * 2
   Draw.text("protect",
             self.x + 417,
             self.y + 281 -- + p(2) * 16
             )
   Draw.text("evade",
             self.x + 590, -- - en * 16
             self.y + 281 -- + p(2) * 16
             )
   Draw.set_font(14)
   Draw.text("10% + 1d2",
             self.x + 460, -- + en * 8
             self.y + 279 -- + p(2) * 16
             )
   Draw.text("10%",
             self.x + 625, -- + en * 8
             self.y + 279 -- + p(2) * 16
             )
end

function CharacterSheetMenu:draw_buffs()
   self.buff_list:draw()

   local buff_desc = "buff desc"
   local hint = self.buff_list:get_hint()

   Draw.set_font(13)
   Draw.text(buff_desc, self.x + 108, self.y + 366, {0, 0, 0})
   Draw.set_font(11, "bold") -- + sizefix * 2 - en * 2
   Draw.text(hint,
             self.x + 70,
             self.y + 369, -- - en * 3
             {0, 0, 0})
end

function CharacterSheetMenu:draw_values()
   Draw.set_font(14)

   self.texts["level_val"]:draw()
   self.texts["name_val"]:draw()
   self:draw_attributes()
   self.texts["fame_val"]:draw()
   self:draw_weapon_info()
   self.texts["time_val"]:draw()
   self.texts["weight_val"]:draw()
   self:draw_buffs()
end

function CharacterSheetMenu:draw()
   self.t.ie_sheet:draw(self.x, self.y, nil, nil, {255, 255, 255})

   Ui.draw_topic("ui.chara_sheet.attributes",    self.x + 28,  self.y + 122)
   Ui.draw_topic("ui.chara_sheet.combat_rolls",  self.x + 400, self.y + 253)
   Ui.draw_topic("ui.chara_sheet.history",       self.x + 28,  self.y + 273)
   Ui.draw_topic("ui.chara_sheet.blessing",      self.x + 400, self.y + 122)
   Ui.draw_topic("ui.chara_sheet.extra_info",    self.x + 220, self.y + 273)

   -- Draw.image(self.portrait, self.x + 560, self.y + 27, 80, 112, nil)
   self.topic_win:draw()
   -- Draw.image(self.chip, self.x + 596 + 22, self.y + 86 + 24, nil, nil, nil, true)

   self:draw_text()
   self:draw_values()
end

function CharacterSheetMenu:update()
   if self.canceled then
      return nil, "canceled"
   end

   self.topic_win:update()
   self.buff_list:update()
end

return CharacterSheetMenu
