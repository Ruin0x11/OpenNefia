local IUiMousePadding = class.interface("IUiMousePadding", {
                                           get_padding = "function"
})

function IUiMousePadding:apply(x, y, width, height)
   local t, l, r, b = self:get_padding()
   return x + l, y + t, width - (l + r), height - (t + b)
end

return IUiMousePadding
