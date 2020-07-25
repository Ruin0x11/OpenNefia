local Itemgen = require("mod.tools.api.Itemgen")
local IGenerator = require("api.test.gen.IGenerator")
local ObjectGen = require("api.test.gen.ObjectGen")

local ItemGen = class.class("ItemGen", IGenerator)

function ItemGen:init(props, ignore)
   props = props or {}
   props.ownerless = true
   local cb = function(size)
      return Itemgen.create(nil, nil, props)
   end
   ignore = ignore or {}
   ignore.amount = true
   self.inner = ObjectGen:new(cb, ignore)
end

ItemGen:delegate("inner", IGenerator)

return ItemGen
