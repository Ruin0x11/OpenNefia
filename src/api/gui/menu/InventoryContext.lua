local InputHandler = require("api.gui.InputHandler")

local InventoryContext = class("InventoryContext")

function InventoryContext:init(proto, params)
   self.proto = proto
   self.input = InputHandler:new()

   self.sources = self.proto.sources
   self.query_amount = self.proto.query_amount
   self.show_money = self.proto.show_money
   self.shortcuts = self.proto.shortcuts
   self.stack = {}

   self.chara = params.chara
   self.target = params.target or nil
   self.container = params.container or nil
   self.map = params.map or nil

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

function InventoryContext:sort(item)
   if self.proto.sort then
      return self.proto.sort(self, item)
   end

   return true
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

function InventoryContext:on_select(item)
   if self.proto.on_select then
      return self.proto.on_select(self, item)
   end

   return "player_turn_query"
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
