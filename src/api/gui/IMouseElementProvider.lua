local IMouseElementProvider = class.interface("IMouseElementProvider", {
                          get_mouse_elements = "function",
                          iter_mouse_elements = "function"
                      })

function IMouseElementProvider:iter_mouse_elements(recursive)
   return fun.iter(self:get_mouse_elements(recursive))
end

return IMouseElementProvider
