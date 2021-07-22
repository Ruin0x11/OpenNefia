local Enum = require("api.Enum")

local _UiMouseFit = {}

_UiMouseFit.none = {}
function _UiMouseFit.none.apply(child, parent)
   return math.min(child:get_minimum_width(), parent.width),
      math.min(child:get_minimum_height(), parent.height)
end

return Enum.new("UiMouseFit", _UiMouseFit)
