local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local UiBuffList = require("api.gui.UiBuffList")
local UiTextGroup = require("api.gui.UiTextGroup")
local UiWindow = require("api.gui.UiWindow")

local CharacterSheetMenu = class("CharacterSheetMenu", IUiLayer)

CharacterSheetMenu:delegate("win", {"x", "y", "width", "height", "relayout"})

local function potential_string(pot)
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

function CharacterSheetMenu:init(behavior)
   self.x, self.y, self.width, self.height = Ui.params_centered(700, 400)
   self.y = self.y - 10

   self.win = UiWindow:new("title", self.x, self.y, self.width, self.height)

   self.portrait = Draw.load_image("graphic/temp/portrait_female.bmp")
   self.chip = Draw.load_image("graphic/temp/chip_female.bmp")

   self.topic_win = TopicWindow:new(self.x + 557, self.y + 23, 87, 120, 1, 10)

   self.buff_list = UiBuffList:new(self.x + 430, self.y + 151)

   self.texts = {}

   -------------------- dupe
   self.skill_icons = Draw.load_image("graphic/temp/skill_icons.bmp")
   local skills = {
      "base.strength",
   }

   local iw = self.skill_icons:getWidth()
   local ih = self.skill_icons:getHeight()

   self.quad = {}
   for i, s in ipairs(skills) do
      self.quad[s] = love.graphics.newQuad(i * 48, 0, 48, 48, iw, ih)
   end
   --------------------
end

function CharacterSheetMenu:text_level()
   local level = 10
   local exp = 1000
   local required_exp = 1000
   local god_name = "jure"
   local guild_name = "fighters"

   self.texts["level"] =
      UiTextList:new(self.x + 355,
                     self.y + 46,
                     {"level", "exp", "gold", "god", "guild"},
                     {20, 10, 0},
                     4, 4)
   self.text["level_val"] =
      UiTextList:new(self.x + 410,
                     self.y + 45,
                     {tostring(level), tostring(exp), tostring(required_exp), god_name, guild_name}
      )

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
      UiTextList:new(self.x + 30,
                     self.y + 61,
                     {"name", "aka", "race", "sex", "class", "age", "height", "weight"},
                     {20, 10, 0},
                     4, 4)
   text = {name, title, race, gender, class, age, height, weight}
   self.texts["name_val"] =
      UiTextList:new(self.x + 68, -- + en * ((i > 3) * 12)
                     self.y + 60,
                     {name, title, race, gender, class, age, height, weight},
                     {20, 10, 0},
                     4, 4)
end

function CharacterSheetMenu:text_attr()
   self.texts["attr"] =
      UiTextList:new(
         self.x + 54,
         self.y + 151,
         table.of("base.strength", 8),
         {20, 10, 0},
         4, 4)
end

function CharacterSheetMenu:text_time()
   local turns = tostring(1000)
   local days = tostring(1)
   local kills = tostring(100)
   local time = string(100)

   self.texts["time"] =
      UiTextList:new(self.x + 32,
                     self.y + 301,
                     {"turns", "days", "kills", "time"})
   self.texts["time_val"] =
      UiTextList:new(self.x + 80,
                     self.y + 299,
                     {turns, days, kills, time})

end

function CharacterSheetMenu:text_weight()
   local cargo_weight = tostring(100)
   local cargo_limit = tostring(100)
   local equip_weight = tostring(100)
   local deepest_level = tostring(100)

   self.texts["weight"] =
      UiTextList:new(self.x + 224,
                     self.y + 301,
                     {"cargo_weight", "cargo_limit", "equip_weight", "deepest_level"})
   self.texts["weight_val"] =
      UiTextList:new(self.x + 287,
                     self.y + 299,
                     {cargo_weight, cargo_limit, equip_weight, deepest_level})
end

function CharacterSheetMenu:text_fame()
   local life = "%d(%d)":format(100, 120)
   local mana = "%d(%d)":format(100, 120)
   local insanity = tostring(100)
   local speed = "%d(%d)":format(100, 120)
   local fame = tostring(1000)
   local karma = tostring(5)

   self.texts["fame"] =
      UiTextList:new(self.x + 255,
                     self.y + 151,
                     {"life", "mana", "sanity", "speed", "", "fame", "karma", "", "melee", "shoot"}
      )
   self.texts["fame_val"] =
      UiTextList:new(self.x + 310,
                     self.y + 151,
                     {life, mana, insanity, speed, "", fame, karma, "", ""})
end

function CharacterSheetMenu:relayout()
   self.win:relayout()
   self.topic_win:relayout()
   self.buff_list:relayout()

   self.texts = {}

   self:text_level()
   self:text_name()
   self:text_attr()
   self:text_time()
   self:text_weight()
   self:text_fame()
end

function CharacterSheetMenu:focus()
end

function CharacterSheetMenu:draw_text()
   Draw.set_font(12, "bold") -- 12 + sizefix - en * 2

   self.texts["level"]:draw()
   self.texts["name"]:draw()

   local attr = self.texts["attr"]
   attr:draw()
   for i, t in ipairs(attr.list) do
      Draw.image_region(self.attribute_icons.image,
                        self.attribute_icons.quad[text],
                        attr.x - 17,
                        attr.y + 6 + (i-1) * attr.item_height,
                        nil, nil, true)
   end

   self.texts["time"]:draw()
   self.texts["weight"]:draw()
   self.texts["fame"]:draw()
end

function CharacterSheetMenu:draw_attributes()
   local attrs = table.of("attr", 8)
   for i, a in ipairs(attrs) do
      local level = "(%d)":format(10)
      local ench = true
      if ench then
         level = level .. "*"
      end
      Draw.text(self.x + 92, self.y + 151 + i * 15, a)
      Draw.text(self.x + 124, self.y + 151 + i * 15, level)
      --------------------
      local pot = potential_string(100)
      Draw.text(self.x + 176, self.y + 152 + (i - 1) * 15, pot)
   end
end

function CharacterSheetMenu:draw_weapon_info
   Draw.set_font(12, "bold") -- sizefix - en * 2
   Draw.text(self.x + 417,
             self.y + 281, -- + p(2) * 16
             "protect")
   Draw.text(self.x + 590, -- - en * 16
             self.y + 281, -- + p(2) * 16
             "evade")
   Draw.set_font(14)
   Draw.text(self.x + 460, -- + en * 8
             self.y + 279, -- + p(2) * 16
             "10% + 1d2")
   Draw.text(self.x + 625, -- + en * 8
             self.y + 279, -- + p(2) * 16
             "10%")
end

function CharacterSheetMenu:draw_buffs()
   self.buff_list:draw()

   local buff_desc = "buff desc"
   local hint = self.buff_list:get_hint()

   Draw.set_font(13)
   Draw.text(buff_desc, self.x + 108, self.y + 366)
   Draw.set_font(11, "bold") -- + sizefix * 2 - en * 2
   Draw.text(hint,
             self.x + 70,
             self.y + 369) -- - en * 3
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
   self.draw_buffs()
end

function CharacterSheetMenu:draw()
   self.win:draw()

   Ui.draw_topic("ui.chara_sheet.attributes",    self.x + 28,  self.y + 122)
   Ui.draw_topic("ui.chara_sheet.combat_rolls",  self.x + 400, self.y + 253)
   Ui.draw_topic("ui.chara_sheet.history",       self.x + 28,  self.y + 273)
   Ui.draw_topic("ui.chara_sheet.blessing",      self.x + 400, self.y + 122)
   Ui.draw_topic("ui.chara_sheet.extra_info",    self.x + 220, self.y + 273)

   Draw.image(self.portrait, self.x + 560, self.y + 27)
   self.topic_win:draw()
   Draw.image(self.chip, self.x + 596 + 22, self.y + 86 + 24)

   self:draw_text()
   self:draw_values()
end

function CharacterSheetMenu:update()
   self.win:update()
   self.topic_win:update()
   self.buff_list:update()
end

return CharacterSheetMenu
