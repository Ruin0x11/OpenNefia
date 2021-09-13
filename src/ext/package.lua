package.require = require
if package.searchpath == nil then
    function package.searchpath(name, path, sep, rep)
        sep = (sep or "."):gsub("(%p)", "%%%1")
        rep = (rep or package.config:sub(1, 1)):gsub("(%%)", "%%%1")
        local pname = name:gsub(sep, rep):gsub("(%%)", "%%%1")
        local msg = {}
        for subpath in path:gmatch("[^;]+") do
            local fpath = subpath:gsub("%?", pname)
            local f = io.open(fpath, "r")
            if f then
                f:close()
                return fpath
            end
            msg[#msg+1] = "\n\tno file '" .. fpath .. "'"
        end
        return nil, table.concat(msg)
    end
end
