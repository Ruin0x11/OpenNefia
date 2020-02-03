local config = {}

config["base.keybinds"] = {}
config["base.play_music"] = false
config["base.anim_wait"] = 80 * 0.5
config["base.screen_sync"] = 6
config["base.positional_audio"] = false

-- Don't overwrite the current config.
config.on_hotload = function(old, new)
   for k, v in pairs(new) do
      if old[k] == nil then
         old[k] = v
      end
   end
end

return config
