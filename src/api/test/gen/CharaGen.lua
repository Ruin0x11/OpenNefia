local Charagen = require("mod.tools.api.Charagen")
local IGenerator = require("api.test.gen.IGenerator")
local ObjectGen = require("api.test.gen.ObjectGen")

local CharaGen = class.class("CharaGen", IGenerator)

function CharaGen:init(props)
   props = props or {}
   props.ownerless = true
   local cb = function(size)
      return Charagen.create(nil, nil, props)
   end
   self.inner = ObjectGen:new(cb)
end

CharaGen:delegate("inner", IGenerator)

return CharaGen
