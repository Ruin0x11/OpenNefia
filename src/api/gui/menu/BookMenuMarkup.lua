local BookMenuMarkup = {}

local function parse_color(hex)
   hex = hex:gsub("#","")
   return {
      tonumber("0x"..hex:sub(1,2)),
      tonumber("0x"..hex:sub(3,4)),
      tonumber("0x"..hex:sub(5,6))
   }
end

local function parse_params(line)
   local params = {}

   while string.sub(line, 1, 1) == "<" do
      if string.sub(line, 2, 2) == "<" then
         line = string.sub(line, 2)
         break
      end
      local part = string.sub(line, 1, string.find(line, ">"))
      local stop = string.find(line, ">")
      if stop == nil then
         error(("Could not find closing '>' in markup: %s"):format(line))
      end
      stop = stop + 1
      line = string.sub(line, stop)
      part = string.sub(part, 2, string.len(part) - 1)
      local key, value = table.unpack(string.split(part, "="))
      if key == "size" then
         local parsed = tonumber(value)
         if type(parsed) ~= "number" then
            error(("invalid value for key '%s' (%s)"):format(key, value))
         end
         params.size = parsed
      elseif key == "style" then
         params.style = value
      elseif key == "color" then
         local parsed = parse_color(value)
         if type(parsed[1]) ~= "number"
            or type(parsed[2]) ~= "number"
            or type(parsed[3]) ~= "number"
         then
            error(("invalid value for key '%s' (%s)"):format(key, value))
         end
         params.color = parse_color(value)
      else
         error(string.format("unknown key '%s' (%s)", tostring(key), part))
      end
   end

   return line, params
end

function BookMenuMarkup.parse(text, elona_compat)
   local lines = {}
   local i = 0
   for line in string.lines(text) do
      local params
      line, params = parse_params(line)
      local font = {}
      font.size = params.size or 12 -- 12 + sizefix - en * 2
      font.style = params.style or nil
      local color = params.color or {0, 0, 0}
      if elona_compat then
         if i == 0 then
            font = { size = 12, style = "bold" }
         elseif i == 1 then
            font = { size = 10 }
         end
      end
      i = i + 1
      lines[#lines+1] = { font = font, color = color, line = line }
   end
   return lines
end

return BookMenuMarkup
