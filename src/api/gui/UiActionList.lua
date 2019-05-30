local Draw = require("api.Draw")
local IUiList = require("api.gui.IUiList")
local UiList = require("api.gui.UiList")

local UiActionList = class("UiActionList", IUiList)

UiActionList:delegate("inner", {
                         "x",
                         "y",
                         "item_offset_x",
                         "item_offset_y",
                         "item_height",
                         "items",
                         "changed",
                         "selected",
                         "selected_item",
                         "select",
                         "select_next",
                         "select_previous",
                         "can_select",
                         "draw_item",
                         "draw_item_text",
                         "draw_select_key", -- NOTE bug
                         "relayout",
                         "update",
                         "focus",
                         "set_data"
})

function UiActionList:init(x, y, items, item_height, item_offset_x, item_offset_y)
   self.inner = UiList:new(x, y, items, item_height, item_offset_x, item_offset_y)
end

function UiActionList:get_item_text(item)
   return item.text
end

UiActionList.bind = UiList.bind
UiActionList.draw = UiList.draw

function UiActionList:choose(i)
   self.inner:choose(i)
   if self:selected_item().on_choose then
      self:selected_item().on_choose()
   end
end

return UiActionList
