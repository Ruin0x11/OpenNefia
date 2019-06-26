local Chara = require("api.Chara")
local I18N = require("api.I18N")
local Input = require("api.Input")
local DialogMenu = require("mod.elona_sys.dialog.DialogMenu")

local Dialog = {}

local function dialog_error(talk, msg, err)
   if err ~= nil then
      error("Dialog error in " .. talk.id .. ": " .. msg .. ":\n    " .. err)
   else
      error("Dialog error in " .. talk.id .. ": " .. msg)
   end
end

--- Convert a response localization key to the full localization key.
--- It can be one of the following.
---  * __MORE__                - "(More)"
---  * __BYE__                 - "Bye bye."
---  * key.fragment            - core.locale.dialog.root.key.fragment
---  * core.locale.dialog.key  - core.locale.dialog.key
---  * {"key.fragment", args = {"arg1", "arg2"}}  - (localized with arguments)
local function resolve_response(obj, talk)
   local args = {}
   local get
   local key

   if obj == nil then
      key = "__MORE__"
   elseif type(obj) == "table" then
      key = obj[1]
      args = obj.args
   else
      key = obj
   end

   if key == "__BYE__" then
      return "core.locale.ui.bye", args
   elseif key == "__MORE__" then
      return "core.locale.ui.more", args
   end

   get = talk.dialog.root .. "." .. key

   if I18N.get_optional(get) == nil then
      get = key
   end
   return get, args
end

local function speaker_name(chara)
   return chara:calc("name")
end

--- Opens a single talk window choice.
-- @tparam table talk Dialog control data.
-- @tparam string text String to display (not locale key)
-- @tparam table choices List of choices in format {"response_id", "core.locale.key"}
-- @tparam[opt] int default_choice index of default choice if window is canceled
-- @treturn string Response ID of the choice selected.
local function query(talk, text, choices, default_choice)
   local show_impress = true
   if talk.speaker.quality == "Special" and not talk.speaker:is_ally() then
      show_impress = false
   end

   if #choices == 1 then
      default_choice = 1
   end

   local the_choices = {}
   for i, choice in ipairs(choices) do
      local response, args = resolve_response(choice[2], talk)
      the_choices[i] = I18N.get(response, table.unpack(args))
      if default_choice == nil and choice[1] == "__END__" then
         default_choice = i
      end
   end

   local menu
   if show_impress then
      menu = DialogMenu:new(text,
                            the_choices,
                            speaker_name(talk.speaker),
                            talk.speaker:calc("portrait"),
                            talk.speaker:copy_image(),
                            default_choice,
                            talk.speaker.impression,
                            talk.speaker.interest)
   else
      menu = DialogMenu:new(text,
                            the_choices,
                            speaker_name(talk.speaker),
                            talk.speaker:calc("portrait"),
                            talk.speaker:copy_image(),
                            default_choice)
   end

   local result = menu:query()

   return choices[result][1]
end

--- Initializes the dialog control data.
-- @tparam IChara speaker Character who is speaking.
-- @tparam core.dialog dialog Dialog data.
-- @tparam string id Dialog data ID.
-- @treturn table Dialog control data.
local function make_talk(speaker, dialog, id)
   return {
      id = id,
      speaker = speaker,
      dialog = dialog,
      -- say = function(self, key, response)
      --    local resolved, args = resolve_response(key, self)
      --    query(self, I18N.get(resolved, table.unpack(args)), {{"dummy", resolve_response(response, self)}})
      -- end
   }
end

--- Jumps to a node in a dialog outside the current dialog.
-- @tparam table talk Current dialog control data.
-- @tparam string new_dialog_id New dialog ID to change to.
-- @tparam string node Node inside the dialog to jump to.
-- @treturn table Current node data in {choice, opts} format
local function jump_to_dialog(talk, new_dialog_id, node)
   local dialog = data["elona_sys.dialog"][new_dialog_id]
   if dialog == nil then
      error("No such dialog " .. new_dialog_id)
   end
   talk.dialog = dialog
   return {choice = node, opts = {}}
end

local function step_dialog(dialog, node_data, talk, state)
   if node_data.choice == "__END__" then
      return nil
   end
   -- TODO remove
   -- if node_data.choice == "__IGNORED__" then
   --    return jump_to_dialog(talk, "elona_sys.ignores_you", "__start")
   -- end
   if node_data.choice == nil then
      return nil
   end

   local node = dialog.nodes[node_data.choice]
   if node == nil then
      dialog_error(talk, "No node with ID " .. node_data.choice .. " found")
   end

   local next_node = nil

   if type(node) == "function" then
      -- Run function. It is expected to return either a string or
      -- table containing the next node to jump to.
      local ok, result = pcall(node, talk, state, node_data.opts)
      if ok then
         if type(result) == "string" then
            next_node = {choice = result, opts = {}}
         elseif type(result) == "table" then
            next_node = result
         end
      else
         dialog_error(talk, "Error running dialog inline function", result)
      end
   elseif type(node) == "table" then
      -- Parse table structure for dialog data.
      -- text: array of text entries, displayed in order.
      --     text[1][1]: locale fragment or key, or function
      --     text[1].args: function returning table of arguments to localization
      --     text[1].speaker: core.chara ID of speaker to display, if they are in this map
      --     text[1].choice: locale key of default choice. Defaults to "more" or "bye".
      -- choices: array of choices, displayed at last text entry. If nil, end the dialog at the last one.
      --     choices[1][1]: Node ID to jump to
      --     choices[1][2]: locale key of choice. Defaults to "more" or "bye".
      -- on_finish: Function run when this node is exited.
      -- default_choice: If provided, dialog option is cancellable with this response as the default.
      local texts = node.text

      for i, text in ipairs(texts) do
         if texts[i+1] == nil then
            if type(text) ~= "table" then
               dialog_error(talk, "Last text entry must be table (got: " .. type(text) .. ")")
            end
         end

         if type(text) == "table" then
            -- Obtain arguments to I18N.get().
            local args = {}
            if text.args then
               local ok
               ok, args = pcall(text.args, talk, state, node_data.opts)
               if not ok then
                  dialog_error(talk, "Error getting I18N arguments", args)
               end
            end

            -- Get localization key of default response ("more", "bye").
            local choice_key = text.choice
            if choice_key == nil then
               if texts[i+1] == nil then
                  choice_key = "__BYE__"
               else
                  choice_key = "__MORE__"
               end
            end

            -- Change speaking character.
            if text.speaker ~= nil then
               local found = Chara.find(text.speaker, "Others")
               if found == nil then
                  found = Chara.find(text.speaker, "Allies")
               end
               if found ~= nil then
                  talk.speaker = found
               end
            end

            -- Build choices. Default to ending the dialog.
            local choices = node.choices
            if choices == nil then
               choices = {{"__END__", choice_key}}
            elseif type(choices) == "function" then
               local ok
               ok, choices = pcall(choices, talk, state, node_data.opts)
               if not ok then
                  dialog_error(talk, "Error running choices function", choices)
               end
            end

            -- Set the default choice to select if window is
            -- cancelled. If nil, prevent cancellation.
            local default_choice = nil
            if node.default_choice ~= nil then
               for j, choice in ipairs(choices) do
                  if choice[1] == node.default_choice then
                     default_choice = j - 1
                  end
               end
               if default_choice == nil then
                  dialog_error(talk, "Could not find default choice \"" .. node.default_choice .. "\"")
               end
            end

            -- Resolve localized text.
            local key = talk.dialog.root .. "." .. text[1]
            local tex = I18N.get_optional(key, table.unpack(args))
            if tex == nil then
               tex = I18N.get(text[1], table.unpack(args))
            end

            -- Prompt for choice if on the last text entry, otherwise
            -- show single choice.
            if texts[i+1] == nil then
               local choice = query(talk, tex, choices, default_choice)
               next_node = {choice = choice, opts = {}}
            else
               query(talk, tex, {{"dummy", choice_key}})
            end
         elseif type(text) == "function" then
            -- Call an arbitrary function. The result is ignored.
            local ok, err = pcall(text, talk, state, node_data.opts)
            if not ok then
               dialog_error(talk, "Error running text function", err)
            end
         else
            dialog_error(talk, "Cannot parse text entry, must be function or table (got: " .. type(text) .. ")")
         end
      end

      -- Run on_finish callback.
      if node.on_finish then
         local ok, result = pcall(node.on_finish, talk, state, node_data.opts)
         if not ok then
            dialog_error(talk, "Error running on_finish function", result)
         end
      end
   else
      dialog_error(talk, "Invalid node, must be string or table (got: " .. type(node) .. ")")
   end

   return next_node
end

function Dialog.start(chara, dialog_id)
   if not Chara.is_alive(chara) then
      return
   end

   dialog_id = dialog_id or chara:calc("dialog") or "elona_sys.ignores_you"

   local dialog = data["elona_sys.dialog"]:ensure(dialog_id)

   local talk = make_talk(chara, dialog, dialog_id)
   local state = {}
   local next_node = {choice = "__start", opts = {}}

   while next_node ~= nil do
      next_node = step_dialog(talk.dialog, next_node, talk, state)
   end
end

return Dialog
