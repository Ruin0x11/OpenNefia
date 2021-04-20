local TalkTxtEntryDecoder = {}
local CodeGenerator = require("api.CodeGenerator")

local function split_ctalk(ctalk)
   local s = {}
   local cur = {kind = "text", text = ""}
   local go = false
   for c in string.chars(ctalk) do
      if go then
         if c == "}" then
            go = false

            local name, args = string.match(cur.text, "(.+)%((.+)%)")
            if name then
               args = string.split(args, ",")
               for i, s in ipairs(args) do
                  args[i] = string.trim(s)
               end
               cur.name = name
               cur.args = args
            end

            s[#s+1] = cur
            cur = {kind = "text", text = ""}
         else
            cur.text = cur.text .. c
         end
      else
         if c == "{" then
            s[#s+1] = cur
            cur = {kind = "ctalk", text = ""}
            go = true
         else
            cur.text = cur.text .. c
         end
      end
   end

   s[#s+1] = cur

   return s
end

local function count_args(parsed)
   local args = {}
   for _, v in ipairs(parsed) do
      if v.kind == "ctalk" then
         v.args = v.args or { v.text }
         for _, arg in ipairs(v.args) do
            local num = string.match(arg, "^_(%d+)")
            if num then
               for _ = 1, (num-#args) do
                  args[#args+1] = "_" .. tostring(#args+1)
               end
            end
         end
      end
   end
   return args
end

local lookup = {
   -- ["ある"] = "aru(npc)",
   -- ["う"] = "u(npc)",
   -- ["か"] = "ka(npc)",
   -- ["が"] = "ga(npc)",
   -- ["かな"] = "kana(npc)",
   -- ["くれ"] = "kure(npc)",
   -- ["た"] = "ta(npc)",
   -- ["だ"] = "da(npc)",
   -- ["だな"] = "dana(npc)",
   -- ["だろ"] = "daro(npc)",
   -- ["たのむ"] = "tanomu(npc)",
   -- ["のだ"] = "noda(npc)",
   -- ["よ"] = "yo(npc)",
   -- ["な"] = "na(npc)",
   -- ["る"] = "ru(npc)",

   -- ["player"] = "player.name",
   -- ["aka"] = "player.title",
   -- ["npc"] = "npc.name",
   -- ["sex"] = "params.gender",
   -- ["me"] = "ore(npc)",
   -- ["you"] = "kimi(npc)",
   -- ["objective"] = "params.objective",
   -- ["reward"] = "params.reward",
   -- ["ref"] = "params.ref",
   -- ["map"] = "params.map",
   -- ["client"] = "params.__CLIENT_NAME__",

   ["player"] = "env.player()",
   ["aka"] = "env.aka()",
   ["nptc"] = "env.name(t)",
   ["npcc"] = "env.name(t)",
}

function TalkTxtEntryDecoder.decode(str)
   local parsed = split_ctalk(str)

   local res
   if #parsed == 1 then
      assert(parsed[1].kind == "text")
      res = parsed[1].text
   else
      res = "function("
      -- local args = count_args(parsed)
      local args = { "t", "env", "args", "chara" }
      for i, arg in ipairs(args) do
         if i == #args then
            res = res .. arg
         else
            res = res .. arg .. ", "
         end
      end
      res = res .. ")\n  return (\""
      for _, v in ipairs(parsed) do
         if v.kind == "text" then
            res = res .. v.text:gsub('"', '\\"')
         else
            res = res .. "%s"
         end
      end
      res = res .. "\")\n  :format("

      local added = false
      for i, v in ipairs(parsed) do
         if v.kind == "ctalk" then
            if added then
               res = res .. ", "
            end
            local func = lookup[v.text]
            assert(func, v.text)
            res = res .. func
            added = true
         end
      end

      res = res .. ")\nend"

      res = CodeGenerator.gen_literal(res)
   end

   return res
end

return TalkTxtEntryDecoder
