if jit == nil then
   bit = require("thirdparty.bit.numberlua")
end

if jit then
   bit.extract = function(n, f, w)
      w = w or 1
      local mask = bit.lshift(4294967295, 1)
      mask = bit.lshift(mask, w - 1)
      mask = bit.bnot(mask)
      local r = bit.rshift(n, f)
      r = bit.band(r, mask)
      return r
   end
end
