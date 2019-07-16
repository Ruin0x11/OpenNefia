Tools = require("mod.tools.api.Tools")
Compat = require("mod.elona_sys.api.Compat")
Combat = require("mod.elona.api.Combat")

local modify_table_index = {}

function modify_table_index:new(field, cb)
   return setmetatable({field = field, cb = cb}, {__index = modify_table_index})
end
function modify_table_index:applies_to(node)
   if node:type() ~= "constructor_expression" then
      return false
   end

   local target = node:index(self.field)
   if not target or target:type() ~= "expression" or not target:to_value() then
      return false
   end

   return true
end
function modify_table_index:execute(node)
   local id = node:index(self.field):to_value()
   local val = self.cb(id)
   local Codegen = require("yalf.parser.codegen")
   local expr = Codegen.gen_expression_from_value(val)
   node:modify_index(self.field, expr)
end

local function file2src(file)
   local inf = io.open(file, 'r')
   if not inf then
      print("Failed to open `"..file.."` for reading")
      return
   end
   local s = inf:read('*all')
   inf:close()

   return s
end

local function src2cst(code)
   local cst_parser = require("yalf.parser.cst_parser")
   local a, new = cst_parser(code):parse()
   assert(a, new)

   return new
end

local function file2cst(file)
   return src2cst(file2src(file))
end

local function refactor_file(file, refs)
   local cst = file
   if type(file) == "string" then
      cst = file2cst(file)
   end

   local visitors = require("yalf.visitor.visitors")
   visitors.visitor.visit(visitors.refactoring_visitor:new(refs), cst)

   return cst
end

function cst2file(cst, file)
   assert(file)

   local visitors = require("yalf.visitor.visitors")
   local inf = io.open(file, 'w')
   visitors.visitor.visit(visitors.code_convert_visitor:new(inf), cst)
   inf:close()
end

function refactor_chara_chips()
   local cb = require("mod.elona_sys.api.Compat").convert_122_chara_chip
   return refactor_file("/home/ruin/build/next/src/src/mod/elona/data/chara.lua", { modify_table_index:new("image", cb)})
end
