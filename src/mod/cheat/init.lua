local Event = require("api.Event")
local Env = require("api.Env")

local function enable_themes()
   local themes = {}

   if Env.is_mod_loaded("beautify") then
      themes[#themes+1] = "beautify.beautify"
   end

   if Env.is_mod_loaded("scrounged_theme") then
      themes[#themes+1] = "scrounged_theme.scrounged"
   end

   if Env.is_mod_loaded("elonapack") then
      themes[#themes+1] = "elonapack.elonapack"
   end

   if Env.is_mod_loaded("ceri_items") then
      themes[#themes+1] = "ceri_items.ceri_items"
   end

   if Env.is_mod_loaded("ffhp_matome") then
      themes[#themes+1] = "ffhp_matome.ffhp_matome"
   end

   config.base.themes = themes
end
Event.register("base.before_engine_init", "Enable non-redistributable themes if available", enable_themes)

require("mod.cheat.advice.init")
require("mod.cheat.data.init")
