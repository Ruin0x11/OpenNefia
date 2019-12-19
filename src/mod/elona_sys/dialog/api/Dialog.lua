--- @module Dialog

local Chara = require("api.Chara")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Input = require("api.Input")
local DialogMenu = require("mod.elona_sys.dialog.api.DialogMenu")
local Env = require("api.Env")
local Log = require("api.Log")
local ansicolors = require("thirdparty.ansicolors")

local Dialog = {}

local function dialog_error(talk, msg, err)
   if err ~= nil then
      error("Dialog error in " .. talk.id .. ": " .. msg .. ":\n    " .. err)
   else
      error("Dialog error in " .. talk.id .. ": " .. msg)
   end
end

--- Converts a root and key suffix to a full i18n key.
--- "talk.root" + "key"   = "talk.root.key"
--- "" + "talk.other.key" = "talk.other.key"
local function resolve_translated_text(root, key, args)
   local full_key = key

   if root and root ~= "" then
      full_key = root .. "." .. key
   end

   return I18N.get_optional(full_key, table.unpack(args or {})) or key
end

--- Convert a response localization key to the full localization key.
--- obj can be one of the following.
---  * __MORE__                - "(More)"
---  * __BYE__                 - "Bye bye."
---  * key.fragment            - dialog.root.key.fragment
---  * dialog.key              - dialog.key
---  * {"key.fragment", args = {"arg1", "arg2"}}  - (localized with arguments)
local function resolve_response(obj, args, choices_root)
   local args = args or {}
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
      choices_root = ""
      key = "ui.bye"
   elseif key == "__MORE__" then
      choices_root = ""
      key = "ui.more"
   end

   return resolve_translated_text(choices_root, key, args)
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
local function query(talk, text, choices, default_choice, choices_root)
   local show_impress = true
   if talk.speaker.quality == 6 -- special
      and not talk.speaker:is_ally()
   then
      show_impress = false
   end

   if #choices == 1 then
      default_choice = 1
   end

   local the_choices = {}
   for i, choice in ipairs(choices) do
      the_choices[i] =  resolve_response(choice[2], choices_root)
      if default_choice == nil and choice[1] == "__END__" then
         default_choice = i
      end
   end

   if Env.is_headless() and Log.has_level("info") then
      local mes = ("<dialog> %%{blue}[%s] %%{green}%s %%{yellow}%s%%{reset}")
         :format(talk.dialog._id,
                 talk.speaker and talk.speaker.name or "<none>",
                 text)
      print(ansicolors(mes))
      for i, choice in ipairs(choices) do
         mes = ("  %d) %%{green}%s %%{blue}(%s)%%{reset}"):format(i, choice[2], choice[1])
         print((ansicolors(mes)))
      end
   end

   local menu
   if show_impress then
      menu = DialogMenu:new(text,
                            the_choices,
                            speaker_name(talk.speaker),
                            talk.speaker:copy_portrait(),
                            talk.speaker:copy_image(),
                            default_choice,
                            talk.speaker.impression,
                            talk.speaker.interest)
   else
      menu = DialogMenu:new(text,
                            the_choices,
                            speaker_name(talk.speaker),
                            talk.speaker:copy_portrait(),
                            talk.speaker:copy_image(),
                            default_choice)
   end

   local result = menu:query()

   if Env.is_headless() and Log.has_level("info") then
      local mes = ("<dialog> %%{yellow}>> %s %%{blue}(%s)%%{reset}")
         :format(choices[result][2],
                 choices[result][1])
      print(ansicolors(mes))
   end

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

-- Looks for a dialog and node given an ID like
-- "mod.dialog_id:node_id" or "mod.dialog_id" (implicitly using
-- __start as the first node)
local function find_dialog(cur, id)
   local arr = string.split(id, ":")

   local dialog_id, node_id

   if #arr == 1 then
      if string.find(id, "%.") then
         -- "mod.dialog_id"
         dialog_id = arr[1]
         node_id = "__start"
      else
         -- "node_id"
         dialog_id = cur._id
         node_id = arr[1]
      end
   elseif #arr == 2 then
      -- "mod.dialog_id:node_id"
      dialog_id = arr[1]
      node_id = arr[2]
   else
      return nil, nil
   end

   local dialog_data = data["elona_sys.dialog"][dialog_id]
   if dialog_data == nil then
      return nil, nil
   end

   local node_data = dialog_data.nodes[node_id]
   if node_data == nil then
      return nil, nil
   end

   return dialog_data, node_data
end

local get_choices
get_choices = function(node, talk, state, node_data, choice_key, found)
   found = found or {}
   local choices = node.choices
   if choices == nil then
      choices = {{"__END__", choice_key}}
   elseif type(choices) == "function" then
      local ok
      ok, choices = pcall(choices, talk, state, node_data.opts)
      if not ok then
         dialog_error(talk, "Error running choices function", choices)
      end
   elseif type(choices) == "string" then
      local new_dialog, new_node = find_dialog(talk.dialog, choices)
      if new_dialog then
         if found[choices] then
            dialog_error(talk, "Infinite recursion when retrieving external node for dialog choices", choices)
         end
         found[choices] = true
         -- root = new_dialog.root
         choices = get_choices(new_node, talk, state, node_data, choice_key, found) -- recurse
      else
         dialog_error(talk, "Cannot find external node for dialog choices", choices)
      end
   end

   return choices
end

local function step_dialog(node_data, talk, state)
   if node_data.choice == "__END__" then
      return nil
   end
   if node_data.choice == nil then
      return nil
   end

   local node = talk.dialog.nodes[node_data.choice]
   if node == nil then
      -- try to jump to another dialog, like "mod.dialog_id:node_name"
      local new_dialog, new_node = find_dialog(talk.dialog, node_data.choice)

      if new_dialog and new_node then
         talk.dialog = new_dialog
         node = new_node
      else
         dialog_error(talk, "No node with ID " .. node_data.choice .. " found")
      end
   end

   local next_node = nil

   if type(node) == "function" then
      -- Run function. It is expected to return either a string or
      -- table containing the next node to jump to.
      local ok, result = xpcall(node, debug.traceback, talk, state, node_data.opts)
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

      -- text ({string|function|table...}): array of text entries, displayed in order. Can be strings, functions or
      --                                   tables.
      --     text[1][1] (string|function): locale fragment or key, or function
      --     text[1].args (function): function returning table of arguments to localization
      --     text[1].speaker (string): core.chara ID of speaker to display, if they are in this map
      --     text[1].choice (string): locale key of default choice. Defaults to "more" or "bye".
      -- choices (table): array of choices, displayed at last text entry. If nil, end the dialog at the last one.
      --     choices[1][1] (string): Node ID to jump to
      --     choices[1][2] (string): locale key of choice. Defaults to "more" or "bye".
      -- on_finish: Function run when this node is exited.
      -- default_choice: If provided, dialog option is cancellable with this response as the default.
      -- inherit (string[opt]): node to inherit all values from. Must resolve to a table.

      -- Find another dialog node and merge its values into a copy of
      -- this one.
      if node.inherit then
         local dialog, inherit_node = find_dialog(talk.dialog, node.inherit)
         if dialog and inherit_node then
            print("inherit")
            if type(inherit_node) ~= "table" then
               dialog_error(talk, "Inherit node '%s' must be a table, got '%s'", node.inherit, type(inherit_node))
            end

            node = table.deepcopy(node)
            table.merge_missing(node, inherit_node)
         else
            error(("cannot find node with ID %s"):format(node.inherit))
         end
      end

      local texts = node.text
      if type(texts) == "function" then
         local ok
         ok, texts = pcall(texts, talk, state, node_data.opts)
         if not ok then
            dialog_error(talk, "Error getting dialog text", texts)
         end

         if type(texts) ~= "table" then
            dialog_error(talk, "`text` function must return a table of strings")
         end
      end

      for i, text in ipairs(texts) do
         if texts[i+1] == nil then
            if type(text) ~= "table" then
               dialog_error(talk, "Last text entry must be table (got: " .. type(text) .. ")")
            end
         end

         if type(text) == "string" then
            text = {text}
         end

         if type(text) == "table" then
            -- Obtain arguments to I18N.get().
            -- Assume the speaker is the first argument unless otherwise noted.
            local args = {talk.speaker}
            if text.args then
               local ok
               ok, args = pcall(text.args, talk, state, node_data.opts)
               if not ok then
                  dialog_error(talk, "Error getting I18N arguments", args)
               end
            end

            -- Change speaking character.
            if text.speaker ~= nil then
               local found = Chara.find(text.speaker, "others")
               if found == nil then
                  found = Chara.find(text.speaker, "allies")
               end
               if found ~= nil then
                  talk.speaker = found
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

            -- Build choices. Default to ending the dialog.
            local choices = get_choices(node, talk, state, node_data, choice_key)

            -- Set the default choice to select if window is
            -- cancelled. If nil, prevent cancellation.
            local default_choice = nil
            if node.default_choice ~= nil then
               for j, choice in ipairs(choices) do
                  if choice[1] == node.default_choice then
                     default_choice = j
                  end
               end
               if default_choice == nil then
                  dialog_error(talk, "Could not find default choice \"" .. node.default_choice .. "\"")
               end
            end

            -- Resolve localized text.
            local tex = resolve_translated_text(talk.dialog.root, text[1], args)

            -- Prompt for choice if on the last text entry or
            -- `next_node` is non-nil, otherwise show single choice.
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
            dialog_error(talk, "Cannot parse text entry, must be string, function or table (got: " .. type(text) .. ")")
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

   dialog_id = dialog_id or "elona_sys.ignores_you"

   local start_node = "__start"
   local colon_pos = string.find(dialog_id, ":")
   if colon_pos then
      start_node = dialog_id:sub(colon_pos+1)
      dialog_id = dialog_id:sub(1, colon_pos-1)
   end

   local dialog = data["elona_sys.dialog"]:ensure(dialog_id)

   local talk = make_talk(chara, dialog, dialog_id)
   local state = {}
   local next_node = {choice = start_node, opts = {}}

   Gui.play_sound("base.chat")

   while next_node ~= nil do
      next_node = step_dialog(next_node, talk, state)
   end
end

function Dialog.talk_to_chara(chara)
   local dialog_id = chara:calc("dialog") or "elona.default"
   Dialog.start(chara, dialog_id)
end

--- Adds a dialog choice to a list of possible choices if it doesn't
--- already exist in the list.
---
--- @tparam string choice_id
--- @tparam string choice_text
--- @tparam {{string,string}...} choices
--- @tparam[opt] bool also_text If true, also match by the localized choice text
function Dialog.add_choice(choice_id, choice_text, choices, also_text)
   for _, exist in ipairs(choices) do
      if exist[1] == choice_id -- choice ID
         and (also_text and exist[2] == choice_id) -- localized text
      then
         return
      end
   end

   table.insert(choices, {choice_id, choice_text})
end

return Dialog
