--- @module Dialog
local Enum = require("api.Enum")

local Chara = require("api.Chara")
local Event = require("api.Event")
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

local function resolve_translated_text(key, args)
   args = args or {}

   return I18N.get_optional(key, table.unpack(args)) or key
end

--- Convert a response localization key to the full localization key.
--- obj can be one of the following.
---  * dialog.key              - dialog.key
---  * {"key.fragment", args = {"arg1", "arg2"}}  - (localized with arguments)
local function resolve_response(obj, args)
   args = args or {}
   local key

   if obj == nil then
      key = "ui.more"
   elseif type(obj) == "table" then
      key = obj[1]
      args = obj.args
   else
      key = obj
   end

   return resolve_translated_text(key, args)
end

local function speaker_name(chara)
   -- >>>>>>>> shade2/chat.hsp:3206 	if cnAka(tc)="":s=cnName(tc)+" ":else:s=lang(cnAk ..
   local name = chara:calc("name")
   local title = chara:calc("title") or ""
   if title == "" then
      name = name .. " "
   else
      name = I18N.get("talk.window.of", name, title) .. " "
   end

   name = name .. I18N.capitalize(I18N.get("ui.sex3." .. chara:calc("gender")))

   if title ~= "" then
      name = name .. " " .. I18N.get("talk.window.fame", chara:calc("fame"))
   end

   if chara:find_role("elona.shopkeeper") then
      name = name .. " " .. I18N.get("talk.window.shop_rank", chara:calc("shop_rank"))
   end

   if Chara.player():calc("can_detect_religion") then
      local god = chara:calc("god") or "elona.eyth"
      name = name .. (" (%s)"):format(I18N.get("god." .. god .. ".name"))
   end

   if config.base.development_mode then
      name = name .. " imp:" .. tostring(chara:calc("impression"))
   end

   return name
   -- <<<<<<<< shade2/chat.hsp:3212 	if sceneMode:s=actor(0,rc) ..
end

--- Opens a single talk window choice.
-- @tparam table talk Dialog control data.
-- @tparam string text String to display (not locale key)
-- @tparam table choices List of choices in format {"response_id", "core.locale.key"}
-- @tparam[opt] int default_choice index of default choice if window is canceled
-- @treturn string Response ID of the choice selected.
local function query(talk, text, choices, default_choice)
   if #choices == 1 then
      default_choice = 1
   end

   local the_choices = {}
   for i, choice in ipairs(choices) do
      local rest = {}
      for i = 3, #choice do
         rest[i-2] = choice[i]
      end
      the_choices[i] =  resolve_response(choice[2], rest)
      if default_choice == nil and choice[1] == "__END__" then
         default_choice = i
      end

      -- Turn each node ID into a fully qualified one.
      if not string.match(choice[1], ":") and choice[1] ~= "__END__" then
         choice[1] = talk.dialog._id .. ":" .. choice[1]
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

   Gui.refresh_hud()

   -- >>>>>>>> shade2/chat.hsp:60 	chatVal(1)=false,true ..
   local impression, interest
   if talk.speaker:calc("quality") < Enum.Quality.Unique then
      impression = talk.speaker.impression
      interest = talk.speaker.interest
   end
   -- <<<<<<<< shade2/chat.hsp:61 	if cQuality(tc)=fixUnique:chatVal(1)=cId(tc),fals ..

   local menu = DialogMenu:new(text,
                               the_choices,
                               speaker_name(talk.speaker),
                               talk.speaker:calc("portrait"),
                               talk.speaker:calc("image"),
                               talk.speaker:calc("color"),
                               default_choice,
                               true,
                               impression,
                               interest)

   local result, canceled = menu:query()

   if Env.is_headless() and Log.has_level("info") then
      local mes = ("<dialog> %%{yellow}>> %s %%{blue}(%s)%%{reset}")
         :format(choices[result][2],
                 choices[result][1])
      print(ansicolors(mes))
   end

   return choices[result][1], choices[result].params or {}
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
      return nil, nil, nil
   end

   local dialog_data = data["elona_sys.dialog"][dialog_id]
   if dialog_data == nil then
      return nil, nil, nil
   end

   local node_data = dialog_data.nodes[node_id]
   if node_data == nil then
      return nil, nil, nil
   end

   local full_id = ("%s:%s"):format(dialog_id, node_id)

   return dialog_data, node_data, full_id
end

local function get_choices(node, talk, state, node_data, choice_key, found)
   found = found or {}
   local choices = node.choices
   if choices == nil then
      choices = {{"__END__", choice_key}}
   elseif type(choices) == "function" then
      local ok
      ok, choices = xpcall(choices, debug.traceback, talk, state, node_data.params)
      if not ok then
         dialog_error(talk, "Error running choices function", choices)
      end
   elseif type(choices) ~= "table" then
      error("Unknown choices property: " .. tostring(choices))
   end

   return choices, node
end

-- Fully qualify the node's ID if it omits the dialog ID.
local function fully_qualify_node_id(node_id, talk)
   if not string.match(node_id, ":") and node_id ~= "__END__" then
      node_id = talk.dialog._id .. ":" .. node_id
   end
   return node_id
end

local function step_dialog(node_data, talk, state, prev_node_id)
   node_data.node_id = fully_qualify_node_id(node_data.node_id, talk)
   node_data = Event.trigger("elona_sys.on_step_dialog", {talk=talk,state=state,prev_node_id=prev_node_id}, node_data)
   local prev = node_data.node_id

   if node_data.node_id == "__END__" then
      return nil
   end
   if node_data.node_id == nil then
      return nil
   end

   local node = talk.dialog.nodes[node_data.node_id]
   if node == nil then
      -- try to jump to another dialog, like "mod.dialog_id:node_name"
      local new_dialog, new_node = find_dialog(talk.dialog, node_data.node_id)

      if new_dialog and new_node then
         talk.dialog = new_dialog
         node = new_node
      else
         dialog_error(talk, "No node with ID " .. node_data.node_id .. " found")
      end
   end

   local next_node = nil

   if type(node) == "function" then
      -- Run function. It is expected to return either a string or
      -- table containing the next node to jump to.
      local ok, result = xpcall(node, debug.traceback, talk, state, node_data.params)
      if ok then
         if type(result) == "string" then
            next_node = {node_id = result, params = {}}
         elseif type(result) == "table" then
            assert(result.node_id, "Dialog function must return a table like {node_id='elona.default:talk', params={...}}")

            if result.params then
               assert(type(result.params) == "table")
            end
            next_node = { node_id = result.node_id, params = result.params }
         else
            next_node = {node_id = "__END__", params = {}}
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
      -- on_start: Function run when this node is entered.
      -- on_finish: Function run when this node is exited.
      -- default_choice: If provided, dialog option is cancellable with this response as the default.
      -- jump_to (string[opt]): node to jump to after printing all text.

      -- `prev_text` supports setting custom text while inheriting the
      -- choices/callbacks of a different node. See chat2.hsp:*chat_default
      -- which checks if the chat buffer wasn't previously set. (buff="")
      local texts = node_data.prev_text or node.text

      -- Run on_start callback.
      if node.on_start then
         local ok, result = pcall(node.on_start, talk, state, node_data.params)
         if not ok then
            dialog_error(talk, "Error running on_start function", result)
         end
      end

      if type(texts) == "string" then
         texts = { texts }
      elseif type(texts) == "function" then
         local ok
         ok, texts = xpcall(texts, debug.traceback, talk, state, node_data.params)
         if not ok then
            dialog_error(talk, "Error getting dialog text", texts)
         end

         if type(texts) == "string" then
            texts = { texts }
         end

         if type(texts) ~= "table" then
            dialog_error(talk, "`text` function must return a string or a table of strings")
         end
      end

      if node.jump_to then
         local dialog, jumped_node, jumped_node_id = find_dialog(talk.dialog, node.jump_to)
         if dialog and jumped_node then
            next_node = { node_id = jumped_node_id, params = {}, prev_text = texts }
            return next_node, prev
         else
            error(("cannot find node with ID %s"):format(node.inherit))
         end
      end

      for i, text in ipairs(texts) do
         local proceed = true
         if type(text) == "function" then
            -- Call an arbitrary function.
            local ok, err = xpcall(text, debug.traceback, talk, state, node_data.params)
            if not ok then
               dialog_error(talk, "Error running text function", err)
            end
            text = err
            if text == nil and texts[i+1] ~= nil then
               proceed = false
            end
         end

         if proceed then
            if type(text) == "string" then
               text = {text}
            end

            if type(text) == "table" then
               -- Obtain arguments to I18N.get().
               -- Assume the speaker is the first argument unless otherwise noted.
               local args = {talk.speaker}
               if text.args then
                  local ok
                  ok, args = pcall(text.args, talk, state, node_data.params)
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
                     choice_key = "ui.bye"
                  else
                     choice_key = "ui.more"
                  end
               end

               -- Build choices. Default to ending the dialog.
               local choices
               choices, node = get_choices(node, talk, state, node_data, choice_key)

               -- Set the default choice to select if window is
               -- cancelled. If nil, prevent cancellation.
               local default_choice = nil
               if node.default_choice ~= nil then
                  local full_id = node.default_choice
                  if not full_id:find(":") then
                     full_id = talk.id .. ":" .. full_id
                  end
                  for j, choice in ipairs(choices) do
                     local choice_id = choice[1]
                     if not choice_id:find(":") then
                        choice_id = talk.id .. ":" .. choice_id
                     end
                     if choice_id == full_id then
                        default_choice = j
                     end
                  end
                  if default_choice == nil then
                     dialog_error(talk, "Could not find default choice \"" .. full_id .. "\"")
                  end
               end

               -- Resolve localized text.
               local tex = resolve_translated_text(text[1], args)

               -- Prompt for choice if on the last text entry or
               -- `next_node` is non-nil, otherwise show single choice.
               if texts[i+1] == nil then
                  local node_id, params = query(talk, tex, choices, default_choice)
                  next_node = {node_id = node_id, params = params}
               else
                  query(talk, tex, {{"dummy", choice_key}})
               end
            else
               dialog_error(talk, "Cannot parse text entry, must be string, function or table (got: " .. type(text) .. ")")
            end
         end
      end

      -- Run on_finish callback.
      if node.on_finish then
         local ok, result = xpcall(node.on_finish, debug.traceback, talk, state, node_data.params)
         if not ok then
            dialog_error(talk, "Error running on_finish function", result)
         end
      end
   else
      dialog_error(talk, "Invalid node, must be string or table (got: " .. type(node) .. ")")
   end

   next_node.node_id = fully_qualify_node_id(next_node.node_id, talk)

   return next_node, prev
end

function Dialog.start(chara, dialog_id)
   if not Chara.is_alive(chara) then
      return
   end

   dialog_id = dialog_id or chara:calc("dialog") or "elona.default"

   local result = chara:emit("elona_sys.on_chara_dialog_start", { dialog_id = dialog_id }, { blocked = false })
   if result.blocked then
      return
   end

   local start_node
   local colon_pos = string.find(dialog_id, ":")
   if colon_pos then
      start_node = dialog_id
      dialog_id = dialog_id:sub(1, colon_pos-1)
   else
      start_node = dialog_id .. ":__start"
   end

   local dialog = data["elona_sys.dialog"]:ensure(dialog_id)

   local talk = make_talk(chara, dialog, dialog_id)
   local state = {}
   local next_node = {node_id = start_node, params = {}}
   local prev_node_id

   Gui.play_sound("base.chat")

   while next_node ~= nil do
      next_node, prev_node_id = step_dialog(next_node, talk, state, prev_node_id)
   end
end

--- Adds a dialog choice to a list of possible choices if it doesn't
--- already exist in the list.
---
--- @tparam string choice_id
--- @tparam string choice_text
--- @tparam {{string,string}...} choices
--- @tparam[opt] table params
--- @tparam[opt] bool also_text If true, also match by the localized choice text
function Dialog.add_choice(choice_id, choice_text, choices, params, also_text)
   for _, exist in ipairs(choices) do
      if exist[1] == choice_id -- choice ID
         and (also_text and exist[2] == choice_id) -- localized text
      then
         return
      end
   end

   table.insert(choices, {choice_id, choice_text, params = params})
end

return Dialog
