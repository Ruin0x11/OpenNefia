local data = require("internal.data")
local CodeGenerator = require("api.CodeGenerator")

data:add {
   _type = "base.theme",
   _id = "default",

   overrides = {}
}

data:add_type {
   name = "theme_transform",

   fields = {
      {
         name = "applies_to",
         type = "string",
         template = true
      },
      {
         name = "transform",
         type = "function",
         template = true,
         default = CodeGenerator.gen_literal [[
function(old, new)
   return table.merge(old, {})
end
]]
      }
   }
}

data:add {
   _type = "base.theme_transform",
   _id = "chip",

   applies_to = "base.chip",
   transform = function(old, new)
      local fields = {
         image = new.image,
         width = new.width,
         height = new.height,
         tall = new.tall,
         key_color = new.key_color
      }
      if fields.tall == nil then
         fields.tall = old.tall
      end
      return table.merge(old, fields)
   end
}

data:add {
   _type = "base.theme_transform",
   _id = "music",

   applies_to = "base.music",
   transform = function(old, new)
      local fields = {
         file = new.file
      }
      old.volume = new.volume
      return table.merge(old, fields)
   end
}

data:add {
   _type = "base.theme_transform",
   _id = "sound",

   applies_to = "base.sound",
   transform = function(old, new)
      local fields = {
         file = new.file
      }
      old.volume = new.volume
      return table.merge(old, fields)
   end
}

data:add {
   _type = "base.theme_transform",
   _id = "map_tile",

   applies_to = "base.map_tile",
   transform = function(old, new)
      local fields = {
         image = new.image
      }
      return table.merge(old, fields)
   end
}

data:add {
   _type = "base.theme_transform",
   _id = "portrait",

   applies_to = "base.portrait",
   transform = function(old, new)
      local fields = {
         image = new.image
      }
      return table.merge(old, fields)
   end
}

data:add {
   _type = "base.theme_transform",
   _id = "pcc_part",

   applies_to = "base.pcc_part",
   transform = function(old, new)
      local fields = {
         image = new.image
      }
      old.key_color = new.key_color
      return table.merge(old, fields)
   end
}

data:add {
   _type = "base.theme_transform",
   _id = "asset",

   applies_to = "base.asset",
   transform = function(old, new)
      local fields = {
         -- TODO: maybe use only "image" and detect type based on x/y/width/height
         -- parameter presence, like all other asset types
         image = new.image,
         source = new.source,

         x = new.x,
         y = new.y,
         width = new.width,
         height = new.height,
         count_x = new.count_x,
         count_y = new.count_y,
         key_color = new.key_color,

         -- XXX: probably a bad idea to mod this, given the pervasive amount of
         -- fixed offsets used when rendering. The better option would to be code
         -- entirely new GUIs instead.
         --
         -- regions = new.regions
      }
      return table.merge(old, fields)
   end
}
