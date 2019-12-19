if _IS_LOVEJS then
   local coxpcall = require("thirdparty.coxpcall")
   xpcall = coxpcall.xpcall
   pcall = coxpcall.pcall
end
