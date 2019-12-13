return {
   -- List of files, each containing an "items" field with the
   -- documented items (functions, classes) the file contains.
   entries = {},

   -- A map of [any => {{entry_key=string,full_path=string}}].
   --
   -- Allows multiple strings/objects to resolve to the same
   -- documentation. Each alias can point to multiple files, and each
   -- file can have multiple aliases.
   --
   -- Examples:
   --   - "Chara"            => {api.Chara, mod.elona.api.Chara}
   --   - "Chara.create"     => {api.Chara}
   --   - "api.Chara.create" => {api.Chara}
   aliases = {},

   -- Defer loading until initial startup has finished, to prevent
   -- errors.
   can_load = false
}
