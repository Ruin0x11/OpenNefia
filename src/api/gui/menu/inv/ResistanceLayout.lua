local Const = require("api.Const")
local Draw = require("api.Draw")
local Enum = require("api.Enum")
local I18N = require("api.I18N")
local UiTheme = require("api.gui.UiTheme")
local IInventoryMenuDetailView = require("api.gui.menu.inv.IInventoryMenuDetailView")
local data = require("internal.data")

local ResistanceLayout = class.class("ResistanceLayout", IInventoryMenuDetailView)

function ResistanceLayout.make_list()
   local filter = function(e)
      return e.can_resist
   end

   local map = function(e)
      return {
         _id = e._id,
         short_name = I18N.get("element." .. e._id .. ".short_name"),
         color = e.ui_color or {0, 0, 0}
      }
   end

   local sort = function(a, b)
      return (a.ordering or 0) < (b.ordering or 0)
   end

   return data["base.element"]:iter()
      :filter(filter)
      :map(map)
      :into_sorted(sort)
      :to_list()
end

function ResistanceLayout:init()
   self.resists = ResistanceLayout.make_list()
   self.entries = {}
   self.t = nil
end

local function get_resist_powers(item)
   local function is_resist_enc(merged_enc)
      return merged_enc._id == "elona.modify_resistance"
         and merged_enc.total_power ~= 0
   end

   local adjusted_power = data["base.enchantment"]["elona.modify_resistance"].adjusted_power

   local function map(merged_enc)
      -- HACK
      local power = adjusted_power(merged_enc.total_power, merged_enc.params)
      return merged_enc.params.element_id, power
   end

   return item:iter_merged_enchantments():filter(is_resist_enc):map(map):to_map()
end

function ResistanceLayout:relayout()
   self.t = UiTheme.load(self)
end

function ResistanceLayout:on_page_changed(menu)
   self.entries = {}
   for i, entry in menu.pages:iter() do
      local t = {
         name = utf8.wide_sub(entry.name, 0, 24),
         resists = {}
      }

      if entry.item and entry.item:calc("identify_state") >= Enum.IdentifyState.Full then
         local resist_powers = get_resist_powers(entry.item)

         for _, resist in ipairs(self.resists) do
            local resist_power = resist_powers[resist._id]
            if resist_power and resist_power ~= 0 then
               local resist_grade = math.floor(resist_power / Const.RESIST_GRADE) + 1
               t.resists[resist._id] = { power = resist_power, text = tostring(math.abs(resist_grade)) }
            end
         end
      end

      self.entries[i] = t
   end
end

function ResistanceLayout:draw_header(x, y)
   -- >>>>>>>> shade2/command.hsp:3558 	if showResist:pos wx+300,wy+40:color 0,0,0:mes la ...
   x = x + 300
   y = y

   Draw.set_font(14)
   Draw.set_color(self.t.base.text_color)
   local space = Draw.text_width(" ")
   for _, entry in ipairs(self.resists) do
      Draw.text(entry.short_name, x + 4, y)
      x = x + Draw.text_width(entry.short_name) + space
   end
   -- <<<<<<<< shade2/command.hsp:3558 	if showResist:pos wx+300,wy+40:color 0,0,0:mes la ..
end

function ResistanceLayout:draw_row(entry, i, x, y)
   -- >>>>>>>> shade2/item_func.hsp:768 #deffunc equipInfo int ci,int x,int y ...
   local t = self.entries[i]
   if not t then
      return
   end

   x = x + 300 - 58 - 4 - 18
   y = y

   local jp = I18N.is_fullwidth()
   local text_positive = "●"
   local text_negative = "▼"

   Draw.set_font(14)
   local space = Draw.text_width(" ")
   for _, entry in ipairs(self.resists) do
      local resist = t.resists[entry._id]

      if resist then
         if jp then
            Draw.set_color(entry.color)
            if resist.power >= 0 then
               Draw.text(text_positive, x, y)
            else
               Draw.text(text_negative, x, y)
            end
            Draw.set_color(self.t.base.text_color_light_shadow)
            Draw.text(resist.text, x + 4, y + 1)
            Draw.set_color(self.t.base.text_color_light)
            Draw.text(resist.text, x + 3, y)
         else
            Draw.set_color(self.t.base.text_resist_grade_shadow)
            Draw.text(resist.text, x + 4, y)
            Draw.set_color(entry.color)
            Draw.text(resist.text, x + 3, y)
         end
      end
      x = x + Draw.text_width(entry.short_name) + space
   end
   -- <<<<<<<< shade2/item_func.hsp:796 	return ..
end

function ResistanceLayout:update(dt)
end

return ResistanceLayout
