local schema = require ("thirdparty.schema")

-- base.chara
local chara = {
   schema = schema.Record {
      name = schema.String,
      image = schema.Number,
      max_hp = schema.Number,
   },
   index_on = "name"
}

-- base.ui_theme
local ui_theme = {
   schema = schema.Record {
      target = schema.String,
   },
}

-- base.asset
local asset = {
   schema = schema.Record {
      target = schema.String,
   }
}

return {
   ["base.chara"] = chara,
   ["base.ui_theme"] = ui_theme,
   ["base.asset"] = asset,
}
