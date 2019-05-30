require("boot")

local p = require("api.gui.PagedListModel"):new(table.of(function(i) return "hoge"..i end, 200), 20)


_p(p.items)

for i=1,300 do
end

