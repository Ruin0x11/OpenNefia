local IBBoxTransform = require("mod.plot.api.IBBoxTransform")

local IdentityBBox = class.class("IdentityBBox", IBBoxTransform)

function IdentityBBox:init(bbox)
   self.bbox = bbox
end

function IdentityBBox.new_unit()
   return IdentityBBox:new {
      { 0.0, 1.0 },
      { 0.0, 1.0 }
   }
end

function IdentityBBox:get_bounds()
   return self.bbox
end

function IdentityBBox:invalidate()
end

function IdentityBBox:transform(x, y)
   return x, y
end

return IdentityBBox
