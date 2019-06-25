local Log = require("api.Log")
local InputHandler = require("api.gui.InputHandler")

local InventoryContext = class("InventoryContext")

local function source_chara(ctxt)
   return ctxt.chara:iter_items()
end

local function source_ground(ctxt)
   local Item = require("api.Item")

   local ground_x = ctxt.ground_x or (ctxt.chara and ctxt.chara.x)
   local ground_y = ctxt.ground_y or (ctxt.chara and ctxt.chara.y)

   if type(ground_x) ~= "number" or type(ground_y) ~= "number" then
      Log.warn("Inventory ground position was invalid: %s,%s", tostring(ground_x), tostring(ground_y))
   end

   return Item.at(ground_x, ground_y)
end

local function source_equipment(ctxt)
   return ctxt.chara:iter_equipment()
end

local sources = {
   {
      name = "chara",
      getter = source_chara,
      order = 10000,
      params = {
         chara = "IChara"
      }
   },
   {
      name = "ground",
      getter = source_ground,
      order = 9000,
      on_get_name = function(self, name, item, menu)
         return name .. " (Ground)"
      end,
      params = {
         ground_x = { type = "number", optional = true },
         ground_y = { type = "number", optional = true },
         chara_y  = { type = "IChara", optional = true },
      }
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
      end,
      params = {
         chara = "IChara"
      }
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
   -- self.target = params.target or nil
   -- self.container = params.container or nil
   -- self.map = params.map or nil

   self.icon = self.proto.icon or 1

   if self.proto.keybinds then
      self.input:bind_keys(self.proto.keybinds)
   end

   if self.proto.params then
      for name, required_type in pairs(self.proto.params) do
         local val = params[name]

         local ok = type(val) == required_type

         if not ok then
            ok = type(val) == "table"
               and val.is_a
               and val:is_a(required_type)
         end

         if not ok then
            error(string.format("Inventory context expects parameter %s (%s) to be passed.", name, required_type))
         end

         if self[name] ~= nil then
            error(string.format("Inventory context parameter has a name conflict: %s", name))
         end

         self[name] = val
      end
   end
end

function InventoryContext:can_select(item)
   if self.proto.can_select then
      return self.proto.can_select(self, item)
   end

   return true
end

local function default_sort(a, b)
   return a.item._id > b.item._id
end

function InventoryContext:gen_sort(a, b)
   local f = default_sort

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

function InventoryContext:on_select(item, amount, rest)
   if self.proto.on_select then
      return self.proto.on_select(self, item, amount, rest)
   end

   return "inventory_continue"
end

function InventoryContext:on_menu_enter()
   if self.proto.on_menu_enter then
      self.proto.on_menu_enter(self)
   end
end

function InventoryContext:on_menu_exit()
   if self.proto.on_menu_exit then
      return self.proto.on_menu_exit(self)
   end

   return "player_turn_query"
end

return InventoryContext
