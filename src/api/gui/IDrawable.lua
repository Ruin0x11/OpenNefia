local IDrawable =  class.interface("IDrawable",
                                   { update = "function", draw = "function" })

function IDrawable:is_drawable_in_ui()
   return true
end

return IDrawable
