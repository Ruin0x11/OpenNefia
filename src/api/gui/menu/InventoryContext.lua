local Item = require("api.Item")
local InputHandler = require("api.gui.InputHandler")

local InventoryContext = class("InventoryContext")

local function source_chara(ctxt)
   return ctxt.chara:iter_items()
end

local function source_ground(ctxt)
   return Item.at(ctxt.ground_x, ctxt.ground_y)
end

local function source_equipment(ctxt)
   return ctxt.chara:iter_equipment()
end

local sources = {
   {
      name = "chara",
      getter = source_chara,
      order = 10000
   },
   {
      name = "ground",
      getter = source_ground,
      order = 9000,
      on_get_name = function(self, name, item, menu)
         return name .. " (Ground)"
      end
   },
   {
      name = "equipment",
      getter = source_equipment,
      order = 8000,
      on_get_name = function(self, name, item, menu)
         return name .. " (main hand)"
      end,
      on_draw = function(self, x, y, item, menu)
         menu.t.equipped_icon:draw(x - 12, y + 14)
      end
   },
}

sources = fun.iter(sources):map(function(s) return s.name, s end):to_map()

local function gen_default_sort(user_sort)
   return function(a, b)
      if a.source == b.source then
         return user_sort(a, b)
      end

      return a.source.order < b.source.order
   end
end

function InventoryContext:init(proto, params)
   self.proto = proto
   self.input = InputHandler:new()

   self.sources = {}
   for _, source_name in ipairs(self.proto.sources) do
      local source = sources[source_name]
      if source == nil then
         error("unknown source " .. source_name)
      end
      self.sources[#self.sources+1] = source
   end

   self.query_amount = self.proto.query_amount
   self.show_money = self.proto.show_money
   self.shortcuts = self.proto.shortcuts
   self.stack = {}

   self.chara = params.chara or nil
   self.target = params.target or nil
   self.container = params.container or nil
   self.map = params.map or nil

   self.ground_x = (self.chara and self.chara.x) or 0
   self.ground_y = (self.chara and self.chara.y) or 0

   self.icon = 5

   if self.proto.keybinds then
      self.input:bind_keys(self.proto.keybinds)
   end
end

function InventoryContext:can_select(item)
   if self.proto.can_select then
      return self.proto.can_select(self, item)
   end

   return true
end

function InventoryContext:gen_sort(a, b)
   local f = function() return true end

   if self.proto.sort then
      f = function(a, b) return self.proto.sort(self, a, b) end
   end

   return gen_default_sort(f)
end

function InventoryContext:filter(item)
   if self.proto.filter then
      return self.proto.filter(self, item)
   end

   return true
end

function InventoryContext:after_filter(item)
   if self.proto.filter then
      return self.proto.filter(self, item)
   end

   return true
end

function InventoryContext:on_select(item, rest)
   if self.proto.on_select then
      return self.proto.on_select(self, item, rest)
   end

   return "inventory_continue"
end

function InventoryContext:on_menu_enter()
   if self.proto.on_menu_enter then
      self.proto.on_menu_enter(self, item)
   end
end

function InventoryContext:on_menu_exit()
   if self.proto.on_menu_exit then
      return self.proto.on_menu_exit(self, item)
   end

   return "player_turn_query"
end

return InventoryContext
