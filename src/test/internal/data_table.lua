local data = require("internal.data")
local Assert = require("api.test.Assert")

function test_data_table__ext()
   data:add {
      _type = "base.data_ext",
      _id = "color",

      fields = {
         {
            name = "color",
            type = "table",
            default = {64, 128, 196}
         }
      }
   }

   data:add {
      _type = "base.chara",
      _id = "ext_colored",

      _ext = {
         "@test@.color"
      }
   }

   data:add {
      _type = "base.chara",
      _id = "ext_colored_param",

      _ext = {
         ["@test@.color"] = {
            color = {196, 128, 64}
         }
      }
   }

   data:add {
      _type = "base.chara",
      _id = "ext_uncolored",
   }

   Assert.same({}, data["base.chara"]["@test@.ext_colored"]._ext["@test@.color"])
   Assert.same({}, data["base.chara"]:ext("@test@.ext_colored", "@test@.color"))
   Assert.same({ color = { 196, 128, 64 }}, data["base.chara"]["@test@.ext_colored_param"]._ext["@test@.color"])
   Assert.same({ color = { 196, 128, 64 }}, data["base.chara"]:ext("@test@.ext_colored_param", "@test@.color"))
   Assert.same({ color = { 64, 128, 196 }}, data["base.chara"]:ext("@test@.ext_uncolored", "@test@.color"))
end

function test_data_table_no_save_fields()
   -- These are only really relevant for object types that get instantiated and
   -- serialized, but it's worth testing the defaults
   local no_save = data["base.music"]._no_save_fields
   Assert.same(table.set { "_ext", "_ordering" }, no_save)

   no_save = data["base.chara"]._no_save_fields
   Assert.same(table.set { "_ext", "_ordering", "events" }, no_save)
end
